{% set root = "/etc/ai-sd" %}

{% from "maps/nebula.jinja" import nebula_hosts, nebula_certpack_password with context %}
{% from "maps/ai-stack.jinja" import base_cuda_image with context %}

{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{{ root }}/Dockerfile.stablediffusion:
  file.managed:
    - source: salt://tools/ai/stable-diffusion/Dockerfile.stablediffusion
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      base_cuda_image: {{ base_cuda_image }}

{{ root }}/docker-compose.yml:
    file.managed:
    - source: salt://tools/ai/stable-diffusion/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      nebula_ip: {{ nebula_info['ip'].split('/')[0] }}
    - require:
      - file: {{ root }}/Dockerfile.stablediffusion