# ##### Install sops #####
install_commands+=(install_sops)
function install_sops() {
  log_info "Install sops..."
  skip_on_darwin "$OS detected, skipping sops installation." && return

  local remote_version=$(gh_latest_tag getsops/sops)
  local local_version=$(command -v sops &>/dev/null && sops --version | awk '/^sops /{print $2}' || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/getsops/sops/releases/download/$remote_version/sops-${remote_version}.${OS}.${ARCH}" sops bin
}
