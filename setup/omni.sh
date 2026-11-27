# ##### Setup omnictl #####
setup_commands+=(setup_omnictl)
function setup_omnictl() {
  gen_zsh_completion omnictl
}

# ##### Install omnictl #####
install_commands+=(install_omnictl)
function install_omnictl() {
  log_info "Install omnictl..."
  skip_on_darwin "$OS detected, skipping omnictl installation." && return

  local remote_version=$(gh_latest_tag siderolabs/omni)
  local local_version=$(command -v omnictl &>/dev/null && omnictl --version | awk '{print $3}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_sub "is up to date..."
    return
  fi
  install_release "https://github.com/siderolabs/omni/releases/download/$remote_version/omnictl-${OS}-${ARCH}" omnictl bin
}
