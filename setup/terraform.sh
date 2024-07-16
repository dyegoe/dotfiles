# ##### Install Terraform deps #####
install_commands+="install_terraform "
function install_terraform() {
  install_tenv
  install_terraform_docs
  install_tflint
}

function install_tenv() {
  log_info "Install tenv..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/tofuutils/tenv/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v tenv &>/dev/null && tenv version | awk '{print $3}' || echo "0.0.0")
  local download_url="https://github.com/tofuutils/tenv/releases/download/$remote_version/tenv_${remote_version}_${OSS}_${ARCHM}.tar.gz"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  local temp_dir=$(mktemp -d)
  mkdir -p $temp_dir
  $CURL_CMD -o $temp_dir/download.tar.gz $download_url
  tar -C $temp_dir -xzf $temp_dir/download.tar.gz
  [[ "$OS" == "linux" ]] && find "$temp_dir" -type f -perm /u=x,g=x,o=x -exec sh -c 'rm -f $0/$(basename $1)' $LOCAL_BIN {} \; -exec mv {} "$LOCAL_BIN" \;
  [[ "$OS" == "darwin" ]] && find "$temp_dir" -type f -perm +0111 -exec sh -c 'rm -f $0/$(basename $1)' $LOCAL_BIN {} \; -exec mv {} "$LOCAL_BIN" \;
  rm -rf $temp_dir
  log_info "  installed..."
}

function install_terraform_docs() {
  log_info "Install terraform-docs..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest) | jq -r '.tag_name')
  local local_version=$(command -v terraform-docs &>/dev/null && terraform-docs -v | awk '{print $3}' || echo "v0.0.0")
  local download_url="https://github.com/terraform-docs/terraform-docs/releases/download/$remote_version/terraform-docs-$remote_version-$OS-$ARCH.tar.gz"
  local bin_name="terraform-docs"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  download_tar_gz_local_bin $download_url $bin_name
  log_info "  installed..."
}

function install_tflint() {
  log_info "Install tflint..."
  local remote_version=$(echo $(_curl_github https://api.github.com/repos/terraform-linters/tflint/releases/latest) | jq -r '.tag_name')
  local local_version=v$(command -v tflint &>/dev/null && tflint -v | grep version | awk '{print $3}' || echo "0.0.0")
  local download_url="https://github.com/terraform-linters/tflint/releases/download/$remote_version/tflint_${OS}_${ARCH}.zip"
  local bin_name="tflint"
  if [[ "$remote_version" == "$local_version" ]]; then
    log_info "  is up to date..."
    return
  fi
  log_info "  installing..."
  download_zip_local_bin $download_url $bin_name
  log_info "  installed..."
}
