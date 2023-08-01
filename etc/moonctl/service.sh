#!/bin/bash

service_main() {
	local argv=("$@")

	SVDIR="$DOTDIR/sv"

	[ ! -d "$SVDIR" ] && {
		echo "The svdir $SVDIR does not exist"
		return
	}

	print_help() {
		echo -e "moonctl service - control the moon services"
		echo -e ""
		echo -e "Usage: "
		echo -e "\thelp\t\tShow this help menu"
		echo -e "\tinit\t\tRun all services inside svdir"
		echo -e "\tstat\t\tGet information about a specific service"
		echo -e "\tlog\t\tRead all logs from service"
		echo -e "\trun\t\tStart a service inside svdir"
		echo -e "\tstop\t\tStop a service inside svdir"
		echo -e "\tkillall\t\tKill all services running"
		echo -e "\tlist-running\tList all services running"
		echo -e ""

		exit
	}

	service_running() {
		SERVICE_DIR=$SVDIR/$1

		[ ! -f "$SERVICE_DIR/stat/pid" ] && return 1

		PID=$(< "$SERVICE_DIR/stat/pid")

		if (ps aux | grep -E "$PID" | grep "runsv.sh") > /dev/null 2>&1; then
			return 0
		fi

		return 1
	}

	service_get_pid() {
		SERVICE_DIR=$SVDIR/$1

		[ -f "$SERVICE_DIR/stat/pid" ] && cat "$SERVICE_DIR/stat/pid"
	}

	service_get_status() {
		SERVICE_DIR=$SVDIR/$1

		[ -f "$SERVICE_DIR/stat/status" ] && cat "$SERVICE_DIR/stat/status" || echo "stopped"
	}

	service_get_start_time() {
		SERVICE_DIR=$SVDIR/$1

		[ -f "$SERVICE_DIR/stat/start_time" ] && cat "$SERVICE_DIR/stat/start_time"
	}

	service_get_stop_time() {
		SERVICE_DIR=$SVDIR/$1

		[ -f "$SERVICE_DIR/stat/stop_time" ] && cat "$SERVICE_DIR/stat/stop_time"
	}

	service_get_logs() {
		SERVICE_DIR=$SVDIR/$1

		[ -f "$SERVICE_DIR/stat/log" ] && cat "$SERVICE_DIR/stat/log"
	}

	service_runsv() {
		service_running $1 && {
			err "The service '$1' is already running\n"
			return
		}

		$DOTDIR/etc/runsv.sh $DOTDIR $SVDIR $1 $2 2> /dev/null >&2 & disown
	}

	service_get_running_services() {
		for service in $(ls -1 $SVDIR); do
			service_running $service && echo $service
		done
	}

	service_stat() {
		local argv=("$@")

		print_help() {
			echo -e "moonctl service stat - get status about a moon service"
			echo -e ""
			echo -e "Usage: stat <sv name>"
			echo -e ""
			
			exit
		}

		[ -z "${argv[0]}" ] && {
			err "No service name provided\n"
			print_help
		}

		SVNAME="${argv[0]}"
		SERVICE_DIR=$SVDIR/$SVNAME

		[ ! -d "$SERVICE_DIR" ] && {
			err "The service '$SVNAME' does not exist!\n"
			exit 1
		}

		[ ! -d "$SERVICE_DIR/stat" ] && {
			err "The service '$SVNAME' was not ran a single time\n"
			exit 1
		}

		{
			STATUS=$(service_get_status $SVNAME)
			PID=$(service_get_pid $SVNAME)

			START_TIME=$(date -d "@$(service_get_start_time $SVNAME)")
			STATUS_TEXT=$STATUS

			[ "$STATUS" = "running" ] && {
				STATUS_TEXT="$STATUS_TEXT (pid: $PID)"
			}

			echo -e "Service '\033[32m$SVNAME\033[m' information:"
			echo -e "\t\033[1mStatus:\033[m $STATUS_TEXT"
			echo -e "\t\033[1mStart time:\033[m $START_TIME"

			[ "$STATUS" != "running" ] && {
				STOP_TIME=$(service_get_stop_time)

				echo -e "\t\033[1mStop time:\033[m $STOP_TIME"
			}

			echo -e "\t\033[1mLogs \033[m(last 10 lines; use 'moonctl service logs $SVNAME' to see all logs):"
			service_get_logs $SVNAME | tail -n 10
		} | less -R
	}

	service_logs() {
		[ ! -d "$SERVICE_DIR" ] && {
		local argv=("$@")

		print_help() {
			echo -e "moonctl service log - read all logs from a moon service"
			echo -e ""
			echo -e "Usage: log <sv name>"
			echo -e ""
			
			exit
		}

		[ -z "${argv[0]}" ] && {
			err "No service name provided\n"
			print_help
		}

		SVNAME="${argv[0]}"
		SERVICE_DIR=$SVDIR/$SVNAME


			err "The service '$SVNAME' does not exist!\n"
			exit 1
		}

		[ ! -d "$SERVICE_DIR/stat" ] && {
			err "The service '$SVNAME' was not ran a single time\n"
			exit 1
		}

		[ ! -f "$SERVICE_DIR/stat/log" ] && {
			err "The service '$SVNAME' has no logs\n"
			exit 0
		}

		service_get_logs $SVNAME | less
	}

	service_run() {
		local argv=("$@")

		print_help() {
			echo -e "moonctl service run - run a service that is in the moon"
			echo -e ""
			echo -e "Usage: run <sv name>"
			echo -e ""
			
			exit
		}

		[ -z "${argv[0]}" ] && {
			err "No service name provided.\n"
			print_help
		}

		SVNAME="${argv[0]}"
		TARGET=${argv[1]:-manual_start}

		service_runsv $SVNAME $TARGET
	}

	service_stop() {
		local argv=("$@")

		print_help() {
			echo -e "moonctl service stop - run a service that is in the moon"
			echo -e ""
			echo -e "Usage: stop <sv name>"
			echo -e ""
			
			exit
		}

		[ -z "${argv[0]}" ] && {
			err "No service name provided.\n"
			print_help
		}

		SVNAME="${argv[0]}"

		service_running $SVNAME || {
			err "The service '$SVNAME' is already stopped.\n"
			exit 1
		}

		PID=$(service_get_pid $SVNAME)

		kill -USR1 $PID && ok "service '$SVNAME' stopped.\n" || err "could not stop service '$SVNAME': 'kill' exited with code %d" $?
	}

	service_list_running() {
		local argv=("$@")

		for service in $(service_get_running_services); do
			echo "Service '$service': $(service_running $service && echo "running (pid: $(service_get_pid $service))" || echo "stopped")"
		done
	}

	service_killall() {
		local argv=("$@")

		for service in $(service_get_running_services); do
			service_stop $service
		done
	}

	service_init() {
		local argv=("$@")

		[ ! -z "${argv[0]}" ] && {
			TARGET=${argv[0]}
		}

		for service in $(ls -1 $SVDIR); do
			([ ! -d "$SVDIR/$service" ] || [ ! -f "$SVDIR/$service/enable" ]) && continue

			service_runsv "$service" "$TARGET" &
		done
	}

	[ -z "${argv[0]}" ] && print_help

	case "${argv[0]}" in
		init)
			service_init ${argv[@]:1}
			;;

		stat)
			service_stat ${argv[@]:1}
			;;

		log)
			service_logs ${argv[@]:1}
			;;

		run)
			service_run ${argv[@]:1}
			;;

		stop)
			service_stop ${argv[@]:1}
			;;

		killall)
			service_killall ${argv[@]:1}
			;;

		list-running)
			service_list_running ${argv[@]:1}
			;;

		help)
			print_help
			;;

		*)
			err "Unknown subcommand: %s\n" ${argv[0]}
			print_help
			;;
	esac
}

