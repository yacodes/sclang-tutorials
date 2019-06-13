Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();


/* MouseX/Y
 * Using the mouse as a controller is a quick
 * and easy way of interacting with a patch
 *
 *
 * MouseX.kr(leftscreenval, rightscreenval, warp, lag)
 * MouseY.kr(topscreenval, bottomscreenval, warp, lag)
 *
 * warp can be \linear or \exponential
 *
 * lag is a smoothing factor to avoid sudden jumps
 * in value if you move the mouse really quickly across the screen
 *
 * Compare these hearing tests (be careful, they're piercing)
 */

{SinOsc.ar(MouseX.kr(20, 20000, 'linear'), 0, 0.1)}.play();

{SinOsc.ar(MouseY.kr(20, 20000, 'exponential'), 0, 0.1)}.play();

/* The exponential mapping is far more comforting
 * as a proportion of screen space than the linear one!
 */
