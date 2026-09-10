/scripts:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644  
    - recurse:
      - user
      - group
      - mode


/scripts/iesgrao-config-sssd.sh:
  file.managed:    
    - contents: | 
        #!/bin/bash
        #Activate cache credentials

        sudo sed -i -e '/^\[domain\/EDU.GVA.ES\]$/a cache_credentials = true' /etc/sssd/sssd.conf 
        sudo sed -i -e'/^\[domain\/ALU.EDU.GVA.ES\]$/a cache_credentials = true' /etc/sssd/sssd.conf
    
    - user: root
    - group: root
    - mode: '0644'    
    - makedirs: True

exec_sssd_config_cache_file:
  cmd.wait:
    - name: bash /scripts/iesgrao-config-sssd.sh
    - watch: 
      - file: /scripts/iesgrao-config-sssd.sh
    