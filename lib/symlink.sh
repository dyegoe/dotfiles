# ##### Config symlinks #####
# link_config <origin> <target> [display_name]
#
# Idempotently symlinks <target> -> <origin>:
#   - a real file at <target> is copied aside as a timestamped backup
#   - the symlink is created via a temp-link + atomic rename, so <target>
#     is never briefly missing or half-written
#   - already-correct symlinks are left untouched (and not re-logged)
function link_config() {
  local origin=$1
  local target=$2
  local display_name=${3:-$(basename "$target")}

  run mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$origin" ]]; then
    log_info "  $display_name already linked..."
    return 0
  fi

  if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
    log_info "  $display_name already exists. It is a file, moving it to backup..."
    run cp -p "$target" "${target}.$(date +%Y%m%d%H%M%S).backup"
  fi

  log_info "  creating the symlink for $display_name..."
  local tmp_link="${target}.tmp.$$"
  run ln -sf "$origin" "$tmp_link"
  run mv -T "$tmp_link" "$target"
}
