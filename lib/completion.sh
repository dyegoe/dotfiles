# ##### Zsh completions #####
# gen_zsh_completion <command> [completion_name]
#
# Generates $ZDOTDIR/functions/_<completion_name> by running
# `<command> completion zsh`. No-ops silently if <command> isn't installed.
function gen_zsh_completion() {
  local cmd=$1
  local completion_name=${2:-$cmd}

  command -v "$cmd" &>/dev/null || return 0

  log_info "Setup $cmd completion..."
  run mkdir -p "$ZDOTDIR/functions"
  run_write "$ZDOTDIR/functions/_$completion_name" "$cmd" completion zsh
  run chmod 755 "$ZDOTDIR/functions/_$completion_name"
  log_info "  setup done..."
}
