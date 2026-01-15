sshkeys:
  ssh_auth.manage:
    - user: administrador
    - source: salt://fileserver/ssh_keys/iesgrao_rsa.pub
    - comment: administrador
    - enc : ssh-rsa
    - ssh_keys: carlossg@aulaxxxpczz