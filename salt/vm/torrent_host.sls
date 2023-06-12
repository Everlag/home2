{% set host = grains["host"] %}

{% set vm_name = "torrents" %}
{% from "maps/vms.jinja" import vms, vm_base_template with context %}

{# ensure the current hostname is a node for all following states #}
vm_ensure_node:
  cmd.run:
    - name: pvesh get /nodes --output-format=json | jq -r '. | first.node' | grep -q {{ host }} 
    - stateful: True

{{ vm_name }}_vm_create:
  cmd.run:
    - name: pvesh create /nodes/{{ host }}/qemu/{{ vms[vm_base_template] }}/clone -newid 1290 -name {{ vm_name }} -full false -name {{ vm_name }}
    - unless: pvesh get /nodes/{{ host }}/qemu/{{ vms[vm_name] }}/config --output-format=json | jq -r '.name' | grep -q {{ vm_name }}  # don't try to do this twice
    - require:
      - cmd: vm_ensure_node

{{ vm_name }}_vm_start:
  cmd.run:
    - name: pvesh create /nodes/{{ host }}/qemu/{{ vms[vm_name] }}/status/start
    - onchanges:
      - cmd: {{ vm_name }}_vm_create