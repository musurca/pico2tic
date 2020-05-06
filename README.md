# pico2tic

> PICO-8 API Wrapper for TIC-80 (0.80.0)
by <a href="http://www.twitter.com/musurca">@musurca</a> (nick dot musurca at gmail dot com)

Wraps the PICO-8 API for ease of porting games to the TIC-80. Favors compatibility over performance.


## Known Issues

* flip_x and flip_y are currently ignored in spr() and sspr()
* music() and flip() do nothing. sfx() does not take into account offset
* stat(1) always returns "0.5"
