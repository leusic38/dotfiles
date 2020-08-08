#mount 1&1 server
#!/bin/zsh

sshfs manuf@93.90.203.192:/home/manuf /server1and1 -o IdentityFile=/home/manu/.ssh/id_rsa_1and1,idmap=user
