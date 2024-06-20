#!/usr/bin/env zsh

# ##### General #####
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
  print ${ref#refs/heads/}
}
function _check_git_repos() {
  l1ocal current_dir=$(pwd)
  for i in $(find . -name .git -type d -not -iwholename '*.terraform*'); do
    local folder=${i:A:h}
    echo "########## $folder ##########"
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

# ##### 1Password #####
function _check_1password() {
  if ! command -v op &>/dev/null; then
    print "1Password CLI is not installed"
    return 1
  fi
  return 0
}

# ##### Export credentials #####
alias ec='_export_cred'
function _export_cred() {
  if [[ "$1" == "help" ]]; then
    print "Usage: ec <service>"
    print ""
    print "Available services: gitlab, cloudflare, proxmox, ssh, vault, aws, all"
    print ""
    print "The 'all' argument will export all available services but not AWS."
    return 0
  fi
  if [[ -z "$1" ]]; then
    print "Please provide a service"
    return 1
  fi
  if [[ "$1" == "all" ]]; then
    _export_cred_gitlab
    _export_cred_cloudflare
    _export_cred_proxmox
    _export_cred_ssh
    _export_cred_vault
    return 0
  fi
  local service=$1
  if ! command -v "_export_cred_$service" &>/dev/null; then
    print "Service $service not found"
    return 1
  fi
  "_export_cred_$service" ${@:2}
}
# export gitlab credentials
alias ecgitlab='_export_cred_gitlab'
function _export_cred_gitlab() {
  if ! _check_1password; then
    return 1
  fi
  local gitlab_user=$(op item get ijy23npdfhkrjc54ntffjekr5a --fields username)
  local gitlab_token=$(op item get hsn4rskbnen4g3m5lqb4totaou --fields token)
  if [[ -z "$gitlab_user" || -z "$gitlab_token" ]]; then
    print "Gitlab credentials not found in 1Password"
    return 1
  fi
  export TF_HTTP_USERNAME=$gitlab_user TF_HTTP_PASSWORD=$gitlab_token
  return 0
}
# export cloudflare credentials
alias eccloudflare='_export_cred_cloudflare'
function _export_cred_cloudflare() {
  if ! _check_1password; then
    return 1
  fi
  local cloudflare_account_id=$(op item get neo3orqoubdi5ilhx4yauzgww4 --fields 'account ID')
  local cloudflare_api_token=$(op item get dgmyyo2fzipvx3qhpm7qgljux4 --fields credential)
  if [[ -z "$cloudflare_account_id" || -z "$cloudflare_api_token" ]]; then
    print "Cloudflare credentials not found in 1Password"
    return 1
  fi
  export TF_VAR_cloudflare_account_id=$cloudflare_account_id TF_VAR_cloudflare_api_token=$cloudflare_api_token
  return 0
}
# export proxmox credentials
alias ecproxmox='_export_cred_proxmox'
function _export_cred_proxmox() {
  if ! _check_1password; then
    return 1
  fi
  local proxmox_user=$(op item get ahcroyqbhvlxksnilqgw73gynq --fields username)
  local proxmox_password=$(op item get ahcroyqbhvlxksnilqgw73gynq --fields password)
  if [[ -z "$proxmox_user" || -z "$proxmox_password" ]]; then
    print "Proxmox credentials not found in 1Password"
    return 1
  fi
  export TF_VAR_proxmox_user=$proxmox_user TF_VAR_proxmox_password=$proxmox_password
  return 0
}
# export ssh public key
alias ecssh='_export_cred_ssh'
function _export_cred_ssh() {
  if ! _check_1password; then
    return 1
  fi
  local ssh_public_key=$(op item get josurj44uxonxdvlk5mgk7hcvy --fields 'public key')
  if [[ -z "$ssh_public_key" ]]; then
    print "SSH public key not found in 1Password"
    return 1
  fi
  export TF_VAR_ssh_public_key=$ssh_public_key
  return 0
}
# export vault credentials
alias ecvault='_export_cred_vault'
function _export_cred_vault() {
  if ! _check_1password; then
    return 1
  fi
  local vault_addr=$(op item get sjohltwhbvcdin62uranbih3ay --fields hostname)
  local vault_token=$(op item get sjohltwhbvcdin62uranbih3ay --fields credential)
  if [[ -z "$vault_addr" || -z "$vault_token" ]]; then
    print "Vault credentials not found in 1Password"
    return 1
  fi
  export VAULT_ADDR=$vault_addr VAULT_TOKEN=$vault_token
  return 0
}
# export aws credentials
alias ecaws='_export_cred_aws'
function _export_cred_aws() {
  if [[ "$1" == "help" || -z "$1" ]]; then
    print "Usage: ecaws <string> <region>"
    print ""
    print "This command will search for an AWS Access Key in 1Password and export the credentials."
    print "A string is required and it will be added to 'AWS Access Key <string>' to search for the item."
    print ""
    print "Example: ecaws my-aws-key eu-central-1"
    print "This will search for 'AWS Access Key my-aws-key' in 1Password."
    print "The items should have the fields 'access key id' and 'secret access key'."
    print "Make sure that you have the 1Password CLI installed and configured."
    return 0
  fi
  if ! _check_1password; then
    return 1
  fi
  local aws_op_item="AWS Access Key $1"
  [[ "$2" =~ ^[a-z]{2}-[a-z]+-[0-9]+$ ]] && local aws_default_region=$2
  local aws_access_key_id=$(op item get $aws_op_item --fields 'access key id')
  local aws_secret_access_key=$(op item get $aws_op_item --fields 'secret access key')
  if [[ -z "$aws_access_key_id" || -z "$aws_secret_access_key" ]]; then
    print "AWS credentials not found in 1Password"
    return 1
  fi
  export AWS_DEFAULT_REGION=$aws_default_region AWS_ACCESS_KEY_ID=$aws_access_key_id AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
  return 0
}
function _test() {
  print "${@:2}"
}
