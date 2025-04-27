# Dotfiles

## Fedora 42

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
  - For `/` Mount point, select the disk where Fedora will be installed: `nvme1n1p1`
    - Ensure that the `Reformat` switch is on.
  - For `/boot/efi` Mount point, select the disk with an existing EFI partition: `nvme0n1p1`
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
- Search for your Time Zone
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
