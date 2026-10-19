# Linux

Work in progress: bash, i3 and friends.

Shared configs live in [`../shared/`](../shared/). Starship reads [`../shared/starship/starship.toml`](../shared/starship/starship.toml) from `~/.config/starship.toml`.

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
