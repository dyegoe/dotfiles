# ##### Setup podman docker #####
setup_commands+="setup_podman_docker "
function setup_podman_docker() {
  log_info "Setup Podman Docker..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS doesn't need further Podman setup... Podman setup skipped..."
    return
  fi
  sudo touch /etc/containers/nodocker
}
