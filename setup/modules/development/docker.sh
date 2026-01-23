#!/bin/bash

USER_TO_ADD="${1:-$USER}"
DOCKER_DAEMON_DIR="/etc/docker"

setup_docker() {
  _ensure_docker_dir_exists
  _limit_docker_log_size
  _enable_docker_services
  _ensure_docker_group_exists
  _add_user_to_docker_group
}

_ensure_docker_dir_exists() {
  create_directory_with_permissions "$DOCKER_DAEMON_DIR" "0755" --sudo
}

_limit_docker_log_size() {
  sudo tee $DOCKER_DAEMON_DIR/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
EOF
}

_enable_docker_services() {
  local docker_services=("docker" "containerd")

  for service in "${docker_services[@]}"; do
      enable_service "$service"
  done
}

_ensure_docker_group_exists() {
  if ! getent group docker > /dev/null 2>&1; then
      sudo groupadd docker
  fi
}

_add_user_to_docker_group() {
  sudo usermod -aG docker "$USER_TO_ADD"
}