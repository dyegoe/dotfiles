# ##### Install awss #####
install_commands+=(install_awss)
function install_awss() {
  log_info "Install awss..."
  local remote_version=$(gh_latest_tag dyegoe/awss)
  local local_version=$(command -v awss &>/dev/null && awss --version | awk '{print $3}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/dyegoe/awss/releases/download/$remote_version/awss-$remote_version-$OS-$ARCH.tar.gz" awss tar.gz
}
