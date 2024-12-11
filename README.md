# Dotfiles

## Fedora 41

### Installation

- Select `English (United Kingdom)` as the language
- Click `Continue`
- Click on `Keyboard`
  - Click on `+`
  - Add `English (US, intl., with dead keys)`
  - Select the previous keyboard, `English (UK)`
  - Click on `-` to remove
  - Click `Done`
- Click on `Installation Destination`
  - Select the disks (or disk if you have one). In my specific case, I have two disks. One has Windows and holds the EFI.
  - For `Storage Configuration`, select `Advanced Custom (Blivet-GUI)`
  - Click `Done`
  - Select the disk with an existing EFI partition (my case is Gigabyte).
  - Select the EFI partition and set the mount point as `/boot/efi`
  - Select the disk where Fedora will be installed (my case is Kingston).
  - If there is a partition, remove it (click on `(x)`)
  - Click on `x` to add a partition
    - Filesystem: `ext4`
    - Label: `fedora`
    - Mount point: `/`
    - Click `OK`.
  - Click `Done`
- Begin installation

### Post Installation

- Start Setup
- Enable third-party packages
- Open a terminal
- `sudo dnf install -y git`
- `git clone https://github.com/dyegoe/dotfiles.git $HOME/dotfiles`
- `cd dotfiles`
- `./setup.sh full`
- Wait for the installation to finish. Akmmod will build the driver for the current kernel.
  - `sudo ps aux |grep akmods |grep -v grep` until the process is finished.
- `reboot`
- Once the driver is installed and after the reboot, this command should not output anything: `lsmod |grep nouveau`

Node: The `setup.sh` script is unable to enable the `gnome-extensions` in a single run. To enable the extensions, run the following command:

```bash
$HOME/dotfiles/setup.sh install_gnome_extensions
```

#### Setup 1Password

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
