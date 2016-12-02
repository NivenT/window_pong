# window_pong
Playing Pong with open windows on Ubuntu

<img src="https://github.com/NivenT/window_pong/blob/master/screenshot.png" alt="Screenshot" width="800" height="400">

# How to run
Type the following in terminal to get and run the code
```
git clone https://github.com/NivenT/window_pong
cd window_pong
./pong.sh 
```

# How to use
Once the program is run, it will first count how many windows you have open. In order to be able to display any number plus both paddles and the ball, the program needs at least 13 windows. If 13 are found, it will ask you to click on the terminal you are running the program from (this lets it know which window to use for getting keypresses later on). Once that is done, there is one more check before the game can begin.

While writing this, I ran into the issue of some windows not being resizable and some windows having some minimum size that was still too big to be part of pong. To address this issue, the program attempts to resize all your windows, and only uses the ones that can be resized arbitrarily small for displaying the game. This means that you need 13 arbitrarily resizeable windows for the program to run. Unfortunately, in my expierience, this means opening a bunch of junk sublime text windows. Assuming you've made it passed this part, the program will minimize all your windows and draw the game of pong over your desktop using only the good windows.

At this point, the game has begun. Use `w` and `s` to move your paddle up and down, respectively. Press `q` to quit the program. You can also quit using `Ctrl+c` but this frowned upon because it stops the program from cleaning up after itself.
