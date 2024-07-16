# ##### Setup user #####
setup_commands+="setup_user "
function setup_user() {
  log_info "Set ZSH as shell for the current user..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS doesn't need further User setup..."
    return
  fi
  log_info "  set ZSH as shell for the current user..."
  sudo usermod -s $(which zsh) $USER
  log_info "  add the current user to the libvirt group..."
  sudo usermod -aG libvirt $USER
  log_info "  setup done..."
}
