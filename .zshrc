# vars
platform=$(uname -s | tr '[:upper:]' '[:lower:]')

##############################################################################
# ZSH OPTS
##############################################################################

# multiple redirects become implicit tee/cat
setopt multios

# .zsh_history
setopt share_history
setopt append_history
setopt inc_append_history
setopt extended_history
setopt hist_no_store

# tab completion uses menu format
setopt auto_menu

# tab completion does more fuzzy matching rather than just suffix matching
setopt complete_in_word

# move cursor to end of word after completion
setopt always_to_end
setopt glob_complete

# disable error message if no match
setopt nonomatch

# movement behavior
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent

unsetopt correctall
setopt prompt_subst
setopt auto_remove_slash

##############################################################################
# ZSH PLUGINS
##############################################################################
autoload -U colors && colors
autoload -Uz vcs_info
autoload -Uz compinit

##############################################################################
# ZSH COMPLETION
##############################################################################

COMPLETION_WAITING_DOTS="false"

# use cache
zstyle ':completion:*' use-cache on

# use rehash to handle new installs and use menu selection
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu select

# case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''

zstyle ':completion:*:*:make:*' tag-order 'targets'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*'  max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

compinit -C

##############################################################################
# ZSH HISTORY
##############################################################################

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

##############################################################################
# ENVIRONMENT
##############################################################################

export CLICOLOR=1
export ARCHFLAGS='-arch i386 -arch x86_64'

# pip config
export PIP_RESPECT_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip_cache

bindkey '^R' history-incremental-search-backward

# default editor
export EDITOR="`which vim`"

# golang
export GO111MODULE=on
export PATH=$(go env GOROOT)/bin:$(go env GOPATH)/bin:$PATH

# platform-specific things
if [[ "${platform}" == "linux" ]]; then
    # --user installed pip
    export PATH=$PATH:$HOME/.local/bin

    # This was some weird xfce thing with tmux panes
    export DBUS_SESSION_BUS_ADDRESS=$(tr '\0' '\n' < /proc/$(pgrep -U $(whoami) xfce4-session)/environ|grep ^DBUS_SESSION_BUS_ADDRESS=|cut -d= -f2-)
elif [[ "${platform}" == "darwin" ]]; then
    # --user installed pip
    export PATH=~/Library/Python/3.9/bin:$PATH

    # this makes the directories on mac blue and not cyan
    export LSCOLORS=Exfxcxdxbxegedabagacad
fi

# load secrets
if [ -f ~/.secrets.env ]; then
    source ~/.secrets.env
fi

##############################################################################
# ALIASES
##############################################################################
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color'
alias myshell="ps -p $$ | tail -1 | awk '{print $NF}'"
alias vi='vim'
alias fucking='sudo'
alias ping='ping -c 10'

# linux-only
if [[ "${platform}" == "linux" ]]; then
    alias pbcopy='xclip -selection c'
elif [[ "${platform}" == "darwin" ]]; then
    # uncomment if using exa
    # alias ls="exa --color"
    # alias ll="exa --color -lh"
    # alias la="exa --color -lAh"
fi

# tmux UTF-8, always
alias tmux='tmux -u -f ~/.tmux.conf'
alias attach='tmux attach-session'
alias curlh='curl -D /dev/stdout -o /dev/null -s -L'
alias curlall='curl -D /dev/stdout -o /dev/stdout -s -L'
alias tree='tree -C'

##############################################################################
# MISC UTILS
##############################################################################
if [[ "${platform}" == "linux" ]]; then
    # shorthand for xdg-open
    function open() {
        thing=$1
        if [ "$thing" = "" ]; then
            thing="."
        fi
        xdg-open $thing &> /dev/null
    }
fi


##############################################################################
# PROMPT CONFIG
##############################################################################

# Color codes: green=046, yellow=226, red=196
zstyle ':vcs_info:*' stagedstr " %{$fg[green]%}●%{$reset_color%}"
zstyle ':vcs_info:*' unstagedstr " %{$fg[yellow]%}●%{$reset_color%}"
zstyle ':vcs_info:*' formats " %{$fg[green]%}%b%{$reset_color%}%c%u"
zstyle ':vcs_info:*' check-for-changes false
zstyle ':vcs_info:*' git-mq false
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:*' enable git
precmd () {
    vcs_info
}

# Only show last 50 chars. Show '..' for the truncation
function _dirpath() {
    echo "%{$fg[cyan]%}$(perl -pl0 -e "s|^${HOME}|~|;s|([^/])[^/]*/|$""1/|g" <<<${PWD})%{$reset_color%}"
}

function _venv_name() {
    if [ "$VIRTUAL_ENV" ]; then
        echo "%{$fg[yellow]%}(`basename $VIRTUAL_ENV`)%{$reset_color%} "
    fi
}

if [ "$(env | grep VIM)" ]; then
    FROM_VIM="%{$fg[red]%}[V]%{$reset_color%} "
fi

COMMAND_MODE="%{$fg[red]%}<<<%{$reset_color%}"
INSERT_MODE="%{$fg[cyan]%}>>>%{$reset_color%}"
VI_MODE=$INSERT_MODE

PROMPT='${FROM_VIM}%{$fg[yellow]%}%T%{$reset_color%} %{$fg[magenta]%}%n@%m%{$reset_color%} $(_venv_name)$(_dirpath)${vcs_info_msg_0_} %{$fg[cyan]%}>>>%{$reset_color%} '
