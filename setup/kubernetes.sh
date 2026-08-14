# ##### Setup kubernetes tools #####
setup_commands+=(setup_kubernetes)
function setup_kubernetes() {
  setup_kubectl
  setup_netshoot
  setup_helm
}

function setup_kubectl() {
  gen_zsh_completion kubectl
}

function setup_netshoot() {
  gen_zsh_completion kubectl-netshoot
}

function setup_helm() {
  gen_zsh_completion helm
}

# ##### Install kubernetes tools #####
install_commands+=(install_kubernetes)
function install_kubernetes() {
  install_kubectl
  install_netshoot
  install_helm
  install_kubectx
  install_k9s
  install_kubeseal
}

function install_kubectl() {
  log_info "Install kubectl..."
  local remote_version=$(gh_latest_tag kubernetes/kubernetes)
  local local_version=$(command -v kubectl &>/dev/null && kubectl version --client --output json | jq -r '.clientVersion.gitVersion' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://dl.k8s.io/release/$remote_version/bin/$OS/$ARCH/kubectl" kubectl bin
}

function install_netshoot() {
  log_info "Install kubectl-netshoot..."
  local remote_version=$(gh_latest_tag nilic/kubectl-netshoot)
  local local_version=$(command -v kubectl-netshoot &>/dev/null && kubectl-netshoot version | awk '{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/nilic/kubectl-netshoot/releases/download/$remote_version/kubectl-netshoot_${remote_version}_${OS}_${ARCH}.tar.gz" kubectl-netshoot tar.gz
}

function install_helm() {
  log_info "Install helm..."
  local remote_version=$(gh_latest_tag helm/helm)
  local local_version=$(command -v helm &>/dev/null && helm version --template {{.Version}} || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://get.helm.sh/helm-$remote_version-$OS-$ARCH.tar.gz" helm tar.gz "$OS-$ARCH/helm"
}

function install_kubectx() {
  log_info "Install kubectx..."
  local remote_version=$(gh_latest_tag ahmetb/kubectx)
  local local_version=v$(command -v kubectx &>/dev/null && kubectx -V || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/ahmetb/kubectx/releases/download/$remote_version/kubectx_${remote_version}_${OS}_${ARCHM}.tar.gz" kubectx tar.gz
}

function install_k9s() {
  log_info "Install k9s..."
  local remote_version=$(gh_latest_tag derailed/k9s)
  local local_version=$(command -v k9s &>/dev/null && k9s version --short | grep Version | awk '{print $2}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/derailed/k9s/releases/download/$remote_version/k9s_${OSS}_${ARCH}.tar.gz" k9s tar.gz
}

function install_kubeseal() {
  log_info "Install kubeseal..."
  local remote_version=$(gh_latest_tag bitnami-labs/sealed-secrets)
  local local_version=$(command -v kubeseal &>/dev/null && kubeseal --version | awk '{print $3}' || echo "v0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/bitnami-labs/sealed-secrets/releases/download/$remote_version/kubeseal-${remote_version#v}-$OS-$ARCH.tar.gz" kubeseal tar.gz
}
