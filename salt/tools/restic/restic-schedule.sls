include:
  - tools.restic.restic_bin

{# Validate required pillar values - fail fast if missing #}
{% if not salt['pillar.get']('restic:google_project_id') %}
{{ salt['test.exception']('restic:google_project_id pillar value is required') }}
{% endif %}
{% if not salt['pillar.get']('restic:gcp_service_account_json') %}
{{ salt['test.exception']('restic:gcp_service_account_json pillar value is required') }}
{% endif %}
{% if not salt['pillar.get']('restic:password') %}
{{ salt['test.exception']('restic:password pillar value is required') }}
{% endif %}
{% if not salt['pillar.get']('restic:gcs_bucket') %}
{{ salt['test.exception']('restic:gcs_bucket pillar value is required') }}
{% endif %}

{% set restic_config_dir = "/etc/restic" %}
{% set restic_repos_file = restic_config_dir + "/restic-repos" %}
{% set restic_gcp_creds_file = restic_config_dir + "/gcp-service-account.json" %}
{% set restic_backup_script = restic_config_dir + "/restic-backup.sh" %}
{% set restic_bucket = "gs:" + salt['pillar.get']('restic:gcs_bucket') + ":" %}

# Create config directory
{{ restic_config_dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 700 # locked down

# Write GCP service account JSON from pillar
{{ restic_gcp_creds_file }}:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: restic:gcp_service_account_json
    - require:
      - file: {{ restic_config_dir }}

# Create empty repos file (won't overwrite existing file)
{{ restic_repos_file }}:
  file.managed:
    - user: root
    - group: root
    - mode: 700
    - replace: False
    - contents: |
        # Add restic repository paths here, one per line
        # Example: /path/to/restic/repo
    - require:
      - file: {{ restic_config_dir }}

# Deploy backup script using Jinja2 template with context
{{ restic_backup_script }}:
  file.managed:
    - source: salt://tools/restic/restic-backup.sh.jinja
    - user: root
    - group: root
    - mode: 700
    - template: jinja
    - context:
        restic_repos_file: {{ restic_repos_file }}
        restic_bucket: {{ restic_bucket }}
        google_project_id: {{ salt['pillar.get']('restic:google_project_id', '') }}
        google_application_credentials: {{ restic_gcp_creds_file }}
        restic_password: {{ salt['pillar.get']('restic:password', '') }}
    - require:
      - file: {{ restic_repos_file }}
      - file: {{ restic_gcp_creds_file }}
      - cmd: restic-install

/etc/systemd/system/restic-backup.service:
  file.managed:
    - source: salt://tools/restic/restic-backup.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        restic_backup_script: {{ restic_backup_script }}
        restic_config_dir: {{ restic_config_dir }}
    - require:
      - file: {{ restic_backup_script }}

/etc/systemd/system/restic-backup.timer:
  file.managed:
    - source: salt://tools/restic/restic-backup.timer
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /etc/systemd/system/restic-backup.service

systemd-restic-backup-reload:
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/restic-backup.service
      - file: /etc/systemd/system/restic-backup.timer

restic-backup-timer:
  service.running:
    - name: restic-backup.timer
    - enable: True
    - watch:
      - file: /etc/systemd/system/restic-backup.timer
      - file: /etc/systemd/system/restic-backup.service
    - require:
      - module: systemd-restic-backup-reload