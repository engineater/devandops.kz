#!/bin/bash
######  содержимое файла 02_MASTER_on_first_only.sh

clear
echo '>>>> Запуск установки: только для первой control-plane ноды'

############################
# Значение данной переменной (версия k8s) должна быть такой же как и в файлах 01_02_*.sh
### ### KVERSION=1.29.4
# Адрес и порт балансировщика kubernetes apiserver
### ### BALANCER='192.168.1.150:8443'
# Подсеть для подов k8s кластера
### ### PODNETWORKCIDR=172.17.0.0/16
# Подсеть для сервисов k8s кластера
### ### SERVICECIDR=10.10.0.0/16

### значение флага control-plane-endpoint присваивается IP-адрес и порт балансировщика kubernetes apiserver, который мы настроили в предыдущих главах
### значение подсети флагов pod-network-cidr и service-cidr не должны совпадать с уже использованной подсетью вашего окружения 
### ### должна использовать "частная подсеть" (смотрите https://ru.wikipedia.org/wiki/%D0%A7%D0%B0%D1%81%D1%82%D0%BD%D1%8B%D0%B9_IP-%D0%B0%D0%B4%D1%80%D0%B5%D1%81#IPv4)
### флаг --upload-certs используется для загрузки сертификатов, которые должны быть общими для всех экземпляров плоскости управления, в кластер.
echo '>>>> Инициализация kubeadm'
sudo kubeadm init --control-plane-endpoint $BALANCER --pod-network-cidr $PODNETWORKCIDR --service-cidr $SERVICECIDR --kubernetes-version $KVERSION --upload-certs | tee -a ~/kubeadm_init.log
### в целях безопасности запрещаем другим пользователям читать(пользователям с правами root мы не можем запретить) файл kubeadm_init.log
chmod 600 kubeadm_init.log
