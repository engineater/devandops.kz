#!/bin/bash
######  содержимое файла 00_preinstall.sh

### очищаем экран от предыдущих записей
clear


###############################
echo '>>>> отключаем автозапуск сервиса firewall'
sudo systemctl disable firewalld
echo '>>>> останавливаем firewall'
sudo systemctl stop firewalld


###############################
echo '>>>> (00) Проверяем статус SELINUX'
sestatus
echo '>>>> Устанавливаем SELinux режим permissive (до следующей перезагрузки ОС)'
sudo setenforce 0
echo '>>>> (01) Проверяем статус SELINUX'
sestatus

echo '>>>> Устанавливаем режим permissive или disabled SELINUX на постоянной основе (вступит в силу после перезагрузки ОС)'
## возможно лучший вариант для отключения SELINUX это следующая команда
######  для SELinux с помощью значения permissive устанавливаем состояние запущен, но не применяется, регистрирует действия Access Vector Cache (данный способ рекомендуется)
# sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
######  политика SELinux не загружена, НЕ регистрирует действия Access Vector Cache (данный способ не рекомендуется, но для ДОМАШНЕГО кластера приемлимо и если вам не требуется отладка)
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

### Проверяем статус SELINUX
echo '>>>> (02) Проверяем статус SELINUX'
sestatus


###############################
### ### раcкоментируйте (удалив символы ### в начале строк) следующий блок кода если хотите запустить команды обновления ОС
###echo '>>>> обновляем ОС'
###sudo dnf upgrade -y
### ###### echo '>>>> Применяем системные параметры без перезагрузки (делать это не обязательно, т.к. последующая команда будет перезагружать ОС)'
### ###### sudo sysctl --system
###echo '>>>> Перезагружаем ОС'
###sudo shutdown -r now


###############################
