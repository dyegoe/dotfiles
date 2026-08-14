# ##### Setup zsh #####
setup_commands+=(setup_zsh)
function setup_zsh() {
  log_info "Setup ZSH..."
  link_config "$SCRIPT_DIR/zsh/zshenv" "$HOME/.zshenv" ".zshenv"
  link_config "$SCRIPT_DIR/zsh/zprofile" "$ZDOTDIR/.zprofile" ".zprofile"
  link_config "$SCRIPT_DIR/zsh/zshrc" "$ZDOTDIR/.zshrc" ".zshrc"
  link_config "$SCRIPT_DIR/zsh/aliases.zsh" "$ZDOTDIR/aliases.zsh" "aliases.zsh"
  log_info "  setup done..."
}

# ##### Install ZSH plugins #####
install_commands+=(install_zsh_plugins)
function install_zsh_plugins() {
  log_info "Install ZSH plugins..."
  run mkdir -p "$ZDOTDIR/plugins"
  clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$ZDOTDIR/plugins/zsh-autosuggestions"
  clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZDOTDIR/plugins/zsh-syntax-highlighting"
  clone_or_pull https://github.com/lincheney/fzf-tab-completion "$ZDOTDIR/plugins/fzf-tab-completion"
}
