export PATH=$PATH:~/bin
export PS1="[\u@\h] \w: "

export PIP_RESPECT_VIRTUALENV=true
export PIP_REQUIRE_VIRTUALENV=true

export PGPORT=5432
export PGUSER=postgres
export PGHOST=/var/postgres/sockets
export PGDATA=/var/postgres/data

alias dbstart="`pg_config --bindir`/pg_ctl start -w -l /var/postgres/logs/postgres.log -D $PGDATA"
alias dbstop="`pg_config --bindir`/pg_ctl stop -w -l /var/postgres/logs/postgres.log -D $PGDATA"
function dbload()
{
    restore="`pg_config --bindir`/pg_restore --create -Fc -h $PGHOST -p $PGPORT -U $PGUSER"
    image="$1"
    logfile=/tmp/dbload.log

    exec 4>$logfile
    if [ "${image%.gz}" != "${image}" ]; then
        cat_cmd="zcat -f"
    else
        cat_cmd="cat"
    fi
    pv $image | $cat_cmd | $restore | psql >&4 2>&4
    echo >$4
}

source ~/.bash_common
