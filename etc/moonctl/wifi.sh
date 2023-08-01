#!/bin/bash

wifi_main() {
	local argv=("$@")

	print_help() {
		echo -e "moonctl wifi - control all wifi networks in the moon"
		echo -e ""
		echo -e "Usage: "
		echo -e "\tinfo\t\tShow all information about the current wifi network in the moon"
		echo -e ""

		exit
	}

	wifi_get_name() {
		iwctl station wlan0 show | grep "Connected network" | awk '{ sub(/[ \t]+$/, ""); print(substr($0,35)); }'
	}

	wifi_get_signal() {
		while read -r line; do
			[ "$(echo "$line" | awk '{ print $2 }')" != "$(echo -ne "\x1b[1;90m>")" ] && continue

			SIG_STR="$(echo "$line" | awk '{ print $6 }')"
			SIGNAL=0

			for ((i = 0; i < ${#SIG_STR}; i++)); do
				if [ "${SIG_STR:i:1}" != "*" ]; then
					break
				fi

				SIGNAL=$((SIGNAL+1))
			done

			echo -n "$SIGNAL"
			break
		done < <(iwctl station wlan0 get-networks | grep '>')
	}

	wifi_is_connected() {
		[ "$(iwctl station wlan0 show | grep "State" | awk '{ print $2 }')" = "connected" ] && return 0 || return 1
	}

	wifi_get_icon() {
		! wifi_is_connected && {
			echo -n "signal_wifi_off"
			return
		}

		SIGNAL=$(wifi_get_signal)

		case "$SIGNAL" in
			1|2|3)
				echo -n "network_wifi_${SIGNAL}_bar"
				;;

			4|0)
				echo -n "signal_wifi_${SIGNAL}_bar"
				;;

			*)
				;;
		esac
	}

	wifi_info() {
		printf '{"Connected": %s, "NetworkName": "%s", "Signal": %d, "Icon": "%s"}' "$(wifi_is_connected && echo true || echo false)" "$(wifi_get_name)" "$(wifi_get_signal)" "$(wifi_get_icon)"
	}

	[ -z "${argv[0]}" ] && print_help

	case "${argv[0]}" in
		info)
			wifi_info ${argv[@]:1}
			;;

		is_connected)
			wifi_is_connected
			;;

		*)
			;;
	esac
}

