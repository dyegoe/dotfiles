# ##### Setup ssh #####
setup_commands+=(setup_ssh)
function setup_ssh() {
  log_info "Setup SSH..."
  local ssh_dir="$HOME/.ssh"

  if [[ ! -d "$ssh_dir" ]]; then
    log_info "  Creating .ssh directory..."
    run mkdir -p "$ssh_dir"
    run chmod 700 "$ssh_dir"
  fi

  link_config "$SCRIPT_DIR/ssh/config.$OS" "$ssh_dir/config" "ssh config"
  log_info "  setup done..."
}
