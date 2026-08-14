# ##### GitHub releases #####

# _curl_github <url> [curl args...]
function _curl_github() {
  local headers=(-H "X-GitHub-Api-Version: 2022-11-28")
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    headers+=(-H "Authorization: Bearer $GITHUB_TOKEN")
  fi
  "${CURL_CMD[@]}" "${headers[@]}" "$@"
}

# gh_latest_tag <owner/repo>
function gh_latest_tag() {
  _curl_github "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name'
}

# gh_asset_url <owner/repo> <asset_name>
function gh_asset_url() {
  _curl_github "https://api.github.com/repos/$1/releases/latest" |
    jq -r --arg name "$2" '.assets[] | select(.name==$name) | .browser_download_url'
}

# version_is_current <remote_tag> <local_version>
# Compares versions after stripping a leading 'v' from both sides, so callers
# don't each need their own v-prefix convention.
function version_is_current() {
  [[ "${1#v}" == "${2#v}" ]]
}

# install_release <download_url> <bin_name> <tar.gz|zip|bin> [bin_source]
#
# Downloads a single binary (optionally inside an archive at <bin_source>,
# default <bin_name>) into $LOCAL_BIN. Extraction happens in a temp dir that
# is always cleaned up; the final placement is a single atomic `mv` (no
# preceding `rm`, so a bad bin_source never deletes a working install).
function install_release() {
  local url=$1
  local bin_name=$2
  local kind=$3
  local bin_source=${4:-$bin_name}

  log_info "  installing..."
  (
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    case "$kind" in
    tar.gz)
      run "${CURL_CMD[@]}" -o "$tmp/download.tar.gz" "$url"
      run tar -C "$tmp" -xzf "$tmp/download.tar.gz"
      ;;
    zip)
      run "${CURL_CMD[@]}" -o "$tmp/download.zip" "$url"
      run "${UNZIP_CMD[@]}" "$tmp" "$tmp/download.zip"
      ;;
    bin)
      bin_source=$bin_name
      run "${CURL_CMD[@]}" -o "$tmp/$bin_name" "$url"
      ;;
    *)
      log_error "  install_release: unknown kind '$kind'"
      exit 1
      ;;
    esac

    run mkdir -p "$LOCAL_BIN"
    run chmod 750 "$tmp/$bin_source"
    run mv -f "$tmp/$bin_source" "$LOCAL_BIN/$bin_name"
  )
  log_info "  installed..."
}

# install_release_tree <download_url> <tar.gz|zip>
#
# For archives that contain multiple executables at unpredictable paths
# (tenv, glab): moves every executable file found in the extracted tree into
# $LOCAL_BIN.
function install_release_tree() {
  local url=$1
  local kind=$2

  log_info "  installing..."
  (
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    case "$kind" in
    tar.gz)
      run "${CURL_CMD[@]}" -o "$tmp/download.tar.gz" "$url"
      run tar -C "$tmp" -xzf "$tmp/download.tar.gz"
      ;;
    zip)
      run "${CURL_CMD[@]}" -o "$tmp/download.zip" "$url"
      run "${UNZIP_CMD[@]}" "$tmp" "$tmp/download.zip"
      ;;
    *)
      log_error "  install_release_tree: unknown kind '$kind'"
      exit 1
      ;;
    esac

    run mkdir -p "$LOCAL_BIN"

    if ((DRY_RUN)); then
      log_dry "move every executable under $tmp into $LOCAL_BIN"
    else
      local perm_test=(-perm /u=x,g=x,o=x)
      [[ "$OS" == "darwin" ]] && perm_test=(-perm +0111)
      local f name
      while IFS= read -r -d '' f; do
        name=$(basename "$f")
        chmod 750 "$f"
        mv -f "$f" "$LOCAL_BIN/$name"
      done < <(find "$tmp" -type f "${perm_test[@]}" -print0)
    fi
  )
  log_info "  installed..."
}
