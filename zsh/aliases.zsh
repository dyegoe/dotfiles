#!/usr/bin/env zsh

# ##### Default log prefix #####
function log_info() {
  printf "\e[33m\e[1m[INFO]\e[0m\e[34m $1\e[0m\n"
}
function log_error() {
  printf "\e[31m\e[1m[ERROR]\e[0m\e[33m $1\e[0m\n"
}

# ##### Eza #####
alias ll='eza --icons=always --git -lah'
alias ls='eza --icons --git'

# ##### Bat #####
alias cat='bat -p'

# ##### Git #####
# Copied from https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return # no git repo.
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  printf ${ref#refs/heads/\n}
}
alias gcr='git_check_repos'
function git_check_repos() {
  local current_dir=$(pwd)
  for i in $(find . -name .git -type d -not -iwholename '*.terraform*'); do
    local folder=${i:A:h}
    log_info "########## $folder ##########"
    cd $folder
    git pull
    git status
    cd $current_dir
  done
}
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbr='git branch --remote'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcmsg='git commit --message'
alias gf='git fetch'
alias gfa='git fetch --all --prune --jobs=10'
alias gl='git pull'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gst='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'
alias gr='git restore'
alias grs='git restore --staged'

# ##### fzf #####
function _check_fzf() {
  if ! command -v fzf &>/dev/null; then
    log_error "FZF is not installed"
    return 1
  fi
  return 0
}

# ##### jq #####
function _check_jq() {
  if ! command -v jq &>/dev/null; then
    log_error "jq is not installed"
    return 1
  fi
  return 0
}

# ##### 1Password #####
function _check_op() {
  if ! command -v op &>/dev/null; then
    log_error "1Password CLI is not installed"
    return 1
  fi
  return 0
}
alias oph='op_helper'
function op_helper() {
  if ! _check_op; then
    return 1
  fi
  if ! _check_fzf; then
    return 1
  fi
  if ! _check_jq; then
    return 1
  fi
  local op_items=$(op item list --format json | jq -r '.[] | "\(.title) [\(.additional_information)] (\(.id))"')
  if [[ -z "$op_items" ]]; then
    log_error "No items found in 1Password"
    return 1
  fi
  if [[ ! -z "$1" ]]; then
    local op_item_id=$(printf $op_items | fzf --header 'Select the 1Password item' --header-first -m 0 --query $1 | sed 's/.*(\(.*\))/\1/')
  else
    local op_item_id=$(printf $op_items | fzf --header 'Select the 1Password item' --header-first -m 0 | sed 's/.*(\(.*\))/\1/')
  fi
  if [[ -z "$op_item_id" ]]; then
    log_error "No item selected"
    return 1
  fi
  local op_item_fields=$(op item get $op_item_id --format json | jq -r '.fields[] | select(.id != "" and .id != "notesPlain") | "\(.label) (\(.id))"')
  if [[ -z "$op_item_fields" ]]; then
    log_error "No fields found in 1Password item"
    return 1
  fi
  local op_item_field=$(echo $op_item_fields | fzf --header 'Select the 1Password item field' --header-first | sed 's/.*(\(.*\))/\1/' | tr '\n' ',' | sed 's/,$//')
  if [[ -z "$op_item_field" ]]; then
    log_error "No field selected"
    return 1
  fi
  local op_item_field_value=$(op item get $op_item_id --fields $op_item_field --format json | jq -r '.[] | "[\(.label)] \(.value)"')
  if [[ -z "$op_item_field_value" ]]; then
    log_error "No value found for field $op_item_field"
    return 1
  fi
  echo $op_item_field_value
}

# ##### Export credentials #####
alias ec='export_cred'
function export_cred() {
  if [[ "$1" == "help" ]]; then
    printf "Usage: ec <service>\n"
    printf "\n"
    printf "Available services: gitlab, cloudflare, proxmox, ssh, vault, aws, all\n"
    printf "\n"
    printf "The 'all' argument will export all available services but not AWS.\n"
    return 0
  fi
  if [[ -z "$1" ]]; then
    log_error "Please provide a service"
    return 1
  fi
  if [[ "$1" == "all" ]]; then
    export_cred_gitlab
    export_cred_cloudflare
    export_cred_proxmox
    export_cred_ssh
    export_cred_vault
    return 0
  fi
  local service=$1
  if ! command -v "export_cred_$service" &>/dev/null; then
    log_error "Service $service not found"
    return 1
  fi
  "export_cred_$service" ${@:2}
}

# ##### Export gitlab credentials #####
alias ecgitlab='export_cred_gitlab'
function export_cred_gitlab() {
  if ! _check_op; then
    return 1
  fi
  local gitlab_user=$(op item get ijy23npdfhkrjc54ntffjekr5a --fields username)
  local gitlab_token=$(op item get hsn4rskbnen4g3m5lqb4totaou --fields token)
  if [[ -z "$gitlab_user" || -z "$gitlab_token" ]]; then
    log_error "Gitlab credentials not found in 1Password"
    return 1
  fi
  export TF_HTTP_USERNAME=$gitlab_user TF_HTTP_PASSWORD=$gitlab_token &&
    log_info "Gitlab credentials exported"
  return 0
}

# ##### Export cloudflare credentials #####
alias eccloudflare='export_cred_cloudflare'
function export_cred_cloudflare() {
  if ! _check_op; then
    return 1
  fi
  local cloudflare_account_id=$(op item get neo3orqoubdi5ilhx4yauzgww4 --fields 'account ID')
  local cloudflare_api_token=$(op item get dgmyyo2fzipvx3qhpm7qgljux4 --fields credential)
  if [[ -z "$cloudflare_account_id" || -z "$cloudflare_api_token" ]]; then
    log_error "Cloudflare credentials not found in 1Password"
    return 1
  fi
  export TF_VAR_cloudflare_account_id=$cloudflare_account_id TF_VAR_cloudflare_api_token=$cloudflare_api_token &&
    log_info "Cloudflare credentials exported"
  return 0
}

# ##### Export proxmox credentials #####
alias ecproxmox='export_cred_proxmox'
function export_cred_proxmox() {
  if ! _check_op; then
    return 1
  fi
  local proxmox_user=$(op item get ahcroyqbhvlxksnilqgw73gynq --fields username)
  local proxmox_password=$(op item get ahcroyqbhvlxksnilqgw73gynq --fields password)
  if [[ -z "$proxmox_user" || -z "$proxmox_password" ]]; then
    log_error "Proxmox credentials not found in 1Password"
    return 1
  fi
  export TF_VAR_proxmox_user="${proxmox_user}@pam" TF_VAR_proxmox_password=$proxmox_password &&
    log_info "Proxmox credentials exported"
  return 0
}

# ##### Export ssh public key #####
alias ecssh='export_cred_ssh'
function export_cred_ssh() {
  if ! _check_op; then
    return 1
  fi
  local ssh_public_key=$(op item get josurj44uxonxdvlk5mgk7hcvy --fields 'public key')
  if [[ -z "$ssh_public_key" ]]; then
    log_error "SSH public key not found in 1Password"
    return 1
  fi
  export TF_VAR_ssh_public_key=$ssh_public_key &&
    log_info "SSH public key exported"
  return 0
}

# ##### Export vault credentials #####
alias ecvault='export_cred_vault'
function export_cred_vault() {
  if ! _check_op; then
    return 1
  fi
  local vault_addr=$(op item get sjohltwhbvcdin62uranbih3ay --fields hostname)
  local vault_token=$(op item get sjohltwhbvcdin62uranbih3ay --fields credential)
  if [[ -z "$vault_addr" || -z "$vault_token" ]]; then
    log_error "Vault credentials not found in 1Password"
    return 1
  fi
  export VAULT_ADDR=$vault_addr VAULT_TOKEN=$vault_token &&
    log_info "Vault credentials exported"
  return 0
}

# ##### Export ansible vault password #####
alias ecav='export_cred_ansible_vault'
function export_cred_ansible_vault() {
  if [[ "$1" == "help" || -z "$1" ]]; then
    printf "Usage: ecav <string>\n"
    printf "\n"
    printf "This command will search for Ansible Vault password in 1Password and export the credentials.\n"
    printf "A string is required and it will be added to 'Ansible Vault <string>' to search for the item.\n"
    printf "\n"
    printf "Example: ecav home-lab\n"
    printf "This will search for 'Ansible Vault home-lab' in 1Password.\n"
    printf "The items should have the field 'password'.\n"
    printf "Make sure that you have the 1Password CLI installed and configured.\n"
    return 0
  fi
  if ! _check_op; then
    return 1
  fi
  local ansible_vault_op_item="Ansible Vault $1"
  local ansible_vault_password=$(op item get $ansible_vault_op_item --fields password)
  if [[ -z "$ansible_vault_password" ]]; then
    log_error "Ansible Vault password not found in 1Password"
    return 1
  fi
  echo '#!/usr/bin/env bash\necho $ANSIBLE_VAULT_PASSWORD' >$HOME/.ansible_vault_password
  chmod 700 $HOME/.ansible_vault_password
  export ANSIBLE_VAULT_PASSWORD_FILE=$HOME/.ansible_vault_password
  export ANSIBLE_VAULT_PASSWORD=$ansible_vault_password
  log_info "Ansible Vault password exported"
  return 0
}

# ##### Export aws credentials #####
alias ecaws='export_cred_aws'
function export_cred_aws() {
  if [[ "$1" == "help" || -z "$1" || ! "$2" =~ '^[a-z]{2}-[a-z]+-[0-9]+$' ]]; then
    printf "Usage: ecaws <string> <aws region>\n"
    printf "\n"
    printf "This command will search for an AWS Access Key in 1Password and export the credentials.\n"
    printf "A string is required and it will be added to 'AWS Access Key <string>' to search for the item.\n"
    printf "\n"
    printf "Example: ecaws my-aws-key eu-central-1\n"
    printf "\n"
    printf "This will search for 'AWS Access Key my-aws-key' in 1Password.\n"
    printf "The items should have the fields 'access key id' and 'secret access key'.\n"
    printf "Make sure that you have the 1Password CLI installed and configured.\n"
    return 0
  fi
  if ! _check_op; then
    return 1
  fi
  local aws_op_item="AWS Access Key $1"
  local aws_region=$2
  local aws_access_key_id=$(op item get $aws_op_item --fields 'access key id')
  local aws_secret_access_key=$(op item get $aws_op_item --fields 'secret access key')
  if [[ -z "$aws_access_key_id" || -z "$aws_secret_access_key" ]]; then
    log_error "AWS credentials not found in 1Password"
    return 1
  fi
  export AWS_REGION=$aws_region AWS_ACCESS_KEY_ID=$aws_access_key_id AWS_SECRET_ACCESS_KEY=$aws_secret_access_key &&
    log_info "AWS credentials exported"
  return 0
}

# ##### Export github personal access token #####
alias ecgh='export_cred_github'
function export_cred_github() {
  if [[ "$1" == "help" || -z "$1" ]]; then
    printf "Usage: ecgh <string>\n"
    printf "\n"
    printf "This command will search for a Github Personal Access Token in 1Password and export the credentials.\n"
    printf "A string is required and it will be added to 'Github Personal Access Token <string>' to search for the item.\n"
    printf "\n"
    printf "Example: ecgh my-github-token\n"
    printf "\n"
    printf "This will search for 'Github Personal Access Token my-github-token' in 1Password.\n"
    printf "The items should have the field 'token'.\n"
    printf "Make sure that you have the 1Password CLI installed and configured.\n"
    return 0
  fi
  if ! _check_op; then
    return 1
  fi
  local github_op_item="Github Personal Access Token $1"
  local github_token=$(op item get $github_op_item --fields token)
  if [[ -z "$github_token" ]]; then
    log_error "Github Personal Access Token not found in 1Password"
    return 1
  fi
  export GITHUB_TOKEN=$github_token &&
    log_info "Github Personal Access Token exported"
  if command -v tenv &>/dev/null; then
    export TENV_GITHUB_TOKEN=$github_token &&
      log_info "TENV Github Personal Access Token exported"
  fi
  return 0
}

# ##### Python #####
alias pyvenv='python_venv'
function python_venv() {
  local python_venv_root=$XDG_CONFIG_HOME/python/venv
  local python_cmd
  local python_venv_name=$1
  local python_venv_path=$python_venv_root/$python_venv_name
  if command -v python3 &>/dev/null; then
    python_cmd=$(command -v python3)
  elif command -v python &>/dev/null; then
    python_cmd=$(command -v python)
  else
    log_error "Python not found"
    return 1
  fi
  if [[ -z "$1" ]]; then
    log_error "Please provide a name for the virtual environment"
    return 1
  fi
  if [[ ! -d "$python_venv_path" ]]; then
    log_info "Creating virtual environment $python_venv_name"
    $python_cmd -m venv $python_venv_path &&
      log_info "Virtual environment $python_venv_name created" ||
      log_error "Failed to create virtual environment $python_venv_name"
  fi
  if [[ ! -f "$python_venv_path/bin/activate" ]]; then
    log_error "Virtual environment $python_venv_name not created"
    return 1
  fi
  log_info "Activating virtual environment $python_venv_name"
  source $python_venv_path/bin/activate &&
    log_info "Virtual environment $python_venv_name activated" ||
    log_error "Failed to activate virtual environment $python_venv_name"
}
