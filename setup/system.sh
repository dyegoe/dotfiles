# ##### Setup system #####
setup_commands+="setup_system "
function setup_system() {
  log_info "Setup system..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS doesn't need further system setup... system setup skipped..."
    return
  fi

  # Update GRUB configuration
  log_info "  Updating GRUB configuration..."
  sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=3/' /etc/default/grub
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  log_info "  GRUB configuration updated successfully."

  # Configure DNF to retain only 2 kernels
  log_info "  Configuring DNF to retain only 2 kernels..."
  if grep -q '^installonly_limit=' /etc/dnf/dnf.conf; then
    sudo sed -i 's/^installonly_limit=.*/installonly_limit=2/' /etc/dnf/dnf.conf
  else
    echo "installonly_limit=2" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
  fi
  log_info "  DNF configuration updated successfully."
}
