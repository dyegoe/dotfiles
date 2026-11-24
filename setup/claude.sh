# ##### Install Claude Code #####
install_commands+=(install_claude)
function install_claude() {
  log_info "Install Claude Code..."
  if command -v claude &>/dev/null; then
    log_sub "already installed, skipping..."
    return
  fi
  # Quoted so --dry-run neither downloads nor executes the installer.
  run bash -c 'set -o pipefail; curl -fsSL https://claude.ai/install.sh | bash'
}
