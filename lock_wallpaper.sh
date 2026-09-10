mkdir -p /etc/dconf/db/local.d/locks
mkdir -p /etc/dconf/profile
echo -e "user-db:user\nsystem-db:local" > /etc/dconf/profile/user
cat > /etc/dconf/db/local.d/00-wallpaper << EOF
[org/mate/desktop/background]
picture-filename='file:///usr/share/backgrounds/linuxmint/default_background_grao.jpg'
picture-options='zoom'
EOF

cat > /etc/dconf/db/local.d/locks/00-wallpaper << EOF
/org/mate/desktop/background/picture-filename
/org/mate/desktop/background/picture-options
EOF

dconf update