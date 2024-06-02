###############################
###  https://devandops.kz/  ###
###############################

find ~/source_OL_deploy_CRI-O_CONTAINERD_K8S/*.sh -type f -exec chmod 744 {} \;


### ##############################################################
(01)
Для ВМ OL9-MASTER-151

export VERSION=1.29
export KVERSION=1.29.4
export BALANCER='192.168.1.150:8443'
export PODNETWORKCIDR=172.17.0.0/16
export SERVICECIDR=10.10.0.0/16

### запуск скриптов
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/00_preinstall.sh
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/01_02_cri-o_k8s_install.sh
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/02_MASTER_on_first_only.sh
cat ~/kubeadm_init.log
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/03_config_and_install_utilities.sh


### ##############################################################
(02)
Для ВМ OL9-MASTER-152

export OSCD=centos
export OSCDVERSION=9
export VERSION=1.29
export KVERSION=1.29.4

### запуск скриптов
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/00_preinstall.sh
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/01_02_containerd_k8s_install.sh

### Далее необходимо запустить команду "kubeadm join ..." для создания и присоединения control-plane ВМ OL9-MASTER-152 к кластеру kubernetes.
### ### команду "kubeadm join ..." берём с ВМ OL9-MASTER-151
### ### cat ~/kubeadm_init.log
### ### ### sudo kubeadm join 192.168.1.150:8443 --token AAAAAA.AAAAAAAAAAAAAAAA \
### ### ###     --discovery-token-ca-cert-hash sha256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB \
### ### ###     --control-plane --certificate-key CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


~/source_OL_deploy_CRI-O_CONTAINERD_K8S/03_config_and_install_utilities.sh


### ##############################################################
(03)
Для ВМ OL9-MASTER-153

export VERSION=1.29
export KVERSION=1.29.4


### запуск скриптов
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/00_preinstall.sh
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/01_02_cri-o_k8s_install.sh

### Далее необходимо запустить команду "kubeadm join ..." для создания и присоединения control-plane ВМ OL9-MASTER-152 к кластеру kubernetes.
### ### команду "kubeadm join ..." берём с ВМ OL9-MASTER-151
### ### cat ~/kubeadm_init.log
### ### ### sudo kubeadm join 192.168.1.150:8443 --token AAAAAA.AAAAAAAAAAAAAAAA \
### ### ###     --discovery-token-ca-cert-hash sha256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB \
### ### ###     --control-plane --certificate-key CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


~/source_OL_deploy_CRI-O_CONTAINERD_K8S/03_config_and_install_utilities.sh


### ##############################################################
(04)
Для ВМ OL9-WORKER-154

export VERSION=1.29
export KVERSION=1.29.4

### запуск скриптов
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/00_preinstall.sh
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/01_02_cri-o_k8s_install.sh

### Пример запуска команды "kubeadm join ..." для worker ноды,
### находится на ВМ OL9-MASTER-151 в файле ~/kubeadm_init.log .
### ### cat ~/kubeadm_init.log

### Запускаем "kubeadm join ..." команду
### ### ### sudo kubeadm join 192.168.1.150:8443 --token XXXXXX.XXXXXXXXXXXXXXXX \
### ### ###     --discovery-token-ca-cert-hash sha256:YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY


### ##############################################################
(05)
Для ВМ OL9-WORKER-155

export OSCD=centos
export OSCDVERSION=9
export VERSION=1.29
export KVERSION=1.29.4

### запуск скриптов
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/00_preinstall.sh
~/source_OL_deploy_CRI-O_CONTAINERD_K8S/01_02_containerd_k8s_install.sh

### Пример запуска команды "kubeadm join ..." для worker ноды,
### находится на ВМ OL9-MASTER-151 в файле ~/kubeadm_init.log .
### ### cat ~/kubeadm_init.log

### Запускаем "kubeadm join ..." команду
### ### ### sudo kubeadm join 192.168.1.150:8443 --token XXXXXX.XXXXXXXXXXXXXXXX \
### ### ###     --discovery-token-ca-cert-hash sha256:YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY


### ##############################################################