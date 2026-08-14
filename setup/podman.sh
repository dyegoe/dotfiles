# ##### Setup podman docker #####
setup_commands+=(setup_podman_docker)
function setup_podman_docker() {
  log_info "Setup Podman Docker..."
  skip_on_darwin "$OS doesn't need further Podman setup... Podman setup skipped..." && return
  run sudo mkdir -p /etc/containers
  run sudo touch /etc/containers/nodocker
  log_info "  setup done..."
}
