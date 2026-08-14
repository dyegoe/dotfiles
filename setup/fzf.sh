# ##### Install fzf #####
install_commands+=(install_fzf)
function install_fzf() {
  log_info "Install fzf..."
  skip_on_darwin "$OS installs fzf via brew, skipping..." && return

  local remote_version=$(gh_latest_tag junegunn/fzf)
  local local_version=$(command -v fzf &>/dev/null && fzf --version | awk '{print $1}' || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/junegunn/fzf/releases/download/$remote_version/fzf-${remote_version#v}-${OS}_${ARCH}.tar.gz" fzf tar.gz
}
