#!/bin/bash

create_base_directories() {
  create_directory_with_permissions "$HOME/Documents" 0755
  create_directory_with_permissions "$HOME/Downloads" 0755
  create_directory_with_permissions "$HOME/Pictures" 0755
  create_directory_with_permissions "$HOME/Developer" 0755
  create_directory_with_permissions "$HOME/.config" 0755
}