# ##### Setup zsh #####
setup_commands+="setup_zsh "
function setup_zsh() {
  log_info "Setup ZSH..."
  # zshenv
  local zshenv_symlink=$HOME/.zshenv
  local zshenv_origin=$SCRIPT_DIR/zsh/zshenv

  if [[ -f $zshenv_symlink ]] && [[ ! -L $zshenv_symlink ]]; then
    log_info "  .zshenv already exists. It is a file, moving it to backup..."
    mv $zshenv_symlink ${zshenv_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $zshenv_symlink ]] && [[ "$(readlink $zshenv_symlink)" != "$zshenv_origin" ]]; then
    log_info "  .zshenv already exists, but it is a symlink to the wrong target."
    rm -f $zshenv_symlink
  fi

  if [[ -L $zshenv_symlink ]] && [[ ! -e $zshenv_symlink ]]; then
    log_info "  .zshenv already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $zshenv_symlink
  fi

  if [[ ! -L $zshenv_symlink ]]; then
    log_info "  Creating the symlink for .zshenv..."
    ln -s $zshenv_origin $zshenv_symlink
  fi

  # zprofile
  local zprofile_symlink=$ZDOTDIR/.zprofile
  local zprofile_origin=$SCRIPT_DIR/zsh/zprofile

  if [[ -f $zprofile_symlink ]] && [[ ! -L $zprofile_symlink ]]; then
    log_info "  .zprofile already exists. It is a file, moving it to backup..."
    mv $zprofile_symlink ${zprofile_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $zprofile_symlink ]] && [[ "$(readlink $zprofile_symlink)" != "$zprofile_origin" ]]; then
    log_info "  .zprofile already exists, but it is a symlink to the wrong target."
    rm -f $zprofile_symlink
  fi

  if [[ -L $zprofile_symlink ]] && [[ ! -e $zprofile_symlink ]]; then
    log_info "  .zprofile already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $zprofile_symlink
  fi

  if [[ ! -L $zprofile_symlink ]]; then
    log_info "  Creating the symlink for .zprofile..."
    ln -s $zprofile_origin $zprofile_symlink
  fi

  # zshrc
  local zshrc_symlink=$ZDOTDIR/.zshrc
  local zshrc_origin=$SCRIPT_DIR/zsh/zshrc

  if [[ -f $zshrc_symlink ]] && [[ ! -L $zshrc_symlink ]]; then
    log_info "  .zshrc already exists. It is a file, moving it to backup..."
    mv $zshrc_symlink ${zshrc_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $zshrc_symlink ]] && [[ "$(readlink $zshrc_symlink)" != "$zshrc_origin" ]]; then
    log_info "  .zshrc already exists, but it is a symlink to the wrong target."
    rm -f $zshrc_symlink
  fi

  if [[ -L $zshrc_symlink ]] && [[ ! -e $zshrc_symlink ]]; then
    log_info "  .zshrc already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $zshrc_symlink
  fi

  if [[ ! -L $zshrc_symlink ]]; then
    log_info "  Creating the symlink for .zshrc..."
    ln -s $zshrc_origin $zshrc_symlink
  fi

  # aliases
  local aliases_symlink=$ZDOTDIR/aliases.zsh
  local aliases_origin=$SCRIPT_DIR/zsh/aliases.zsh

  if [[ -f $aliases_symlink ]] && [[ ! -L $aliases_symlink ]]; then
    log_info "  aliases.zsh already exists. It is a file, moving it to backup..."
    mv $aliases_symlink ${aliases_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $aliases_symlink ]] && [[ "$(readlink $aliases_symlink)" != "$aliases_origin" ]]; then
    log_info "  aliases.zsh already exists, but it is a symlink to the wrong target."
    rm -f $aliases_symlink
  fi

  if [[ -L $aliases_symlink ]] && [[ ! -e $aliases_symlink ]]; then
    log_info "  aliases.zsh already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $aliases_symlink
  fi

  if [[ ! -L $aliases_symlink ]]; then
    log_info "  Creating the symlink for aliases.zsh..."
    ln -s $aliases_origin $aliases_symlink
  fi
}

# ##### Install ZSH plugins #####
install_commands+="install_zsh_plugins "
function install_zsh_plugins() {
  # zsh-autosuggestions
  if [[ ! -d $ZDOTDIR/plugins/zsh-autosuggestions ]]; then
    log_info "Install zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZDOTDIR/plugins/zsh-autosuggestions
  else
    log_info "Update zsh-autosuggestions..."
    cd $ZDOTDIR/plugins/zsh-autosuggestions && git pull
  fi

  # zsh-syntax-highlighting
  if [[ ! -d $ZDOTDIR/plugins/zsh-syntax-highlighting ]]; then
    log_info "Install zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZDOTDIR/plugins/zsh-syntax-highlighting
  else
    log_info "Update zsh-syntax-highlighting..."
    cd $ZDOTDIR/plugins/zsh-syntax-highlighting && git pull
  fi

  # fzf-tab-completion
  if [[ ! -d $ZDOTDIR/plugins/fzf-tab-completion ]]; then
    log_info "Install fzf-tab-completion..."
    git clone https://github.com/lincheney/fzf-tab-completion $ZDOTDIR/plugins/fzf-tab-completion
  else
    log_info "Update fzf-tab-completion..."
    cd $ZDOTDIR/plugins/fzf-tab-completion && git pull
  fi
}
