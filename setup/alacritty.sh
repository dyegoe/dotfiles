# ##### Setup Alacritty #####
setup_commands+=(setup_alacritty)
function setup_alacritty() {
  log_info "Setup Alacritty..."
  link_config "$SCRIPT_DIR/alacritty/alacritty-${OS}.toml" "$XDG_CONFIG_HOME/alacritty/alacritty.toml" "alacritty.toml"
  log_info "  setup done..."
}

install_commands+=(install_alacritty)
function install_alacritty() {
  [[ "$OS" == "darwin" ]] || return 0

  log_info "Install Alacritty..."
  local app=/Applications/Alacritty.app
  local remote_version=$(gh_latest_tag alacritty/alacritty)
  local local_version=$("$app/Contents/MacOS/alacritty" --version 2>/dev/null | awk '{print $2}')

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
  else
    local download_url=$(gh_asset_url alacritty/alacritty "Alacritty-$remote_version.dmg")
    if [[ -z "$download_url" ]]; then
      log_error "  Alacritty DMG not found for $remote_version"
      return 1
    fi

    (
      local tmp mounted=0
      if ((DRY_RUN)); then
        tmp="${TMPDIR:-/tmp}/alacritty-dry-run"
      else
        tmp=$(mktemp -d)
      fi
      trap 'if ((mounted)); then run hdiutil detach "$tmp/mount"; fi; run rm -rf "$tmp"' EXIT

      run "${CURL_CMD[@]}" -o "$tmp/Alacritty.dmg" "$download_url"
      run hdiutil attach "$tmp/Alacritty.dmg" -nobrowse -readonly -mountpoint "$tmp/mount"
      mounted=1
      run sudo ditto "$tmp/mount/Alacritty.app" "$app"
    )
    log_info "  installed..."
  fi

  link_config "$app/Contents/MacOS/alacritty" "$LOCAL_BIN/alacritty" "alacritty"
}
