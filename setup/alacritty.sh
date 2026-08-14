# ##### Setup Alacritty #####
setup_commands+=(setup_alacritty)
function setup_alacritty() {
  log_info "Setup Alacritty..."
  link_config "$SCRIPT_DIR/alacritty/alacritty-${OS}.toml" "$XDG_CONFIG_HOME/alacritty/alacritty.toml" "alacritty.toml"
  log_info "  setup done..."
}
