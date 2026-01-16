/**
 * OSCE Timing System - Timer Worker
 * Handles timing intervals in a background thread to prevent browser throttling.
 */

let intervalId = null;

self.onmessage = function (e) {
    const { command, interval } = e.data;

    if (command === 'start') {
        if (intervalId) clearInterval(intervalId);
        intervalId = setInterval(() => {
            self.postMessage('tick');
        }, interval || 100);
    } else if (command === 'stop') {
        if (intervalId) {
            clearInterval(intervalId);
            intervalId = null;
        }
    }
};
