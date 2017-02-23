# pico2tic
PICO-8 API Wrapper for the TIC-80 (0.18.0)
by @musurca (nick dot musurca at gmail dot com)
----------------------------------------
Wraps the PICO-8 API for ease of porting games to the TIC-80. Favors compatibility over performance.
----------------------------------------
known issues:
* swapping elements in the screen palette--e.g. pal(a,b,1)--doesn't work properly yet. However, pal(a,b) does work
* flip_x and flip_y are currently ignored in spr() and sspr()
* music() and flip() do nothing. sfx() does not take into account offset
* stat(1) always returns "0.5"
