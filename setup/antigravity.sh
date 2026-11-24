# ##### Install Antigravity CLI #####
install_commands+=(install_antigravity)
function install_antigravity() {
  log_info "Install Antigravity CLI..."
  if command -v agy &>/dev/null; then
    log_sub "already installed, skipping..."
    return
  fi
  # Quoted so --dry-run neither downloads nor executes the installer.
  run bash -c 'set -o pipefail; curl -fsSL https://antigravity.google/cli/install.sh | bash'
}
