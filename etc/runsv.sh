#!/bin/bash

DOTDIR=$1
SVDIR=$2
SERVICE_NAME=$3
TARGET=$4
SERVICE_DIR=$SVDIR/$SERVICE_NAME

[ ! -d "$SERVICE_DIR" ] && exit

SERVICE_TARGET=$([ -f "$SERVICE_DIR/target" ] && cat $SERVICE_DIR/target)

([ ! -z "$SERVICE_TARGET" ] && [ "$SERVICE_TARGET" != "$TARGET" ]) && exit

CHILD_PID=

mkdir -p $SERVICE_DIR/stat

# https://stackoverflow.com/questions/2618403/how-to-kill-all-subprocesses-of-shell
kill_descendant_processes() {
	local pid="$1"
	local and_self="${2:-false}"

	if children="$(pgrep -P "$pid")"; then
		for child in $children; do
			kill_descendant_processes "$child" true
		done
	fi

	if [[ "$and_self" == true ]]; then
		kill -TERM "$pid"
	fi
}

sigusr1() {
	kill_descendant_processes $CHILD_PID true

	echo stopped > $SERVICE_DIR/stat/status
	echo -1 > $SERVICE_DIR/stat/exitcode

	rm -rf $SERVICE_DIR/stat/pid $SERVICE_DIR/stat/stop_time

	exit
}

termsig() {
	kill_descendant_processes $CHILD_PID true

	echo killed > $SERVICE_DIR/stat/status
	echo -2 > $SERVICE_DIR/stat/exitcode

	rm -rf $SERVICE_DIR/stat/pid $SERVICE_DIR/stat/stop_time

	exit
}

trap sigusr1 USR1
trap termsig TERM

pushd $SERVICE_DIR
	bash -c "source $DOTDIR/etc/functions.sh; source ./run" 2> $SERVICE_DIR/stat/log >&2 &

	CHILD_PID=$!

	echo $$ > $SERVICE_DIR/stat/pid
	date +%s > $SERVICE_DIR/stat/start_time
	echo running > $SERVICE_DIR/stat/status

	wait

	CODE=$?

	date +%s > $SERVICE_DIR/stat/stop_time
popd

echo $CODE > $SERVICE_DIR/stat/exitcode

[ "$CODE" != "0" ] && {
	echo failed > $SERVICE_DIR/stat/status
} || {
	echo finished > $SERVICE_DIR/stat/status
}

rm -rf $SERVICE_DIR/stat/pid
