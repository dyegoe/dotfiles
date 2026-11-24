# Dotfiles

## Fedora 43

### Installation

- For Language: Select `English (United Kingdom)`
- For Keyboard: `Change system keyboard layout`
  - Click `+ Add Input Source`
  - Click `English (United States)`
  - Select `English (US, intl., with dead keys)`
  - Close `X`
- Click `Next`
- Select `Mount point assignment`
- Click `Next`
  - For the `/` Mount point, select the disk where Fedora will be installed: e.g. `nvme0n1p6`
    - Ensure that the `Reformat` switch is on.
  - For the `/boot/efi` Mount point, select the disk with an existing EFI partition: e.g. `nvme1n1p1`
  - For the `/boot` Mount point, click on the trash icon to remove it.
  - Click `Next`
  - Check `I understand that some existing data will be erased`
  - Click `Apply mount point assignment and install`
- Click `Reboot`

PS: If it does not boot into Fedora, go to Windows, open a Terminal in Administrator mode, and run `bcdedit /set "{bootmgr}" path \EFI\fedora\shimx64.efi`, reboot.

### Post Installation

- Start Setup
- Setup Wi-Fi
- Click `Next`
- `Location Services` should already be on
- Click `Next`
- Select your location on the map (ONLY select on the map! There is a bug where searching crashes the installer)
- Click `Next`
- Click `Enable Third-Party Repositories`
- Click `Next`
- Fill in your `Full Name` and `Username`
- Click `Next`
- Fill in your `Password` and `Confirm Password`
- Click `Next`
- Click `Start Using Fedora Linux`
- Skip the `Welcome Tour`
- Open a terminal
- You might have some updates available. Although the script will upgrade, it is a good idea to do it manually and avoid issues when installing the new packages.
- `sudo dnf upgrade --refresh -y`
- If any package is updated, it is a good idea to **reboot** the system.
- `sudo dnf install -y git` (most likely already installed)
- **Important**: before continuing, ensure that if your new system has no Windows or NVIDIA video card, you create the following files to skip the installation.
  - `touch $HOME/.nonvidia`
  - `touch $HOME/.nowindows`
- `git clone https://github.com/dyegoe/dotfiles.git $HOME/dotfiles`
- If your system has Nvidia
  - `$HOME/dotfiles/setup.sh install_nvidia`
  - Wait for the installation to finish. Akmmod will build the driver for the current kernel.
    - `while true; do sudo ps aux |grep akmods |grep -v grep; sleep 1; echo '#####'; done` until the process is finished.
  - Restart the system
  - Once the driver is installed and after the reboot, this command should not output anything: `lsmod |grep nouveau`
- `$HOME/dotfiles/setup.sh install_packages`
- `$HOME/dotfiles/setup.sh upgrade_system`
- `$HOME/dotfiles/setup.sh install`
- `$HOME/dotfiles/setup.sh setup`

Node: The `setup.sh` script can't enable `gnome-extensions` in a single run. To enable the extensions, run the following command:

```bash
$HOME/dotfiles/setup.sh install_gnome_extensions
```

#### Setup 1Password

- Open 1Password and sign in
- Open 1Password
- Select "Unlock using system authentication"
- Click `Continue`
- Click `...` on the top left side
- Select `Settings`
- Select `Developer`
- Mark `Set up the SSH Agent`
- It opens a new window. Select `Use the Key Names`
- Scroll down. Mark `Integrate with 1Password CLI`
- Close the window
- Open a terminal
- `op signin`
- Click `Authorise`

## MacOS

### Alacritty

Alacritty is installed from the official GitHub release DMG rather than Homebrew:

```bash
./setup.sh install_alacritty
```

The installer updates `/Applications/Alacritty.app` and links its CLI into
`$LOCAL_BIN`. It also runs as part of `install` and `full`.
If migrating from Homebrew, run `brew uninstall --cask alacritty` before running
the installer. Homebrew disabled its cask because of macOS Gatekeeper checks;
installing the DMG directly does not make the app notarized. If macOS blocks it,
review the release source before approving it in System Settings > Privacy & Security.
The installer does not disable Gatekeeper or remove quarantine attributes.

### Manual configuration

Git repositories that are work related should be cloned under `~/git/work` directory.
Create the directory if it does not exist.

```bash
mkdir -p ~/git/work
```

And under the `~/git/work/` directory, create `.gitconfig` file with smilar content as below:

```bash
[user]
  name = Dyego Alexandre Eugenio
  email = dyego.alexandre.eugenio@company.example

[commit]
  gpgsign = false

[pull]
  rebase = true

[init]
  defaultBranch = master

[credential "https://git.example.com"]
  username = dyego.alexandre.eugenio
  helper = "!f() { test \"$1\" = get && echo \"password=$(op item get xxxxxxxx --fields xxxxxxx)\"; }; f"
```

## References

### Git Credentials

[Git Credentials](https://git-scm.com/docs/gitcredentials)
[Git Credentials](https://git-scm.com/docs/gitcredentials)
