opentofu_key:
  file.managed: 
    - name: /usr/share/keyrings/opentofu.gpp
    - source: https://get.opentofu.org/opentofu.gpg
    - skip_verify: True

{% set os_release = grains['lsb_distrib_codename'] %}
{% set os_distro = grains['lsb_distrib_id'] %}

{% set repos = {
  'incus' : {
    'deb': 'deb [signed-by=/usr/share/keyrings/key.gpg arch=amd64] https://pkgs.zabbly.com/incus/stable ' ~ os_release ~ ' main',
    'key': 'https://pkgs.zabbly.com/key.asc'},
  'github-cli': {
    'deb': 'deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg arch=amd64] https://cli.github.com/packages/ stable main',
    'key': 'https://cli.github.com/packages/githubcli-archive-keyring.gpg'},
  'opentofu': {
    'deb': 'deb [signed-by=/usr/share/keyrings/opentofu.gpg arch=amd64] https://packages.opentofu.org/opentofu/tofu/any any main',
    'key': 'https://packages.opentofu.org/opentofu/tofu/gpgkey'},
  'google-chrome': {
    'deb': 'deb [signed-by=/usr/share/keyrings/google-chrome.gpg arch=amd64] https://dl.google.com/linux/chrome-stable/deb stable main',
    'key': 'https://dl.google.com/linux/linux_signing_key.pub'},
  'vbox': {
    'deb': 'deb [signed-by=/usr/share/keyrings/oracle_virtualbox-2016.gpg arch=amd64] https://download.virtualbox.org/virtualbox/debian ' ~ os_release ~ ' contrib',
    'key': 'https://www.virtualbox.org/download/oracle_vbox_2016.asc'},
  'sublime-text': {
    'deb': 'deb [signed-by=/usr/share/keyrings/sublimehq-pub.gpg archch=amd64] https://download.sublimetext.com/ apt/stable/',
    'key': 'https://download.sublimetext.com/sublimehq-pub.gpg'},
  'task-task': {
    'deb': 'deb [signed-by=/usr/share/keyrings/taskdev archch=amd64] https://dl.cloudsmith.io/public/task/task/deb/'~ os_distro ~'/ ' ~ os_release ~ ' main',
    'key': 'https://dl.cloudsmith.io/public/task/task/gpg.046FD1186CA342F0.key'},
  'vagrant': {
    'deb': 'deb [signed-by=/usr/share/keyrings/hashicorp.gpg archch=amd64] https://apt.releases.hashicorp.com/ ' ~ os_release ~ ' main',
    'key': 'https://apt.releases.hashicorp.com/gpg'},
  'code': {
    'deb': 'deb [signed-by=/usr/share/keyrings/microsoft.gpg archch=amd64] https://packages.microsoft.com/repos/code stable main',
    'key': 'https://packages.microsoft.com/keys/microsoft.asc'}
}
%}

{% for repo in repos %}
add_repo_{{ repo }}:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/{{ repo }}.sources
    - key_url: {{ repos[repo]['key'] }}
    - name: {{ repos[repo]['deb'] }}
    - aptkey: False
    - clean_file: True
{% endfor %}

gns3-ppa:
  pkgrepo.managed:
    - ppa: gns3/ppa


utils:
  pkg.latest:
    - refresh: True
    - pkgs:
      - tree
      - wget
      - tmux
    #  - byobu
      - python3-debian
      - software-properties-common
      - gpg
      - fping    
      - xsel
    #  - ldap-utils
    #  - ldapscripts
    #  - nmap
    #  - just
    #  - apt-transport-https
    #  - ca-certificates
    #  - curl
    #  - virt-viewer
    #  - p11-kit
    #  - wireshark
      - sublime-text

alumno:
  user.present:
    - fullname: Alumno 
    - hash_password: False
    - password: $5$rzb0ru1hXTfIHuA7$VSqCzICXnSi3nVHQs5sDHwCRLs.46utvfXSyGfDszm4
    #- password: alumno


profesor:
  user.present:
    - fullname: Profesor
    - hash_password: False
    #- password: profesor
    - password: $5$8tMKXbsqHp61AQSm$.tDaGlERI4ZEVxqZida/rVQUE6EiZOKWgsW1fxnmkXD
