# ##### Setup vim #####
setup_commands+="setup_vim "
function setup_vim() {
  log_info "Setup Vim..."
  local vimrc_symlink=$VIM_HOME/vimrc
  local vimrc_origin=$SCRIPT_DIR/vim/vimrc

  mkdir -p $VIM_HOME
  # check vimrc -> set undodir
  mkdir -p $VIM_HOME/undo

  if [[ -f $vimrc_symlink ]] && [[ ! -L $vimrc_symlink ]]; then
    log_info "  .vimrc already exists. It is a file, moving it to backup..."
    mv $vimrc_symlink ${vimrc_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $vimrc_symlink ]] && [[ "$(readlink $vimrc_symlink)" != "$vimrc_origin" ]]; then
    log_info "  .vimrc already exists, but it is a symlink to the wrong target."
    rm -f $vimrc_symlink
  fi

  if [[ -L $vimrc_symlink ]] && [[ ! -e $vimrc_symlink ]]; then
    log_info "  .vimrc already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $vimrc_symlink
  fi

  if [[ ! -L $vimrc_symlink ]]; then
    log_info "  creating the symlink for .vimrc..."
    ln -s $vimrc_origin $vimrc_symlink
  fi
  log_info "  setup done..."
}

# ##### Install vim plugins #####
install_commands+="install_vim_plugins "
function install_vim_plugins() {
  log_info "Install vim plugins..."
  mkdir -p $VIM_THEMES
  mkdir -p $VIM_PLUGINS

  local vim_themes_code_dark=$VIM_THEMES/vim-code-dark
  if [[ ! -d $vim_themes_code_dark ]]; then
    log_info "  color scheme..."
    git clone https://github.com/tomasiser/vim-code-dark $vim_themes_code_dark
  else
    log_info "  color scheme already installed... update it..."
    cd $vim_themes_code_dark && git pull
  fi

  local vim_plugins_vim_terraform=$VIM_PLUGINS/vim-terraform
  if [[ ! -d $vim_plugins_vim_terraform ]]; then
    log_info "  vim-terraform..."
    git clone https://github.com/hashivim/vim-terraform.git $vim_plugins_vim_terraform
  else
    log_info "  vim-terraform already installed... update it..."
    cd $vim_plugins_vim_terraform && git pull
  fi
  log_info "  done..."
}
