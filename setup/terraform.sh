# ##### Setup tenv #####
setup_commands+=(setup_tenv)
function setup_tenv() {
  gen_zsh_completion tenv
}

# ##### Install Terraform deps #####
install_commands+=(install_terraform)
function install_terraform() {
  install_tenv
  install_terraform_docs
  install_tflint
}

function install_tenv() {
  log_info "Install tenv..."
  local remote_version=$(gh_latest_tag tofuutils/tenv)
  local local_version=$(command -v tenv &>/dev/null && tenv version | awk '{print $3}' || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release_tree "https://github.com/tofuutils/tenv/releases/download/$remote_version/tenv_${remote_version}_${OSS}_${ARCHM}.tar.gz" tar.gz
}

function install_terraform_docs() {
  log_info "Install terraform-docs..."
  local remote_version=$(gh_latest_tag terraform-docs/terraform-docs)
  local local_version=$(command -v terraform-docs &>/dev/null && terraform-docs -v | awk '{print $3}' || echo "v0.0.0")
  [[ "$OS" == "darwin" ]] && local_version="v0.20.0"

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/terraform-docs/terraform-docs/releases/download/$remote_version/terraform-docs-$remote_version-$OS-$ARCH.tar.gz" terraform-docs tar.gz
}

function install_tflint() {
  log_info "Install tflint..."
  local remote_version=$(gh_latest_tag terraform-linters/tflint)
  local local_version=v$(command -v tflint &>/dev/null && tflint -v | grep version | awk '{print $3}' || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release "https://github.com/terraform-linters/tflint/releases/download/$remote_version/tflint_${OS}_${ARCH}.zip" tflint zip
}
