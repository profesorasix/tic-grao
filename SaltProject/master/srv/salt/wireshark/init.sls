install_wireshark:
  pkg.installed:
    - name: wireshark

/scripts/wireshark-config.sh:
  file.managed:    
    - contents: | 
        #!/bin/bash
        #Activate cache credentials

        sudo bash -c "echo '%students ALL=(ALL) NOPASSWD: /usr/bin/wireshark' >> /etc/sudoers.d/wireshark"
        sudo bash -c "echo '%ALU_FP_A3 ALL=(ALL) NOPASSWD: /usr/bin/wireshark' >> /etc/sudoers.d/wireshark"
    
    - user: root
    - group: root
    - mode: '0644'    
    - makedirs: True

exec_wireshark_config_file:
  cmd.wait:
    - name: bash /scripts/wireshark-config.sh
    - watch: 
      - file: /scripts/wireshark-config.sh