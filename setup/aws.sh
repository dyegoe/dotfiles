# ##### Install awscli2 #####
install_commands+="install_awscli "
function install_awscli() {
  log_info "Install awscli2..."
  local temp_dir=$(mktemp -d)
  if [[ "$OS" == "darwin" ]]; then
    log_info "  installing..."
    $CURL_CMD -o $temp_dir/AWSCLIV2.pkg https://awscli.amazonaws.com/AWSCLIV2.pkg
    sudo installer -pkg $temp_dir/AWSCLIV2.pkg -target /
    log_info "  installed..."
  fi
  if [[ "$OS" == "linux" ]]; then
    log_info "  installing..."
    $CURL_CMD -o $temp_dir/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCHM}.zip
    $UNZIP_CMD $temp_dir $temp_dir/awscliv2.zip
    sudo $temp_dir/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    log_info "  installed..."
  fi

  log_info "Install aws session manager plugin..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  installing..."
    $CURL_CMD -o $temp_dir/session-manager-plugin.pkg https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg
    sudo installer -pkg $temp_dir/session-manager-plugin.pkg -target /
    sudo ln -sf /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin
    log_info "  installed..."
  fi
  if [[ "$OS" == "linux" && "$DISTRO" == "fedora" ]]; then
    log_info "  installing..."
    sudo dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_${ARCHS}/session-manager-plugin.rpm
    log_info "  installed..."
  fi
  rm -rf $temp_dir
}
