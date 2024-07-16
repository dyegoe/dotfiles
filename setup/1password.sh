# ##### Setup 1Password #####
setup_commands+="setup_1password "
function setup_1password() {
  log_info "Setup 1Password..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS doesn't need further 1Password setup... 1Password setup skipped..."
    return
  fi
  local autostart_path=$XDG_CONFIG_HOME/autostart
  mkdir -p $autostart_path
  cp $SCRIPT_DIR/1password/1password.desktop $autostart_path/.
  log_info "  setup done..."
}
