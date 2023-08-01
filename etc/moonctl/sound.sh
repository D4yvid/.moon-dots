#!/bin/bash

sound_main() {
	local argv=("$@")

	print_help() {
		echo -e "moonctl sound - control the sound played in the moon"
		echo -e ""
		echo -e "Usage: "
		echo -e "\tget-current-port\t\tGet the current sound output port"
		echo -e "\tmedia-session-info\t\tGet the current media session information"
		echo -e ""

		exit
	}

	sound_get_status() {
		playerctl status 2> /dev/null >&2
		CODE=$?

		return $CODE
	}

	sound_get_output_type() {
		SINK_NAME=$(pactl list sinks | grep "Active Port" | awk '{ print substr($0, 15) }')

		echo $SINK_NAME
	}

	sound_get_output_type_formatted() {
		SINK_NAME=$(pactl list sinks | grep "Active Port" | awk '{ print substr($0, 15) }')

		case "$SINK_NAME" in
			*headphones*)	echo "Headphones"	;;
			*speaker*)		echo "This device"	;;
			*)				echo $SINK_NAME		;;
		esac
	}

	sound_get_current_port() {
		local argv=("$@")

		printf '{"CurrentPort": "%s"}' "$(sound_get_output_type)"
	}

	sound_get_current_port_icon() {
		case "$(sound_get_output_type)" in
			*headphones*)
				echo "headphones"
				;;
			*speaker*)
				echo "laptop"
				;;
		esac
	}

	sound_get_current_player_name() {
		playerctl metadata | head -1 | awk '{ print toupper(substr($1, 1, 1)) substr($1, 2); }'
	}

	sound_get_current_player_icon() {
		PLAYER_NAME=$(sound_get_current_player_name)

		case "$PLAYER_NAME" in
			*Firefox*)
				echo -e " "
				;;
			*Spotify*)
				echo -e " "
				;;
			*)
				echo -e "󰌳 "
				;;
		esac
	}

	sound_get_art_url() {
		playerctl metadata | grep "artUrl" | awk '{ n=split($0,arr," "); print arr[n] }' | sed 's/file:\/\///g'
	}

	sound_media_session_info() {
		local argv=("$@")

		JSON='{"Status": "{{status}}", "Volume": {{volume}}, "Album": "{{album}}", "Artist": "{{artist}}", "Title": "{{title}}", "CurrentPort": "%s", "CurrentPortIcon": "%s", "ArtURL": "%s", "PlayerName": "%s", "PlayerIcon": "%s"}'

		if sound_get_status; then
			printf "$(playerctl metadata --format "$JSON")" "$(sound_get_output_type_formatted)" "$(sound_get_current_port_icon)" "$(sound_get_art_url)" "$(sound_get_current_player_name)" "$(sound_get_current_player_icon)"
		else
			echo '{"Status": "NotPlaying", "Volume": 0.0, "Album": "", "Artist": "No artist", "Title": "Music title", "CurrentPort": "No audio playing", "CurrentPortIcon": "close", "ArtURL": "", "PlayerName": "No player found", "PlayerIcon": "󰎈"}'
		fi
	}

	[ -z "${argv[0]}" ] && print_help

	case "${argv[0]}" in
		get-current-port)
			sound_get_current_port ${argv[@]:1}
			;;

		media-session-info)
			sound_media_session_info ${argv[@]:1}
			;;

		*)
			err "Unknown subcommand: %s\n" ${argv[0]}
			print_help
			;;
	esac
}

