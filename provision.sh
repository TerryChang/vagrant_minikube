# root password set
echo -e "root\nroot" | passwd
# root login allow
sed  -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed  -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;

# disable swap memory(sudo swapoff -a)
sed -i 's/\/swapfile none swap defaults 0 0/# \/swapfile none swap defaults 0 0/g' /etc/fstab;