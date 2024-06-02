#!/bin/bash
######  содержимое файла 01_02_containerd_k8s_install.sh

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
echo '>>>> Устанавливаем CONTAINERD'

### специальных пакетов containerd для Oracle Linux не выпускают,
### но т.к. Oracle Linux бинарно совместим с RedHat Family дистрибутивами Linux, то мы можем использовать пакеты предназначены для CentOS
### ### OSCD=centos
### ### OSCDVERSION=9
sudo dnf -y install https://download.docker.com/linux/$OSCD/$OSCDVERSION/x86_64/stable/Packages/containerd.io-1.6.32-3.1.el9.x86_64.rpm
echo '>>>> Создаём каталог /etc/containerd для конфигурационных файлов containerd'
sudo mkdir -p /etc/containerd
echo '>>>> Создаём конфигурационный файл /etc/containerd/config.toml с настройками по умолчанию'
# устанавливаем настройки по умолчанию для containerd. Без этого kubeadm выдаст ошибку "[ERROR CRI]: container runtime is not running"
containerd config default | sudo tee /etc/containerd/config.toml

echo '>>>> В конфигурационном файле /etc/containerd/config.toml меняем значение параметра SystemdCgroup на true'
### Необходимо изменить на true иначе не будет доступен unix:///var/run/containerd/containerd.sock
### ### sudo vi /etc/containerd/config.toml
### ###          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
### ###             . . .
### ###            SystemdCgroup = true
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

echo '>>>> Добавляем в файл /etc/containerd/config.toml mirrors на Sonatype Nexus Repository'
sudo sed -i 's,\[plugins."io.containerd.grpc.v1.cri".registry.mirrors\],[plugins."io.containerd.grpc.v1.cri".registry.mirrors]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]\n          endpoint = ["https://nexus.my.private:18131"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]\n          endpoint = ["https://nexus.my.private:18132"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]\n          endpoint = ["https://nexus.my.private:18133"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]\n          endpoint = ["https://nexus.my.private:18134"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.k8s.io"]\n          endpoint = ["https://nexus.my.private:18135"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."ghcr.io"]\n          endpoint = ["https://nexus.my.private:18136"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.gitlab.com"]\n          endpoint = ["https://nexus.my.private:18137"]\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18131".tls]\n           insecure_skip_verify = true\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18132".tls]\n           insecure_skip_verify = true\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18133".tls]\n           insecure_skip_verify = true\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18134".tls]\n           insecure_skip_verify = true\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18135".tls]\n           insecure_skip_verify = true\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18136".tls]\n           insecure_skip_verify = true\n        [plugins."io.containerd.grpc.v1.cri".registry.configs."nexus.my.private:18137".tls]\n           insecure_skip_verify = true\n,g' /etc/containerd/config.toml


echo '>>>> Просматриваем итоговое содержимое файла /etc/containerd/config.toml'
echo '#### ###################################################################'
cat /etc/containerd/config.toml
echo '#### ###################################################################'

echo '>>>> Запускаем и добавляем сервис containerd в автозапуск'
sudo systemctl enable --now containerd


echo '>>>> Устанавливаем kubernetes (kubeadm, kubectl, kubelet, cri-tools и т.д.)'
### ### VERSION=1.29
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
# Значение данной переменной (версия k8s) должна быть такой же как и в файле 01_02_cri-o_k8s_install.sh, 02_MASTER_on_first_only.sh
### ### KVERSION=1.29.4
### следующая команда установит kubeadm, kubectl, kubelet, а так же при необходимости установит или обновит cri-tools
sudo dnf install -y kubelet-$KVERSION kubeadm-$KVERSION --disableexcludes=kubernetes
### downgrad'им kubectl, если это необходимо
sudo dnf install -y kubectl-$KVERSION --disableexcludes=kubernetes
sudo systemctl enable --now kubelet


echo '>>>> Настраиваем crictl для работы с containerd.sock'
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
EOF


echo '>>>> С помощью crictl выводим версию container runtime'
sudo crictl version

