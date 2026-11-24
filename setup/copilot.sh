# ##### Install GitHub Copilot CLI #####
install_commands+=(install_copilot)
function install_copilot() {
  log_info "Install GitHub Copilot CLI..."
  # VS Code ships a `copilot` shim (/usr/bin/copilot -> .../code/bin/copilot-shim/copilot)
  # that would otherwise make the CLI look installed on any machine with `code`.
  local bin=$(command -v copilot || true)
  if [[ -n "$bin" && "$(readlink -f "$bin")" != */copilot-shim/* ]]; then
    log_sub "already installed, skipping..."
    return
  fi
  # Quoted so --dry-run neither downloads nor executes the installer.
  run bash -c 'set -o pipefail; curl -fsSL https://gh.io/copilot-install | bash'
}
