######  содержимое файла check_works_of_mirror_registries.sh


### docker.io
sudo crictl rmi docker.io/nginx:1.25.4 2>/dev/null
sudo crictl pull docker.io/nginx:1.25.4
sudo crictl rmi docker.io/nginx:1.25.4 2>/dev/null

### quay.io
sudo crictl rmi quay.io/prometheus/prometheus:v2.50.1 2>/dev/null
sudo crictl pull quay.io/prometheus/prometheus:v2.50.1
sudo crictl rmi quay.io/prometheus/prometheus:v2.50.1 2>/dev/null

### gcr.io
sudo crictl rmi gcr.io/google_containers/busybox:latest 2>/dev/null
sudo crictl pull gcr.io/google_containers/busybox:latest
sudo crictl rmi gcr.io/google_containers/busybox:latest 2>/dev/null

### k8s.gcr.io
### #### невозможно проверить, в дальнешем его не надо будет подключать, т.к. Kubernetes отказывается от его использования

### registry.k8s.io
sudo crictl rmi registry.k8s.io/busybox:latest 2>/dev/null
sudo crictl pull registry.k8s.io/busybox:latest
sudo crictl rmi registry.k8s.io/busybox:latest 2>/dev/null


### ghcr.io
sudo crictl rmi ghcr.io/distroless/busybox:latest 2>/dev/null
sudo crictl pull ghcr.io/distroless/busybox:latest
sudo crictl rmi ghcr.io/distroless/busybox:latest 2>/dev/null

### registry.gitlab.com
sudo crictl rmi registry.gitlab.com/gitlab-org/gitlab-runner/alpine-entrypoint:latest 2>/dev/null
sudo crictl pull registry.gitlab.com/gitlab-org/gitlab-runner/alpine-entrypoint:latest
sudo crictl rmi registry.gitlab.com/gitlab-org/gitlab-runner/alpine-entrypoint:latest 2>/dev/null
