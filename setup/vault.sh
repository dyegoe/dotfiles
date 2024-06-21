# ##### Install vault #####
install_commands+="install_vault "
function install_vault() {
  log_info "Install vault..."
  local vault_version=$($CURL_CMD https://api.github.com/repos/hashicorp/vault/releases/latest | jq -r '.tag_name')
  local vault_local_version=$(command -v vault &>/dev/null && vault version | awk '{print $2}' || echo "v0.0.0")
  local vault_url="https://releases.hashicorp.com/vault/${vault_version:1}/vault_${vault_version:1}_${OS}_${ARCH}.zip"
  if [[ "$vault_version" == "$vault_local_version" ]]; then
    log_info "  vault is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/vault.zip
    $CURL_CMD -o /tmp/vault.zip $vault_url
    rm -f $LOCAL_BIN/vault
    $UNZIP_CMD $LOCAL_BIN /tmp/vault.zip
    chmod 750 $LOCAL_BIN/vault
  fi
}
