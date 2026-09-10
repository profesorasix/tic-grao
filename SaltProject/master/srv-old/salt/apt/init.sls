install_traceroute:
  pkg.installed:
    - name: traceroute

install_github_cli:
  pkgrepo.managed:    
    - humanname: github-cli
    - name: deb [arch=amd64 signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main
    - file: /etc/apt/sources.list.d/github-cli.list
    - require_in:
      - pkg: gh
    - gpgcheck: 1  
    - aptkey: False  
    - key_url: https://cli.github.com/packages/githubcli-archive-keyring.gpg

  pkg.installed:
    - name: gh

install_vagrant:
  pkgrepo.managed:
    - humanname: vagrant-hashicorp
    - name: deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main
    - key_url: https://apt.releases.hashicorp.com/gpg
    - file: /etc/apt/sources.list.d/hashicorp.list
    - aptkey: False
    - require_in:
      - pkg: vagrant
    - gpgcheck: 1
    
  pkg.installed:
    - name: vagrant

install_google_chrome_stable:
  pkgrepo.managed:
    - humanname: google-chrome-stable
    - name: deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main
    - dist: stable
    - file: /etc/apt/sources.list.d/google-chrome.list
    - require_in:
      - pkg: google-chrome-stable
    - gpgcheck: 1
    - aptkey: False
    - key_url: https://dl-ssl.google.com/linux/linux_signing_key.pub

  pkg.installed:
    - name: google-chrome-stable
  
  

  


