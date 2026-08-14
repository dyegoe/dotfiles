# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal dotfiles repository, hand-built with bash (no third-party dotfiles manager, no stow/chezmoi/etc). It targets two OSes — Fedora Linux and macOS — from the same script tree, branching on OS/distro where behavior must differ.

## Commands

- `./setup.sh full` — everything: NVIDIA drivers (Fedora only), package install, system upgrade, setup, install.
- `./setup.sh install_packages` — install packages via `dnf` (Fedora) or `brew` (macOS).
- `./setup.sh upgrade_system` — `dnf upgrade` (Fedora only; no-op elsewhere).
- `./setup.sh setup` — run every registered `setup_*` function (symlinks configs into place, dconf/gnome settings, shell completions).
- `./setup.sh install` — run every registered `install_*` function (installs/updates standalone binaries and plugins).
- `./setup.sh install_nvidia` — Fedora-only NVIDIA driver install; skipped if `~/.nonvidia` exists.
- `./setup.sh install_gnome_extensions` — must be run as a separate step after `install`; GNOME won't enable extensions reliably in the same run (see README).
- `./setup.sh <any single function name>` — every `setup_*`/`install_*` function (and helpers like `test`) can be invoked directly, e.g. `./setup.sh setup_git`, `./setup.sh install_eza`. This is the fast path when iterating on one tool.
- `./setup.sh test` — dumps detected `OS`/`OSS`/`DISTRO`/`ARCHM`/`ARCH`/`ARCHS`/XDG paths for debugging environment detection (`setup/test.sh`).
- `./setup.sh help` — lists all registered command names.

There is no build step, linter, or test suite beyond `setup/test.sh`'s environment dump. There are no CI files in this repo.

## Architecture

**Entry point (`setup.sh`) + plugin scripts (`setup/*.sh`).** `setup.sh` sources `zsh/zshenv` for OS/distro detection and XDG paths, defines shared helpers, then `source`s every file in `setup/*.sh`. Each of those files self-registers its functions by appending its own function name(s) to one of two space-separated string variables:

```bash
setup_commands+="setup_foo "
install_commands+="install_foo "
```

`setup()` and `install()` just iterate and eval those lists. This means **adding a new tool = adding a new `setup/<tool>.sh` file** — nothing else needs to be touched to wire it into `full`/`setup`/`install`. Function/file naming convention: `setup_<tool>` for idempotent config/symlink work, `install_<tool>` for downloading/updating a binary or plugin. A file can define one, the other, or both (see `setup/tmux.sh`, `setup/vim.sh`, `setup/talos.sh` for both).

**Two established patterns to follow when adding a script:**

1. **Symlink-with-backup pattern** (used by every `setup_*` that manages a dotfile — see `setup/git.sh`, `setup/tmux.sh`, `setup/vim.sh`): check if the target is a real file (back it up with a timestamp suffix), a symlink to the wrong place (remove it), or a dangling symlink (remove it), then symlink from the repo path. Always idempotent — safe to rerun.
2. **Version-checked binary install pattern** (used by every `install_*` that fetches a GitHub release — see `setup/eza.sh`, `setup/sops.sh`, `setup/talos.sh`): fetch the latest tag via `_curl_github` + `jq`, compare against the installed version, skip if current, otherwise call one of the shared downloader helpers defined in `setup.sh`:
   - `download_tar_gz_local_bin $url $bin_name [$bin_source]`
   - `download_zip_local_bin $url $bin_name [$bin_source]`
   - `download_bin_local_bin $url $bin_name [$bin_source]`
   All three install into `$LOCAL_BIN` (`~/.local/bin`). darwin usually short-circuits early in these functions since Homebrew handles that tool instead (check `brew install` list in `setup.sh`'s `install_packages`).

**OS/distro branching** happens inside each function, not via separate files per OS — the standard shape is `if [[ "$OS" == "darwin" ]]; then ... return; fi` followed by the Linux/Fedora path (or vice versa), using `$OS`, `$DISTRO`, `$ARCH`/`$ARCHM` from `zsh/zshenv`. Where a config file itself differs by OS rather than just its install step, the convention is a `.<os>` suffix and the setup function picks the right one, e.g. `git/gitconfig.darwin` vs `git/gitconfig.linux`, `ssh/config.darwin` vs `ssh/config.linux`, `alacritty/alacritty-darwin.toml` vs `alacritty/alacritty-linux.toml`.

**Shell environment (`zsh/zshenv`)** is the single source of truth for OS/distro detection (`OS`, `OSS`, `DISTRO`, `ARCHM`, `ARCH`, `ARCHS`), XDG base dirs, and all tool-specific env vars (FZF, bat, Go, Terraform/tenv, etc.). It's sourced both by `setup.sh` (for install-time detection) and by the user's actual zsh session. `zsh/zshrc` handles interactive-shell concerns (completions, keybindings, plugin loading, prompt). Both end by sourcing an optional untracked `work.env` / `work.zsh` for machine-local/work-only overrides — don't add work-specific config to the tracked files.

**Config files live in top-level dirs named after the tool** (`tmux/`, `vim/`, `alacritty/`, `git/`, `ssh/`, `oh-my-posh/`) and are symlinked into `$XDG_CONFIG_HOME` (or `$HOME` for dotfiles like `.gitconfig`) by the matching `setup_*` function — they are never edited in place at their symlink destination.

## Conventions to preserve

- Every log line goes through `log_info` / `log_error` (yellow/blue and red/yellow ANSI prefixes) defined once in `setup.sh` — don't use raw `echo`/`printf` for status output in `setup/*.sh`.
- `setup.sh` runs with `set -e -o pipefail`; individual `setup/*.sh` functions rely on early `return` (not `exit`) for OS short-circuits, since they're sourced into the same shell.
- Idempotency matters: `full` and `install`/`setup` are meant to be safe to rerun on an already-provisioned machine (version checks before installing, symlink checks before linking, `git pull` on already-cloned plugin repos).
