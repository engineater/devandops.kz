#!/bin/bash
######  содержимое файла 03_config_and_install_utilities.sh

clear

echo ">>>> Донастройка .kube/config, kubectl autocomplete и установка других утилит"


############################
echo ">>>> Перемещение .kube/config в директорию пользователя $(id -un)"
### если вы так же хотите запускать kubectl не только из под root пользователя необходимо
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# необязательно устанавливать
echo '>>>> Устанавливаем autocomplete для kubectl и его алиаса k'
sudo  dnf install bash-completion -y
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
source /usr/share/bash-completion/bash_completion


echo '>>>> Устанавливаем jq для форматирования JSON'
### данная утилита может понадобиться для обработки запросов утилиты kubectl
sudo dnf install jq -y
#### ### простой пример работы с jq
