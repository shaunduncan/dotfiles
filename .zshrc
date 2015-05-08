export TERM="xterm-256color"
ZSH=$HOME/.zsh

# Some dumb ohmyzsh plugins think everyone is using a mac
alias pbcopy='xclip -selection c'

# Load plugins -> extract these
plugins=(
    celery
    copydir
    copyfile
    debian
    django
    docker
    encode64
    fabric
    git
    git-extras
    git-flow
    github
    gnu-utils
    go
    heroku
    jira
    jump
    lol
    med
    mercurial
    pip
    postgres
    python
    tmux
    urltools
    vagrant
    virtualenv
    web-search
)
# MAYBE: vi-mode

source $ZSH/oh-my-zsh.sh

export JAVA_HOME=/usr/local/java/jdk1.7.0_40

# Set custom path
# Apparently we have to put java first
export GOROOT=/opt/golang
export GOPATH=/opt/devel/golang
PATH=$JAVA_HOME/bin:$PATH:/sbin:$HOME/bin:/opt/android/tools:/opt/android/platform-tools:/usr/local/sbin:/opt/neo4j/bin

# Go Things
PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

COMPLETION_WAITING_DOTS="true"

zstyle ':completion:*' use-cache on
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY

setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt glob_complete

# Make rehash happen for installs
zstyle ':completion:*' rehash true

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*'  max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

setopt nonomatch

# No LDAP
zstyle ':completion:*' users {sduncan,root,cmg}

export CLICOLOR=1
export ARCHFLAGS='-arch i386 -arch x86_64'

# PIP CONFIG - ONLY OPERATE IN VIRTUALENV
export PIP_REQUIRE_VIRTUALENV=true
export PIP_RESPECT_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip_cache

# POSTGRES CONFIG
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=postgres
export PGHOST=localhost
export PGDATA=/var/lib/postgresql/9.0/main
export PGCONNECT_TIMEOUT=30

bindkey '^R' history-incremental-search-backward

unsetopt correctall

export EDITOR="`which vim`"



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
alias ack=ack-grep
alias clippy='xclip -selection c'
alias pbcopy='xclip -selection c'
alias ping='ping -c 10'

# This is a hack to control spotify from the terminal
alias spotify_next='dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next'
alias spotify_prev='dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous'
alias spotify_play='dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause'

# tmux UTF-8, always
alias tmux='tmux -u -f ~/.tmux.conf'
alias attach='tmux attach-session'

# FIXME : Once you have things installed
#alias dbstart="`pg_config --bindir`/pg_ctl start -w -l /var/postgres/logs/postgres.log -D $PGDATA"
#alias dbstop="`pg_config --bindir`/pg_ctl stop -w -l /var/postgres/logs/postgres.log -D $PGDATA"

alias curlh='curl -D /dev/stdout -o /dev/null -s -L'
alias curlall='curl -D /dev/stdout -o /dev/stdout -s -L'
alias mcflush='echo "flush_all" | nc localhost 11211'
alias my='mysql -u root -h 127.0.0.1'
alias tree='tree -C'



##############################################################################
# MISC UTILS
##############################################################################
function open() {
    thing=$1
    if [ "$thing" = "" ]; then
        thing="."
    fi
    xdg-open $thing &> /dev/null
}



##############################################################################
# PROMPT CONFIG
##############################################################################
autoload -U colors && colors
autoload -Uz vcs_info

# Color codes: green=046, yellow=226, red=196
zstyle ':vcs_info:*' stagedstr " %{$fg[green]%}●%{$reset_color%}"
zstyle ':vcs_info:*' unstagedstr " %{$fg[yellow]%}●%{$reset_color%}"
zstyle ':vcs_info:*' formats " %{$fg[green]%}%b%{$reset_color%}%c%u"
zstyle ':vcs_info:*' check-for-changes false
zstyle ':vcs_info:*' git-mq false
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:*' enable git svn hg
precmd () {
    #if [[ -z $(git status --porcelain 2> /dev/null | grep "^??") ]] {
    #    zstyle ':vcs_info:*' formats " %{$fg[green]%}%b%{$reset_color%}%c%u"
    #} else {
    #    zstyle ':vcs_info:*' formats " %{$fg[green]%}%b%{$reset_color%}%c%u %{$fg[red]%}●%{$reset_color%}"
    #}
    vcs_info
}

setopt prompt_subst

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

# function zle-keymap-select zle-line-init zle-line-finish {
#     VI_MODE="${${KEYMAP/vicmd/$COMMAND_MODE}/(main|viins)/$INSERT_MODE}"
#     zle reset-prompt
# }
#
# zle -N zle-line-init
# zle -N zle-keymap-select
# bindkey -v

PROMPT='${FROM_VIM}%{$fg[magenta]%}%n@%M%{$reset_color%} $(_venv_name)$(_dirpath)${vcs_info_msg_0_} %{$fg[cyan]%}>>>%{$reset_color%} '



##############################################################################
# VIRTUALENV HELPERS
##############################################################################

# All of this stuff here lets me fire up a subshell and activate
# a virtualenv. Like this:
#
# $ venv /path/to/virtualenv
# (venv) $ exit
# $
#
function venv() {
    export _OLD_DIR=$(pwd)
    export _OLD_PATH=$PATH

    if [ "$1" ]; then
        export VENV_DIR=$(cd $1; pwd)
    else
        export VENV_DIR=$(pwd)
    fi

    # Check if the VENV_DIR/bin/activate exists otherwise fail
    if [ -e "$VENV_DIR/bin/activate" ]; then
        zsh -d
    else
        echo "$VENV_DIR is not a valid virtual environment"
        unset VENV_DIR
    fi

    export PATH=$_OLD_PATH
    cd $_OLD_DIR
    unset _OLD_PATH
    unset _OLD_DIR
    unset VENV_DIR
}

function _venv_deactivate() {
    if [ "$VIRTUAL_ENV" ]; then
        export PATH=$_OLD_PATH
        export PYTHON_HOME=$_OLD_PYTHON_HOME
        unset VIRTUAL_ENV
        unset _OLD_PATH
        unset _OLD_PYTHON_HOME
    fi
}

# This is just a dirty, dirty hack. Since we invoke another shell
if [ "$VENV_DIR" ]; then
    export _OLD_PATH=$PATH
    export _OLD_PYTHON_HOME=$PYTHON_HOME

    export VIRTUAL_ENV=$VENV_DIR
    export PATH=$VENV_DIR/bin:$PATH
    unset PYTHON_HOME

    cd $VENV_DIR
    unset VENV_DIR
fi

# Hack for vim :shell
if [ "$(env | grep VIM)" ]; then
    if [ "$VIRTUAL_ENV" ]; then
        export PATH=$VIRTUAL_ENV/bin:$PATH
    fi
fi

trap _venv_deactivate EXIT
