# ##### Setup Alacritty #####
setup_commands+="setup_alacritty "
function setup_alacritty() {
  log_info "Setup Alacritty..."
  # alacritty.toml
  local alacritty_symlink=$XDG_CONFIG_HOME/alacritty/alacritty.toml
  local alacritty_origin=$SCRIPT_DIR/alacritty/alacritty-${OS}.toml

  mkdir -p $XDG_CONFIG_HOME/alacritty

  if [[ -f $alacritty_symlink ]] && [[ ! -L $alacritty_symlink ]]; then
    log_info "  alacritty.toml already exists. It is a file, moving it to backup..."
    mv $alacritty_symlink ${alacritty_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $alacritty_symlink ]] && [[ "$(readlink $alacritty_symlink)" != "$alacritty_origin" ]]; then
    log_info "  alacritty.toml already exists, but it is a symlink to the wrong target."
    rm -f $alacritty_symlink
  fi

  if [[ -L $alacritty_symlink ]] && [[ ! -e $alacritty_symlink ]]; then
    log_info "  alacritty.toml already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $alacritty_symlink
  fi

  if [[ ! -L $alacritty_symlink ]]; then
    log_info "  Creating the symlink for alacritty.toml..."
    ln -s $alacritty_origin $alacritty_symlink
  fi
}
