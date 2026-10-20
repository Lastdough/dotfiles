# ~/.config/powershell/profile.ps1
# Shared by Windows PowerShell 5.1 and PowerShell 7 (both $PROFILE files dot-source this).
#
#   theme              cycle to the next theme (terminal + prompt + fzf + syntax colors)
#   theme <name>       switch to a theme (tab-completes)

$ESC = [char]27
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# ── Themes ──────────────────────────────────────────────────────────────────
# Wt = Windows Terminal scheme, Starship = palette in starship.toml, Bat = bat theme
$RiceThemes = [ordered]@{
    catppuccin = @{ Wt = 'Catppuccin Mocha'; Starship = 'catppuccin'; Bat = 'Catppuccin Mocha'
        bg = '#1e1e2e'; surface = '#313244'; muted = '#6c7086'; fg = '#cdd6f4'
        red = '#f38ba8'; green = '#a6e3a1'; yellow = '#f9e2af'; blue = '#89b4fa'; magenta = '#cba6f7'; cyan = '#94e2d5' }
    tokyonight = @{ Wt = 'Tokyo Night'; Starship = 'tokyonight'; Bat = 'ansi'
        bg = '#1a1b26'; surface = '#292e42'; muted = '#565f89'; fg = '#c0caf5'
        red = '#f7768e'; green = '#9ece6a'; yellow = '#e0af68'; blue = '#7aa2f7'; magenta = '#bb9af7'; cyan = '#7dcfff' }
    gruvbox    = @{ Wt = 'Gruvbox Dark'; Starship = 'gruvbox'; Bat = 'gruvbox-dark'
        bg = '#282828'; surface = '#3c3836'; muted = '#928374'; fg = '#ebdbb2'
        red = '#fb4934'; green = '#b8bb26'; yellow = '#fabd2f'; blue = '#83a598'; magenta = '#d3869b'; cyan = '#8ec07c' }
    rosepine   = @{ Wt = 'Rose Pine'; Starship = 'rosepine'; Bat = 'ansi'
        bg = '#191724'; surface = '#26233a'; muted = '#6e6a86'; fg = '#e0def4'
        red = '#eb6f92'; green = '#31748f'; yellow = '#f6c177'; blue = '#9ccfd8'; magenta = '#c4a7e7'; cyan = '#ebbcba' }
}
$RiceThemeFile = Join-Path $PSScriptRoot 'theme.txt'

function ConvertTo-AnsiFg([string]$Hex) {
    $h = $Hex.TrimStart('#')
    $r, $g, $b = 0, 2, 4 | ForEach-Object { [Convert]::ToInt32($h.Substring($_, 2), 16) }
    "$ESC[38;2;${r};${g};${b}m"
}

function Set-RiceTheme {
    param(
        [ValidateSet('catppuccin', 'tokyonight', 'gruvbox', 'rosepine')]
        [string]$Name,
        # Only recolor this session; don't touch config files (used at startup)
        [switch]$SessionOnly
    )
    $keys = @($RiceThemes.Keys)
    if (-not $Name) {
        $current = if (Test-Path $RiceThemeFile) { (Get-Content $RiceThemeFile -TotalCount 1).Trim() } else { $keys[-1] }
        $Name = $keys[([array]::IndexOf($keys, $current) + 1) % $keys.Count]
    }
    $t = $RiceThemes[$Name]

    Set-PSReadLineOption -Colors @{
        Command          = ConvertTo-AnsiFg $t.blue
        Parameter        = ConvertTo-AnsiFg $t.cyan
        String           = ConvertTo-AnsiFg $t.green
        Variable         = ConvertTo-AnsiFg $t.magenta
        Number           = ConvertTo-AnsiFg $t.yellow
        Keyword          = ConvertTo-AnsiFg $t.magenta
        Type             = ConvertTo-AnsiFg $t.yellow
        Operator         = ConvertTo-AnsiFg $t.cyan
        Comment          = ConvertTo-AnsiFg $t.muted
        Error            = ConvertTo-AnsiFg $t.red
        Default          = ConvertTo-AnsiFg $t.fg
        InlinePrediction = ConvertTo-AnsiFg $t.muted
        ListPrediction   = ConvertTo-AnsiFg $t.blue
    }

    $env:FZF_DEFAULT_OPTS = "--height=45% --layout=reverse --border=rounded --info=inline " +
        "--color=bg+:$($t.surface),bg:-1,fg:$($t.fg),fg+:$($t.fg),hl:$($t.red),hl+:$($t.red)," +
        "border:$($t.muted),prompt:$($t.magenta),pointer:$($t.magenta),marker:$($t.green)," +
        "spinner:$($t.cyan),info:$($t.blue),header:$($t.blue)"
    $env:BAT_THEME = $t.Bat

    if ($SessionOnly) { return }

    $utf8 = New-Object Text.UTF8Encoding $false

    # Starship re-reads its config every prompt, so this applies immediately
    $starshipToml = if ($env:STARSHIP_CONFIG) { $env:STARSHIP_CONFIG } else { Join-Path $HOME '.config\starship.toml' }
    if (Test-Path $starshipToml) {
        $toml = [IO.File]::ReadAllText($starshipToml)
        [IO.File]::WriteAllText($starshipToml, ($toml -replace "(?m)^palette\s*=.*$", "palette = '$($t.Starship)'"), $utf8)
    }

    # Windows Terminal hot-reloads settings.json; only profiles already using one of our schemes are changed
    $wtSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    if (Test-Path $wtSettings) {
        $names = ($RiceThemes.Values | ForEach-Object { [regex]::Escape($_.Wt) }) -join '|'
        $json = [IO.File]::ReadAllText($wtSettings)
        $new = [regex]::Replace($json, "(`"colorScheme`"\s*:\s*`")(?:$names)(`")", "`${1}$($t.Wt)`${2}")
        if ($new -ne $json) { [IO.File]::WriteAllText($wtSettings, $new, $utf8) }
    }

    Set-Content -Path $RiceThemeFile -Value $Name
    Write-Host "theme -> $Name" -ForegroundColor DarkGray
}
Set-Alias theme Set-RiceTheme

# ── PSReadLine ──────────────────────────────────────────────────────────────
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Windows -BellStyle None -HistoryNoDuplicates
# Predictions need a real VT console (fails in redirected/non-interactive hosts)
if (-not [Console]::IsOutputRedirected) {
    $predictionSource = if ($PSVersionTable.PSVersion -ge [version]'7.2') { 'HistoryAndPlugin' } else { 'History' }
    Set-PSReadLineOption -PredictionSource $predictionSource -PredictionViewStyle ListView
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

$startTheme = if (Test-Path $RiceThemeFile) { (Get-Content $RiceThemeFile -TotalCount 1).Trim() } else { 'catppuccin' }
if (-not $RiceThemes.Contains($startTheme)) { $startTheme = 'catppuccin' }
Set-RiceTheme $startTheme -SessionOnly

# ── fzf ─────────────────────────────────────────────────────────────────────
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# fuzzy-find a file with a syntax-highlighted preview
function fzp { fzf --preview 'bat --color=always --style=numbers --line-range=:300 {}' @args }

# ── ls / icons ──────────────────────────────────────────────────────────────
# Terminal-Icons adds icons to Get-ChildItem (dir, gci); ls & friends use eza
Import-Module Terminal-Icons
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
function ls { eza --icons=auto --group-directories-first @args }
function ll { eza -l --icons=auto --group-directories-first --git --time-style=relative @args }
function la { eza -la --icons=auto --group-directories-first --git --time-style=relative @args }
function lt { eza --tree --level=2 --icons=auto --group-directories-first @args }

# ── Tab title ───────────────────────────────────────────────────────────────
# Idle: current folder (~ for home).  While a command runs: the command itself.
function Get-RiceTitle {
    $path = $PWD.ProviderPath
    if ($path -eq $HOME) { return '~' }
    $leaf = Split-Path $path -Leaf
    if ($leaf) { $leaf } else { $path }   # drive root, e.g. C:\
}

# Starship calls this before drawing each prompt
function Invoke-Starship-PreCommand { $Host.UI.RawUI.WindowTitle = Get-RiceTitle }

Set-PSReadLineKeyHandler -Key Enter -BriefDescription RiceAcceptLine -ScriptBlock {
    $line = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $cmd = $line.Trim() -replace '\s+', ' '
    if ($cmd) {
        if ($cmd.Length -gt 30) { $cmd = $cmd.Substring(0, 29) + '…' }
        $Host.UI.RawUI.WindowTitle = $cmd
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# ── Prompt ──────────────────────────────────────────────────────────────────
Invoke-Expression (&starship init powershell)

# zoxide wraps the prompt, so it must come after starship.  z <dir> / zi (interactive via fzf)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# ── Greeting ────────────────────────────────────────────────────────────────
# Only in an interactive Windows Terminal tab, not in editors, scripts or nested shells
if ($env:WT_SESSION -and $Host.Name -eq 'ConsoleHost' -and -not [Console]::IsOutputRedirected -and -not $env:RICE_GREETED) {
    $env:RICE_GREETED = 1
    fastfetch
}
