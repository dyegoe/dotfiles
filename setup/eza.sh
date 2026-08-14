# ##### Install eza #####
install_commands+=(install_eza)
function install_eza() {
  log_info "Install eza..."
  skip_on_darwin "$OS installs eza via brew, skipping..." && return

  local remote_version=$(gh_latest_tag eza-community/eza)
  local local_version=$(command -v eza &>/dev/null && eza --version | grep -oP '^v[0-9]+\.[0-9]+\.[0-9]+' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/eza-community/eza/releases/download/$remote_version/eza_${ARCHM}-unknown-${OS}-gnu.tar.gz" eza tar.gz
}
