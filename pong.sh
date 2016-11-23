#!/bin/bash

function print_winds() {
	winds=($@)
	cnt=0
	for wind in ${winds[@]}; do
		echo $cnt 'window id:' $wind
		cnt=$(($cnt+1))
	done
	echo ''
}

# Get IDs of all windows (except for a few we don't want to mess with)
windows=($(wmctrl -l | grep -v unity | grep -v Xdnd | grep -v Hud | grep -v Desktop | cut -c 1-10))

if [ "${#windows[@]}" -lt "12" ]; then
	echo 'You must have at least 12 open windows to play'
	echo 'You only have' ${#windows[@]} 'windows open'
	exit 0
fi

score1winds=()
score2winds=()
paddle1winds=()
paddle2winds=()

half=$(( ((${#windows[@]}-10))/2 ))
rest=$((${#windows[@]}-10-$half))

for i in $(seq 0 4); do
	score1winds[i]=${windows[i]}
done

for i in $(seq 0 4); do
	score2winds[i]=${windows[i+5]}
done

for i in $(seq 1 $half); do
	paddle1winds[i-1]=${windows[i+9]}
done

for i in $(seq 1 $rest); do
	paddle2winds[i-1]=${windows[i+9+$half]}
done

print_winds ${windows[@]}
print_winds ${score1winds[@]}
print_winds ${score2winds[@]}
print_winds ${paddle1winds[@]}
print_winds ${paddle2winds[@]}
