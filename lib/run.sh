# ##### Dry-run core #####
# All mutating commands (ln, mv, rm, mkdir, curl -o, tar, git clone, sudo, dnf,
# brew, dconf, ...) must go through run() so --dry-run can preview them without
# touching the filesystem. Read-only probes (version checks, command -v) should
# be called directly so dry-run comparisons stay accurate.
: "${DRY_RUN:=0}"

# run <command> [args...]
function run() {
  if ((DRY_RUN)); then
    log_dry "$*"
    return 0
  fi
  "$@"
}

# run_write <target_file> <command> [args...]
# Runs <command...>, redirecting its stdout to <target_file> atomically
# (write to a temp file, then rename). Under --dry-run, only logs the intent.
function run_write() {
  local target=$1
  shift
  if ((DRY_RUN)); then
    log_dry "$* > $target"
    return 0
  fi
  local tmp
  tmp=$(mktemp)
  "$@" >"$tmp"
  mv -f "$tmp" "$target"
}

# skip_on_darwin <log_message>
# Returns 0 (and logs) when OS is darwin, so callers can write:
#   skip_on_darwin "reason..." && return
function skip_on_darwin() {
  [[ "$OS" == "darwin" ]] || return 1
  log_info "  $1"
  return 0
}
