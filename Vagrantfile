Vagrant.configure("2") do |config|
  
  config.vm.provision "shell", path: "provision.sh"
  
  config.vm.define "centos7-minikube" do |centos7_minikube|
	centos7_minikube.vm.box = "centos/7"
	centos7_minikube.vm.box_version = "1905.1"
    centos7_minikube.vm.hostname = "centos7-minikube"
    
	centos7_minikube.vm.network "private_network", ip: "192.168.100.100"
	
	# 포트포워딩 설명(guest : vagrant에서 실행되는 vm, host : vagrant가 실행되는 PC)
	# centos7_minikube.vm.network "forwarded_port", guest: 8080, host: 80
	
    centos7_minikube.vm.provider "virtualbox" do |vb|
       vb.name = "centos7-minikube"
       vb.memory = 4096
  	   vb.cpus = 2
    end
	
	# Windoqws Host Machine 일 경우 Host Machine 과의 파일 공유를 위해 사전에 vagrant-vbguest 플러그인을 설치해야 한다
	# 관련 링크는 https://github.com/dotless-de/vagrant-vbguest
	
	centos7_minikube.vm.synced_folder ".", "/home/vagrant/sync", disabled: true
	centos7_minikube.vm.synced_folder "../../share_folder/centos_minikube", "/vagrant_hosts", create: true
	
	# swap 메모리 disable
	centos7_minikube.vm.provision :shell, privileged: false, inline: "sudo swapoff -a"
	
	# VM에 설치할 프로그램들을 설치해주고 초기 설정을 해주는 shell script 파일 실행
	centos7_minikube.vm.provision :shell, privileged: false, path: "install.sh"
  end
  
end
