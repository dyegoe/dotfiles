#!/usr/bin/env bash
set -e -o pipefail

# ##### Get script directory #####
SCRIPT_DIR=$(dirname $(readlink -f $0))

# ##### Set variables #####
CURL_CMD="curl -fsSL"
UNZIP_CMD="unzip -qq -o -d"

source $SCRIPT_DIR/zsh/zshenv
mkdir -m 700 -p $LOCAL_BIN
mkdir -m 700 -p $ZDOTDIR

# ##### Default log prefix #####
function echo_info() {
  echo -e "\e[33m\e[1m[INFO]\e[0m\e[34m $1\e[0m"
}
function echo_error() {
  echo -e "\e[31m\e[1m[ERROR]\e[0m\e[33m $1\e[0m"
}

# ##### Collect all commands #####
install_commands=""
setup_commands=""

# ##### upgrade system
function upgrade_system() {
  echo_info "Upgrade system..."
  sudo dnf -y upgrade --refresh
  sudo dnf -y autoremove
}

# ##### Install packages #####
function install_packages() {
  echo_info "Import Visual Studio Code repository..."
  if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  fi
  echo_info "Install packages..."
  command -v 1password &>/dev/null || sudo rpm -ivh https://downloads.1password.com/linux/rpm/stable/x86\_64/1password-latest.rpm
  # because fzf is quite outdated in Fedora repos, we install it manually: `install_fzf`
  sudo dnf --setopt=install_weak_deps=False -y install \
    akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-vaapi-driver libva-utils vdpauinfo \
    zsh fd-find bat eza zoxide jq tmux xclip xsel vim pwgen alacritty \
    google-chrome-stable code 1password 1password-cli \
    podman-docker \
    @virtualization
}

# ##### Install Gnome extensions #####
install_commands+="install_gnome_extensions "
function install_gnome_extensions() {
  echo_info "Install gnome-extensions..."
  local gnome_version=$(gnome-shell --version | sed -n 's/^GNOME Shell \([0-9]\+\)\..*/\1/p')
  local gnome_extensions=(
    "appindicatorsupport@rgcjonas.gmail.com"
    "gTile@vibou"
  )
  for gnome_extension_id in ${gnome_extensions[@]}; do
    echo_info "Installing $gnome_extension_id..."
    local gnome_extension_version=$($CURL_CMD "https://extensions.gnome.org/extension-query/?search=$gnome_extension_id" | jq --arg gnome_version "$gnome_version" --arg gnome_extension_id $gnome_extension_id -r '.extensions[] | select(.uuid==$gnome_extension_id) | .shell_version_map[$gnome_version].version')
    local gnome_extension_zip=${gnome_extension_id//@/}.v${gnome_extension_version}.shell-extension.zip
    $CURL_CMD -o /tmp/$gnome_extension_zip https://extensions.gnome.org/extension-data/$gnome_extension_zip
    if command -v gnome-extensions >/dev/null 2>&1; then
      gnome-extensions install --force /tmp/$gnome_extension_zip
      gnome-extensions enable $gnome_extension_id &>/dev/null || true
    fi
  done
}

# ##### Install Fonts #####
install_commands+="install_fonts "
function install_fonts() {
  local font_dir=$HOME/.local/share/fonts
  if [ ! -d $font_dir ]; then
    echo_info "Creating font dir..."
    mkdir -p $font_dir
  else
    echo_info "Font dir already exists..."
  fi
  local font_nerd_fonts_repo="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
  # Hack Nerd Font
  echo_info "Install Hack Nerd font..."
  local font_file="Hack.zip"
  local font_url=$($CURL_CMD $font_nerd_fonts_repo | jq --arg font_file $font_file -r '.assets[] | select(.name==$font_file) | .browser_download_url')
  $CURL_CMD -o /tmp/$font_file $font_url
  $UNZIP_CMD $font_dir /tmp/$font_file
}

# ##### Install ZSH plugins #####
install_commands+="install_zsh_plugins "
function install_zsh_plugins() {
  # zsh-autosuggestions
  if [ ! -d $ZDOTDIR/plugins/zsh-autosuggestions ]; then
    echo_info "Install zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZDOTDIR/plugins/zsh-autosuggestions
  else
    echo_info "Update zsh-autosuggestions..."
    cd $ZDOTDIR/plugins/zsh-autosuggestions && git pull
  fi

  # zsh-syntax-highlighting
  if [ ! -d $ZDOTDIR/plugins/zsh-syntax-highlighting ]; then
    echo_info "Install zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZDOTDIR/plugins/zsh-syntax-highlighting
  else
    echo_info "Update zsh-syntax-highlighting..."
    cd $ZDOTDIR/plugins/zsh-syntax-highlighting && git pull
  fi
}

# ##### Install oh-my-posh #####
install_commands+="install_oh_my_posh "
function install_oh_my_posh() {
  echo_info "Install oh-my-posh..."
  local oh_my_posh_version=$($CURL_CMD https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest | jq -r '.tag_name')
  local oh_my_posh_local_version=v$(command -v oh-my-posh &>/dev/null && oh-my-posh --version || echo "0.0.0")
  local oh_my_posh_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/$oh_my_posh_version/posh-$OS-$ARCH"
  if [ "$oh_my_posh_version" == "$oh_my_posh_local_version" ]; then
    echo_info "  oh-my-posh is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/oh-my-posh
    $CURL_CMD -o $LOCAL_BIN/oh-my-posh $oh_my_posh_url
    chmod 750 $LOCAL_BIN/oh-my-posh
  fi
}

# ##### Install fzf #####
install_commands+="install_fzf "
function install_fzf() {
  echo_info "Install fzf..."
  local fzf_version=$($CURL_CMD https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r '.tag_name')
  local fzf_local_version=$(command -v fzf &>/dev/null && fzf --version | awk '{print $1}' || echo "0.0.0")
  local fzf_url="https://github.com/junegunn/fzf/releases/download/$fzf_version/fzf-$fzf_version-${OS}_${ARCH}.tar.gz"
  if [ "$fzf_version" == "$fzf_local_version" ]; then
    echo_info "  fzf is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/fzf.tar.gz
    $CURL_CMD -o /tmp/fzf.tar.gz $fzf_url
    rm -f $LOCAL_BIN/fzf
    tar -C $LOCAL_BIN -xzf /tmp/fzf.tar.gz
    chmod 750 $LOCAL_BIN/fzf
  fi
}

# ##### Install Tmux plugins #####
install_commands+="install_tmux_plugins "
function install_tmux_plugins() {
  local tmux_plugins_dir="$XDG_CONFIG_HOME/tmux/plugins"
  local tmux_plugins_tpm_url="https://github.com/tmux-plugins/tpm.git"
  local tmux_plugins_tpm_dir="$tmux_plugins_dir/tpm"

  if [ ! -d $tmux_plugins_dir ]; then
    echo_info "Creating tmux plugins..."
    mkdir -p $tmux_plugins_dir
  else
    echo_info "Tmux plugins directoy already exists..."
  fi

  if [ ! -d $tmux_plugins_tpm_dir ]; then
    echo_info "Instal tmux tpm plugin..."
    git clone $tmux_plugins_tpm_url $tmux_plugins_tpm_dir
  else
    echo_info "Update tmux tpm plugin..."
    cd $tmux_plugins_tpm_dir
    git pull
    cd $SCRIPT_DIR
  fi

  echo_info "Install tmux plugins..."
  $tmux_plugins_tpm_dir/bin/install_plugins
}

# ##### Install vim plugins #####
install_commands+="install_vim_plugins "
function install_vim_plugins() {
  echo_info "Install vim plugins..."
  mkdir -p $VIM_THEMES
  mkdir -p $VIM_PLUGINS

  local vim_themes_code_dark=$VIM_THEMES/vim-code-dark
  if [ ! -d $vim_themes_code_dark ]; then
    echo_info "  color scheme..."
    git clone https://github.com/tomasiser/vim-code-dark $vim_themes_code_dark
  else
    echo_info "  color scheme already installed... update it..."
    cd $vim_themes_code_dark && git pull
  fi

  local vim_plugins_vim_terraform=$VIM_PLUGINS/vim-terraform
  if [ ! -d $vim_plugins_vim_terraform ]; then
    echo_info "  vim-terraform..."
    git clone https://github.com/hashivim/vim-terraform.git $vim_plugins_vim_terraform
  else
    echo_info "  vim-terraform already installed... update it..."
    cd $vim_plugins_vim_terraform && git pull
  fi
}

# ##### Install Terraform deps #####
install_commands+="install_terraform_deps "
function install_terraform_deps() {
  # tfenv
  local tfenv_dir="$XDG_CONFIG_HOME/tfenv"
  if [ ! -d $tfenv_dir ]; then
    echo_info "Instal tfenv..."
    git clone --depth=1 https://github.com/tfutils/tfenv.git $tfenv_dir
  else
    echo_info "tfenv already installed... update it..."
    cd $tfenv_dir && git pull
  fi

  # tgswitch
  echo_info "Install tgswitch..."
  local tgswitch_version=$($CURL_CMD https://api.github.com/repos/warrensbox/tgswitch/releases/latest | jq -r '.tag_name')
  local tgswitch_local_version=$(command -v tgswitch &>/dev/null && tgswitch -v | grep Version | awk '{print $2}' || echo "v0.0.0")
  local tgswitch_url="https://github.com/warrensbox/tgswitch/releases/download/$tgswitch_version/tgswitch_${tgswitch_version}_${OS}_${ARCH}.tar.gz"
  if [ "$tgswitch_version" == "$tgswitch_local_version" ]; then
    echo_info "  tgswitch is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/tgswitch
    $CURL_CMD -o /tmp/tgswitch.tar.gz $tgswitch_url
    tar -C /tmp -xzf /tmp/tgswitch.tar.gz
    mv /tmp/tgswitch $LOCAL_BIN
    chmod 750 $LOCAL_BIN/tgswitch
  fi

  # terraform-docs
  echo_info "Install terraform-docs..."
  local terraform_docs_version=$($CURL_CMD https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | jq -r '.tag_name')
  local terraform_docs_local_version=$(command -v terraform-docs &>/dev/null && terraform-docs -v | awk '{print $3}' || echo "v0.0.0")
  local terraform_docs_url="https://github.com/terraform-docs/terraform-docs/releases/download/$terraform_docs_version/terraform-docs-$terraform_docs_version-$OS-$ARCH.tar.gz"
  if [ "$terraform_docs_version" == "$terraform_docs_local_version" ]; then
    echo_info "  terraform-docs is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/terraform-docs
    $CURL_CMD -o /tmp/terraform-docs.tar.gz $terraform_docs_url
    tar -C /tmp -xzf /tmp/terraform-docs.tar.gz
    mv /tmp/terraform-docs $LOCAL_BIN
    chmod 750 $LOCAL_BIN/terraform-docs
  fi

  # tflint
  echo_info "Install tflint..."
  local tflint_version=$($CURL_CMD https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r '.tag_name')
  local tflint_local_version=v$(command -v tflint &>/dev/null && tflint -v | grep version | awk '{print $3}' || echo "0.0.0")
  local tflint_url="https://github.com/terraform-linters/tflint/releases/download/$tflint_version/tflint_${OS}_${ARCH}.zip"
  if [ "$tflint_version" == "$tflint_local_version" ]; then
    echo_info "  tflint is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/tflint
    $CURL_CMD -o /tmp/tflint.zip $tflint_url
    $UNZIP_CMD /tmp /tmp/tflint.zip
    mv /tmp/tflint $LOCAL_BIN
    chmod 750 $LOCAL_BIN/tflint
  fi
}

# ##### Install awscli2 #####
install_commands+="install_awscli "
function install_awscli() {
  echo_info "Install awscli2..."
  rm -f /tmp/awscliv2.zip
  rm -rf /tmp/aws/
  $CURL_CMD -o /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-$OS-$ARCHM.zip
  $UNZIP_CMD /tmp /tmp/awscliv2.zip
  sudo /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
}

# ##### Install kubectl #####
install_commands+="install_kubectl "
function install_kubectl() {
  # kubectl
  echo_info "Install kubectl..."
  local kubectl_version=$($CURL_CMD https://api.github.com/repos/kubernetes/kubernetes/releases/latest | jq -r '.tag_name')
  local kubectl_local_version=$(command -v kubectl &>/dev/null && kubectl version --client --output json | jq -r '.clientVersion.gitVersion' || echo "v0.0.0")
  local kubectl_url="https://dl.k8s.io/release/$kubectl_version/bin/$OS/$ARCH/kubectl"
  if [ "$kubectl_version" == "$kubectl_local_version" ]; then
    echo_info "  kubectl is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/kubectl
    $CURL_CMD -o $LOCAL_BIN/kubectl $kubectl_url
    chmod 750 $LOCAL_BIN/kubectl
  fi

  # plugin: netshoot
  echo_info "Install netshoot..."
  local netshoot_version=$($CURL_CMD https://api.github.com/repos/nilic/kubectl-netshoot/releases/latest | jq -r '.tag_name')
  local netshoot_local_version=$(command -v kubectl-netshoot &>/dev/null && kubectl-netshoot version | awk '{print $2}' || echo "v0.0.0")
  local netshoot_url="https://github.com/nilic/kubectl-netshoot/releases/download/$netshoot_version/kubectl-netshoot_${netshoot_version}_${OS}_${ARCH}.tar.gz"
  if [ "$netshoot_version" == "$netshoot_local_version" ]; then
    echo_info "  netshoot is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/kubectl-netshoot
    $CURL_CMD -o /tmp/kubectl-netshoot.tar.gz $netshoot_url
    tar -C /tmp -xzf /tmp/kubectl-netshoot.tar.gz
    mv /tmp/kubectl-netshoot $LOCAL_BIN
    chmod 750 $LOCAL_BIN/kubectl-netshoot
  fi

  # helm
  echo_info "Install helm..."
  local helm_version=$($CURL_CMD https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name')
  local helm_local_version=$(command -v helm &>/dev/null && helm version --template {{.Version}} || echo "v0.0.0")
  local helm_url="https://get.helm.sh/helm-$helm_version-$OS-$ARCH.tar.gz"
  if [ "$helm_version" == "$helm_local_version" ]; then
    echo_info "  helm is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/helm.tar.gz
    $CURL_CMD -o /tmp/helm.tar.gz $helm_url
    tar -C /tmp -xzf /tmp/helm.tar.gz
    mv /tmp/$OS-$ARCH/helm $LOCAL_BIN
    chmod 750 $LOCAL_BIN/helm
  fi

  # kubectx
  echo_info "Install kubectx..."
  local kubectx_version=$($CURL_CMD https://api.github.com/repos/ahmetb/kubectx/releases/latest | jq -r '.tag_name')
  local kubectx_local_version=v$(command -v kubectx &>/dev/null && kubectx -V || echo "0.0.0")
  local kubectx_url="https://github.com/ahmetb/kubectx/releases/download/$kubectx_version/kubectx_${kubectx_version}_${OS}_${ARCHM}.tar.gz"
  if [ "$kubectx_version" == "$kubectx_local_version" ]; then
    echo_info "  kubectx is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/kubectx.tar.gz
    rm -rf /tmp/kubectx
    rm -f $LOCAL_BIN/kubectx
    $CURL_CMD -o /tmp/kubectx.tar.gz $kubectx_url
    mkdir -p /tmp/kubectx
    tar -C /tmp/kubectx -xzf /tmp/kubectx.tar.gz
    mv /tmp/kubectx/kubectx $LOCAL_BIN
    chmod 750 $LOCAL_BIN/kubectx
  fi
}

# ##### Install k9s #####
install_commands+="install_k9s "
function install_k9s() {
  echo_info "Install k9s..."
  local k9s_version=$($CURL_CMD https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
  local k9s_local_version=$(command -v k9s &>/dev/null && k9s version --short | grep Version | awk '{print $2}' || echo "v0.0.0")
  local k9s_url="https://github.com/derailed/k9s/releases/download/$k9s_version/k9s_${OS^}_${ARCH}.tar.gz"
  if [ "$k9s_version" == "$k9s_local_version" ]; then
    echo_info "  k9s is up to date..."
  else
    echo_info "  installing..."
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

# ##### Install argocd #####
install_commands+="install_argocd "
function install_argocd() {
  echo_info "Install argocd..."
  local argocd_version=$($CURL_CMD https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r '.tag_name')
  local argocd_local_version=$(command -v argocd &>/dev/null && argocd version --client --short | awk -F'[ +]' '{print $2}' || echo "v0.0.0")
  local argocd_url="https://github.com/argoproj/argo-cd/releases/download/$argocd_version/argocd-$OS-$ARCH"
  if [ "$argocd_version" == "$argocd_local_version" ]; then
    echo_info "  argocd is up to date..."
  else
    echo_info "  installing..."
    rm -f $LOCAL_BIN/argocd
    $CURL_CMD -o $LOCAL_BIN/argocd $argocd_url
    chmod 750 $LOCAL_BIN/argocd
  fi
}

# ##### Install cilium #####
install_commands+="install_cilium "
function install_cilium() {
  echo_info "Install cilium..."
  local cilium_version=$($CURL_CMD https://api.github.com/repos/cilium/cilium-cli/releases/latest | jq -r '.tag_name')
  local cilium_local_version=$(command -v cilium &>/dev/null && cilium version --client | grep cli | awk '{print $2}' || echo "v0.0.0")
  local cilium_url="https://github.com/cilium/cilium-cli/releases/download/$cilium_version/cilium-$OS-$ARCH.tar.gz"
  if [ "$cilium_version" == "$cilium_local_version" ]; then
    echo_info "  cilium is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/cilium.tar.gz
    rm -rf /tmp/cilium
    rm -f $LOCAL_BIN/cilium
    $CURL_CMD -o /tmp/cilium.tar.gz $cilium_url
    mkdir -p /tmp/cilium
    tar -C /tmp/cilium -xzf /tmp/cilium.tar.gz
    mv /tmp/cilium/cilium $LOCAL_BIN
    chmod 750 $LOCAL_BIN/cilium
  fi
}

# ##### Install vault #####
install_commands+="install_vault "
function install_vault() {
  echo_info "Install vault..."
  local vault_version=$($CURL_CMD https://api.github.com/repos/hashicorp/vault/releases/latest | jq -r '.tag_name')
  local vault_local_version=$(command -v vault &>/dev/null && vault version | awk '{print $2}' || echo "v0.0.0")
  local vault_url="https://releases.hashicorp.com/vault/${vault_version:1}/vault_${vault_version:1}_${OS}_${ARCH}.zip"
  if [ "$vault_version" == "$vault_local_version" ]; then
    echo_info "  vault is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/vault.zip
    $CURL_CMD -o /tmp/vault.zip $vault_url
    rm -f $LOCAL_BIN/vault
    $UNZIP_CMD $LOCAL_BIN /tmp/vault.zip
    chmod 750 $LOCAL_BIN/vault
  fi
}

# ##### Install golang #####
install_commands+="install_golang "
function install_golang() {
  echo_info "Install golang..."
  local golang_version=$($CURL_CMD 'https://go.dev/VERSION?m=text' | head -1)
  local golang_local_version=$(command -v go &>/dev/null && go version | awk '{print $3}' || echo "0.0.0")
  local golang_url="https://go.dev/dl/$golang_version.$OS-$ARCH.tar.gz"
  if [ "$golang_version" == "$golang_local_version" ]; then
    echo_info "  golang is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/golang.tar.gz
    sudo rm -rf /usr/local/go
    $CURL_CMD -o /tmp/golang.tar.gz $golang_url
    sudo tar -C /usr/local -xzf /tmp/golang.tar.gz
  fi
}

# ##### Install awss #####
install_commands+="install_awss "
function install_awss() {
  echo_info "Install awss..."
  local awss_version=$($CURL_CMD https://api.github.com/repos/dyegoe/awss/releases/latest | jq -r '.tag_name')
  local awss_local_version=v$(command -v awss &>/dev/null && awss --version | awk '{print $3}' || echo "0.0.0")
  local awss_url="https://github.com/dyegoe/awss/releases/download/$awss_version/awss-$awss_version-$OS-$ARCH.tar.gz"
  if [ "$awss_version" == "$awss_local_version" ]; then
    echo_info "  awss is up to date..."
  else
    echo_info "  installing..."
    rm -f /tmp/awss.tar.gz
    $CURL_CMD -o /tmp/awss.tar.gz $awss_url
    rm -f $LOCAL_BIN/awss
    tar -C $LOCAL_BIN -xzf /tmp/awss.tar.gz
    chmod 750 $LOCAL_BIN/awss
  fi
}

# ##### Setup user #####
setup_commands+="setup_user "
function setup_user() {
  echo_info "Set ZSH as shell for the current user..."
  sudo usermod -s $(which zsh) $USER
  echo_info "Add user to libvirt group..."
  sudo usermod -aG libvirt $USER
}

# ##### Setup Gnome settings #####
setup_commands+="setup_gnome_settings "
function setup_gnome_settings() {
  echo_info "Setup Gnome settings..."

  local profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
  dconf write /org/gnome/terminal/legacy/profiles:/:${profile}/visible-name "'Default'"
  dconf write /org/gnome/terminal/legacy/profiles:/:${profile}/use-system-font false
  dconf write /org/gnome/terminal/legacy/profiles:/:${profile}/font "'Hack Nerd Font 11'"
  dconf write /org/gnome/terminal/legacy/profiles:/:${profile}/default-size-columns "140"
  dconf write /org/gnome/terminal/legacy/profiles:/:${profile}/default-size-rows "75"

  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Open Terminal'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'alacritty'"

  dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'interactive'"
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"

  dconf write /org/gnome/desktop/interface/clock-show-date true
  dconf write /org/gnome/desktop/interface/clock-show-seconds true
  dconf write /org/gnome/desktop/interface/clock-show-weekday true
  dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  dconf write /org/gnome/desktop/interface/toolbar-icons-size "'small'"

  dconf write /org/gnome/shell/favorite-apps "['google-chrome.desktop', 'org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'Alacritty.desktop', 'code.desktop', 'slack.desktop', '1password.desktop']"
}

# ##### Setup podman docker #####
setup_commands+="setup_podman_docker "
function setup_podman_docker() {
  echo_info "Setup Podman Docker..."
  sudo touch /etc/containers/nodocker
}

# ##### Setup zsh #####
setup_commands+="setup_zsh "
function setup_zsh() {
  echo_info "Setup ZSH..."
  # zshenv
  local zshenv_symlink=$HOME/.zshenv
  local zshenv_origin=$SCRIPT_DIR/zsh/zshenv

  if [ -f $zshenv_symlink ] && [ ! -L $zshenv_symlink ]; then
    echo_info "  .zshenv already exists. It is a file, moving it to backup..."
    mv $zshenv_symlink ${zshenv_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $zshenv_symlink ] && [ "$(readlink $zshenv_symlink)" = "$zshenv_origin" ]; then
    echo_info "  .zshenv already exists and is a symlink to the correct target."
  fi

  if [ -L $zshenv_symlink ] && [ ! -e $zshenv_symlink ]; then
    echo_info "  .zshenv already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $zshenv_symlink
  fi

  if [ ! -L $zshenv_symlink ]; then
    echo_info "  Creating the symlink for .zshenv..."
    ln -s $zshenv_origin $zshenv_symlink
  fi

  # zshrc
  local zshrc_symlink=$ZDOTDIR/.zshrc
  local zshrc_origin=$SCRIPT_DIR/zsh/zshrc

  if [ -f $zshrc_symlink ] && [ ! -L $zshrc_symlink ]; then
    echo_info "  .zshrc already exists. It is a file, moving it to backup..."
    mv $zshrc_symlink ${zshrc_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $zshrc_symlink ] && [ "$(readlink $zshrc_symlink)" = "$zshrc_origin" ]; then
    echo_info "  .zshrc already exists and is a symlink to the correct target."
  fi

  if [ -L $zshrc_symlink ] && [ ! -e $zshrc_symlink ]; then
    echo_info "  .zshrc already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $zshrc_symlink
  fi

  if [ ! -L $zshrc_symlink ]; then
    echo_info "  Creating the symlink for .zshrc..."
    ln -s $zshrc_origin $zshrc_symlink
  fi

  # aliases
  local aliases_symlink=$ZDOTDIR/aliases.zsh
  local aliases_origin=$SCRIPT_DIR/zsh/aliases.zsh

  if [ -f $aliases_symlink ] && [ ! -L $aliases_symlink ]; then
    echo_info "  aliases.zsh already exists. It is a file, moving it to backup..."
    mv $aliases_symlink ${aliases_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $aliases_symlink ] && [ "$(readlink $aliases_symlink)" = "$aliases_origin" ]; then
    echo_info "  aliases.zsh already exists and is a symlink to the correct target."
  fi

  if [ -L $aliases_symlink ] && [ ! -e $aliases_symlink ]; then
    echo_info "  aliases.zsh already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $aliases_symlink
  fi

  if [ ! -L $aliases_symlink ]; then
    echo_info "  Creating the symlink for aliases.zsh..."
    ln -s $aliases_origin $aliases_symlink
  fi
}

# ##### Setup oh-my-posh #####
setup_commands+="setup_oh_my_posh "
function setup_oh_my_posh() {
  echo_info "Setup oh-my-posh..."
  local oh_my_posh_templates=(
    "default.json"
    "my.json"
  )

  for template in ${oh_my_posh_templates[@]}; do
    local oh_my_posh_symlink=$XDG_CONFIG_HOME/oh-my-posh/$template
    local oh_my_posh_origin=$SCRIPT_DIR/oh-my-posh/$template

    mkdir -p $XDG_CONFIG_HOME/oh-my-posh

    if [ -f $oh_my_posh_symlink ] && [ ! -L $oh_my_posh_symlink ]; then
      echo_info "  $template already exists. It is a file, moving it to backup..."
      mv $oh_my_posh_symlink ${oh_my_posh_symlink}.$(date +%Y%m%d%H%M%S).backup
    fi

    if [ -L $oh_my_posh_symlink ] && [ "$(readlink $oh_my_posh_symlink)" = "$oh_my_posh_origin" ]; then
      echo_info "  $template already exists and is a symlink to the correct target."
    fi

    if [ -L $oh_my_posh_symlink ] && [ ! -e $oh_my_posh_symlink ]; then
      echo_info "  $template already exists. It is a symlink, but the target does not exist. Removing it..."
      rm -f $oh_my_posh_symlink
    fi

    if [ ! -L $oh_my_posh_symlink ]; then
      echo_info "  Creating the symlink for $template..."
      ln -s $oh_my_posh_origin $oh_my_posh_symlink
    fi
  done
}

# ##### Setup Alacritty #####
setup_commands+="setup_alacritty "
function setup_alacritty() {
  echo_info "Setup Alacritty..."
  # alacritty.toml
  local alacritty_symlink=$XDG_CONFIG_HOME/alacritty/alacritty.toml
  local alacritty_origin=$SCRIPT_DIR/alacritty/alacritty.toml

  mkdir -p $XDG_CONFIG_HOME/alacritty

  if [ -f $alacritty_symlink ] && [ ! -L $alacritty_symlink ]; then
    echo_info "  alacritty.toml already exists. It is a file, moving it to backup..."
    mv $alacritty_symlink ${alacritty_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $alacritty_symlink ] && [ "$(readlink $alacritty_symlink)" = "$alacritty_origin" ]; then
    echo_info "  alacritty.toml already exists and is a symlink to the correct target."
  fi

  if [ -L $alacritty_symlink ] && [ ! -e $alacritty_symlink ]; then
    echo_info "  alacritty.toml already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $alacritty_symlink
  fi

  if [ ! -L $alacritty_symlink ]; then
    echo_info "  Creating the symlink for alacritty.toml..."
    ln -s $alacritty_origin $alacritty_symlink
  fi
}

# ##### Setup tmux #####
setup_commands+="setup_tmux "
function setup_tmux() {
  echo_info "Setup Tmux..."
  # tmux.conf
  local tmux_conf_symlink=$XDG_CONFIG_HOME/tmux/tmux.conf
  local tmux_conf_origin=$SCRIPT_DIR/tmux/tmux.conf

  mkdir -p $XDG_CONFIG_HOME/tmux

  if [ -f $tmux_conf_symlink ] && [ ! -L $tmux_conf_symlink ]; then
    echo_info "  tmux.conf already exists. It is a file, moving it to backup..."
    mv $tmux_conf_symlink ${tmux_conf_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $tmux_conf_symlink ] && [ "$(readlink $tmux_conf_symlink)" = "$tmux_conf_origin" ]; then
    echo_info "  tmux.conf already exists and is a symlink to the correct target."
  fi

  if [ -L $tmux_conf_symlink ] && [ ! -e $tmux_conf_symlink ]; then
    echo_info "  tmux.conf already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $tmux_conf_symlink
  fi

  if [ ! -L $tmux_conf_symlink ]; then
    echo_info "  Creating the symlink for tmux.conf..."
    ln -s $tmux_conf_origin $tmux_conf_symlink
  fi
}

# ##### Setup vim #####
setup_commands+="setup_vim "
function setup_vim() {
  echo_info "Setup Vim..."
  # vimrc
  local vimrc_symlink=$XDG_CONFIG_HOME/vim/vimrc
  local vimrc_origin=$SCRIPT_DIR/vim/vimrc

  mkdir -p $XDG_CONFIG_HOME/vim
  # check vimrc -> set undodir
  mkdir -p $XDG_CONFIG_HOME/vim/undo

  if [ -f $vimrc_symlink ] && [ ! -L $vimrc_symlink ]; then
    echo_info "  .vimrc already exists. It is a file, moving it to backup..."
    mv $vimrc_symlink ${vimrc_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $vimrc_symlink ] && [ "$(readlink $vimrc_symlink)" = "$vimrc_origin" ]; then
    echo_info "  .vimrc already exists and is a symlink to the correct target."
  fi

  if [ -L $vimrc_symlink ] && [ ! -e $vimrc_symlink ]; then
    echo_info "  .vimrc already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $vimrc_symlink
  fi

  if [ ! -L $vimrc_symlink ]; then
    echo_info "  Creating the symlink for .vimrc..."
    ln -s $vimrc_origin $vimrc_symlink
  fi
}

# ##### Setup 1Password #####
setup_commands+="setup_1password "
function setup_1password() {
  echo_info "Setup 1Password..."
  local autostart_path=$XDG_CONFIG_HOME/autostart
  mkdir -p $autostart_path
  cp $SCRIPT_DIR/1password/1password.desktop $autostart_path/.
}

# ##### Setup ssh #####
setup_commands+="setup_ssh "
function setup_ssh() {
  echo_info "Setup SSH..."
  local ssh_dir=$HOME/.ssh
  local ssh_config=$ssh_dir/config
  local ssh_config_origin=$SCRIPT_DIR/ssh/config.$OS

  if [ ! -d $ssh_dir ]; then
    echo_info "  Creating .ssh directory..."
    mkdir -p $ssh_dir
    chmod 700 $ssh_dir
  fi

  if [ -f $ssh_config ] && [ ! -L $ssh_config ]; then
    echo_info "  config already exists. It is a file, moving it to backup..."
    mv $ssh_config ${ssh_config}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $ssh_config ] && [ "$(readlink $ssh_config)" = "$ssh_config_origin" ]; then
    echo_info "  config already exists and is a symlink to the correct target."
  fi

  if [ -L $ssh_config ] && [ ! -e $ssh_config ]; then
    echo_info "  config already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $ssh_config
  fi

  if [ ! -L $ssh_config ]; then
    echo_info "  Creating the symlink for config..."
    ln -s $ssh_config_origin $ssh_config
  fi
}

# ##### Setup git #####
setup_commands+="setup_git "
function setup_git() {
  echo_info "Setup Git..."
  local gitconfig_symlink=$HOME/.gitconfig
  local gitconfig_origin=$SCRIPT_DIR/git/gitconfig.$OS

  if [ -f $gitconfig_symlink ] && [ ! -L $gitconfig_symlink ]; then
    echo_info "  .gitconfig already exists. It is a file, moving it to backup..."
    mv $gitconfig_symlink ${gitconfig_symlink}.$(date +%Y%m%d%H%M%S).backup
  fi

  if [ -L $gitconfig_symlink ] && [ "$(readlink $gitconfig_symlink)" = "$gitconfig_origin" ]; then
    echo_info "  .gitconfig already exists and is a symlink to the correct target."
  fi

  if [ -L $gitconfig_symlink ] && [ ! -e $gitconfig_symlink ]; then
    echo_info "  .gitconfig already exists. It is a symlink, but the target does not exist. Removing it..."
    rm -f $gitconfig_symlink
  fi

  if [ ! -L $gitconfig_symlink ]; then
    echo_info "  Creating the symlink for .gitconfig..."
    ln -s $gitconfig_origin $gitconfig_symlink
  fi
}

# ##### full #####
function full() {
  install_packages
  upgrade_system
  for f in $setup_commands; do
    $f
  done
  for f in $install_commands; do
    $f
  done
}

# ##### help #####
function help() {
  echo "Usage: $0 [ full | ${install_commands// / | }${setup_commands// / | }]" | sed 's/ | ]$/ ]/'
}

eval $@
