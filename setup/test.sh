# ##### Show detected environment (debugging) #####
# Named show_env, not `test` -- a function called `test` shadows the shell
# builtin for every script sourced after it. `./setup.sh test` still works
# as an alias (see main() in setup.sh).
function show_env() {
  log_info "OS: $OS"
  log_info "OSS: $OSS"
  log_info "DISTRO: $DISTRO"
  log_info "ARCHM: $ARCHM"
  log_info "ARCH: $ARCH"
  log_info "ARCHS: $ARCHS"
  log_info "HOME: $HOME"
  log_info "XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
  log_info "XDG_CACHE_HOME: $XDG_CACHE_HOME"
  log_info "XDG_DATA_HOME: $XDG_DATA_HOME"
  log_info "XDG_STATE_HOME: $XDG_STATE_HOME"
  log_info "SCRIPT_DIR: $SCRIPT_DIR"
}
