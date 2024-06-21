# ##### Install golang #####
install_commands+="install_golang "
function install_golang() {
  log_info "Install golang..."
  local golang_version=$($CURL_CMD 'https://go.dev/VERSION?m=text' | head -1)
  local golang_local_version=$(command -v go &>/dev/null && go version | awk '{print $3}' || echo "0.0.0")
  local golang_url="https://go.dev/dl/$golang_version.$OS-$ARCH.tar.gz"
  if [[ "$golang_version" == "$golang_local_version" ]]; then
    log_info "  golang is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/golang.tar.gz
    sudo rm -rf /usr/local/go
    $CURL_CMD -o /tmp/golang.tar.gz $golang_url
    sudo tar -C /usr/local -xzf /tmp/golang.tar.gz
  fi
}
