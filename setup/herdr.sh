# ##### Setup herdr #####
setup_commands+=(setup_herdr)
function setup_herdr() {
  log_info "Setup herdr..."
  skip_on_darwin "$OS detected, herdr is Linux-only for now, skipping..." && return

  link_config "$SCRIPT_DIR/herdr/config.toml" "$XDG_CONFIG_HOME/herdr/config.toml" "herdr config.toml"
  log_info "  setup done..."

  gen_zsh_completion herdr
}

# ##### Install herdr #####
install_commands+=(install_herdr)
function install_herdr() {
  log_info "Install herdr..."
  skip_on_darwin "$OS detected, herdr is Linux-only for now, skipping..." && return

  local remote_version=$(gh_latest_tag herdrdev/herdr)
  local local_version=$(command -v herdr &>/dev/null && herdr --version | awk '{print $NF}' || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/herdrdev/herdr/releases/download/$remote_version/herdr-${OS}-${ARCHM}" herdr bin
}
