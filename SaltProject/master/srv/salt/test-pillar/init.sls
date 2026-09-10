{% set hwaddr = grains['hwaddr_interfaces']['eth0'] %}

pillar_test:
  file.managed:
    - name: /tmp/{{ hwaddr }}
    - contents: |
        This is line 1
        This is line 2 with pillar {{ pillar[ hwaddr ]['ipv4'] }}
        This is line 3 with pillar {{ pillar[ hwaddr ]['hostname'] }}
         

