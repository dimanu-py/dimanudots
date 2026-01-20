#!/bin/bash

USER_TO_ADD="${1:-$USER}"
DOCKER_DAEMON_DIR="/etc/docker"

setup_docker() {
  ensure_docker_dir_exists
  limit_docker_log_size
  enable_docker_services
  ensure_docker_group_exists
  add_user_to_docker_group
}

ensure_docker_dir_exists() {
  create_directory_with_permissions "$DOCKER_DAEMON_DIR" "0755"
}

limit_docker_log_size() {
  sudo tee $DOCKER_DAEMON_DIR/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
EOF
  set_owner root $DOCKER_DAEMON_DIR/daemon.json --sudo
  set_permissions 0644 $DOCKER_DAEMON_DIR/daemon.json --sudo
}

enable_docker_services() {
  local docker_services=("docker" "containerd")

  for service in "${docker_services[@]}"; do
      enable_service "$service"
  done
}

ensure_docker_group_exists() {
    if ! getent group docker > /dev/null 2>&1; then
        sudo groupadd docker
    fi
}

add_user_to_docker_group() {
    sudo usermod -aG docker "$USER_TO_ADD"
}