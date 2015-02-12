#!/bin/bash
# command simple mpc actions via dmenu

readonly COMMANDS=(toggle next prev up down album artist playlists shuffle)

function mpc_load() {
	mpc -q clear

	if [[ "$1" == "playlist" ]]; then
		mpc -q load "$2"
		mpc shuffle
	else
		mpc search "$1" "$2" | mpc add
	fi
	mpc -q play
}

function dmenu_wrapper() {
	dmenu -i -sb '#81A2BE' -sf '#000000' -nf '#969896' -p "$1:" -h 21\
		-fn 'Source Code Pro-9:normal'
}

function parse_cmd() {
	local $action=$1

	case $action in
		playlists)
			res=$(mpc lsplaylists | dmenu_wrapper "playlist" )
			[[ ! -z $res ]] && mpc_load "playlist" "$res"
			;;

		artist)
			res=$(mpc list artist | sort | uniq -i | dmenu_wrapper "artist")
			[[ ! -z $res ]] && mpc_load "artist" "$res"
			;;

		album)
			res=$(mpc list album | dmenu_wrapper "album")
			[[ ! -z $res ]] && mpc_load "album" "$res"
			;;

		up)
			pulseaudio-ctl up 5
			;;

		down)
			pulseaudio-ctl down 5
			;;

		toggle)
			mpc -q toggle
			;;

		next)
			mpc -q next
			;;

		prev)
			mpc -q prev
			;;

		shuffle)
			mpc -q shuffle
			;;

		*)
			mpc search title "$action" | mpc insert
			;;
	esac
}

main() {
	# start mpd ?
	[[ -z $(pidof mpd) ]] && mpd

	# add commands
	commands=("${COMMANDS[@]}")
	# add all songs
	commands+=("$(mpc list Title)")

	action=$(printf "%s\n" "${commands[@]}" | dmenu_wrapper "MPD")

	[[ ! -z $action ]] && parse_cmd $action
}

main

exit 0
