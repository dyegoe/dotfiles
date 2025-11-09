# ##### Install cilium #####
install_commands+="install_cilium "
function install_cilium() {
  log_info "Install cilium..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/cilium/cilium-cli/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v cilium &>/dev/null && cilium version --client | grep cli | awk '{print $2}' || echo "v0.0.0")
  local download_url="https://github.com/cilium/cilium-cli/releases/download/$remote_version/cilium-$OS-$ARCH.tar.gz"
  local bin_name="cilium"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
  log_info "  installed..."
}

# ##### Install cilium hubble #####
install_commands+="install_cilium_hubble "
function install_cilium_hubble() {
  log_info "Install cilium hubble..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/cilium/hubble/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v hubble &>/dev/null && hubble version | grep Client | awk '{print $3}' || echo "v0.0.0")
  local download_url="https://github.com/cilium/hubble/releases/download/$remote_version/hubble-$OS-$ARCH.tar.gz"
  local bin_name="hubble"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
  log_info "  installed..."
}