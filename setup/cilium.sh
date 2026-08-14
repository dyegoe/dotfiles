# ##### Setup cilium #####
setup_commands+=(setup_cilium)
function setup_cilium() {
  gen_zsh_completion cilium
}

# ##### Install cilium #####
install_commands+=(install_cilium)
function install_cilium() {
  log_info "Install cilium..."
  local remote_version=$(gh_latest_tag cilium/cilium-cli)
  local local_version=$(command -v cilium &>/dev/null && cilium version --client | grep cli | awk '{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/cilium/cilium-cli/releases/download/$remote_version/cilium-$OS-$ARCH.tar.gz" cilium tar.gz
}

# ##### Setup hubble #####
setup_commands+=(setup_hubble)
function setup_hubble() {
  gen_zsh_completion hubble
}

# ##### Install cilium hubble #####
install_commands+=(install_cilium_hubble)
function install_cilium_hubble() {
  log_info "Install hubble..."
  local remote_version=$(gh_latest_tag cilium/hubble)
  local local_version=$(command -v hubble &>/dev/null && hubble version | grep hubble | awk '{print $2}' | cut -d@ -f1 || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/cilium/hubble/releases/download/$remote_version/hubble-$OS-$ARCH.tar.gz" hubble tar.gz
}
