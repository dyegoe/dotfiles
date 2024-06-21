# ##### Install argocd #####
install_commands+="install_argocd "
function install_argocd() {
  log_info "Install argocd..."
  local argocd_version=$($CURL_CMD https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r '.tag_name')
  local argocd_local_version=$(command -v argocd &>/dev/null && argocd version --client --short | awk -F'[ +]' '{print $2}' || echo "v0.0.0")
  local argocd_url="https://github.com/argoproj/argo-cd/releases/download/$argocd_version/argocd-$OS-$ARCH"
  if [[ "$argocd_version" == "$argocd_local_version" ]]; then
    log_info "  argocd is up to date..."
  else
    log_info "  installing..."
    rm -f $LOCAL_BIN/argocd
    $CURL_CMD -o $LOCAL_BIN/argocd $argocd_url
    chmod 750 $LOCAL_BIN/argocd
  fi
}
