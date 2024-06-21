# ##### Install cilium #####
install_commands+="install_cilium "
function install_cilium() {
  log_info "Install cilium..."
  local cilium_version=$($CURL_CMD https://api.github.com/repos/cilium/cilium-cli/releases/latest | jq -r '.tag_name')
  local cilium_local_version=$(command -v cilium &>/dev/null && cilium version --client | grep cli | awk '{print $2}' || echo "v0.0.0")
  local cilium_url="https://github.com/cilium/cilium-cli/releases/download/$cilium_version/cilium-$OS-$ARCH.tar.gz"
  if [[ "$cilium_version" == "$cilium_local_version" ]]; then
    log_info "  cilium is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/cilium.tar.gz
    rm -rf /tmp/cilium
    rm -f $LOCAL_BIN/cilium
    $CURL_CMD -o /tmp/cilium.tar.gz $cilium_url
    mkdir -p /tmp/cilium
    tar -C /tmp/cilium -xzf /tmp/cilium.tar.gz
    mv /tmp/cilium/cilium $LOCAL_BIN
    chmod 750 $LOCAL_BIN/cilium
  fi
}
