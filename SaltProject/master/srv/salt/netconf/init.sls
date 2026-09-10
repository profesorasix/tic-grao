{% set ifaces = ['eth0','eno1','enp2s0','enp5s0'] %}

{% set ns = namespace(hwaddr=null) %}

{% for iface in ifaces %}
{%   if salt['grains.has_value'](['hwaddr_interfaces',iface]) %}
{%     set ns.hwaddr = grains['hwaddr_interfaces'][iface] %}
{%   endif %}
{% endfor %}


NetworkManager_config:
  file.managed:
    - name: /tmp/{{ ns.hwaddr }}
    - contents: |
        ipv4: {{ pillar[ ns.hwaddr ]['ipv4'] }}
        netmask: {{ pillar[ ns.hwaddr ]['netmask'] }}
        hostname: {{ pillar[ ns.hwaddr ]['hostname'] }}
        gateway: {{ grains['ip4_gw'] }}
        dns: {{ grains['dns']['ip4_nameservers'][0] }}

net_run:
   cmd.run:
     - name: nmcli con add type ethernet con-name RedClase2 ifname {{ pillar[ ns.hwaddr ]['ifname'] }} ip4 {{ pillar[ns.hwaddr]['ipv4'] }} gw4 {{ grains['ip4_gw'] }} ipv4.dns {{ grains['dns']['ip4_nameservers'][0] }} ipv6.method disabled
     - onchanges:
       - file: /root/network_configured
         
net_hostname:
  cmd.run:
    - name: hostnamectl set-hostname  {{ pillar[ns.hwaddr]['hostname'] }} && hostname > /etc/salt/minion_id
    - onchanges:
      - file: /root/network_configured

salt-minion:
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - cmd: net_hostname

network_configured:
  file.managed:
    - name: /root/network_configured
    - contents: "Network succesfully configured"
    
