# ##### Install Fonts #####
install_commands+="install_fonts "
function install_fonts() {
  log_info "Install Hack Nerd font..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    log_info "  installing..."
    brew install --cask font-hack-nerd-font
    log_info "  installed..."
    return
  fi

  # anything else
  local temp_dir=$(mktemp -d)
  local font_dir=$HOME/.local/share/fonts
  if [[ ! -d $font_dir ]]; then
    log_info "  creating font dir..."
    mkdir -p $font_dir
  fi
  local font_nerd_fonts_repo="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
  log_info "  installing..."
  local font_file="Hack.zip"
  local font_url=$($CURL_CMD $font_nerd_fonts_repo | jq --arg font_file $font_file -r '.assets[] | select(.name==$font_file) | .browser_download_url')
  $CURL_CMD -o $temp_dir/$font_file $font_url
  $UNZIP_CMD $font_dir $temp_dir/$font_file
  log_info "  installed..."
  rm -rf $temp_dir
}
