# PowerShell Rice

Windows Terminal + PowerShell 7 setup with Starship, fzf, eza, bat, zoxide and fastfetch, plus a one-command theme switcher.

Set up on 2026-10-19 · Windows 11 · display at 200% scaling (192 DPI)

---

## Quick reference

| Command | What it does |
| --- | --- |
| `theme` | Cycle to the next theme |
| `theme <name>` | Switch to `catppuccin`, `tokyonight`, `gruvbox` or `rosepine` (Tab completes) |
| `ls` | eza listing with icons, directories first |
| `ll` / `la` | Long listing with git status and relative times (`la` includes hidden files) |
| `lt` | Tree view, 2 levels deep |
| `dir` / `gci` | PowerShell `Get-ChildItem` with Terminal-Icons (returns objects you can pipe) |
| `z <dir>` | Jump to a frequently used directory (zoxide) |
| `zi` | Pick a directory interactively with fzf |
| `fzp` | Fuzzy-find a file with a bat syntax-highlighted preview |
| `bat <file>` | `cat` with syntax highlighting |
| `fastfetch` | System info banner (runs automatically in new Windows Terminal tabs) |

| Key | Action |
| --- | --- |
| `Ctrl+T` | fzf file picker (PSFzf), inserts the path at the cursor |
| `Ctrl+R` | fzf history search (PSFzf) |
| `Tab` | Completion menu |
| `→` / `F2` | Accept a suggestion / toggle the suggestion list and inline views |
| `Ctrl+D` | Delete a character, or exit on an empty line |
| `Enter` | Runs the line as usual, and also sets the tab title to the command (see [Tab titles](#tab-titles)) |

### Tab titles

Each Windows Terminal tab shows the **current folder** (`~` for home, `C:\` at a drive root). While a command is running it shows the **command** instead (trimmed to 30 characters), e.g. `git push`, then switches back when the prompt returns.

- Folder: `Invoke-Starship-PreCommand`, a hook Starship calls before every prompt
- Command: a custom PSReadLine `Enter` handler (`RiceAcceptLine`) that sets the title, then calls `AcceptLine`
- This needs `suppressApplicationTitle` to be unset or `false` in Windows Terminal (it's unset). A fixed `tabTitle` in a WT profile also overrides it.

---

## What's installed

| Component | Version | Source | Notes |
| --- | --- | --- | --- |
| PowerShell 7 | 7.6.7 | winget `Microsoft.PowerShell` | Store/MSIX build, default Windows Terminal profile |
| Starship | — | already installed | `C:\Program Files\starship\bin\starship.exe` |
| fzf | — | already installed (winget) | |
| eza | 0.23.5 | winget `eza-community.eza` | |
| bat | 0.26.1 | winget `sharkdp.bat` | |
| fastfetch | 2.70.0 | winget `Fastfetch-cli.Fastfetch` | |
| zoxide | 0.10.0 | winget `ajeetdsouza.zoxide` | |
| PSReadLine | 2.4.5 | PSGallery | Upgraded from the 2.0.0 that ships with 5.1 |
| PSFzf | 2.7.12 | PSGallery | |
| Terminal-Icons | 0.11.0 | PSGallery | |
| DepartureMono Nerd Font | — | `~/Downloads/Font/DepartureMono` | Regular, Mono and Propo (.otf) |
| JetBrainsMono Nerd Font | — | `~/Downloads/Font/JetBrainsMono.zip` | `NerdFont` and `NerdFontMono` variants only (no NL/Propo) |

Fonts are installed **per user** (no admin): copied to `%LOCALAPPDATA%\Microsoft\Windows\Fonts` and registered under `HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts`.

Font family names as Windows reports them:

- `DepartureMono Nerd Font Mono` ← used in the terminal
- `JetBrainsMono NFM` / `JetBrainsMono NF`

---

## Files in this folder

Snapshot of the live config (taken 2026-10-19):

| File | Live location |
| --- | --- |
| [`powershell/profile.ps1`](powershell/profile.ps1) | `~/.config/powershell/profile.ps1` |
| [`powershell/Microsoft.PowerShell_profile.ps1`](powershell/Microsoft.PowerShell_profile.ps1) | both `$PROFILE` files (one-line stub) |
| [`../shared/starship/starship.toml`](../shared/starship/starship.toml) | `~/.config/starship.toml` (shared with Linux) |
| [`windows-terminal/settings.json`](windows-terminal/settings.json) | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |

These are copies, not symlinks. After changing the live files, copy them back here to keep the repo current.

## File layout

```
~/.config/
├── powershell/
│   ├── profile.ps1        # the real profile, shared by PowerShell 5.1 and 7
│   └── theme.txt          # current theme name, written by `theme`
└── starship.toml          # prompt layout + one palette per theme

~/OneDrive/Dokumen/
├── PowerShell/Microsoft.PowerShell_profile.ps1         # PS 7  → dot-sources the shared profile
└── WindowsPowerShell/Microsoft.PowerShell_profile.ps1  # PS 5.1 → dot-sources the shared profile

%LOCALAPPDATA%/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
```

Each `$PROFILE` contains a single line:

```powershell
. "$HOME\.config\powershell\profile.ps1"
```

`profile.ps1` is saved as **UTF-8 with BOM**. Windows PowerShell 5.1 reads BOM-less files as ANSI.

### Profile load order

1. `$RiceThemes` table and the `Set-RiceTheme` / `theme` function
2. PSReadLine: Windows edit mode, history-based suggestions in the list view, Tab opens the completion menu
3. Apply the saved theme to this session only (PSReadLine colors, `FZF_DEFAULT_OPTS`, `BAT_THEME`)
4. PSFzf with the `Ctrl+T` / `Ctrl+R` chords
5. Terminal-Icons, and eza functions replacing the `ls` alias
6. Tab title: `Get-RiceTitle`, the `Invoke-Starship-PreCommand` hook, and the `Enter` handler
7. `starship init`
8. `zoxide init` (must come **after** Starship, because zoxide wraps the prompt)
9. fastfetch greeting, only in an interactive Windows Terminal tab

---

## Theme system

One palette schema is used everywhere: `fg`, `muted`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan` (plus `bg` and `surface` in the profile, for fzf).

| Theme key | Windows Terminal scheme | Starship palette | bat theme |
| --- | --- | --- | --- |
| `catppuccin` | Catppuccin Mocha | `catppuccin` | Catppuccin Mocha |
| `tokyonight` | Tokyo Night | `tokyonight` | `ansi` (uses terminal colors) |
| `gruvbox` | Gruvbox Dark | `gruvbox` | gruvbox-dark |
| `rosepine` | Rose Pine | `rosepine` | `ansi` (uses terminal colors) |

Running `theme <name>`:

- recolors PSReadLine syntax highlighting and suggestions in the current session
- rewrites `FZF_DEFAULT_OPTS` and `BAT_THEME`
- rewrites the `palette = '…'` line in `starship.toml` (Starship re-reads its config every prompt)
- rewrites `colorScheme` in Windows Terminal's `settings.json` (WT hot-reloads it). **Only profiles already using one of the four rice schemes are changed**; WSL, cmd and other profiles keep their own schemes.
- saves the name to `theme.txt` so new shells start with it

Starship palettes override named colors, so the `blue` / `green` / `yellow` styles in `starship.toml` follow the theme automatically. The styles aren't `bold`: Departure Mono has no bold weight, so Windows Terminal fakes it for palette (hex) colors, which smears the icons. Non-palette colors were remapped: `white` → `fg`, `purple` → `magenta`, `black` (root) → `red`, `197` (read-only) → `red`.

### Palettes

| Key | Catppuccin Mocha | Tokyo Night | Gruvbox Dark | Rosé Pine |
| --- | --- | --- | --- | --- |
| bg | `#1e1e2e` | `#1a1b26` | `#282828` | `#191724` |
| surface | `#313244` | `#292e42` | `#3c3836` | `#26233a` |
| muted | `#6c7086` | `#565f89` | `#928374` | `#6e6a86` |
| fg | `#cdd6f4` | `#c0caf5` | `#ebdbb2` | `#e0def4` |
| red | `#f38ba8` | `#f7768e` | `#fb4934` | `#eb6f92` |
| green | `#a6e3a1` | `#9ece6a` | `#b8bb26` | `#31748f` |
| yellow | `#f9e2af` | `#e0af68` | `#fabd2f` | `#f6c177` |
| blue | `#89b4fa` | `#7aa2f7` | `#83a598` | `#9ccfd8` |
| magenta | `#cba6f7` | `#bb9af7` | `#d3869b` | `#c4a7e7` |
| cyan | `#94e2d5` | `#7dcfff` | `#8ec07c` | `#ebbcba` |

### Adding a theme

1. Add an entry to `$RiceThemes` in `profile.ps1` (all palette keys plus `Wt`, `Starship` and `Bat`).
2. Add its name to the `[ValidateSet(...)]` on `Set-RiceTheme`.
3. Add `[palettes.<name>]` to `starship.toml`.
4. Add the color scheme to `schemes` in Windows Terminal's `settings.json`. Its `name` must match `Wt` exactly.

---

## Windows Terminal

Applied to both the **PowerShell** (7) and **Windows PowerShell** (5.1) profiles:

```jsonc
"colorScheme": "Catppuccin Mocha",   // managed by `theme`
"cursorShape": "bar",
"font": { "face": "DepartureMono Nerd Font Mono", "size": 11 },
"opacity": 92,
"useAcrylic": true,
"padding": "12"
```

- `defaultProfile` → `{574e775e-4f2a-5b96-ac1e-a2962a402336}` (the PowerShell 7 dynamic profile, source `Windows.Terminal.PowershellCore`)
- **Font size:** Departure Mono is drawn on an 11px grid, so it's only crisp when the size in pixels is a multiple of 11. Windows Terminal sizes are in points, converted with the scaling of the monitor the window is on (px = pt × DPI / 72), and there's one size per profile, not per monitor:

  | Scaling | Crisp sizes |
  | --- | --- |
  | 100% (96 DPI) | 8.25pt (11px), 16.5pt (22px) |
  | 150% (144 DPI) | 11pt (22px), 16.5pt (33px) |
  | 200% (192 DPI) | 8.25pt (22px), 12.375pt (33px), 16.5pt (44px) |

  16.5pt is the only size crisp at all three. The profile uses 11pt because it looked best on a 1080p monitor at 100%, even though that's 14.7px, off the grid.

---

## Gotchas & notes

- **`ls` returns text, not objects.** Use `gci` or `dir` when piping (`gci | where Length -gt 1MB`).
- **Startup is about 0.85s**, and Terminal-Icons is most of it. Remove `Import-Module Terminal-Icons` if it feels slow; eza still shows icons for `ls`.
- **Predictions are skipped when output is redirected.** PSReadLine refuses to enable them without a VT console, so the profile guards that call. Editor tasks and scripts that load the profile won't error.
- **The fastfetch greeting** only runs when `$env:WT_SESSION` is set, the host is `ConsoleHost` and output isn't redirected. `RICE_GREETED` stops nested shells from repeating it.
- In PS 5.1, `Expand-Archive` refused the font zip. `[IO.Compression.ZipFile]::ExtractToDirectory` worked.
- After installing fonts, fully close **every** Windows Terminal window, or it won't see them.

---

## Restore the previous setup

Backups taken before any changes:

```
C:\Users\abdur\.rice-backup\20261019-134910\
├── Microsoft.PowerShell_profile.ps1   # old PS 5.1 profile
├── starship.toml
└── wt-settings.json
```

```powershell
$bk = "$HOME\.rice-backup\20261019-134910"
Copy-Item "$bk\Microsoft.PowerShell_profile.ps1" "$HOME\OneDrive\Dokumen\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Copy-Item "$bk\starship.toml" "$HOME\.config\starship.toml"
Copy-Item "$bk\wt-settings.json" "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
```

---

## Reproduce on another machine

```powershell
# 1. Tools
'Microsoft.PowerShell','Starship.Starship','junegunn.fzf','eza-community.eza',
'sharkdp.bat','Fastfetch-cli.Fastfetch','ajeetdsouza.zoxide' | ForEach-Object {
    winget install --id $_ -e --source winget --accept-package-agreements --accept-source-agreements
}

# 2. Modules (in PowerShell 7)
Install-PSResource PSFzf, Terminal-Icons -Scope CurrentUser -TrustRepository

#    ...and for Windows PowerShell 5.1 (also upgrades PSReadLine)
#    Install-Module PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
#    Install-Module PSFzf, Terminal-Icons -Scope CurrentUser -Force

# 3. Fonts (per user, no admin) - point $fonts at the extracted .ttf/.otf files
$dest = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$reg  = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
New-Item -ItemType Directory -Force $dest | Out-Null
foreach ($f in $fonts) {
    Copy-Item $f.FullName (Join-Path $dest $f.Name) -Force
    $kind = if ($f.Extension -eq '.otf') { 'OpenType' } else { 'TrueType' }
    New-ItemProperty -Path $reg -Name "$($f.BaseName) ($kind)" -Value (Join-Path $dest $f.Name) -PropertyType String -Force | Out-Null
}

# 4. Config - run from the repo root
$df = '.\windows'
New-Item -ItemType Directory -Force "$HOME\.config\powershell" | Out-Null
Copy-Item "$df\powershell\profile.ps1" "$HOME\.config\powershell\profile.ps1"
Copy-Item '.\shared\starship\starship.toml' "$HOME\.config\starship.toml"

#    the stub goes to BOTH profile paths ($PROFILE differs between pwsh and powershell)
$docs = [Environment]::GetFolderPath('MyDocuments')
foreach ($dir in "$docs\PowerShell", "$docs\WindowsPowerShell") {
    New-Item -ItemType Directory -Force $dir | Out-Null
    Copy-Item "$df\powershell\Microsoft.PowerShell_profile.ps1" "$dir\Microsoft.PowerShell_profile.ps1"
}

# 5. Windows Terminal
#    The repo copy also contains this machine's other profiles (WSL distros, docker-desktop, ...).
#    On a different machine, merge in just the `schemes` entries and the two PowerShell profile
#    blocks rather than overwriting settings.json wholesale.
```
