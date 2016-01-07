################################################################################
# ZSH Options
################################################################################

# cd with just directory name.
setopt autocd

# Permit shorter loop syntax.
setopt short_loops
setopt function_arg_zero

# Resolve symlinks.
setopt chase_links

# No beeps.
unsetopt beep

# Safe rm.
unsetopt rm_star_silent

autoload colors
colors

# Decrease lag in vim mode: This reduces the timeout between accepted keystrokes
# to 1ms.
KEYTIMEOUT=1

# vim mode
bindkey -v

################################################################################
# Tempdir
################################################################################

if [[ -z $TMPDIR ]] || [[ ! -d "${TMPDIR}" ]]; then
    # $TMPDIR is not declared on my Ubuntu box for some ineffable reason.
    export TMPDIR="/var/tmp/"
    mkdir -p -m 700 "${TMPDIR}"
fi

################################################################################
# Prompt
################################################################################

# Left prompt.
# user@hostname folder $ ...
PROMPT='%n@%m %1~ $ '

function zle-line-init zle-keymap-select {
    # Right prompt.
    # ... [i/n]
    RPROMPT="${${KEYMAP/vicmd/[n]}/(main|viins)/[i]}"
    zle reset-prompt
}

# Remove annoying "%" sign after certain outputs.
# See: https://stackoverflow.com/questions/13660636/what-is-percent-tilde-in-zsh
setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=''

################################################################################
# History
################################################################################

HISTFILE=$HOME/.zhistory
HISTSIZE=2000
SAVEHIST=$HISTSIZE

setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
unsetopt hist_beep

# Bind ctrl + r to history search.
bindkey '^R' history-incremental-search-backward

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
# Node.js Init
################################################################################

# Add node modules to $PATH
path+=('/usr/local/lib/node_modules')

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
# cd to Git Project Root Folder
################################################################################

git-root() {
    if $(git rev-parse 2> /dev/null); then
        builtin cd "$(git rev-parse --show-toplevel)"
    else
        echo "cd: not a git project: ${PWD}"
    fi
}

################################################################################
# See n Biggest Files
################################################################################

big-files() {
    count=10

    if [[ $1 =~ ^[0-9]+$ ]]; then
        count=$1
    fi

    du -axh | sort -n | tail -n ${count} | sort -r
}

################################################################################
# Vim Mode Keybinds
################################################################################

zle -N zle-line-init
zle -N zle-keymap-select

# Backward deletion keybinds in insert mode.
bindkey '^?' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^H' backward-delete-char
bindkey '^U' backward-kill-line

################################################################################
# Command Aliases
################################################################################

alias tmux='tmux -2'
alias rot13='tr a-zA-Z n-za-mN-ZA-M <<<'
alias bf='big-files'
alias gr='git-root'

alias r_reset='RAILS_ENV=test rake db:drop db:create db:migrate'
alias r_console='RAILS_ENV=test script/console'
