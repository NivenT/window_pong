#!/bin/bash

# Print all Window IDs in an array.
# Used mostly more debugging purposes
function print_winds() {
	cnt=0
	for wind; do
		echo $cnt 'window id:' $wind
		cnt=$(($cnt+1))
	done
	echo ''
}

function get_dimensions() {
	info=($(wmctrl -lG | grep $1))
	eval "$2=${info[4]}"
	eval "$3=${info[5]}"
}

function get_name() {
	info=($(wmctrl -l | grep $1))
	eval "$2=${info[3]}"
}

function resize_window() {
	wmctrl -i -R $1
	wmctrl -i -r $1 -b remove,maximized_vert,maximized_horz
	wmctrl -i -r $1 -e 0,-1,-1,$2,$3
}

function get_good_windows() {
	# Get last argument
	for last; do true; done

	cnt=0
	for wind; do
		if [ "$wind" == "$last" ]; then 
			continue
		fi

		get_dimensions $wind w0 h0

		resize_window $wind 10 10
		get_dimensions $wind w h
		if [ $w -eq 10 ] && [ $h -eq 10 ]; then
			eval "$last[$cnt]=$wind"
			cnt=$(($cnt+1))
		fi

		resize_window $wind $w0 $h0
	done
}

# Draws the player's paddle at the given height
function draw_paddle1() {
	wmctrl -i -R ${paddle1winds[0]}
	wmctrl -i -r ${paddle1winds[0]} -b remove,maximized_vert,maximized_horz
	wmctrl -i -r ${paddle1winds[0]} -e 0,100,100,20,500
}

# Constants
WIDTH=$1   #Input screen dimensions
HEIGHT=$2

# Program Treats all displays as if they are 100 x 100
PADDLE_WIDTH=10
PADDLE_HEIGHT=30
PADDLE_BUFFER=10

echo 'Checking number of windows...'

# Get IDs of all windows (except for a few we don't want to mess with)
windows=($(wmctrl -l | grep -v unity | grep -v Xdnd | grep -v Hud | grep -v Desktop | cut -c 1-10))

if [ ${#windows[@]} -lt 13 ]; then
	echo 'You must have at least 13 open windows to play'
	echo 'You only have' ${#windows[@]} 'windows open'
	exit 0
fi

echo 'Figuring out which windows are usable...'

# Only use windows which can be arbitrarily resized
get_good_windows ${windows[@]} good_windows

if [ ${#good_windows[@]} -lt 13 ]; then
	echo 'You must have at least 13 good windows to play'
	echo 'A window is good if it can be resized to any size'
	echo 'Only' ${#good_windows[@]} 'of your windows are good'
	exit 0
fi

# Separate windows into their individual functions
score1winds=()
score2winds=()
paddle1winds=()
paddle2winds=()

# Each score number gets 5 windows
# All extra windows are split roughly evenly between the two paddles

half=$(( ((${#good_windows[@]}-10))/2 ))
rest=$((${#good_windows[@]}-10-$half))

for i in $(seq 0 4); do
	score1winds[i]=${good_windows[i]}
done

for i in $(seq 0 4); do
	score2winds[i]=${good_windows[i+5]}
done

for i in $(seq 1 $half); do
	paddle1winds[i-1]=${good_windows[i+9]}
done

for i in $(seq 1 $rest); do
	paddle2winds[i-1]=${good_windows[i+9+$half]}
done

# "Block comment"
if [ 1 -eq 0 ]; then
	print_winds ${windows[@]}
	print_winds ${good_windows[@]}
	print_winds ${score1winds[@]}
	print_winds ${score2winds[@]}
	print_winds ${paddle1winds[@]}
	print_winds ${paddle2winds[@]}
fi

echo 'Initializing game...'

draw_paddle1 35
