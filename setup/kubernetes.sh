# ##### Install kubernetes #####
install_commands+="install_kubernetes "
function install_kubernetes() {
  # kubectl
  log_info "Install kubectl..."
  local kubectl_version=$($CURL_CMD https://api.github.com/repos/kubernetes/kubernetes/releases/latest | jq -r '.tag_name')
  local kubectl_local_version=$(command -v kubectl &>/dev/null && kubectl version --client --output json | jq -r '.clientVersion.gitVersion' || echo "v0.0.0")
  local kubectl_url="https://dl.k8s.io/release/$kubectl_version/bin/$OS/$ARCH/kubectl"
  if [[ "$kubectl_version" == "$kubectl_local_version" ]]; then
    log_info "  kubectl is up to date..."
  else
    log_info "  installing..."
    rm -f $LOCAL_BIN/kubectl
    $CURL_CMD -o $LOCAL_BIN/kubectl $kubectl_url
    chmod 750 $LOCAL_BIN/kubectl
  fi

  # plugin: netshoot
  log_info "Install netshoot..."
  local netshoot_version=$($CURL_CMD https://api.github.com/repos/nilic/kubectl-netshoot/releases/latest | jq -r '.tag_name')
  local netshoot_local_version=$(command -v kubectl-netshoot &>/dev/null && kubectl-netshoot version | awk '{print $2}' || echo "v0.0.0")
  local netshoot_url="https://github.com/nilic/kubectl-netshoot/releases/download/$netshoot_version/kubectl-netshoot_${netshoot_version}_${OS}_${ARCH}.tar.gz"
  if [[ "$netshoot_version" == "$netshoot_local_version" ]]; then
    log_info "  netshoot is up to date..."
  else
    log_info "  installing..."
    rm -f $LOCAL_BIN/kubectl-netshoot
    $CURL_CMD -o /tmp/kubectl-netshoot.tar.gz $netshoot_url
    tar -C /tmp -xzf /tmp/kubectl-netshoot.tar.gz
    mv /tmp/kubectl-netshoot $LOCAL_BIN
    chmod 750 $LOCAL_BIN/kubectl-netshoot
  fi

  # helm
  log_info "Install helm..."
  local helm_version=$($CURL_CMD https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name')
  local helm_local_version=$(command -v helm &>/dev/null && helm version --template {{.Version}} || echo "v0.0.0")
  local helm_url="https://get.helm.sh/helm-$helm_version-$OS-$ARCH.tar.gz"
  if [[ "$helm_version" == "$helm_local_version" ]]; then
    log_info "  helm is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/helm.tar.gz
    $CURL_CMD -o /tmp/helm.tar.gz $helm_url
    tar -C /tmp -xzf /tmp/helm.tar.gz
    mv /tmp/$OS-$ARCH/helm $LOCAL_BIN
    chmod 750 $LOCAL_BIN/helm
  fi

  # kubectx
  log_info "Install kubectx..."
  local kubectx_version=$($CURL_CMD https://api.github.com/repos/ahmetb/kubectx/releases/latest | jq -r '.tag_name')
  local kubectx_local_version=v$(command -v kubectx &>/dev/null && kubectx -V || echo "0.0.0")
  local kubectx_url="https://github.com/ahmetb/kubectx/releases/download/$kubectx_version/kubectx_${kubectx_version}_${OS}_${ARCHM}.tar.gz"
  if [[ "$kubectx_version" == "$kubectx_local_version" ]]; then
    log_info "  kubectx is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/kubectx.tar.gz
    rm -rf /tmp/kubectx
    rm -f $LOCAL_BIN/kubectx
    $CURL_CMD -o /tmp/kubectx.tar.gz $kubectx_url
    mkdir -p /tmp/kubectx
    tar -C /tmp/kubectx -xzf /tmp/kubectx.tar.gz
    mv /tmp/kubectx/kubectx $LOCAL_BIN
    chmod 750 $LOCAL_BIN/kubectx
  fi

  # k9s
  log_info "Install k9s..."
  local k9s_version=$($CURL_CMD https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
  local k9s_local_version=$(command -v k9s &>/dev/null && k9s version --short | grep Version | awk '{print $2}' || echo "v0.0.0")
  local k9s_url="https://github.com/derailed/k9s/releases/download/$k9s_version/k9s_${OSS}_${ARCH}.tar.gz"
  if [[ "$k9s_version" == "$k9s_local_version" ]]; then
    log_info "  k9s is up to date..."
  else
    log_info "  installing..."
    rm -f /tmp/k9s.tar.gz
    rm -rf /tmp/k9s
    rm -f $LOCAL_BIN/k9s
    $CURL_CMD -o /tmp/k9s.tar.gz $k9s_url
    mkdir -p /tmp/k9s
    tar -C /tmp/k9s -xzf /tmp/k9s.tar.gz
    mv /tmp/k9s/k9s $LOCAL_BIN
    chmod 750 $LOCAL_BIN/k9s
  fi
}
