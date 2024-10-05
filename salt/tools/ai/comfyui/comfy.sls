{% set comfy_loc = "/etc/ai-comfyui" %}
{% set comfy_models = comfy_loc + "/models" %}
{% set comfy_input = comfy_loc + "/inputs" %}
{% set comfy_output = comfy_loc + "/output" %}

{% from "maps/nebula.jinja" import nebula_hosts, nebula_certpack_password with context %}
{% from "maps/ai-stack.jinja" import base_cuda_image with context %}

{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{% from "maps/user.jinja" import user with context %}

{{ comfy_loc }}:
  file.directory:
    - name: {{ comfy_loc }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

{{ comfy_models }}:
  file.directory:
    - name: {{ comfy_models }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

{{ comfy_input }}:
  file.directory:
    - name: {{ comfy_input }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

{{ comfy_output }}:
  file.directory:
    - name: {{ comfy_output }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

{{ comfy_loc }}/Dockerfile.comfyui:
  file.managed:
    - source: salt://tools/ai/comfyui/Dockerfile.comfyui
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      base_cuda_image: {{ base_cuda_image }}

{{ comfy_loc }}/nginx.conf:
  file.managed:
    - source: salt://tools/ai/comfyui/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      base_cuda_image: {{ base_cuda_image }}

{{ comfy_loc }}/docker-compose.yml:
    file.managed:
    - source: salt://tools/ai/comfyui/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      nebula_ip: {{ nebula_info['ip'].split('/')[0] }}
    - require:
      - file: {{ comfy_loc }}
      - file: {{ comfy_models }}
      - file: {{ comfy_output }}
      - file: {{ comfy_loc }}/Dockerfile.comfyui
      - file: {{ comfy_loc }}/nginx.conf