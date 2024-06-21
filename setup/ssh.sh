# ##### Setup ssh #####
setup_commands+="setup_ssh "
function setup_ssh() {
  log_info "Setup SSH..."
  local ssh_dir=$HOME/.ssh
  local ssh_config_symlink=$ssh_dir/config
  local ssh_config_origin=$SCRIPT_DIR/ssh/config.$OS

  if [[ ! -d $ssh_dir ]]; then
    log_info "  Creating .ssh directory..."
    mkdir -p $ssh_dir
    chmod 700 $ssh_dir
  fi

  if [[ -f $ssh_config_symlink ]] && [[ ! -L $ssh_config_symlink ]]; then
    log_info "  ssh config already exists. It is a file, moving it to backup..."
    mv $ssh_config_symlink ${ssh_config_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $ssh_config_symlink ]] && [[ "$(readlink $ssh_config_symlink)" != "$ssh_config_origin" ]]; then
    log_info "  ssh config already exists, but it is a symlink to the wrong target."
    rm -f $ssh_config_symlink
  fi

  if [[ -L $ssh_config_symlink ]] && [[ ! -e $ssh_config_symlink ]]; then
    log_info "  ssh config already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $ssh_config_symlink
  fi

  if [[ ! -L $ssh_config_symlink ]]; then
    log_info "  Creating the symlink for config..."
    ln -s $ssh_config_origin $ssh_config_symlink
  fi
}
