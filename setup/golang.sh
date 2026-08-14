# ##### Install golang #####
install_commands+=(install_golang)
function install_golang() {
  log_info "Install golang..."
  local remote_version=$("${CURL_CMD[@]}" 'https://go.dev/VERSION?m=text' | head -1)
  local local_version=$(command -v go &>/dev/null && go version | awk '{print $3}' || echo "0.0.0")

  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi

  log_info "  installing..."
  (
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    run "${CURL_CMD[@]}" -o "$tmp/download.tar.gz" "https://go.dev/dl/$remote_version.$OS-$ARCH.tar.gz"
    run mkdir -p "$tmp/extracted"
    run tar -C "$tmp/extracted" -xzf "$tmp/download.tar.gz"

    # Verify the new toolchain works, and stage the swap so a failed
    # download/extract never leaves the machine without a working `go`.
    if ((DRY_RUN)); then
      log_dry "verify $tmp/extracted/go/bin/go, then swap into /usr/local/go"
    else
      "$tmp/extracted/go/bin/go" version >/dev/null

      sudo rm -rf /usr/local/go.new
      sudo mv "$tmp/extracted/go" /usr/local/go.new
      sudo rm -rf /usr/local/go.old
      [[ -d /usr/local/go ]] && sudo mv /usr/local/go /usr/local/go.old
      sudo mv /usr/local/go.new /usr/local/go
      sudo rm -rf /usr/local/go.old
    fi
  )
  log_info "  installed..."
}
