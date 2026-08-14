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
- `./setup.sh <any single function name>` — every `setup_*`/`install_*` function (and helpers like `show_env`) can be invoked directly, e.g. `./setup.sh setup_git`, `./setup.sh install_eza`. This is the fast path when iterating on one tool.
- `./setup.sh show_env` — dumps detected `OS`/`OSS`/`DISTRO`/`ARCHM`/`ARCH`/`ARCHS`/XDG paths for debugging environment detection (`setup/test.sh`). `./setup.sh test` still works as an alias, kept for muscle memory — the function itself isn't named `test` anymore because that shadows the shell builtin.
- `./setup.sh help` — lists all registered command names.
- `--dry-run` (or `-n`) — prepend or append to any command to preview every mutating action (symlinks, backups, downloads, `sudo` calls, `dconf write`, ...) without touching the filesystem, e.g. `./setup.sh --dry-run full`, `./setup.sh setup_zsh --dry-run`. Read-only probes (version checks, `command -v`) still run so the preview reflects real state.

There is no build step or test suite beyond `setup/test.sh`'s environment dump (`show_env`). `shellcheck -x setup.sh setup/*.sh lib/*.sh` is the closest thing to a linter; there are no CI files in this repo.

## Architecture

**Entry point (`setup.sh`) + shared library (`lib/*.sh`) + plugin scripts (`setup/*.sh`).** `setup.sh` sources `zsh/zshenv` for OS/distro detection and XDG paths, sources every file in `lib/*.sh`, then `source`s every file in `setup/*.sh`. Each of those files self-registers its functions into one of two arrays:

```bash
setup_commands+=(setup_foo)
install_commands+=(install_foo)
```

`setup()` and `install()` iterate those arrays and invoke each function directly (no `eval`). This means **adding a new tool = adding a new `setup/<tool>.sh` file** — nothing else needs to be touched to wire it into `full`/`setup`/`install`. Function/file naming convention: `setup_<tool>` for idempotent config/symlink work, `install_<tool>` for downloading/updating a binary or plugin. A file can define one, the other, or both (see `setup/tmux.sh`, `setup/vim.sh`, `setup/talos.sh` for both).

**`lib/*.sh` holds the shared helpers** — use these instead of hand-rolling the patterns below:
- `lib/log.sh` — `log_info` / `log_error` / `log_warn` / `log_dry`.
- `lib/run.sh` — `run <cmd...>` wraps every mutating command so `--dry-run` can preview it; `run_write <file> <cmd...>` does the same for `cmd > file`; `skip_on_darwin "<message>"` is the `if [[ "$OS" == "darwin" ]]; then ...; return; fi` guard as a one-liner (`skip_on_darwin "..." && return`).
- `lib/symlink.sh` — `link_config <origin> <target> [display_name]` is the symlink-with-backup pattern (see `setup/git.sh`, `setup/tmux.sh`, `setup/vim.sh` for callers). Idempotent, atomic (temp-link + rename), backs up a real file at `<target>` by copy before replacing it.
- `lib/completion.sh` — `gen_zsh_completion <command> [completion_name]` generates `$ZDOTDIR/functions/_<completion_name>` via `<command> completion zsh`, no-op if the command isn't installed (see `setup/talos.sh`, `setup/cilium.sh`).
- `lib/repo.sh` — `clone_or_pull <url> <dir>` clones or updates a git-based plugin dir (see `setup/zsh.sh`, `setup/vim.sh`, `setup/tmux.sh`).
- `lib/github.sh` — the version-checked release-install pattern (see `setup/eza.sh`, `setup/sops.sh`, `setup/talos.sh`):
  - `gh_latest_tag <owner/repo>` / `gh_asset_url <owner/repo> <asset_name>` — query the GitHub releases API (honors `$GITHUB_TOKEN` if set).
  - `version_is_current <remote_tag> <local_version>` — compares after stripping a leading `v` from both sides.
  - `install_release <download_url> <bin_name> <tar.gz|zip|bin> [bin_source]` — installs a single binary into `$LOCAL_BIN`.
  - `install_release_tree <download_url> <tar.gz|zip>` — for archives with multiple executables at unpredictable paths (`setup/terraform.sh`'s `tenv`, `setup/gitlab.sh`'s `glab`): moves every executable file found into `$LOCAL_BIN`.
  Not every download host is GitHub (`dl.k8s.io`, `get.helm.sh`, `releases.hashicorp.com`, `go.dev`, `gitlab.com`) — callers build their own `download_url` string; there's no URL templating.

**OS/distro branching** happens inside each function, not via separate files per OS — the standard shape is `skip_on_darwin "..." && return` (or a bare `if [[ "$OS" == "darwin" ]]` when the darwin branch does real work rather than skipping) followed by the Linux/Fedora path, using `$OS`, `$DISTRO`, `$ARCH`/`$ARCHM` from `zsh/zshenv`. Where a config file itself differs by OS rather than just its install step, the convention is a `.<os>` suffix and the setup function picks the right one, e.g. `git/gitconfig.darwin` vs `git/gitconfig.linux`, `ssh/config.darwin` vs `ssh/config.linux`, `alacritty/alacritty-darwin.toml` vs `alacritty/alacritty-linux.toml`.

**Shell environment (`zsh/zshenv`)** is the single source of truth for OS/distro detection (`OS`, `OSS`, `DISTRO`, `ARCHM`, `ARCH`, `ARCHS`), XDG base dirs, and all tool-specific env vars (FZF, bat, Go, Terraform/tenv, etc.). It's sourced both by `setup.sh` (for install-time detection) and by the user's actual zsh session — it must stay safe to source from **both** a `set -u` bash script and a real interactive zsh, so guard anything that might be unbound in the bash case (`${FPATH:-}`) rather than assuming zsh's defaults. `zsh/zshrc` handles interactive-shell concerns (completions, keybindings, plugin loading, prompt). Both end by sourcing an optional untracked `work.env` / `work.zsh` for machine-local/work-only overrides — don't add work-specific config to the tracked files.

**Config files live in top-level dirs named after the tool** (`tmux/`, `vim/`, `alacritty/`, `git/`, `ssh/`, `oh-my-posh/`) and are symlinked into `$XDG_CONFIG_HOME` (or `$HOME` for dotfiles like `.gitconfig`) by the matching `setup_*` function — they are never edited in place at their symlink destination.

## Conventions to preserve

- Every log line goes through `log_info` / `log_error` / `log_warn` / `log_dry` (`lib/log.sh`) — don't use raw `echo`/`printf` for status output in `setup/*.sh` or `lib/*.sh`.
- Every mutating command goes through `run` (or `run_write` for redirects) so `--dry-run` stays trustworthy — don't call `ln`, `mv`, `rm`, `mkdir`, `curl -o`, `tar`, `git clone`, `sudo`, `dnf`, `brew`, or `dconf` directly in `setup/*.sh`. Read-only probes (`command -v`, `--version`, GitHub API reads) are called directly.
- `setup.sh` runs with `set -euo pipefail`; individual `setup/*.sh` functions rely on early `return` (not `exit`) for OS short-circuits, since they're sourced into the same shell. Because of `-u`, don't reference `$1`/`$2`/`$3` (etc.) in a function without a default (`${3:-}`) unless the function's contract guarantees they're set. Because of `local x=$(cmd)`, keep declaration and assignment on one line (`local x=$(cmd)`, not `local x; x=$(cmd)`) when `cmd` failing should be non-fatal — splitting them turns a masked failure into a hard abort under `-e`.
- Idempotency matters: `full` and `install`/`setup` are meant to be safe to rerun on an already-provisioned machine (version checks before installing, symlink checks before linking, `git pull` on already-cloned plugin repos).
