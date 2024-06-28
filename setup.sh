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
function log_info() {
  printf "\e[33m\e[1m[INFO]\e[0m\e[34m $1\e[0m\n"
}
function log_error() {
  printf "\e[31m\e[1m[ERROR]\e[0m\e[33m $1\e[0m\n"
}

# ##### Collect all commands #####
setup_commands=""
install_commands=""

# ##### upgrade system
function upgrade_system() {
  # fedora
  if [[ "$DISTRO" == "fedora" ]]; then
    log_info "Upgrade system..."
    sudo dnf -y upgrade --refresh
    sudo dnf -y autoremove
    return
  fi
  # anything else
  log_info "$OS/$DISTRO is not supported... System upgrade skipped..."
}

# ##### Install packages #####
function install_packages() {
  log_info "Install packages..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    if ! command -v brew &>/dev/null; then
      log_info "Install Homebrew..."
      /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # because darwin already has zsh, we don't install it
    log_info "  Installing packages using brew..."
    brew install \
      fd bat fzf eza zoxide ripgrep jq tmux xclip xsel vim pwgen alacritty grep gawk gnu-sed coreutils
    return
  fi

  # fedora
  if [[ "$DISTRO" == "fedora" ]]; then
    if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then
      log_info "  Import Visual Studio Code repository..."
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi
    if ! command -v 1password &>/dev/null; then
      log_info "  Installing 1Password rpm for first time..."
      sudo rpm -ivh https://downloads.1password.com/linux/rpm/stable/x86\_64/1password-latest.rpm
    fi
    # because fzf is quite outdated in Fedora repos, we install it manually: `install_fzf`
    log_info "  Installing packages using dnf..."
    sudo dnf --setopt=install_weak_deps=False -y install \
      akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-vaapi-driver libva-utils vdpauinfo \
      zsh fd-find bat eza zoxide ripgrep jq tmux xclip xsel vim pwgen alacritty \
      google-chrome-stable code 1password 1password-cli \
      podman-docker podman-compose docker-compose \
      @virtualization
    return
  fi

  log_error "  $OS/$DISTRO is not supported... Package installation skipped..."
}

# ##### Import setup scripts #####
for f in $SCRIPT_DIR/setup/*.sh; do
  source $f
done

# ##### full #####
function full() {
  install_packages
  upgrade_system
  setup
  install
}

# ##### install #####
function install() {
  for f in $install_commands; do
    $f
  done
}

# ##### setup #####
function setup() {
  for f in $setup_commands; do
    $f
  done
}

# ##### help #####
function help() {
  printf "Usage: $0 [ full | install_packages | upgrade_system | setup | install | ${setup_commands// / | }${install_commands// / | }]" | sed 's/ | ]$/ ]/'
}

eval $@
