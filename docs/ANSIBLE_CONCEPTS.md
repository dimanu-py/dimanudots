# Ansible Concepts Primer

## Core Concepts

### Playbooks
**What:** YAML files defining automation tasks and execution order  
**Problem solved:** Orchestrate complex multi-step configurations  
**Example:** `ansible-playbook site.yml --tags base`

### Roles
**What:** Reusable collections of tasks, vars, files, templates, handlers  
**Problem solved:** Organize code into logical, shareable units  
**Example:** `roles/common/tasks/main.yml` with `roles/common/defaults/main.yml`

### Inventory
**What:** Defines target hosts and grouping  
**Problem solved:** Map configurations to specific machines  
**Example:** `inventory/hosts` with `[webservers] server1.example.com`

### host_vars/group_vars
**What:** Variable separation - per-host vs per-group  
**Problem solved:** Override defaults without modifying core logic  
**Example:** `group_vars/all.yml` for global vars, `host_vars/localhost.yml` for overrides

### Tasks
**What:** Individual units of work (package install, file copy, etc.)  
**Problem solved:** Atomic, testable configuration steps  
**Example:** `- name: Install nginx\n  pacman: name=nginx state=present`

### Handlers
**What:** Tasks triggered by other tasks' changes (notify)  
**Problem solved:** Restart services only when configuration changes  
**Example:** `- name: restart nginx\n  service: name=nginx state=restarted`

### Templates
**What:** Jinja2-processed configuration files  
**Problem solved:** Dynamic config generation with variables  
**Example:** `templates/nginx.conf.j2` with `{{ ansible_fqdn }}`

### Defaults vs Vars
**What:** `defaults/` (lowest priority) vs `vars/` (higher priority)  
**Problem solved:** Allow overrides while maintaining sane defaults  
**Example:** `defaults/main.yml` for defaults, `vars/main.yml` for required values

### Collections
**What:** Distribution mechanism for plugins, modules, roles  
**Problem solved:** Share and extend Ansible functionality  
**Example:** `community.general` for extra modules like `yay`

### Tags
**What:** Label tasks for selective execution  
**Problem solved:** Run specific parts without full playbook  
**Example:** `ansible-playbook site.yml --tags bootstrap,base`