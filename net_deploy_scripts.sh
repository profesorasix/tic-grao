#!/bin/bash

mkdir /scripts
wget -qO - https://github.com/profesorasix/tic-grao/raw/refs/heads/main/scripts2026.tar.gz | tar -xzf - -C /scripts --strip-components=1