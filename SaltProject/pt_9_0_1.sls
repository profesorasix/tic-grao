#mkdir -p  /srv/salt/files
#wget https://www.dropbox.com/scl/fo/anjgvdc6f8p99k2kns27k/AC7LoYQd4UeZ8gzAL4M5a40?rlkey=7ctlxw6rer7jfk7cfnn0lihyp&st=ufkdaqaw&raw=1 -O /srv/salt/files/CiscoPacketTracer_901_Ubuntu_64bit.deb


packet_tracer_9_0_1:
  pkg.installed:
    - sources:
      - pt_9_0_1: salt://files/CiscoPacketTracer_901_Ubuntu_64bit.deb
