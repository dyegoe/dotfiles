# ##### Install vault #####
install_commands+=(install_vault)
function install_vault() {
  log_info "Install vault..."
  local remote_version=$(gh_latest_tag hashicorp/vault)
  local local_version=$(command -v vault &>/dev/null && vault version | awk '{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://releases.hashicorp.com/vault/${remote_version#v}/vault_${remote_version#v}_${OS}_${ARCH}.zip" vault zip
}
