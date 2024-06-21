# ##### Setup git #####
setup_commands+="setup_git "
function setup_git() {
  log_info "Setup Git..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS doesn't need further Git setup... Git setup skipped..."
    return
  fi
  local gitconfig_symlink=$HOME/.gitconfig
  local gitconfig_origin=$SCRIPT_DIR/git/gitconfig.$OS

  if [[ -f $gitconfig_symlink ]] && [[ ! -L $gitconfig_symlink ]]; then
    log_info "  .gitconfig already exists. It is a file, moving it to backup..."
    mv $gitconfig_symlink ${gitconfig_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $gitconfig_symlink ]] && [[ "$(readlink $gitconfig_symlink)" != "$gitconfig_origin" ]]; then
    log_info "  .gitconfig already exists, but it is a symlink to the wrong target."
    rm -f $gitconfig_symlink
  fi

  if [[ -L $gitconfig_symlink ]] && [[ ! -e $gitconfig_symlink ]]; then
    log_info "  .gitconfig already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $gitconfig_symlink
  fi

  if [[ ! -L $gitconfig_symlink ]]; then
    log_info "  Creating the symlink for .gitconfig..."
    ln -s $gitconfig_origin $gitconfig_symlink
  fi
}
