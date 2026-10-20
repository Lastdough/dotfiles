# Linux

Work in progress: bash, i3 and friends.

Shared configs live in [`../shared/`](../shared/). Starship reads [`../shared/starship/starship.toml`](../shared/starship/starship.toml) from `~/.config/starship.toml`.

## Prompt

The shared prompt is two lines: context on the first, a `→` arrow on the second. The hostname (`in 🌐 <host>`) only shows over SSH (`ssh_only = true`), so local machines (Windows, Fedora) leave it out and SSH sessions into pve or an LXC show it. It's keyed off `SSH_CONNECTION`, so it's also missing in `pct enter` / the Proxmox console, and usually after `sudo -i` or `su -`.

A new LXC needs nothing extra: copy the shared `starship.toml`. If its OS has no icon yet, add one to `[os.symbols]`.

The one exception is pve. `bash/pve/.bashrc` points `STARSHIP_CONFIG` at a copy in `~/.cache/starship-pve.toml` where `Debian` uses `⬢` instead of the Nerd Font logo, so pve doesn't look like its Debian LXCs. At login the copy is rebuilt only if `~/.config/starship.toml` or `~/.bashrc` is newer than it.

Edit the shared file, not the cached copy; changes apply on the next login.

## eza

`bash/204/.bashrc` swaps `ls` for eza, using the same flags as the Windows profile. The aliases are only defined when `eza` is on `PATH`, so plain `ls` still works without it.

| Command | What it does |
| --- | --- |
| `ls` | eza listing with icons, directories first |
| `ll` / `la` | Long listing with git status and relative times (`la` includes hidden files) |
| `lt` | Tree view, 2 levels deep |

Install on Debian: `sudo apt install eza`. Use `command ls` (or `\ls`) to get GNU `ls`.

## Termux

`bash/termux/.bashrc` is a trimmed-down `.bashrc` for Termux on Android. It defines the same eza aliases as above and loads fzf's key bindings and completion (`eval "$(fzf --bash)"`). It doesn't load Starship.

Install with `pkg install eza fzf`, then copy the file to `~/.bashrc`. Both are optional: each one is only set up when it's on `PATH`.

Everything in this folder is checked out with LF line endings (see [`../.gitattributes`](../.gitattributes)).
