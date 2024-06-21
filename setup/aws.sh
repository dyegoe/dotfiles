# ##### Install awscli2 #####
install_commands+="install_awscli "
function install_awscli() {
  log_info "Install awscli2..."
  if [[ "$OS" == "darwin" ]]; then
    rm -f /tmp/AWSCLIV2.pkg
    $CURL_CMD -o /tmp/AWSCLIV2.pkg https://awscli.amazonaws.com/AWSCLIV2.pkg
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
    return
  fi
  rm -f /tmp/awscliv2.zip
  rm -rf /tmp/aws/
  $CURL_CMD -o /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCHM}.zip
  $UNZIP_CMD /tmp /tmp/awscliv2.zip
  sudo /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
}
