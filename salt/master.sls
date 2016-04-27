{% from "salt/map.jinja" import salt_settings with context %}

salt-master:
{% if salt_settings.install_packages %}
  pkg.installed:
    - name: {{ salt_settings.salt_master }}
{% endif %}
  file.recurse:
    - name: {{ salt_settings.config_path }}/master.d
    - template: jinja
    - source: salt://{{ slspath }}/files/master.d
    - clean: {{ salt_settings.clean_config_d_dir }}
    - exclude_pat: _*
  service.running:
    - enable: True
    - name: {{ salt_settings.master_service }}
    - watch:
{% if salt_settings.install_packages %}
      - pkg: salt-master
{% endif %}
      - file: salt-master
      - file: remove-old-master-conf-file

#Create file_roots directory structure
{% if salt_settings.master.file_roots is defined %}
{% for env, roots in salt_settings.master.file_roots.items() %}
{% for root in roots %}
Create {{ root }}:
  file.directory:
    - name {{root }}
{% endfor %}
{% endfor %}
{% endif %}

#Create pillar_roots directory structure
{% if salt_settings.master.pillar_roots is defined %}
{% for env, roots in salt_settings.master.pillar_roots.items() %}
{% for root in roots %}
Create {{ root }}:
  file.directory:
    -name {{ root }}
{% endfor %}
{% endfor %}
{% endif %}

# clean up old _defaults.conf file if they have it around
remove-old-master-conf-file:
  file.absent:
    - name: {{ salt_settings.config_path }}/master.d/_defaults.conf
