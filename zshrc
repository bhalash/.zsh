# Change directory shorthand.
setopt autocd

################################################################################
# Bind <tab> to cd Command
################################################################################

first-tab() {
    if [[ $#BUFFER == 0 ]]; then
        BUFFER="cd "
        CURSOR=3
        zle list-choices
    else
        zle expand-or-complete
    fi
}

zle -N first-tab
bindkey '^I' first-tab

################################################################################
# History
################################################################################

HISTFILE=$HOME/.zhistory
HISTSIZE=2000
SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS

################################################################################
# Command Aliases
################################################################################

alias minify='minify --no-comments'
alias tmux="tmux -2"
alias grep="grep --color=auto"
alias rspec="rspec --color"

################################################################################
# Prompt
################################################################################

# Left prompt.
PROMPT="%n@%m %1~ $ "

# Remove annoying "%" sign after certain outputs.
# See: https://stackoverflow.com/questions/13660636/what-is-percent-tilde-in-zsh
setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=""

################################################################################
# Vim Mode Keybinds
################################################################################

# Decrease lag in vim mode: This reduces the timeout between accepted keystrokes
# to 1ms.
KEYTIMEOUT=1
# vim mode
bindkey -v
# Bind ctrl + r to history search.
bindkey "^R" history-incremental-search-backward

function zle-line-init zle-keymap-select {
    # Right prompt.
    RPROMPT="${${KEYMAP/vicmd/[n]}/(main|viins)/[i]}"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# Backward deletion keybinds in insert mode.
bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^H" backward-delete-char
bindkey "^U" backward-kill-line

################################################################################
# Plugin Init
################################################################################

plugins=(git github history-substring-search)
autoload -Uz compinit && compinit

################################################################################
# Rbenv Init
################################################################################

if type rbenv > /dev/null; then
    eval "$(rbenv init -)"
    path=("$HOME/.rbenv/bin" $path)
fi

################################################################################
# Node Init
################################################################################

# Add node modules to $PATH
path+=('/usr/local/lib/node_modules')
