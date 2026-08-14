# ##### Setup git #####
setup_commands+=(setup_git)
function setup_git() {
  log_info "Setup Git..."
  link_config "$SCRIPT_DIR/git/gitconfig.$OS" "$HOME/.gitconfig" ".gitconfig"
  log_info "  setup done..."
}
