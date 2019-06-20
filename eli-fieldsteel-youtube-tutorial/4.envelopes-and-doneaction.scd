/* SuperCollider Tutorial: 4. Envelopes and doneAction
 * https://youtu.be/-wDAPo9hpCg
 */

s.boot;
s.reboot;

x = {PinkNoise.ar * 0.5}.play;

x.free;
