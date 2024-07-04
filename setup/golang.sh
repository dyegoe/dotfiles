# ##### Install golang #####
install_commands+="install_golang "
function install_golang() {
  log_info "Install golang..."
  local remote_version=$($CURL_CMD 'https://go.dev/VERSION?m=text' | head -1)
  local local_version=$(command -v go &>/dev/null && go version | awk '{print $3}' || echo "0.0.0")
  local download_url="https://go.dev/dl/$remote_version.$OS-$ARCH.tar.gz"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  golang is up to date..."
  else
    log_info "  installing..."
    local temp_dir=$(mktemp -d)
    mkdir -p $temp_dir
    $CURL_CMD -o $temp_dir/download.tar.gz $download_url
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf $temp_dir/download.tar.gz
    rm -rf $temp_dir
  fi
}
