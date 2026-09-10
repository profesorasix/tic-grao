base:
  '*':
    - common
    - test-pillar

  '192.168.14.0/24':
    - match: ipcidr
    - aula14
