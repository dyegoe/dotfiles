# ##### Install vault #####
install_commands+="install_vault "
function install_vault() {
  log_info "Install vault..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/hashicorp/vault/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v vault &>/dev/null && vault version | awk '{print $2}' || echo "v0.0.0")
  local download_url="https://releases.hashicorp.com/vault/${remote_version:1}/vault_${remote_version:1}_${OS}_${ARCH}.zip"
  local bin_name="vault"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  download_zip_local_bin $download_url $bin_name
  log_info "  installed..."
}
