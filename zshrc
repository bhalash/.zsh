################################################################################
# ZSH Options
################################################################################

export TERM=xterm-256color

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

# Enable colour output.
autoload colors && colors

# Decrease lag in vim mode: This reduces the timeout between accepted keystrokes to 1ms.
KEYTIMEOUT=1

# vim mode
bindkey -v

################################################################################
# Editor
################################################################################

if [[ -z "$EDITOR" ]]; then
    export EDITOR='/usr/bin/env vim'
fi

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

mark-prompt() {
    # Left prompt: user@hostname folder $ ...
    # PROMPT='%n@%m %1~ $ '
    PROMPT="${${KEYMAP/vicmd/[n]}/(main|viins)/[i]} %n@%m %1~ $ "

    # Right prompt: ... [i/n]
    # RPROMPT="${${KEYMAP/vicmd/[n]}/(main|viins)/[i]}"
    RPROMPT=""
}

mark-prompt

zle-line-init zle-keymap-select() {
    mark-prompt
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

setopt inc_append_history
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
autoload -Uz compinit && compinit -u

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
# Opt out of Homebrew Tracking
################################################################################

export HOMEBREW_NO_ANALYTICS=1

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

    du -axh | sort -n | tail -n $count | sort -r
}

################################################################################
# Copy the Most Recent File in a Given Directory
################################################################################

cp-last() {
    if [[ -d "$1" ]]; then
        echo "cd: ${1}: Not a directory"
        exit 1
    fi

    cp "${1}/$(ls -A1t $1 | head -n 1)" "$2"
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
alias grep='grep --color=auto -E'

################################################################################
# Work Alias Commands
################################################################################

if [[ $(uname) -eq "Darwin" ]]; then
    # See: https://stackoverflow.com/questions/33817282/
    alias du=gdu
fi

alias be='bundle exec'
alias bereset='RAILS_ENV=test be rake db:drop db:create db:migrate'
alias ber='clear; be rspec'
alias bec='RAILS_ENV=development rails c'

################################################################################
# Work S3 Credentials
################################################################################

s3_credentials="${HOME}/.aws_s3_credentials"

if [[ -f $s3_credentials ]]; then
    source $s3_credentials
fi
