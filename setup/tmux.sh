# ##### Setup tmux #####
setup_commands+="setup_tmux "
function setup_tmux() {
  log_info "Setup Tmux..."
  # tmux.conf
  local tmux_conf_symlink=$XDG_CONFIG_HOME/tmux/tmux.conf
  local tmux_conf_origin=$SCRIPT_DIR/tmux/tmux.conf

  mkdir -p $XDG_CONFIG_HOME/tmux

  if [[ -f $tmux_conf_symlink ]] && [[ ! -L $tmux_conf_symlink ]]; then
    log_info "  tmux.conf already exists. It is a file, moving it to backup..."
    mv $tmux_conf_symlink ${tmux_conf_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $tmux_conf_symlink ]] && [[ "$(readlink $tmux_conf_symlink)" != "$tmux_conf_origin" ]]; then
    log_info "  tmux.conf already exists, but it is a symlink to the wrong target."
    rm -f $tmux_conf_symlink
  fi

  if [[ -L $tmux_conf_symlink ]] && [[ ! -e $tmux_conf_symlink ]]; then
    log_info "  tmux.conf already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $tmux_conf_symlink
  fi

  if [[ ! -L $tmux_conf_symlink ]]; then
    log_info "  Creating the symlink for tmux.conf..."
    ln -s $tmux_conf_origin $tmux_conf_symlink
  fi
}

# ##### Install Tmux plugins #####
install_commands+="install_tmux_plugins "
function install_tmux_plugins() {
  local tmux_plugins_dir="$XDG_CONFIG_HOME/tmux/plugins"
  local tmux_plugins_tpm_url="https://github.com/tmux-plugins/tpm.git"
  local tmux_plugins_tpm_dir="$tmux_plugins_dir/tpm"

  if [[ ! -d $tmux_plugins_dir ]]; then
    log_info "Creating tmux plugins..."
    mkdir -p $tmux_plugins_dir
  else
    log_info "Tmux plugins directoy already exists..."
  fi

  if [[ ! -d $tmux_plugins_tpm_dir ]]; then
    log_info "Instal tmux tpm plugin..."
    git clone $tmux_plugins_tpm_url $tmux_plugins_tpm_dir
  else
    log_info "Update tmux tpm plugin..."
    cd $tmux_plugins_tpm_dir
    git pull
    cd $SCRIPT_DIR
  fi

  log_info "Install tmux plugins..."
  $tmux_plugins_tpm_dir/bin/install_plugins
}
