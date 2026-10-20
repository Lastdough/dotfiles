# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "$(dircolors)"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Proxmox: shared starship.toml with the ⬢ icon, so pve doesn't look like its Debian LXCs
if [ -f ~/.config/starship.toml ]; then
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
    export STARSHIP_CONFIG="${XDG_CACHE_HOME:-$HOME/.cache}/starship-pve.toml"
    # Rebuild only when the shared config or this file (the sed below) is newer than the copy
    if [ ~/.config/starship.toml -nt "$STARSHIP_CONFIG" ] || [ ~/.bashrc -nt "$STARSHIP_CONFIG" ]; then
        sed -e "s/^Debian = .*/Debian = '⬢'/" \
            ~/.config/starship.toml > "$STARSHIP_CONFIG"
    fi
fi
eval "$(starship init bash)"