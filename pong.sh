#!/bin/bash

###########################
###      Constants      ###
###########################
# Program Treats all displays as if they are 100 x 100
PADDLE_WIDTH=3
PADDLE_HEIGHT=25
PADDLE_BUFFER=5

BALL_SIZE=1
BALL_X_SPEED=2
BALL_Y_SPEED=5

PLAYER_SPEED=4
COMPUTER_SPEED=5

# Number of seconds to pause between frames
FRAME_SLEEP_DURR=0
OVER_SLEEP_DURR=10

# Largest score that drawing has been implemented for
MAX_SCORE=7


###########################
###      Functions      ###
###########################

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

function get_screen_dimensions() {
	info=($(xrandr | grep current))
	eval "$1=${info[7]}"
	eval "$2=$(echo ${info[9]} | rev | cut -c 2- | rev)"
}

function get_position() {
	info=($(wmctrl -lG | grep $1))
	eval "$2=${info[2]}"
	eval "$3=${info[3]}"
}

function get_dimensions() {
	info=($(wmctrl -lG | grep $1))
	eval "$2=${info[4]}"
	eval "$3=${info[5]}"
}

function get_name() {
	info=($(wmctrl -l | grep $1))
	eval "$2=\"${info[@]:3}\""
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

function get_window_states() {
	for last; do true; done

	cnt=0
	for wind; do
		if [ "$wind" == "$last" ]; then
			continue
		fi

		get_position $wind x y
		get_dimensions $wind w h

		eval "$last[$cnt]=\"$wind $x $y $w $h\""
		cnt=$(($cnt+1))
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
	h1=$(($PADDLE_HEIGHT/${#paddle2winds[@]}))
	# y position of current window
	y1=$1

	for wind in ${paddle2winds[@]}; do
		draw_window $wind $((100-$PADDLE_BUFFER-$PADDLE_WIDTH)) $y1 $PADDLE_WIDTH $h1 0
		y1=$(($y1+$h1))
	done
}

# Numbers generally drawn in a 10x20 box 3 units from the center and 3 units from the top
function draw_score1() {
	if [ $1 -eq 0 ]; then
		draw_window ${score1winds[0]} 37 3 7 3 0
		draw_window ${score1winds[1]} 37 3 7 3 0
		draw_window ${score1winds[2]} 44 3 3 17 0
		draw_window ${score1winds[3]} 40 20 7 3 0
		draw_window ${score1winds[4]} 37 6 3 17 0
	elif [ $1 -eq 1 ]; then
		draw_window ${score1winds[0]} 40 3 4 20 0
		draw_window ${score1winds[1]} 40 3 4 20 0
		draw_window ${score1winds[2]} 40 3 4 20 0
		draw_window ${score1winds[3]} 40 3 4 20 0
		draw_window ${score1winds[4]} 40 3 4 20 0
	elif [ $1 -eq 2 ]; then
		draw_window ${score1winds[0]} 37 3 7 3 0
		draw_window ${score1winds[1]} 44 3 3 8 0
		draw_window ${score1winds[2]} 40 11 7 3 0
		draw_window ${score1winds[3]} 37 11 3 9 0
		draw_window ${score1winds[4]} 37 20 10 3 0
	elif [ $1 -eq 3 ]; then
		draw_window ${score1winds[0]} 37 3 10 4 0
		draw_window ${score1winds[1]} 44 7 3 4 0
		draw_window ${score1winds[2]} 37 11 10 4 0
		draw_window ${score1winds[3]} 44 15 3 4 0
		draw_window ${score1winds[4]} 37 19 10 4 0
	elif [ $1 -eq 4 ]; then
		draw_window ${score1winds[0]} 37 3 3 10 0
		draw_window ${score1winds[1]} 37 3 3 10 0
		draw_window ${score1winds[2]} 37 10 10 3 0
		draw_window ${score1winds[3]} 37 10 10 3 0
		draw_window ${score1winds[4]} 44 3 3 20 0
	elif [ $1 -eq 5 ]; then
		draw_window ${score1winds[0]} 40 3 7 3 0
		draw_window ${score1winds[1]} 37 3 3 8 0
		draw_window ${score1winds[2]} 37 11 7 3 0
		draw_window ${score1winds[3]} 44 11 3 12 0
		draw_window ${score1winds[4]} 37 20 7 3 0
	elif [ $1 -eq 6 ]; then
		draw_window ${score1winds[0]} 40 3 7 3 0
		draw_window ${score1winds[1]} 37 3 3 17 0
		draw_window ${score1winds[2]} 37 20 7 3 0
		draw_window ${score1winds[3]} 44 13 3 10 0
		draw_window ${score1winds[4]} 40 13 7 3 0
	elif [ $1 -eq 7 ]; then
		draw_window ${score1winds[0]} 37 3 3 5 0
		draw_window ${score1winds[1]} 40 3 7 3 0
		draw_window ${score1winds[2]} 44 6 3 17 0
		draw_window ${score1winds[3]} 37 3 3 5 0
		draw_window ${score1winds[4]} 37 3 3 5 0
	fi
}

function draw_score2() {
	if [ $1 -eq 0 ]; then
		draw_window ${score2winds[0]} 37 3 7 3 16
		draw_window ${score2winds[1]} 37 3 7 3 16
		draw_window ${score2winds[2]} 44 3 3 17 16
		draw_window ${score2winds[3]} 40 20 7 3 16
		draw_window ${score2winds[4]} 37 6 3 17 16
	elif [ $1 -eq 1 ]; then
		draw_window ${score2winds[0]} 40 3 4 20 16
		draw_window ${score2winds[1]} 40 3 4 20 16
		draw_window ${score2winds[2]} 40 3 4 20 16
		draw_window ${score2winds[3]} 40 3 4 20 16
		draw_window ${score2winds[4]} 40 3 4 20 16
	elif [ $1 -eq 2 ]; then
		draw_window ${score2winds[0]} 37 3 7 3 16
		draw_window ${score2winds[1]} 44 3 3 8 16
		draw_window ${score2winds[2]} 40 11 7 3 16
		draw_window ${score2winds[3]} 37 11 3 9 16
		draw_window ${score2winds[4]} 37 20 10 3 16
	elif [ $1 -eq 3 ]; then
		draw_window ${score2winds[0]} 37 3 10 4 16
		draw_window ${score2winds[1]} 44 7 3 4 16
		draw_window ${score2winds[2]} 37 11 10 4 16
		draw_window ${score2winds[3]} 44 15 3 4 16
		draw_window ${score2winds[4]} 37 19 10 4 16
	elif [ $1 -eq 4 ]; then
		draw_window ${score2winds[0]} 37 3 3 10 16
		draw_window ${score2winds[1]} 37 3 3 10 16
		draw_window ${score2winds[2]} 37 10 10 3 16
		draw_window ${score2winds[3]} 37 10 10 3 16
		draw_window ${score2winds[4]} 44 3 3 20 16
	elif [ $1 -eq 5 ]; then
		draw_window ${score2winds[0]} 40 3 7 3 16
		draw_window ${score2winds[1]} 37 3 3 8 16
		draw_window ${score2winds[2]} 37 11 7 3 16
		draw_window ${score2winds[3]} 44 11 3 12 16
		draw_window ${score2winds[4]} 37 20 7 3 16
	elif [ $1 -eq 6 ]; then
		draw_window ${score2winds[0]} 40 3 7 3 16
		draw_window ${score2winds[1]} 37 3 3 17 16
		draw_window ${score2winds[2]} 37 20 7 3 16
		draw_window ${score2winds[3]} 44 13 3 10 16
		draw_window ${score2winds[4]} 40 13 7 3 16
	elif [ $1 -eq 7 ]; then
		draw_window ${score2winds[0]} 37 3 3 5 16
		draw_window ${score2winds[1]} 40 3 7 3 16
		draw_window ${score2winds[2]} 44 6 3 17 16
		draw_window ${score2winds[3]} 37 3 3 5 16
		draw_window ${score2winds[4]} 37 3 3 5 16
	fi
}

function draw_ball() {
	draw_window $ballwindow $1 $2 $BALL_SIZE $BALL_SIZE 0
}

function draw_game() {
	draw_paddle1 $pos1
	draw_paddle2 $pos2
	#draw_score1 $score1
	#draw_score2 $score2
	draw_ball $ballx $bally
}

# These next two should probably be made bigger

# Drawn in 20x50 box with topleft at (25,40)
function draw_win() {
	clear_screen

	# W
	draw_window ${good_windows[0]} 40 25 3 17 0
	draw_window ${good_windows[1]} 43 39 5 3 0
	draw_window ${good_windows[2]} 48 25 3 17 0
	draw_window ${good_windows[3]} 51 39 6 3 0
	draw_window ${good_windows[4]} 57 25 3 17 0
	# I
	draw_window ${good_windows[5]} 48 42 4 13 0
	#draw_window ${good_windows[6]} 40 55 20 3 0
	# N
	draw_window ${good_windows[7]}  40 58 4 17 0
	draw_window ${good_windows[8]}  44 58 4 6 0
	draw_window ${good_windows[9]}  48 64 4 5 0
	draw_window ${good_windows[10]} 52 69 4 6 0
	draw_window ${good_windows[11]} 56 58 4 17 0
}

# Drawn in 20x60 box with topleft at (20,40)
function draw_lose() {
	clear_screen

	# L
	draw_window ${good_windows[0]} 40 20 3 12 0
	draw_window ${good_windows[1]} 40 32 20 3 0
	# O
	draw_window ${good_windows[2]} 40 35 3 12 0
	draw_window ${good_windows[3]} 40 47 20 3 0
	draw_window ${good_windows[4]} 57 35 3 12 0
	# S
	draw_window ${good_windows[5]} 40 50 3 7 0
	draw_window ${good_windows[6]} 43 54 14 3 0
	draw_window ${good_windows[7]} 57 54 3 8 0
	draw_window ${good_windows[8]} 40 62 20 3 0
	# E
	draw_window ${good_windows[9]}  40 65 3 12 0
	draw_window ${good_windows[10]} 43 71 13 3 0
	draw_window ${good_windows[11]} 40 77 20 3 0
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

function move_computer() {
	# Only moves if the ball is coming towards it
	if [ $ballxdir == 1 ]; then
		# Move paddle more frequently when ball gets close
		if [ $ballx -lt 50 ]; then
			urgency=10
		elif [ $ballx -lt 75 ]; then
			urgency=6
		else
			urgency=2
		fi

		# Only moves sometimes so that it is constantly slowing things down
		if [ $(($RANDOM%$urgency)) == 0 ]; then
			if [ 1 -eq 0 ]; then
				center=$(( $pos2 + (($PADDLE_HEIGHT/2)) ))
				if [ $center -gt $bally ] && [ $ballydir == -1 ]; then
					pos2=$(($pos2-$COMPUTER_SPEED))
					draw_paddle2 $pos2
				elif [ $center -lt $bally ] && [ $ballydir == 1 ]; then
					pos2=$(($pos2+$COMPUTER_SPEED))
					draw_paddle2 $pos2
				fi
			else
				center=$(( $pos2 + (($PADDLE_HEIGHT/2)) ))
				pos2x=$((100 - $PADDLE_BUFFER - $PADDLE_WIDTH))
				steps=$(( (($pos2x - $ballx))/$BALL_X_SPEED ))
				ballfuturey=$(( $bally + $steps*(($ballydir*$BALL_Y_SPEED)) ))
				if [ $center -gt $ballfuturey ]; then
					pos2=$(($pos2-$COMPUTER_SPEED))
					draw_paddle2 $pos2
				elif [ $center -lt $ballfuturey ]; then
					pos2=$(($pos2+$COMPUTER_SPEED))
					draw_paddle2 $pos2
				fi
			fi
		fi
	fi
}

function handle_input() {
	wmctrl -i -R $termwind

	read input
	if [ "$input" == "w" ] || [ "$input" == "W" ]; then
		pos1=$(($pos1-$PLAYER_SPEED))
		draw_paddle1 $pos1
	elif [ "$input" == "s" ] || [ "$input" == "S" ]; then
		pos1=$(($pos1+$PLAYER_SPEED))
		draw_paddle1 $pos1
	elif [ "$input" == "q" ] || [ "$input" == "Q" ]; then
		over=true
	fi
}

function handle_collision() {
	if [ $ballx -ge $PADDLE_BUFFER ] && [ $ballx -le $(($PADDLE_BUFFER+$PADDLE_WIDTH)) ]; then
		if [ $bally -ge $pos1 ] && [ $bally -le $(($pos1+$PADDLE_HEIGHT)) ]; then
			ballxdir=$((-$ballxdir))
		fi
	fi

	if [ $ballx -ge $((100-$PADDLE_BUFFER-$PADDLE_WIDTH)) ] && [ $ballx -le $((100-$PADDLE_BUFFER)) ]; then
		if [ $bally -ge $pos2 ] && [ $bally -le $(($pos2+$PADDLE_HEIGHT)) ]; then
			ballxdir=$((-$ballxdir))
		fi
	fi
}

function check_score() {
	if [ $ballx -ge 100 ]; then
		if [ $score1 -lt $MAX_SCORE ]; then
			score1=$(($score1+1))
			draw_score1 $score1
		fi
		reset_positions
		draw_game
	elif [ $ballx -le 0 ]; then
		if [ $score2 -lt $MAX_SCORE ]; then
			score2=$(($score2+1))
			draw_score2 $score2
		fi
		reset_positions
		draw_game
	fi
}

function reset_positions() {
	pos1=35
	pos2=35
	ballx=50
	bally=50
	ballxdir=$(( 2*(($RANDOM%2)) - 1))
	ballydir=$(( 2*(($RANDOM%2)) - 1))
}


########################
###      Script      ###
########################

get_screen_dimensions WIDTH HEIGHT
echo 'Screen dimensions:' $WIDTH 'x' $HEIGHT

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
# Store the state of the windows so they can restored later
get_window_states ${good_windows[@]} window_states

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
ballwindow=${good_windows[10]}
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

score1=0
score2=0
over=false
reset_positions
# Move terminal off screen
move_window $termwind $WIDTH $HEIGHT
clear_screen
draw_score1 $score1
draw_score2 $score2
draw_game

echo 'Starting game...'

# Essentially makes read time 0 so read doesn't stall program 
stty -icanon time 0 min 0 
while ! $over; do
	handle_input
	move_computer
	move_ball
	handle_collision
	check_score

	draw_ball $ballx $bally

	sleep $FRAME_SLEEP_DURR

	if [ $score1 -ge 7 ]; then
		over=true
		draw_win
		sleep $OVER_SLEEP_DURR
	elif [ $score2 -ge 7 ]; then
		over=true
		draw_lose
		sleep $OVER_SLEEP_DURR
	fi
done

echo ''
echo 'Thanks for playing'
echo 'Cleaning up...'
# Fix stuff
stty sane
# Move used windows back to where they were
for i in $(seq 0 ${#window_states[@]}); do
	state=(${window_states[$i]})
	draw_window ${state[0]} ${state[1]} ${state[2]} ${state[3]} ${state[4]} 0
done
# Move terminal back on screen
move_window $termwind 0 0