# ##### Setup talosctl #####
setup_commands+=(setup_talosctl)
function setup_talosctl() {
  gen_zsh_completion talosctl
}

# ##### Install talosctl #####
install_commands+=(install_talosctl)
function install_talosctl() {
  log_info "Install talosctl..."
  skip_on_darwin "$OS detected, skipping talosctl installation." && return

  local remote_version=$(gh_latest_tag siderolabs/talos)
  local local_version=$(command -v talosctl &>/dev/null && talosctl version --client --short | awk '/^Talos /{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/siderolabs/talos/releases/download/$remote_version/talosctl-${OS}-${ARCH}" talosctl bin
}

# ##### Install topf #####
install_commands+=(install_topf)
function install_topf() {
  log_info "Install topf..."

  local remote_version=$(gh_latest_tag postfinance/topf)
  local local_version=$(command -v topf &>/dev/null && topf --version | awk '{print $3}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/postfinance/topf/releases/download/$remote_version/topf_${OS}_${ARCH}.tar.gz" topf tar.gz
}
