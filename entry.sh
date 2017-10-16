#!/usr/bin/env bash

# adopted from
# https://github.com/panubo/docker-sshd/blob/master/entry.sh

set -e

#set -x

DAEMON="sshd"

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

echo "Running $@"
if [ "$(basename $1)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    # run these commands as the guest user
    su - guest <<_EOF_
    # setup environment variables usually taken care of by maxwell middleware
    # hardcode the SESSION number
    #export LANG=en_US.UTF-8
    #export LANGUAGE=en_US.UTF-8
    #export LC_ALL=en_US.UTF-8
    export PATH=/bin:/usr/bin:/usr/bin/X11:/sbin:/usr/sbin
    export SESSION=19151
    export SESSIONDIR=\${HOME}/data/sessions/\${SESSION}
    export RESULTSDIR=\${HOME}/data/results/\${SESSION}
    mkdir -p \${SESSIONDIR} \${RESULTSDIR}
    cd \${HOME}
    xvfb-run -s "-screen 0 800x600x24" $@
_EOF_
fi
