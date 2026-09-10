/etc/apt/keyrings/sublimehq-pub.asc:
  file.managed:    
    - source: salt://fileserver/apt_repos/keys/sublimehq-pub.asc   
    - user: root
    - group: root
    - mode: '0644'        

/etc/apt/sources.list.d/sublime-text.sources:
  file.managed:    
    - source: salt://fileserver/apt_repos/sublime-text.sources   
    - user: root
    - group: root
    - mode: '0644'   

sublime-text:
  pkg.installed
