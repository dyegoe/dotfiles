# ##### Setup talosctl #####
setup_commands+="setup_talosctl "
function setup_talosctl() {
  if command -v talosctl &>/dev/null; then
    local talosctl_completion_file="$ZDOTDIR/functions/_talosctl"
    log_info "Setup talosctl..."
    mkdir -p $ZDOTDIR/functions
    talosctl completion zsh >$talosctl_completion_file
    chmod 755 $talosctl_completion_file
    log_info "  setup done..."
  fi
}

# ##### Install talosctl #####
install_commands+="install_talosctl "
function install_talosctl() {
  log_info "Install talosctl..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS detected, skipping talosctl installation."
    return
  fi

  # anything else
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/siderolabs/talos/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v talosctl &>/dev/null && talosctl version --client --short | awk '/^Talos /{print $2}' || echo "v0.0.0")
  local download_url="https://github.com/siderolabs/talos/releases/download/$remote_version/talosctl-${OS}-${ARCH}"
  local bin_name="talosctl"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  talosctl is up to date..."
    return
  fi
  log_info "  installing talosctl..."
  download_bin_local_bin $download_url $bin_name
  log_info "  talosctl installed..."
}

# ##### Setup talhelper #####
setup_commands+="setup_talhelper "
function setup_talhelper() {
  if command -v talhelper &>/dev/null; then
    local talhelper_completion_file="$ZDOTDIR/functions/_talhelper"
    log_info "Setup talhelper..."
    mkdir -p $ZDOTDIR/functions
    talhelper completion zsh >$talhelper_completion_file
    chmod 755 $talhelper_completion_file
    log_info "  setup done..."
  fi
}

# ##### Install talhelper #####
install_commands+="install_talhelper "
function install_talhelper() {
  log_info "Install talhelper..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS detected, skipping talhelper installation."
    return
  fi

  # anything else
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/budimanjojo/talhelper/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v talhelper &>/dev/null && talhelper --version | awk '{print $3}' || echo "0.0.0")
  local download_url="https://github.com/budimanjojo/talhelper/releases/download/$remote_version/talhelper_${OS}_${ARCH}.tar.gz"
  local bin_name="talhelper"
  if [[ "$remote_version" == "v${local_version}" ]]; then
    log_info "  talhelper is up to date..."
    return
  fi
  log_info "  installing talhelper..."
  download_tar_gz_local_bin $download_url $bin_name
  log_info "  talhelper installed..."
}
