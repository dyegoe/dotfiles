# ##### Setup Gnome settings #####
setup_commands+=(setup_gnome_settings)
function setup_gnome_settings() {
  log_info "Setup Gnome settings..."
  skip_on_darwin "$OS doesn't need further Gnome setup... Gnome settings setup skipped..." && return

  # dconf requires a D-Bus session; running this over SSH/tty is benign, not fatal.
  log_info "  Setting up Gnome custom keybindings..."
  run dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']" || true
  run dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Open Terminal'" || true
  run dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'" || true
  run dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'alacritty'" || true

  log_info "  Setting up Gnome energy settings..."
  run dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'interactive'" || true
  run dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'" || true

  log_info "  Setting up Gnome interface settings..."
  run dconf write /org/gnome/desktop/interface/clock-show-date true || true
  run dconf write /org/gnome/desktop/interface/clock-show-seconds true || true
  run dconf write /org/gnome/desktop/interface/clock-show-weekday true || true
  run dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" || true
  run dconf write /org/gnome/desktop/interface/toolbar-icons-size "'small'" || true

  log_info "  Setting up Gnome favorite apps..."
  run dconf write /org/gnome/shell/favorite-apps "['google-chrome.desktop', 'org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'Alacritty.desktop', 'code.desktop', 'antigravity.desktop', 'slack.desktop', '1password.desktop']" || true
}

# ##### Install Gnome extensions #####
install_commands+=(install_gnome_extensions)
function install_gnome_extensions() {
  log_info "Install gnome-extensions..."
  skip_on_darwin "$OS is not supported... Gnome extensions installation skipped..." && return

  local gnome_version=$(gnome-shell --version | sed -n 's/^GNOME Shell \([0-9]\+\)\..*/\1/p')
  local gnome_extensions=(
    "gTile@vibou"
    "appindicatorsupport@rgcjonas.gmail.com"
  )

  local gnome_extension_id
  for gnome_extension_id in "${gnome_extensions[@]}"; do
    log_info "  installing $gnome_extension_id..."
    (
      local tmp
      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT

      local gnome_extension_version=$("${CURL_CMD[@]}" "https://extensions.gnome.org/extension-query/?search=$gnome_extension_id" | jq --arg gnome_version "$gnome_version" --arg gnome_extension_id "$gnome_extension_id" -r '.extensions[] | select(.uuid==$gnome_extension_id) | .shell_version_map[$gnome_version].version')
      local gnome_extension_zip="${gnome_extension_id//@/}.v${gnome_extension_version}.shell-extension.zip"
      run "${CURL_CMD[@]}" -o "$tmp/$gnome_extension_zip" "https://extensions.gnome.org/extension-data/$gnome_extension_zip"
      if command -v gnome-extensions &>/dev/null; then
        run gnome-extensions install --force "$tmp/$gnome_extension_zip"
        run gnome-extensions enable "$gnome_extension_id" || true
      fi
    )
    log_info "  $gnome_extension_id installed..."
  done
}
