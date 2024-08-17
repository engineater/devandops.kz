#!/bin/bash
######  содержимое файла 01_02_cri-o_k8s_install.sh

### очищаем экран от предыдущих записей
clear


###############################
echo '>>>> Очистка от старых Linux kernel'
sudo dnf -y remove --oldinstallonly --setopt installonly_limit=2 kernel


############################
### https://kubernetes.io/docs/setup/production-environment/container-runtimes/
echo '>>>> Переадресация IPv4 и разрешаение iptables видеть bridged traffic'
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
echo '>>>> Применяем системные параметры без перезагрузки'
sudo sysctl --system
echo '>>>> Проверяем были ли активированы модули br_netfilter и overlay'
lsmod | grep br_netfilter
lsmod | grep overlay
echo '>>>> Проверяем присвоено ли значение 1 для следующих параметров net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables и net.ipv4.ip_forward'
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward


############################
echo '>>>> Устанавливаем CRI-O'

### релизы версий cri-o можно посмотреть на https://github.com/cri-o/cri-o/releases
### мажорные и минорные значения версии cri-o должны соответствовать с мажорной и минорной значениям версии kubernetes 
###### например если вы хотите установить 
######      kubernetes 1.29.4 , то должны установить cri-o 1.29.* 
######      kubernetes 1.28.7 , то должны установить cri-o 1.28.* 
### переменной VERSION присваиваем значение версии устанавливаемых пакетов cri-tools и cri-o
### ### VERSION=1.29
### ### PROJECT_PATH=prerelease:/main
PROJECT_PATH=stable:/v${VERSION}


cat <<EOF | sudo tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/rpm/repodata/repomd.xml.key
EOF

sleep 2
sudo dnf clean all
sudo dnf clean packages
sudo dnf repolist

### Установите зависимости пакета из официальных репозиториев.
sudo dnf install container-selinux -y 


echo '>>>> Запускаем установку cri-o'
### Выводим список доступных версий
### ### sudo dnf list --showduplicates cri-o
sudo dnf install cri-o -y
sleep 2
echo '>>>> Отключаем репозитарий CRI-O'
### следующая команда нужна, чтобы при запуске обновления Linux "sudo dnf -y upgrade",
### пакеты cri-o автоматически не обновились
sudo dnf config-manager cri-o --disable
sleep 2

echo '>>>> Добавляем в файл /etc/containers/registries.conf mirrors на Sonatype Nexus Repository'
cat <<EOF | sudo tee /etc/containers/registries.conf
[[registry]]
  prefix="docker.io"
  location = "nexus.my.private:18131"
  blocked = false
  insecure = true

[[registry]]
  prefix="quay.io"
  location = "nexus.my.private:18132"
  blocked = false
  insecure = true

[[registry]]
  prefix="gcr.io"
  location = "nexus.my.private:18133"
  blocked = false
  insecure = true

[[registry]]
  prefix="k8s.gcr.io"
  location = "nexus.my.private:18134"
  blocked = false
  insecure = true

[[registry]]
  prefix="registry.k8s.io"
  location = "nexus.my.private:18135"
  blocked = false
  insecure = true

[[registry]]
  prefix="ghcr.io"
  location = "nexus.my.private:18136"
  blocked = false
  insecure = true

[[registry]]
  prefix="registry.gitlab.com"
  location = "nexus.my.private:18137"
  blocked = false
  insecure = true

EOF


echo '>>>> Запускаем cri-o'
sudo systemctl daemon-reload
sudo systemctl enable --now crio


echo '>>>> Устанавливаем kubernetes'
# /usr/libexec/platform-python -c 'import dnf, json; db = dnf.dnf.Base(); print(json.dumps(db.conf.substitutions, indent=2))'
### создаём конфигурационный файл репозитария kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v${VERSION}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v${VERSION}/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF



# Значение данной переменной (версия k8s) должна быть такой же как и в файлах 
### 01_02_containerd_k8s_install.sh
### 02_MASTER_on_first_only.sh
### ### KVERSION=1.29.4
### следующая команда установит kubeadm, kubectl, kubelet, а так же при необходимости установит или обновит cri-tools
sudo dnf install -y kubelet-$KVERSION kubeadm-$KVERSION --disableexcludes=kubernetes
### downgrad'им kubectl, если это необходимо
sudo dnf install -y kubectl-$KVERSION --disableexcludes=kubernetes
sudo systemctl enable --now kubelet


echo '>>>> С помощью crictl выводим версию container runtime'
sudo crictl version
