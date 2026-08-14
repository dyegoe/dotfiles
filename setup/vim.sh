# ##### Setup vim #####
setup_commands+=(setup_vim)
function setup_vim() {
  log_info "Setup Vim..."
  run mkdir -p "$VIM_HOME/undo"

  link_config "$SCRIPT_DIR/vim/vimrc" "$VIM_HOME/vimrc" ".vimrc"
  log_info "  setup done..."
}

# ##### Install vim plugins #####
install_commands+=(install_vim_plugins)
function install_vim_plugins() {
  log_info "Install vim plugins..."
  run mkdir -p "$VIM_THEMES"
  run mkdir -p "$VIM_PLUGINS"

  clone_or_pull https://github.com/tomasiser/vim-code-dark "$VIM_THEMES/vim-code-dark"
  clone_or_pull https://github.com/hashivim/vim-terraform.git "$VIM_PLUGINS/vim-terraform"
}
