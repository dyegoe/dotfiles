# ##### Git plugin dirs #####
# clone_or_pull <url> <dir>
#
# Clones <url> into <dir> if it doesn't exist yet, otherwise updates it in
# place via `git -C <dir> pull` (never changes the caller's cwd).
function clone_or_pull() {
  local url=$1
  local dir=$2

  if [[ -d "$dir" ]]; then
    log_sub "updating $(basename "$dir")..."
    run git -C "$dir" pull
  else
    log_sub "installing $(basename "$dir")..."
    run mkdir -p "$(dirname "$dir")"
    run git clone "$url" "$dir"
  fi
  log_sub "done..."
}
