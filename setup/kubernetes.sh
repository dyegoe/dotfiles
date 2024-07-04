# ##### Install kubernetes #####
install_commands+="install_kubernetes "
function install_kubernetes() {
  install_kubectl
  install_netshoot
  install_helm
  install_kubectx
  install_k9s
}

function install_kubectl() {
  log_info "Install kubectl..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/kubernetes/kubernetes/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v kubectl &>/dev/null && kubectl version --client --output json | jq -r '.clientVersion.gitVersion' || echo "v0.0.0")
  local download_url="https://dl.k8s.io/release/$remote_version/bin/$OS/$ARCH/kubectl"
  local bin_name="kubectl"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  $bin_name is up to date..."
    return
  fi
  download_bin_local_bin $download_url $bin_name
}

function install_netshoot() {
  # plugin
  log_info "Install netshoot..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/nilic/kubectl-netshoot/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v kubectl-netshoot &>/dev/null && kubectl-netshoot version | awk '{print $2}' || echo "v0.0.0")
  local download_url="https://github.com/nilic/kubectl-netshoot/releases/download/$remote_version/kubectl-netshoot_${remote_version}_${OS}_${ARCH}.tar.gz"
  local bin_name="kubectl-netshoot"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  $bin_name is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
}

function install_helm() {
  log_info "Install helm..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/helm/helm/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v helm &>/dev/null && helm version --template {{.Version}} || echo "v0.0.0")
  local download_url="https://get.helm.sh/helm-$remote_version-$OS-$ARCH.tar.gz"
  local temp_dir="/tmp/helm"
  local bin_name="helm"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  helm is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name "linux-$ARCH/$bin_name"
}

function install_kubectx() {
  log_info "Install kubectx..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/ahmetb/kubectx/releases/latest) | jq -r '.tag_name')
  local local_version=v$(command -v kubectx &>/dev/null && kubectx -V || echo "0.0.0")
  local download_url="https://github.com/ahmetb/kubectx/releases/download/$remote_version/kubectx_${remote_version}_${OS}_${ARCHM}.tar.gz"
  local bin_name="kubectx"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  kubectx is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
}

function install_k9s() {
  # k9s
  log_info "Install k9s..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/derailed/k9s/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v k9s &>/dev/null && k9s version --short | grep Version | awk '{print $2}' || echo "v0.0.0")
  local download_url="https://github.com/derailed/k9s/releases/download/$remote_version/k9s_${OSS}_${ARCH}.tar.gz"
  local bin_name="k9s"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  k9s is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
}
