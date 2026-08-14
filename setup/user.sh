# ##### Setup user #####
setup_commands+=(setup_user)
function setup_user() {
  log_info "Set ZSH as shell for the current user..."
  skip_on_darwin "$OS doesn't need further User setup..." && return

  log_info "  set ZSH as shell for the current user..."
  run sudo usermod -s "$(command -v zsh)" "$(id -un)"

  log_info "  add the current user to the libvirt group..."
  run sudo usermod -aG libvirt "$(id -un)" || true
  log_info "  setup done..."
}
