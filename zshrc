rpgrep () {
    for pid in $*
    do
        echo $pid
	rpgrep `pgrep -P $pid`
    done
}

sjoin () {
    local IFS=$1
    shift 1
    echo "$*"
}

rless () {
    less -FRX "$@"
}

lid () {
    # displays directories with ls -alh
    # and other files with less
    if [[ -d $1  || -z $1 || $1 == -* ]]; then
        ls -alh --color=yes "$@" | rless
    else
        less -F $1
    fi
}

rwhich () {
    (
        set -euo pipefail
        which "$@" | xargs readlink -f
    )
}

compdef _less rless
compdef _which rwhich # huh, just saw this working, now it doesn't. for rless, it does ... :/

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
#unsetopt nomatch
bindkey -e

autoload -U edit-command-line

zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# reclaim ctrl+s
setopt noflowcontrol

if [ "n$TERM" "==" "ndumb" ]; then
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    unfunction precmd
    unfunction preexec
    PS1='$ '
else
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
    alias tree='tree -C'
    
    # completion using ls colors
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

    zle_highlight=(special region)

    # respect -, /, ... when deleting words
    zle -A vi-backward-word backward-word
    zle -A vi-forward-word forward-word
    zle -A vi-backward-kill-word backward-kill-word
    zle -A vi-backward-kill-word backward-delete-word
fi

# ctrl, alt + left
bindkey "^[[1;5D" emacs-backward-word
bindkey "^[[1;3D" vi-backward-word

# ctrl, alt + right
bindkey "^[[1;5C" emacs-forward-word
bindkey "^[[1;3C" vi-forward-word
