### по умолчанию наименование тэга, если это не переопределено --build-arg
ARG IMAGE_TAG=9.5

FROM docker.io/redhat/ubi9-minimal:${IMAGE_TAG}

#RUN microdnf -h
###### (01) В целях безопасности ОБНОВЛЕНИЕ ПАКЕТОВ IMAGE
RUN echo -e "\
[ubi-9-baseos-rpms]\n\
name = Red Hat Universal Base Image 9 (RPMs) - BaseOS\n\
baseurl = https://nexus.my.private/repository/cdn-ubi.redhat.com_ubi9/\$basearch/baseos/os\n\
enabled = 1\n\
gpgcheck = 0\n\
sslverify=false\n\
\n\
[ubi-9-appstream-rpms]\n\
name = Red Hat Universal Base Image 9 (RPMs) - AppStream\n\
baseurl = https://nexus.my.private/repository/cdn-ubi.redhat.com_ubi9/\$basearch/appstream/os\n\
enabled = 1\n\
gpgcheck = 0\n\
sslverify=false\n\
\n\
[ubi-9-codeready-builder-rpms]\n\
name = Red Hat Universal Base Image 9 (RPMs) - CodeReady Builder\n\
baseurl = https://nexus.my.private/repository/cdn-ubi.redhat.com_ubi9/\$basearch/codeready-builder/os\n\
enabled = 1\n\
gpgcheck = 0\n\
sslverify=false\
" > /etc/yum.repos.d/ubi.repo

RUN microdnf clean all && microdnf repolist
RUN microdnf upgrade --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0 -y

###### (02) Установка дополнительных пакетов для запуска Python скрипта
### tzdata нужна для корректной установки даты и времени на уровне дистрибутива Linux
### shadow-utils нужен для установки пакетов useradd, groupadd
RUN microdnf reinstall tzdata -y && microdnf install shadow-utils -y && microdnf install python3.12 python3.12-pip -y && microdnf clean all -y && id && python3.12 --version

#################################################################
###### (03) Создаём нового пользователя nonroot из под которого будет запускаться Python скрипт
#RUN cat /etc/passwd
#RUN cat /etc/group
RUN groupadd --gid 10001 nonroot && useradd -m -l -u 10001 -r -g 10001 -d /home/nonroot nonroot

### увы, но при больших значениях gid или uid, команда chown работает с ошибками
### RUN groupadd --gid 1000730000 nonroot && useradd -m -l -u 1000730000 -r -g 1000730000 -d /home/nonroot nonroot

###### (04) Удаляем не нужные пакеты
# после запуска groupadd пакеты shadow-utils больше не нужны
# удаляем так же microdnf, ubi.repo
# (данные действия не позволят добавлять новые пакеты в будущем с помощью microdnf, но повысят безопасность собираемого image)
RUN microdnf remove shadow-utils -y && rm -f /bin/microdnf && rm -f /etc/yum.repos.d/ubi.repo


# Chown all the files to the app user.
#RUN ls /home/nonroot
#RUN chown root:nonroot /usr/bin/python3.12
RUN chown -R nonroot:nonroot /home/nonroot


###### (05) Копируем файлы Python скрипта и настраиваем "запуск primary процесса"
### после этой инструкции действия будут совершаться от имени пользователя nonroot
USER nonroot

### копируем необходимы файлы приложения
### COPY --chown=nonroot:nonroot ./main.py /home/nonroot/
### ### не во всех версиях docker можно использовать --parents
COPY --chown=nonroot:nonroot ./app /home/nonroot/app/
### RUN ls -lha --recursive /home/nonroot/
RUN mkdir ~/.pip && echo -e "\
[global]\n\
index-url=https://nexus.my.private/repository/pypi/simple\n\
trusted-host=nexus.my.private\n\
index = https://nexus.my.private/repository/pypi/\
" > ~/.pip/pip.conf
RUN python3.12 -m pip --no-cache-dir install -r /home/nonroot/app/requirements.txt && rm -f /home/nonroot/app/requirements.txt


#RUN ls -alhR /home/nonroot/
#RUN ls -alhR /usr/bin/python3.12

### Вариант (1)
### запуск процесса python3.12
WORKDIR /home/nonroot
ENV PYTHONUNBUFFERED=1 TZ=Asia/Almaty
### ### можем запустить напрямую, т.к. в app/main.py прописан способ запуска
### ### ENTRYPOINT ["python3.12","app/main.py"]
### ### зачастую в main.py разработчики пишут разные вызовы,
### ### поэтому запускаем другим способом
ENTRYPOINT ["python3.12","-m","fastapi", "run", "app/main.py", "--proxy-headers", "--port", "8000", "--workers", "1"]
 

### Вариант (2)
### запуск контейнера в бесконечном цикле - просто для проверки контейнера
### здесь мы не запускаем python скрипт, а создаём скрипт "заглушку"
#RUN echo -e "while true ; do sleep 2 ; done" > /home/nonroot/runsleep.sh && chmod a+x /home/nonroot/runsleep.sh
#ENTRYPOINT ["sh","/home/nonroot/runsleep.sh"]

