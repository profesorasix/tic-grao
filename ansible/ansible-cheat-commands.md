# Workflow
ssh-copy-id -i ~/.ssh/iesgrao_rsa.pub -o StrictHostKeyChecking=no administrador@10.10.82.164
cat ~/.ssh/iesgrao_rsa.pub | ssh -o StrictHostKeyChecking=no root@10.149.165.186 'cat >> ~/.ssh/authorized_keys'

(tar -czvf - ansible | incus file push - ansible/home/ubuntu/ansible.tar.gz --gid 1000 --uid 1000 && incus exec ansible -- su -l ubuntu -c 'tar -xzvf ansible.tar.gz')

# CONFIG
ssh-copy-id -i ~/.ssh/iesgrao_rsa.pub administrador@10.7.178.223
ansible-config init --disabled > ~/.ansible.cfg
	host_key_checking = False
	private_key_file=~/.ssh/iesgrao_rsa
chmod 600 ~/.ssh/iesgrao_rsa

#/etc/ssh/sshd_config
cat << EOF > /etc/ssh/sshd_config.d/ansible.conf
PermitRootLogin yes
PermitEmptyPasswords yes
EOF


# ANSIBLE
ansible aula13 -i inventory/inventory.yaml -m community.general.shutdown --ask-become-pass --become
ansible all -i <ip>, -u administrador -m ping  #ansible without specifying the inventory
ansible-playbook -i <ip>, -u administrador playbook.yml #ansible without specifying the inventory
ansible myhosts -i inventory.yaml -m ping 
ansible-playbook -i inventory.yaml incus-playbook.yaml --limit my_host_01  --u administrador --become --ask-become-pass
ansible aula13 --private-key ~/.ssh/iesgrao_rsa -i inventory.yaml -u administrador -m ping


# LOCAL
[Gist](https://gist.github.com/alces/caa3e7e5f46f9595f715f0f55eef65c1)
ansible --connection=local localhost -m ping
ansible 127.0.0.1 -m ansible.builtin.setup
ansible-playbook -i localhost, --connection=local site.yml 
ansible-playbook --connection=local 127.0.0.1 playbook.yml

# APT
ansible myhosts -i inventory.yaml -u administrador --become -m apt -a name=python3-debian --ask-become-pass 
ansible myhosts -i inventory.yaml -u administrador --become -m apt -a name=flatpak --ask-become-pass 
ansible-playbook -i inventory.yaml update-apt-packages.yaml  --u administrador --become --ask-become-pass
ansible-playbook -i inventory.yaml sublime-playbook.yaml  --u administrador --become --ask-become-pass --limit aula13
ansible-playbook -i inventory.yaml incus-playbook.yaml  --u administrador --become --ask-become-pass --limit aula13


# VAULT
ansible-vault create secret
>>ansible_sudo_pass: ****lp
echo "vault-password" > .vault.txt
ansible-playbook -i inventory.yaml incus-playbook.yaml --limit my_host_02  --u administrador --become --vault-password-file=.vault.txt


# FLATPAK

ansible myhosts -i inventory.yaml -u administrador --become --ask-become-pass -m apt -a name=flatpak
ansible myhosts -i inventory.yaml -u administrador --become --ask-become-pass -m flatpak_remote -a 'name=flathub flatpakrepo_url=https://dl.flathub.org/repo/flathub.flatpakrepo' --ask-become-pass 

ansible myhosts -i inventory.yaml -u administrador --become --ask-become-pass -m flatpak -a 'name=md.obsidian.Obsidian'
ansible myhosts  -i inventory.yaml -u administrador --become --ask-become-pass -m flatpak -a 'name=com.sublimetext.three state=absent'
ansible myhosts  -i inventory.yaml -u administrador --become --ask-become-pass -m shell -a 'flatpak update --noninteractive'  



