# ##### Setup user #####
setup_commands+="setup_user "
function setup_user() {
  if [[ "$OS" == "darwin" ]]; then
    log_info "$OS doesn't need further User setup..."
    return
  fi
  log_info "Set ZSH as shell for the current user..."
  sudo usermod -s $(which zsh) $USER
  log_info "Add user to libvirt group..."
  sudo usermod -aG libvirt $USER
}
