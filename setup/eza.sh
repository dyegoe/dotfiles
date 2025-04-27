# ##### Install eza #####
install_commands+="install_eza "
function install_eza() {
  log_info "Install eza..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS installs eza via brew..."
    return
  fi

  # anything else
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/eza-community/eza/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v eza &>/dev/null && eza --version | grep -oP '^v[0-9]+\.[0-9]+\.[0-9]+' || echo "v0.0.0")
  local download_url="https://github.com/eza-community/eza/releases/download/$remote_version/eza_${ARCHM}-unknown-${OS}-gnu.tar.gz"

  local bin_name="eza"
  if [[ "${remote_version:1}" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
  log_info "  installed..."
}
