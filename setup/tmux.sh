# ##### Setup tmux #####
setup_commands+=(setup_tmux)
function setup_tmux() {
  log_info "Setup Tmux..."
  link_config "$SCRIPT_DIR/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf" "tmux.conf"
  log_info "  setup done..."
}

# ##### Install Tmux plugins #####
install_commands+=(install_tmux_plugins)
function install_tmux_plugins() {
  log_info "Install Tmux plugins..."
  local tmux_plugins_tpm_dir="$XDG_CONFIG_HOME/tmux/plugins/tpm"
  local already_installed=0
  [[ -d "$tmux_plugins_tpm_dir" ]] && already_installed=1

  clone_or_pull https://github.com/tmux-plugins/tpm.git "$tmux_plugins_tpm_dir"

  if ((!already_installed)); then
    log_info "  tmux plugins..."
    run "$tmux_plugins_tpm_dir/bin/install_plugins"
    log_info "  done..."
  fi
}
