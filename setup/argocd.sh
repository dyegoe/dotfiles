# ##### Install argocd #####
install_commands+=(install_argocd)
function install_argocd() {
  log_info "Install argocd..."
  local remote_version=$(gh_latest_tag argoproj/argo-cd)
  local local_version=$(command -v argocd &>/dev/null && argocd version --client --short | awk -F'[ +]' '{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/argoproj/argo-cd/releases/download/$remote_version/argocd-$OS-$ARCH" argocd bin
}
