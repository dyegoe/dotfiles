# ##### Setup oh-my-posh #####
setup_commands+="setup_oh_my_posh "
function setup_oh_my_posh() {
  log_info "Setup oh-my-posh..."
  local oh_my_posh_templates=(
    "default.json"
    "my.json"
  )

  for template in ${oh_my_posh_templates[@]}; do
    local oh_my_posh_symlink=$XDG_CONFIG_HOME/oh-my-posh/$template
    local oh_my_posh_origin=$SCRIPT_DIR/oh-my-posh/$template

    mkdir -p $XDG_CONFIG_HOME/oh-my-posh

    if [[ -f $oh_my_posh_symlink ]] && [[ ! -L $oh_my_posh_symlink ]]; then
      log_info "  $template already exists. It is a file, moving it to backup..."
      mv $oh_my_posh_symlink ${oh_my_posh_symlink}.$(date +%Y%m%d%H%M%S).backup
    fi

    if [[ -L $oh_my_posh_symlink ]] && [[ "$(readlink $oh_my_posh_symlink)" != "$oh_my_posh_origin" ]]; then
      log_info "  $template already exists, but it is a symlink to the wrong target."
      rm -f $oh_my_posh_symlink
    fi

    if [[ -L $oh_my_posh_symlink ]] && [[ ! -e $oh_my_posh_symlink ]]; then
      log_info "  $template already exists. It is a symlink, but the target does not exist. Removing it..."
      rm -f $oh_my_posh_symlink
    fi

    if [[ ! -L $oh_my_posh_symlink ]]; then
      log_info "  Creating the symlink for $template..."
      ln -s $oh_my_posh_origin $oh_my_posh_symlink
    fi
  done
}

# ##### Install oh-my-posh #####
install_commands+="install_oh_my_posh "
function install_oh_my_posh() {
  log_info "Install oh-my-posh..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest) | jq -r '.tag_name')
  local local_version=v$(command -v oh-my-posh &>/dev/null && oh-my-posh --version || echo "0.0.0")
  local download_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/$remote_version/posh-$OS-$ARCH"
  local bin_name="oh-my-posh"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  oh-my-posh is up to date..."
    return
  fi
  log_info "  installing..."
  download_bin_local_bin $download_url $bin_name
}
