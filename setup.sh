#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# ##### Get script directory #####
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# ##### Set variables #####
CURL_CMD=(curl -fsSL)
UNZIP_CMD=(unzip -qq -o -d)
: "${DRY_RUN:=0}"

source "$SCRIPT_DIR/zsh/zshenv"
mkdir -m 700 -p "$LOCAL_BIN"
mkdir -m 700 -p "$ZDOTDIR"

# ##### Shared library #####
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/run.sh"
source "$SCRIPT_DIR/lib/symlink.sh"
source "$SCRIPT_DIR/lib/completion.sh"
source "$SCRIPT_DIR/lib/repo.sh"
source "$SCRIPT_DIR/lib/github.sh"

# ##### Collect all commands #####
declare -a setup_commands=()
declare -a install_commands=()

# ##### upgrade system
function upgrade_system() {
  # fedora
  if [[ "$DISTRO" == "fedora" ]]; then
    log_info "Upgrade system..."
    run sudo dnf -y upgrade --refresh
    run sudo dnf -y autoremove
    return
  fi
  # anything else
  log_info "$OS/$DISTRO is not supported... System upgrade skipped..."
}

# ##### Setup NVIDIA #####
function install_nvidia() {
  log_info "Setup NVIDIA..."
  if [[ "$OS" != "linux" || "$DISTRO" != "fedora" ]]; then
    log_info "  $OS/$DISTRO doesn't support NVIDIA setup... skipped..."
    return
  fi

  if [[ -f ~/.nonvidia ]]; then
    log_info "  ~/.nonvidia exists, skipping NVIDIA setup..."
    return
  fi

  log_info "  Installing NVIDIA drivers..."
  run sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda libva-utils vdpauinfo
  log_info "  NVIDIA drivers installed successfully."
}

# ##### Install packages #####
function install_packages() {
  log_info "Install packages..."
  # darwin
  if [[ "$OS" == "darwin" ]]; then
    if ! command -v brew &>/dev/null; then
      log_info "  Install Homebrew..."
      run /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      unset NONINTERACTIVE
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    # because darwin already has zsh, we don't install it
    log_info "  Installing packages using brew..."
    run brew install \
      fd bat fzf eza zoxide ripgrep jq yq tmux xclip xsel vim pwgen alacritty \
      grep gawk gnu-sed coreutils \
      ansible ansible-lint pre-commit
    run sudo softwareupdate --agree-to-license --install-rosetta || true
    return
  fi

  # fedora
  if [[ "$DISTRO" == "fedora" ]]; then
    if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then
      log_info "  Import Visual Studio Code repository..."
      run sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      run sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi
    if ! command -v 1password &>/dev/null; then
      log_info "  Installing 1Password rpm for first time..."
      run sudo rpm -ivh "https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm"
    fi
    # because fzf is quite outdated in Fedora repos, we install it manually: `install_fzf`
    log_info "  Installing packages using dnf..."
    run sudo dnf --setopt=install_weak_deps=False -y install \
      zsh fd-find bat zoxide ripgrep jq yq tmux xclip xsel vim pwgen alacritty age \
      google-chrome-stable code 1password 1password-cli \
      podman-docker podman-compose docker-compose \
      pre-commit ansible python3-ansible-lint @virtualization
    return
  fi

  log_error "  $OS/$DISTRO is not supported... Package installation skipped..."
}

# ##### Import setup scripts #####
for f in "$SCRIPT_DIR"/setup/*.sh; do
  source "$f"
done

# ##### full #####
function full() {
  install_nvidia
  install_packages
  upgrade_system
  setup
  install
}

# ##### install #####
function install() {
  local f
  for f in "${install_commands[@]}"; do
    "$f"
  done
}

# ##### setup #####
function setup() {
  local f
  for f in "${setup_commands[@]}"; do
    "$f"
  done
}

# ##### help #####
function help() {
  local all=(full install_packages upgrade_system setup install show_env "${setup_commands[@]}" "${install_commands[@]}")
  local list
  list=$(printf '%s | ' "${all[@]}")
  printf 'Usage: %s [--dry-run] [ %s ]\n' "$0" "${list% | }"
}

# ##### dispatch #####
function main() {
  local args=()
  local arg
  for arg in "$@"; do
    case "$arg" in
    --dry-run | -n)
      DRY_RUN=1
      ;;
    *)
      args+=("$arg")
      ;;
    esac
  done

  if [[ ${#args[@]} -eq 0 ]]; then
    help
    return
  fi

  # `test` is kept as a documented alias for `show_env`, which does not
  # shadow the `test` builtin the way the old function name did.
  [[ "${args[0]}" == "test" ]] && args[0]="show_env"

  if ! declare -F "${args[0]}" &>/dev/null; then
    log_error "Unknown command: ${args[0]}"
    help
    return 1
  fi

  "${args[@]}"
}

main "$@"
