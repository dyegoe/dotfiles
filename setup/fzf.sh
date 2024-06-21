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
  local fzf_version=$($CURL_CMD https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r '.tag_name')
  local fzf_local_version=$(command -v fzf &>/dev/null && fzf --version | awk '{print $1}' || echo "0.0.0")
  local fzf_url="https://github.com/junegunn/fzf/releases/download/$fzf_version/fzf-$fzf_version-${OS}_${ARCH}.tar.gz"
  if [[ "$fzf_version" == "$fzf_local_version" ]]; then
    log_info "  fzf is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/fzf.tar.gz
    $CURL_CMD -o /tmp/fzf.tar.gz $fzf_url
    rm -f $LOCAL_BIN/fzf
    tar -C $LOCAL_BIN -xzf /tmp/fzf.tar.gz
    chmod 750 $LOCAL_BIN/fzf
  fi
}
