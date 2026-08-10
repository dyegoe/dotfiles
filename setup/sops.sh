# ##### Install sops #####
install_commands+="install_sops "
function install_sops() {
  log_info "Install sops..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS detected, skipping sops installation."
    return
  fi

  # anything else
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/getsops/sops/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v sops &>/dev/null && sops --version | awk '/^sops /{print $2}' || echo "0.0.0")
  local download_url="https://github.com/getsops/sops/releases/download/$remote_version/sops-${remote_version}.${OS}.${ARCH}"
  local bin_name="sops"
  if [[ "$remote_version" == "v${local_version}" ]]; then
    log_info "  sops is up to date..."
    return
  fi
  log_info "  installing sops..."
  download_bin_local_bin $download_url $bin_name
  log_info "  sops installed..."
}
