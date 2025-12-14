# Dotfiles

## Fedora 43

### Installation

- For Language: Select `English (United Kingdom)`
- For Keyboard: `Change system keyboard layout`
  - Click `+ Add Input Source`
  - Click `English (United States)`
  - Select `English (US, intl., with dead keys)`
  - Select the previous keyboard, `English (US)`
  - Click `...` and `Remove`
  - Close `X`
- Click `Next`
- Click on `Change Destination`
  - Select the disks (or disk if you have one). In my specific case, I have two disks:
    - Gigabyte (SSD) nvme0n1
    - Kingston (SSD) nvme1n1
  - Select `Mount point assignment`
  - Click `Next`
  - For `/` Mount point, select the disk where Fedora will be installed: e.g. `nvme0n1p1`
    - Ensure that the `Reformat` switch is on.
  - For `/boot/efi` Mount point, select the disk with an existing EFI partition: e.g. `nvme1n1p1`
  - For `/boot` Mount point, click on the trash icon to remove it.
  - Click `Next`
  - Check the `I understand that some existing data will be erased`
  - Click `Apply mount point assignment and install`
- Click `Exit to live desktop`
- And restart the system

### Post Installation

- Start Setup
- `English (United Kingdom)` should be already selected
- Click `Next`
- `English (US, intl., with dead keys)` should be already selected
- Click `Next`
- `Location Services` should be already on
- `Automatic Problem Reporting` should be already on
- Click `Next`
- Select your location on the map (ONLY select in the map! There is a bug where searching crashes the installer)
- Click `Next`
- Click `Enable Third-Party Repositories`
- Click `Next`
- Fill in your `Full Name`, `Username`
- Click `Next`
- Fill in your `Password`, and `Confirm Password`
- Click `Next`
- Click `Start Using Fedora Linux`
- Skip the `Welcome Tour`
- Open a terminal
- You might have some updates available. Although the script will upgrade, it is good idea to do it manually and avoid issues when installing the new packages.
- `sudo dnf upgrade --refresh -y`
- If any package is updated, it is a good idea to **reboot** the system.
- `sudo dnf install -y git` (most likely already installed)
- **Important**, before continuing, ensure that if your new system has no windows or nvidia video card, you create the followig files to skip the installation.
  - `touch $HOME/.nonvidia`
  - `touch $HOME/.nowindows`
- `git clone https://github.com/dyegoe/dotfiles.git $HOME/dotfiles`
- `$HOME/dotfiles/setup.sh install_nvidia`
- Wait for the installation to finish. Akmmod will build the driver for the current kernel.
  - `while true; do sudo ps aux |grep akmods |grep -v grep; sleep 1; echo '#####'; done` until the process is finished.
- Restart the system
- Once the driver is installed and after the reboot, this command should not output anything: `lsmod |grep nouveau`
- `$HOME/dotfiles/setup.sh install_packages`
- `$HOME/dotfiles/setup.sh upgrade_system`
- `$HOME/dotfiles/setup.sh setup`
- `$HOME/dotfiles/setup.sh install`

Node: The `setup.sh` script is unable to enable the `gnome-extensions` in a single run. To enable the extensions, run the following command:

```bash
$HOME/dotfiles/setup.sh install_gnome_extensions
```

#### Setup 1Password

- Open 1Password and sign in
- Open 1Password
- Click `...` on left top side
- Select `Settings`
- Select `Developer`
- Mark `Set up the SSH Agent`
- It opens a new window. Select `Use the Key Names`
- Scroll down. Mark `Integrate with 1Password CLI`
- Close the window
- Open a terminal
- `op signin`
- Click `Authorize`

## MacOS

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
