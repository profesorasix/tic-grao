#!/bin/bash

sudo bash -c "echo '%students ALL=(ALL) NOPASSWD: /usr/bin/wireshark' >> /etc/sudoers.d/wireshark"
sudo bash -c "echo '%ALU_FP_A3 ALL=(ALL) NOPASSWD: /usr/bin/wireshark' >> /etc/sudoers.d/wireshark"
