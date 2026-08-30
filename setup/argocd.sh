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

# ##### Install argo rollouts #####
install_commands+=(install_argo_rollouts)
function install_argo_rollouts() {
  log_info "Install argo rollouts..."
  local remote_version=$(gh_latest_tag argoproj/argo-rollouts)
  local local_version=$(command -v kubectl-argo-rollouts &>/dev/null && kubectl-argo-rollouts version --short 2>/dev/null | awk -F'[ +]' '{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-$OS-$ARCH" kubectl-argo-rollouts bin
}
