# eza replaces ls when installed -> refer to dotfile repo
  if command -v eza >/dev/null 2>&1; then
      alias ls='eza --icons=auto --group-directories-first'
      alias ll='eza -l --icons=auto --group-directories-first --git --time-style=relative'
      alias la='eza -la --icons=auto --group-directories-first --git --time-style=relative'
      alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
  fi

  # fzf key bindings and completion, only when installed
  if command -v fzf >/dev/null 2>&1; then
      eval "$(fzf --bash)"
  fi

eval "$(starship init bash)"
