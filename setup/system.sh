# ##### Setup system #####
setup_commands+=(setup_system)
function setup_system() {
  log_info "Setup system..."
  skip_on_darwin "$OS doesn't need further system setup... system setup skipped..." && return

  log_info "  Checking GRUB configuration..."
  if [[ -f ~/.nowindows ]]; then
    log_info "  ~/.nowindows exists, skipping GRUB configuration..."
  else
    log_info "  Updating GRUB configuration..."
    run sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=3/' /etc/default/grub
    run sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    log_info "  GRUB configuration updated successfully."
  fi

  log_info "  Configuring DNF to retain only 2 kernels..."
  if grep -q '^installonly_limit=' /etc/dnf/dnf.conf; then
    run sudo sed -i 's/^installonly_limit=.*/installonly_limit=2/' /etc/dnf/dnf.conf
  else
    run sudo sh -c 'echo "installonly_limit=2" >> /etc/dnf/dnf.conf'
  fi
  log_info "  DNF configuration updated successfully."
}
