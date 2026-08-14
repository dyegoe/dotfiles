# ##### Logging #####
function log_info() {
  printf '\e[33m\e[1m[INFO]\e[0m\e[34m %s\e[0m\n' "$*"
}

function log_error() {
  printf '\e[31m\e[1m[ERROR]\e[0m\e[33m %s\e[0m\n' "$*"
}

function log_warn() {
  printf '\e[33m\e[1m[WARN]\e[0m\e[33m %s\e[0m\n' "$*"
}

function log_dry() {
  printf '\e[36m\e[1m[DRY]\e[0m %s\n' "$*"
}
