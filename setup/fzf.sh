# ##### Install fzf #####
install_commands+="install_fzf "
function install_fzf() {
  log_info "Install fzf..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS installs fzf via brew..."
    return
  fi

  # anything else
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/junegunn/fzf/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v fzf &>/dev/null && fzf --version | awk '{print $1}' || echo "0.0.0")
  local download_url="https://github.com/junegunn/fzf/releases/download/$remote_version/fzf-$remote_version-${OS}_${ARCH}.tar.gz"
  local bin_name="fzf"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  $bin_name is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
}
