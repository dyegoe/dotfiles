# ##### Install Fonts #####
install_commands+=(install_fonts)
function install_fonts() {
  log_info "Install Hack Nerd font..."
  if [[ "$OS" == "darwin" ]]; then
    log_sub "installing..."
    run brew install --cask font-hack-nerd-font
    log_sub "installed..."
    return
  fi

  local font_dir="$HOME/.local/share/fonts"
  run mkdir -p "$font_dir"

  log_sub "installing..."
  (
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    local font_url=$(gh_asset_url ryanoasis/nerd-fonts Hack.zip)
    run "${CURL_CMD[@]}" -o "$tmp/Hack.zip" "$font_url"
    run "${UNZIP_CMD[@]}" "$font_dir" "$tmp/Hack.zip"
  )
  log_sub "installed..."
}
