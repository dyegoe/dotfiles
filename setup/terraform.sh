# ##### Setup tgswitch #####
setup_commands+="setup_tgswitch "
function setup_tgswitch() {
  log_info "Setup tgswitch..."
  # .tgswitch.toml
  local tgswitch_symlink=$HOME/.tgswitch.toml
  local tgswitch_origin=$SCRIPT_DIR/tgswitch/tgswitch.$OS.toml

  if [[ -f $tgswitch_symlink ]] && [[ ! -L $tgswitch_symlink ]]; then
    log_info "  .tgswitch already exists. It is a file, moving it to backup..."
    mv $tgswitch_symlink ${tgswitch_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [[ -L $tgswitch_symlink ]] && [[ "$(readlink $tgswitch_symlink)" != "$tgswitch_origin" ]]; then
    log_info "  .tgswitch already exists, but it is a symlink to the wrong target."
    rm -f $tgswitch_symlink
  fi

  if [[ -L $tgswitch_symlink ]] && [[ ! -e $tgswitch_symlink ]]; then
    log_info "  .tgswitch already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $tgswitch_symlink
  fi

  if [[ ! -L $tgswitch_symlink ]]; then
    log_info "  Creating the symlink for .tgswitch..."
    ln -s $tgswitch_origin $tgswitch_symlink
  fi
}

# ##### Install Terraform deps #####
install_commands+="install_terraform_deps "
function install_terraform_deps() {
  # tfenv
  local tfenv_dir="$XDG_CONFIG_HOME/tfenv"
  if [[ ! -d $tfenv_dir ]]; then
    log_info "Instal tfenv..."
    git clone --depth=1 https://github.com/tfutils/tfenv.git $tfenv_dir
  else
    log_info "tfenv already installed... update it..."
    cd $tfenv_dir && git pull
  fi

  # tgswitch
  log_info "Install tgswitch..."
  local tgswitch_version=$($CURL_CMD https://api.github.com/repos/warrensbox/tgswitch/releases/latest | jq -r '.tag_name')
  local tgswitch_local_version=$(command -v tgswitch &>/dev/null && tgswitch -v | grep Version | awk '{print $2}' || echo "v0.0.0")
  local tgswitch_url="https://github.com/warrensbox/tgswitch/releases/download/$tgswitch_version/tgswitch_${tgswitch_version}_${OS}_${ARCH}.tar.gz"
  if [[ "$tgswitch_version" == "$tgswitch_local_version" ]]; then
    log_info "  tgswitch is up to date..."
  else
    log_info "  installing..."
    rm -f $LOCAL_BIN/tgswitch
    $CURL_CMD -o /tmp/tgswitch.tar.gz $tgswitch_url
    tar -C /tmp -xzf /tmp/tgswitch.tar.gz
    mv /tmp/tgswitch $LOCAL_BIN
    chmod 750 $LOCAL_BIN/tgswitch
  fi

  # terraform-docs
  log_info "Install terraform-docs..."
  local terraform_docs_version=$($CURL_CMD https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | jq -r '.tag_name')
  local terraform_docs_local_version=$(command -v terraform-docs &>/dev/null && terraform-docs -v | awk '{print $3}' || echo "v0.0.0")
  local terraform_docs_url="https://github.com/terraform-docs/terraform-docs/releases/download/$terraform_docs_version/terraform-docs-$terraform_docs_version-$OS-$ARCH.tar.gz"
  if [[ "$terraform_docs_version" == "$terraform_docs_local_version" ]]; then
    log_info "  terraform-docs is up to date..."
  else
    log_info "  installing..."
    rm -f $LOCAL_BIN/terraform-docs
    $CURL_CMD -o /tmp/terraform-docs.tar.gz $terraform_docs_url
    tar -C /tmp -xzf /tmp/terraform-docs.tar.gz
    mv /tmp/terraform-docs $LOCAL_BIN
    chmod 750 $LOCAL_BIN/terraform-docs
  fi

  # tflint
  log_info "Install tflint..."
  local tflint_version=$($CURL_CMD https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r '.tag_name')
  local tflint_local_version=v$(command -v tflint &>/dev/null && tflint -v | grep version | awk '{print $3}' || echo "0.0.0")
  local tflint_url="https://github.com/terraform-linters/tflint/releases/download/$tflint_version/tflint_${OS}_${ARCH}.zip"
  if [[ "$tflint_version" == "$tflint_local_version" ]]; then
    log_info "  tflint is up to date..."
  else
    log_info "  installing..."
    rm -f $LOCAL_BIN/tflint
    $CURL_CMD -o /tmp/tflint.zip $tflint_url
    $UNZIP_CMD /tmp /tmp/tflint.zip
    mv /tmp/tflint $LOCAL_BIN
    chmod 750 $LOCAL_BIN/tflint
  fi
}
