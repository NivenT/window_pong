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

function get_terminal_id() {
	info=($(xwininfo | grep "Window id"))
	eval "$1=${info[3]}"
}

function clear_screen() {
	for wind in ${windows[@]}; do
		xdotool windowminimize $wind
	done
}

function resize_window() {
	wmctrl -i -R $1
	wmctrl -i -r $1 -b remove,maximized_vert,maximized_horz
	wmctrl -i -r $1 -e 0,-1,-1,$2,$3
}

function move_window() {
	wmctrl -i -R $1
	wmctrl -i -r $1 -b remove,maximized_vert,maximized_horz
	wmctrl -i -r $1 -e 0,$2,$3,-1,-1
}

# Converts given position or dimension from game coordinates to screen coordinates
# Converts along x-axis
function convert_x() {
	eval "$2=$(( (($1*$WIDTH))/100 ))"
}

function convert_y() {
	eval "$2=$(( (($1*$HEIGHT))/100 ))"
}

function draw_window() {
	convert_x $(($2 + $6)) x
	convert_y $3 y
	convert_x $4 w
	convert_y $5 h

	wmctrl -i -R $1
	wmctrl -i -r $1 -b remove,maximized_vert,maximized_horz
	wmctrl -i -r $1 -e 0,$x,$y,$w,$h
}

# Draws the player's paddle at the given height
function draw_paddle1() {
	# height of each individual window
	h1=$(($PADDLE_HEIGHT/${#paddle1winds[@]}))
	# y position of current window
	y1=$1

	for wind in ${paddle1winds[@]}; do
		draw_window $wind $PADDLE_BUFFER $y1 $PADDLE_WIDTH $h1 0
		y1=$(($y1+$h1))
	done
}

function draw_paddle2() {
	# height of each individual window
	h1=$(($PADDLE_HEIGHT/${#paddle1winds[@]}))
	# y position of current window
	y1=$1

	for wind in ${paddle2winds[@]}; do
		draw_window $wind $((100-$PADDLE_BUFFER-$PADDLE_WIDTH)) $y1 $PADDLE_WIDTH $h1 0
		y1=$(($y1+$h1))
	done
}

function draw_score1() {
	if [ $1 -eq 0 ]; then
		draw_window ${score1winds[0]} 37 3 7 3 0
		draw_window ${score1winds[1]} 37 3 7 3 0
		draw_window ${score1winds[2]} 44 3 3 17 0
		draw_window ${score1winds[3]} 40 20 7 3 0
		draw_window ${score1winds[4]} 37 6 3 17 0
	fi
}

function draw_score2() {
	if [ $1 -eq 0 ]; then
		draw_window ${score2winds[0]} 37 3 7 3 16
		draw_window ${score2winds[1]} 37 3 7 3 16
		draw_window ${score2winds[2]} 44 3 3 17 16
		draw_window ${score2winds[3]} 40 20 7 3 16
		draw_window ${score2winds[4]} 37 6 3 17 16
	fi
}

function draw_ball() {
	draw_window $ballwindow $1 $2 $BALL_SIZE $BALL_SIZE 0
}

function draw_game() {
	draw_paddle1 $pos1
	draw_paddle2 $pos2
	draw_score1 $score1
	draw_score2 $score2
	draw_ball $ballx $bally
}

function bounce_ball() {
	if [ $bally -le $BALL_SIZE ] || [ $bally -ge $((100-BALL_SIZE)) ]; then
		ballydir=$((-$ballydir))
	fi
}

function move_ball() {
	bounce_ball
	ballx=$(($ballx + $BALL_X_SPEED*$ballxdir))
	bally=$(($bally + $BALL_Y_SPEED*$ballydir))
}

function handle_input() {
	wmctrl -i -R $termwind

	read input

	if [ "$input" == "w" ]; then
		pos1=$(($pos1-1))
		draw_paddle1 $pos1
	elif [ "$input" == "s" ]; then
		pos1=$(($pos1+1))
		draw_paddle1 $pos1
	elif [ "$input" == "q" ]; then
		echo 'Thanks for playing'
		over=true
	fi
}

# Constants
WIDTH=$1   #Input screen dimensions
HEIGHT=$2

# Program Treats all displays as if they are 100 x 100
PADDLE_WIDTH=3
PADDLE_HEIGHT=25
PADDLE_BUFFER=5

BALL_SIZE=1
BALL_X_SPEED=1
BALL_Y_SPEED=2

# Number of seconds to pause between frames
SLEEP_DURR=0

echo 'Checking number of windows...'

# Get IDs of all windows (except for a few we don't want to mess with)
windows=($(wmctrl -l | grep -v unity | grep -v Xdnd | grep -v Hud | grep -v Desktop | cut -c 1-10))

if [ ${#windows[@]} -lt 13 ]; then
	echo ''
	echo 'You must have at least 13 open windows to play'
	echo 'You only have' ${#windows[@]} 'windows open'
	exit 0
fi

echo 'Please click in the terminal you are running this script from'
get_terminal_id termwind
echo 'The id for this terminal is' $termwind

echo 'Figuring out which windows are usable...'

# Only use windows which can be arbitrarily resized
get_good_windows ${windows[@]} good_windows

if [ ${#good_windows[@]} -lt 13 ]; then
	echo ''
	echo 'You must have at least 13 good windows to play'
	echo 'A window is good if it can be resized to any size'
	echo 'Only' ${#good_windows[@]} 'of your windows are good'

	read -p "Do you want to know which ones are good? " -n 1 -r
	echo ''
	if [[ $REPLY =~ ^[Yy]$ ]]; then 
		for wind in ${good_windows[@]}; do
			get_name $wind name
			echo $wind $name
		done
	fi
	exit 0
fi

echo 'Found' ${#good_windows[@]} 'usable windows'

# Separate windows into their individual functions
score1winds=()
score2winds=()
ballwindow=$good_windows[10]
paddle1winds=()
paddle2winds=()

# Each score number gets 5 windows
# All extra windows are split roughly evenly between the two paddles

half=$(( ((${#good_windows[@]}-11))/2 ))
rest=$((${#good_windows[@]}-11-$half))

for i in $(seq 0 4); do
	score1winds[i]=${good_windows[i]}
done

for i in $(seq 0 4); do
	score2winds[i]=${good_windows[i+5]}
done

for i in $(seq 1 $half); do
	paddle1winds[i-1]=${good_windows[i+10]}
done

for i in $(seq 1 $rest); do
	paddle2winds[i-1]=${good_windows[i+10+$half]}
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

pos1=35
pos2=35
score1=0
score2=0
ballx=50
bally=50
ballxdir=-1
ballydir=1
over=false

move_window $termwind $WIDTH $HEIGHT
clear_screen
draw_game

stty -icanon time 0 min 0
while ! $over; do
	handle_input
	move_ball

	draw_ball $ballx $bally

	sleep $SLEEP_DURR

	if [ $score1 -ge 7 ] || [ $score2 -ge 7 ]; then
		over=true
	fi
done

move_window $termwind 0 0
stty sane