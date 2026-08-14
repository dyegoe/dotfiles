# ##### Setup oh-my-posh #####
setup_commands+=(setup_oh_my_posh)
function setup_oh_my_posh() {
  log_info "Setup oh-my-posh..."
  local template
  for template in default.json my.json; do
    link_config "$SCRIPT_DIR/oh-my-posh/$template" "$XDG_CONFIG_HOME/oh-my-posh/$template" "$template"
  done
  log_info "  setup done..."
}

# ##### Install oh-my-posh #####
install_commands+=(install_oh_my_posh)
function install_oh_my_posh() {
  log_info "Install oh-my-posh..."
  local remote_version=$(gh_latest_tag JanDeDobbeleer/oh-my-posh)
  local local_version=v$(command -v oh-my-posh &>/dev/null && oh-my-posh version || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/$remote_version/posh-$OS-$ARCH" oh-my-posh bin
}
