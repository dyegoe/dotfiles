# Fedora

## Installation

- Select `English (United Kingdom)` as language
- Select the keyboard: `English (US, intl., with dead keys)`
- Select the disks and select custom.
- Select a volume or add a new partition, label it as `fedora` and assign `/` as a mount point.
- Select the EFI partition and mount as `/boot/efi`.
- Begin installation

## Post Installation

- Start Setup
- Enable third-party packages
- Open a terminal
- If the hardware has an NVIDIA graphic card, install the driver
  - `sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-vaapi-driver libva-utils vdpauinfo`
  - Wait for the installation to finish. Akmmod will build the driver for the current kernel.
    - `sudo ps aux |grep akmods |grep -v grep` until the process is finished.
- `sudo dnf update -y`
- `sudo dnf autoremove -y`
- `reboot`
- Once the driver is installed and after the reboot, this command should not output anything: `lsmod |grep nouveau`

### Setup script

- Open a terminal
- `sudo dnf install -y git`
- `git clone https://github.com/dyegoe/dotfiles.git $HOME/dotfiles`
- `cd dotfiles`
- `./setup.sh full`

### Setup 1Password

- Open 1Password and sign in
- Setup SSH Agent
  - Open 1Password
  - Go Settings
  - Developer
  - Setup SSH Agent
  - Use the Key Names
  - Select "Edit Automatically"
  - Close
- Setup CLI
  - Enable "Command-Line Interface (CLI)" option under Developer (as above)
  - `op signin`
  - If you forgot to enable the option, 1Password will prompt you to do so.
