# ##### Setup Gnome settings #####
setup_commands+="setup_gnome_settings "
function setup_gnome_settings() {
  log_info "Setup Gnome settings..."
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS doesn't need further Gnome setup... Gnome settings setup skipped..."
    return
  fi

  log_info "  Setting up Gnome custom keybindings..."
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Open Terminal'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'alacritty'"

  log_info "  Setting up Gnome energy settings..."
  dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'interactive'"
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"

  log_info "  Setting up Gnome interface settings..."
  dconf write /org/gnome/desktop/interface/clock-show-date true
  dconf write /org/gnome/desktop/interface/clock-show-seconds true
  dconf write /org/gnome/desktop/interface/clock-show-weekday true
  dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  dconf write /org/gnome/desktop/interface/toolbar-icons-size "'small'"

  log_info "  Setting up Gnome favorite apps..."
  dconf write /org/gnome/shell/favorite-apps "['google-chrome.desktop', 'org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'Alacritty.desktop', 'code.desktop', 'antigravity.desktop', 'slack.desktop', '1password.desktop']"
}

# ##### Install Gnome extensions #####
install_commands+="install_gnome_extensions "
function install_gnome_extensions() {
  log_info "Install gnome-extensions..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  $OS is not supported... Gnome extensions installation skipped..."
    return
  fi

  # anything else
  local gnome_version=$(gnome-shell --version | sed -n 's/^GNOME Shell \([0-9]\+\)\..*/\1/p')
  # Retired extensions: "appindicatorsupport@rgcjonas.gmail.com"
  local gnome_extensions=(
    "gTile@vibou"
    "appindicatorsupport@rgcjonas.gmail.com"
  )
  for gnome_extension_id in ${gnome_extensions[@]}; do
    log_info "  installing $gnome_extension_id..."
    local gnome_extension_version=$($CURL_CMD "https://extensions.gnome.org/extension-query/?search=$gnome_extension_id" | jq --arg gnome_version "$gnome_version" --arg gnome_extension_id $gnome_extension_id -r '.extensions[] | select(.uuid==$gnome_extension_id) | .shell_version_map[$gnome_version].version')
    local gnome_extension_zip=${gnome_extension_id//@/}.v${gnome_extension_version}.shell-extension.zip
    $CURL_CMD -o /tmp/$gnome_extension_zip https://extensions.gnome.org/extension-data/$gnome_extension_zip
    if command -v gnome-extensions &>/dev/null; then
      gnome-extensions install --force /tmp/$gnome_extension_zip
      gnome-extensions enable $gnome_extension_id &>/dev/null || true
    fi
    log_info "  $gnome_extension_id installed..."
  done
}
