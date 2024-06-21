# ##### Install awss #####
install_commands+="install_awss "
function install_awss() {
  log_info "Install awss..."
  local awss_version=$($CURL_CMD https://api.github.com/repos/dyegoe/awss/releases/latest | jq -r '.tag_name')
  local awss_local_version=v$(command -v awss &>/dev/null && awss --version | awk '{print $3}' || echo "0.0.0")
  local awss_url="https://github.com/dyegoe/awss/releases/download/$awss_version/awss-$awss_version-$OS-$ARCH.tar.gz"
  if [[ "$awss_version" == "$awss_local_version" ]]; then
    log_info "  awss is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/awss.tar.gz
    $CURL_CMD -o /tmp/awss.tar.gz $awss_url
    rm -f $LOCAL_BIN/awss
    tar -C $LOCAL_BIN -xzf /tmp/awss.tar.gz
    chmod 750 $LOCAL_BIN/awss
  fi
}
