#!/usr/bin/openrc-run
name="telegraf"
description="Telegraf is an agent for collecting, processing, aggregating, and writing metrics"
supervisor=supervise-daemon
command="/usr/bin/telegraf"
command_args="$TELEGRAF_OPTS"
command_user="telegraf:telegraf"
extra_started_commands="reload"

depend() {
        need net
        after firewall
}

reload() {
        ebegin "Reloading $RC_SVCNAME"
        supervise-daemon $RC_SVCNAME --signal HUP
        eend $?
}
