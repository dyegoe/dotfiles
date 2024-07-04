# ##### Install awss #####
install_commands+="install_awss "
function install_awss() {
  log_info "Install awss..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/dyegoe/awss/releases/latest) | jq -r '.tag_name')
  local local_version=v$(command -v awss &>/dev/null && awss --version | awk '{print $3}' || echo "0.0.0")
  local download_url="https://github.com/dyegoe/awss/releases/download/$remote_version/awss-$remote_version-$OS-$ARCH.tar.gz"
  local bin_name="awss"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  $bin_name is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
}
