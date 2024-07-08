# ##### Install Fonts #####
install_commands+="install_fonts "
function install_fonts() {
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "Install Hack Nerd font..."
    brew install --cask font-hack-nerd-font
    return
  fi

  # anything else
  local font_dir=$HOME/.local/share/fonts
  if [[ ! -d $font_dir ]]; then
    log_info "Creating font dir..."
    mkdir -p $font_dir
  fi
  local font_nerd_fonts_repo="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
  # Hack Nerd Font
  log_info "Install Hack Nerd font..."
  local font_file="Hack.zip"
  local font_url=$($CURL_CMD $font_nerd_fonts_repo | jq --arg font_file $font_file -r '.assets[] | select(.name==$font_file) | .browser_download_url')
  $CURL_CMD -o /tmp/$font_file $font_url
  $UNZIP_CMD $font_dir /tmp/$font_file
}
