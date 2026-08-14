# ##### Setup 1Password #####
setup_commands+=(setup_1password)
function setup_1password() {
  log_info "Setup 1Password..."
  skip_on_darwin "$OS doesn't need further 1Password setup... 1Password setup skipped..." && return

  local autostart_path="$XDG_CONFIG_HOME/autostart"
  run mkdir -p "$autostart_path"
  run cp "$SCRIPT_DIR/1password/1password.desktop" "$autostart_path/."
  log_info "  setup done..."
}
