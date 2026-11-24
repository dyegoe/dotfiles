# ##### Logging #####
# Same style as dotfiles-private/sync.sh: bold colored prefix, plain message.
# log_info opens a step; log_sub and log_dry are indented under it.
# Warnings and errors go to stderr so they stay visible when stdout is redirected.
function log_info() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

function log_sub() {
  printf '  \033[1;34m•\033[0m %s\n' "$*"
}

function log_warn() {
  printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2
}

function log_error() {
  printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2
}

function log_dry() {
  printf '  \033[1;36mDRY:\033[0m %s\n' "$*"
}
