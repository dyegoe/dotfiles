# ##### Setup herdr #####
setup_commands+=(setup_herdr)
function setup_herdr() {
  log_info "Setup herdr..."
  skip_on_darwin "$OS detected, herdr is Linux-only for now, skipping..." && return

  link_config "$SCRIPT_DIR/herdr/config.toml" "$XDG_CONFIG_HOME/herdr/config.toml" "herdr config.toml"
  log_sub "setup done..."

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
    log_sub "is up to date..."
    return
  fi
  install_release "https://github.com/herdrdev/herdr/releases/download/$remote_version/herdr-${OS}-${ARCHM}" herdr bin
}

# ##### Install herdr plugins #####
# Each entry is "<owner/repo> <plugin_id>"; the plugin_id is what `herdr plugin list` shows.
herdr_plugins=(
  "0bmario/herdr-pane-id-labels pane-id-labels"
)
install_commands+=(install_herdr_plugins)
function install_herdr_plugins() {
  log_info "Install herdr plugins..."
  skip_on_darwin "$OS detected, herdr is Linux-only for now, skipping..." && return

  if ! command -v herdr &>/dev/null; then
    log_warn "  herdr is not installed, skipping..."
    return
  fi
  # Plugins are managed through the running server's socket API.
  if ! herdr status server 2>/dev/null | grep -q '^status: running'; then
    log_warn "  herdr server is not running, start herdr and rerun: ./setup.sh install_herdr_plugins"
    return
  fi

  local entry repo plugin_id
  for entry in "${herdr_plugins[@]}"; do
    read -r repo plugin_id <<<"$entry"
    if herdr plugin list --plugin "$plugin_id" --json | grep -q "\"plugin_id\":\"$plugin_id\""; then
      log_sub "$plugin_id is installed, updating..."
      run herdr plugin update --yes "$plugin_id"
    else
      log_sub "installing $plugin_id from $repo..."
      run herdr plugin install --yes "$repo"
    fi
  done

  # Label the panes that already exist; the plugin's pane.created/pane.moved hooks handle new ones.
  run herdr plugin action invoke pane-id-labels.relabel ||
    log_warn "  pane-id-labels.relabel failed, run it manually: herdr plugin action invoke pane-id-labels.relabel"
}
