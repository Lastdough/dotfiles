# dotfiles

My terminal and desktop configs for Windows and Linux.

| Folder | What's in it |
| --- | --- |
| [`windows/`](windows/) | PowerShell 7 / 5.1 profile with a theme switcher, Windows Terminal settings. See [`windows/README.md`](windows/README.md). |
| [`linux/`](linux/) | Linux configs (bash, i3, ...). Work in progress. |
| [`shared/`](shared/) | Configs used on both: [Starship](https://starship.rs) prompt. |

## Layout

```
dotfiles/
├── shared/
│   └── starship/starship.toml        → ~/.config/starship.toml
├── windows/
│   ├── powershell/                   → ~/.config/powershell/ + $PROFILE stub
│   └── windows-terminal/settings.json
└── linux/
```

The files here are copies, not symlinks. After changing a live config, copy it back here and commit.

## Themes

Four themes, using the same palette keys across PowerShell, Starship, fzf, bat and Windows Terminal: **Catppuccin Mocha**, **Tokyo Night**, **Gruvbox Dark** and **Rosé Pine**. On Windows, `theme <name>` switches all of them at once. The Starship palettes live in [`shared/starship/starship.toml`](shared/starship/starship.toml). On Linux, change the `palette = '…'` line by hand.

## Line endings

[`.gitattributes`](.gitattributes) keeps Linux files (`*.sh`, `*.toml`, everything under `linux/`) as LF and PowerShell files as CRLF, whatever your `core.autocrlf` setting is. Linux scripts with CRLF line endings fail with `$'\r': command not found`.
