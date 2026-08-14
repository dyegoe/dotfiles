# ##### Install awscli2 #####
install_commands+=(install_awscli)
function install_awscli() {
  log_info "Install awscli2..."
  (
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    if [[ "$OS" == "darwin" ]]; then
      log_info "  installing..."
      run "${CURL_CMD[@]}" -o "$tmp/AWSCLIV2.pkg" https://awscli.amazonaws.com/AWSCLIV2.pkg
      run sudo installer -pkg "$tmp/AWSCLIV2.pkg" -target /
      log_info "  installed..."
    fi
    if [[ "$OS" == "linux" ]]; then
      log_info "  installing..."
      run "${CURL_CMD[@]}" -o "$tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCHM}.zip"
      run "${UNZIP_CMD[@]}" "$tmp" "$tmp/awscliv2.zip"
      run sudo "$tmp/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
      log_info "  installed..."
    fi

    log_info "Install aws session manager plugin..."
    if [[ "$OS" == "darwin" ]]; then
      log_info "  installing..."
      run "${CURL_CMD[@]}" -o "$tmp/session-manager-plugin.pkg" https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg
      run sudo installer -pkg "$tmp/session-manager-plugin.pkg" -target /
      run sudo ln -sf /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin
      log_info "  installed..."
    fi
    if [[ "$OS" == "linux" && "$DISTRO" == "fedora" ]]; then
      log_info "  installing..."
      run sudo dnf install -y "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_${ARCHS}/session-manager-plugin.rpm"
      log_info "  installed..."
    fi
  )
}
