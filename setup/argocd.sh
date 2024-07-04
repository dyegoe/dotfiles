# ##### Install argocd #####
install_commands+="install_argocd "
function install_argocd() {
  log_info "Install argocd..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/argoproj/argo-cd/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v argocd &>/dev/null && argocd version --client --short | awk -F'[ +]' '{print $2}' || echo "v0.0.0")
  local download_url="https://github.com/argoproj/argo-cd/releases/download/$remote_version/argocd-$OS-$ARCH"
  local bin_name="argocd"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  $bin_name is up to date..."
    return
  fi
  log_info "  installing..."
  download_bin_local_bin $download_url $bin_name
}
