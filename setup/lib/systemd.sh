#!/bin/bash

enable_service() {
  local service_name="$1"

  sudo systemctl enable "$service_name"
}