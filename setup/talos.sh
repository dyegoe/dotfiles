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

# ##### Setup talhelper #####
setup_commands+=(setup_talhelper)
function setup_talhelper() {
  gen_zsh_completion talhelper
}

# ##### Install talhelper #####
install_commands+=(install_talhelper)
function install_talhelper() {
  log_info "Install talhelper..."
  skip_on_darwin "$OS detected, skipping talhelper installation." && return

  local remote_version=$(gh_latest_tag budimanjojo/talhelper)
  local local_version=$(command -v talhelper &>/dev/null && talhelper --version | awk '{print $3}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/budimanjojo/talhelper/releases/download/$remote_version/talhelper_${OS}_${ARCH}.tar.gz" talhelper tar.gz
}
