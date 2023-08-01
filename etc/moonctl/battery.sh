#!/bin/bash

battery_main() {
	local argv=("$@")

	print_help() {
		echo -e "moonctl battery - control the battery of the moon"
		echo -e ""
		echo -e "Usage: <subcommand> [BATTERY]"
		echo -e "\tcapacity\t\tGet the capacity of the battery"
		echo -e "\tcharging\t\tVerify if the battery is charging"
		echo -e "\tinfo\t\tGet information about the battery"
		echo -e "\tfollow\t\t"
		echo -e ""

		exit
	}

	find_battery() {
		local argv=("$@")

		ls -1 "/sys/class/power_supply" | while read -r line; do
			if ! grep "${argv[0]}" - > /dev/null <<<"$line"; then
				continue
			fi

			echo "$line"
			return 0
		done

		return 1
	}

	export BATTERY=$(find_battery ${argv[1]:-BAT1})

	battery_is_charging() {
		test -f "$(cat /sys/class/power_supply/$BATTERY/status)" = "Charging" && return 0 || return 1
	}

	battery_get_capacity() {
		cat /sys/class/power_supply/$BATTERY/capacity
	}

	battery_get_icon() {
		if battery_is_charging; then
			echo "battery_charging_full"
			return
		fi

		PERCENTAGE=$(battery_get_capacity)

		case 1 in
			$((PERCENTAGE > 90)))	echo "battery_full"		;;
			$((PERCENTAGE > 71))) 	echo "battery_6_bar"	;;
			$((PERCENTAGE > 71))) 	echo "battery_6_bar"	;;
			$((PERCENTAGE > 57))) 	echo "battery_5_bar"	;;
			$((PERCENTAGE > 42))) 	echo "battery_4_bar"	;;
			$((PERCENTAGE > 28))) 	echo "battery_3_bar"	;;
			$((PERCENTAGE > 20))) 	echo "battery_2_bar"	;;
			$((PERCENTAGE > 10))) 	echo "battery_1_bar"	;;
			*)						echo "battery_0_bar"	;;
		esac
	}

	battery_get_info() {
		printf '{"Capacity": %d, "Icon": "%s"}' "$(battery_get_capacity)" "$(battery_get_icon)"
	}

	[ -z "${argv[0]}" ] && print_help

	[ -z "$BATTERY" ] && {
		err "No battery found, specify at least one battery\n"
		return 1
	}

	case "${argv[0]}" in
		info)
			battery_get_info ${argv[@]:1}
			;;

		icon)
			battery_get_icon ${argv[@]:1}
			;;
		
		capacity)
			battery_get_capacity ${argv[@]:1}
			;;

		*)
			print_help
			;;
	esac
}
