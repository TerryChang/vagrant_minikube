echo "yum updating........."
sudo yum update -y

# kubernetes 에서 사용되는 docker는 2020년 2월 6일 시점으로 19.03.4 버전까지 지원한다(이 당시의 docker 최신 버전은 19.03.5 이다)
echo "Docker Installing........."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce-19.03.4 docker-ce-cli-19.03.4 containerd.io-1.2.10

## Create /etc/docker directory.
sudo mkdir /etc/docker

# Setup daemon.
sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
sudo systemctl enable docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

#echo "Allow Connect Docker From Client.........."
#sudo sed -i 's|dockerd -H fd://|dockerd -H tcp://0\.0\.0\.0:2375|g' /usr/lib/systemd/system/docker.service
#sudo systemctl daemon-reload
#sudo systemctl restart docker

#echo "Add DOCKER_HOST Environment Variable(Connect to Docker).........."
#sudo sh -c "echo export DOCKER_HOST=tcp://0.0.0.0:2375 >> /etc/profile"

echo "Execute Docker Command without sudo"
sudo usermod -aG docker $USER

echo "Docker Compose Installing........."
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Intall ntp and timezone config...."
sudo yum install -y ntp
sudo sed -i 's/centos\.pool\.ntp\.org iburst/asia\.pool\.ntp\.org/g' /etc/ntp.conf
sudo timedatectl set-timezone Asia/Seoul
sudo systemctl enable ntpd
sudo systemctl start ntpd

echo "Intall net-tools...."
sudo yum install -y net-tools

echo "Intall socat...."
sudo yum install -y socat

echo "Install kubelet & kubectl & kubeadm..."
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'
sudo yum install -y kubelet kubectl kubeadm --disableexcludes=kubernetes
sudo systemctl enable kubelet.service

echo "Install minikube latest(v1.7.2)..."
sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube
sudo mv minikube /usr/bin

# minikube를 기동하게 되면 
# error creating file at /usr/share/ca-certificates/minikubeCA.pem: open /usr/share/ca-certificates/minikubeCA.pem: no such file or directory
# 가 나와서 /usr/share/ca-certificates 디렉토리를 생성해준다
sudo mkdir -p /usr/share/ca-certificates

# minikube를 기동하게 되면 
# /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
# 에러 메시지가 나와서 /proc/sys/net/bridge/bridge-nf-call-iptables 파일을 만든뒤 그 안에 1을 기록해준다
echo -e "\nnet.bridge.bridge-nf-call-ip6tables = 1" | sudo tee --append /etc/sysctl.conf > /dev/null
echo -e "net.bridge.bridge-nf-call-iptables = 1" | sudo tee --append /etc/sysctl.conf > /dev/null
sudo sysctl -p

# sudo minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost --kubernetes-version v1.17.2
sudo minikube start --vm-driver=none

# vagrant 계정에 로그인 된 상태에서도 kubectl 명령어를 이용할 수 있게끔 하기 위해 다음의 작업을 진행한다
sudo mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config