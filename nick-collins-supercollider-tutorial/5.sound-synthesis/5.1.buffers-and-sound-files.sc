Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();


/* Buffers and Sound Files
 *
 * To do sample playback and manipulation,
 * for streaming files off disk,
 * for recording and wavetables and many other processes,
 * it is necessary to handle memory buffers on the Server.
 *
 * Note: SuperCollider versions from 3.5 on have the
 * default sound files that come with SuperCollider in a different location.
 *
 * You will see the path as:
 */
Platform.resourceDir +/+ "sounds/a11wlk01.wav"; // 3.5 or later

/* Note that if you need a path for a sound file,
 * you can drag and drop to the text window in SuperCollider to get the path.
 */
