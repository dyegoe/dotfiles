# ##### Zsh completions #####
# gen_zsh_completion <command> [completion_name] [completion_args...]
#
# Generates $ZDOTDIR/functions/_<completion_name> by running
# `<command> <completion_args...>` (default: `completion zsh`, the cobra
# convention). Pass completion_args for tools that differ, e.g. glab needs
# `completion -s zsh`. No-ops silently if <command> isn't installed.
function gen_zsh_completion() {
  local cmd=$1
  local completion_name=${2:-$cmd}
  local args=(completion zsh)
  if (($# > 2)); then
    args=("${@:3}")
  fi

  command -v "$cmd" &>/dev/null || return 0

  log_info "Setup $cmd completion..."
  run mkdir -p "$ZDOTDIR/functions"
  run_write "$ZDOTDIR/functions/_$completion_name" "$cmd" "${args[@]}"
  run chmod 755 "$ZDOTDIR/functions/_$completion_name"
  log_sub "setup done..."
}
