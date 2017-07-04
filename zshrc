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

# Enable color output.
autoload colors && colors

# Decrease lag in vim mode: This reduces the timeout between accepted keystrokes to 1ms.
KEYTIMEOUT=1

# vim mode
bindkey -v

################################################################################
# Editor
################################################################################

if [[ -z "$EDITOR" ]]; then
    export EDITOR='vim'
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

#
# Wrap $1 in a given color, with a fallback to color 15 (white).
#

function user-prompt-color {
    echo "%F{${2:-15}}${1}%f"
}

#
# Username prompt.
#

function user-prompt {
    USER_PROMPT=$(user-prompt-color '%n' ${1:-246})

    if [[ $(id -u) == 0 ]]; then
        USER_PROMPT=$(user-prompt-color '%n' ${2:-15})
    fi

    echo "${USER_PROMPT}"
}

#
# Hostname prompt.
#

function host-prompt {
    echo $(user-prompt-color '%m' ${1:-246})
}

#
# Set vi-style prompt colors.
#

function vi-prompt {
    VI_BEFORE=$(user-prompt-color '[' ${1:-246})
    VI_AFTER=$(user-prompt-color ']' ${2:-246})

    VI_NORMAL="${VI_BEFORE}$(user-prompt-color n ${3:-15})${VI_AFTER}"
    VI_INSERT="${VI_BEFORE}$(user-prompt-color i ${3:-15})${VI_AFTER}"

    echo "${${KEYMAP/vicmd/${VI_NORMAL}}/(main|viins)/${VI_INSERT}}"
}

#
# Set prompt for current working directory.
#

function dir-prompt {
    DIR_PROMPT=''
    echo $(user-prompt-color "%1~" ${1:-246})
}

#
# Bring together all of the above elements for left and right prompts.
#

function mark-prompt {
    PROMPT="%B$(vi-prompt) $(user-prompt)@$(host-prompt):$(dir-prompt) $ %b"
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

HISTFILE=$HOME/.zsh_history
HISTSIZE=2000
SAVEHIST=$HISTSIZE

setopt INC_APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
unsetopt HIST_BEEP

# Bind ctrl + r to history search.
bindkey '^R' history-incremental-search-backward

if [[ ! -f $HISTFILE ]]; then
    # Create $HISTFILE if it does not exist.
    touch $HISTFILE
fi

################################################################################
# Plugin Init
################################################################################

plugins=(git github history-substring-search)
autoload -Uz compinit && compinit -u

################################################################################
# Node.js Init
################################################################################

# Add node modules to $PATH
path+=('/usr/local/lib/node_modules')

################################################################################
# Elastic Beanstalk Init
################################################################################

# NOTE: Check installed path per os.
# TODO: Add per OS path.
# NOTE: AWS instructions are bogus for macOS and zsh: absolute path should be
#       used. Relative paths are ignored.
#
# SEE: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html?icmpid=docs_elasticbeanstalk_console

function add-eb-path {
    local PYTHON_SHORT_VERSION=$(python --version 2>&1 | sed -E 's/^.*[[:space:]]//;s/\.[[:digit:]]{2,}//')
    local EB_PATH="${HOME}/Library/Python/${PYTHON_SHORT_VERSION}/bin"

    if [[ -d $EB_PATH ]]; then
        path+=($EB_PATH)
    fi
}

add-eb-path

################################################################################
# Opt out of Homebrew Tracking
################################################################################

export HOMEBREW_NO_ANALYTICS=1

################################################################################
# Bind <tab> to cd Command
################################################################################

function first-tab {
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

function git-root {
    if $(git rev-parse 2> /dev/null); then
        builtin cd "$(git rev-parse --show-toplevel)"
    else
        echo "cd: not a git project: ${PWD}"
    fi
}

################################################################################
# See n Biggest Files
################################################################################

function big-files {
    count=10

    if [[ $1 =~ ^[0-9]+$ ]]; then
        count=$1
    fi

    du -axh | sort -n | tail -n $count | sort -r
}

################################################################################
# Copy the Most Recent File in a Given Directory
################################################################################

function cp-last {
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
alias grep='grep --color=auto'
alias agu='sudo apt-get update && sudo apt-get -y dist-upgrade'

################################################################################
# Work Config
################################################################################

if [[ -f "${HOME}/.zsh/work.conf" ]]; then
    source "${HOME}/.zsh/work.conf"
fi

export PATH="${PATH}:${HOME}/.rvm/bin"
