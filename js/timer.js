/**
 * OSCE Timing System - Timer Module
 * Precision timer with drift correction and phase management
 */

class Timer {
    constructor() {
        this.interval = null;
        this.startTime = null;
        this.pausedTime = 0;
        this.totalPausedDuration = 0;
        this.isRunning = false;
        this.isPaused = false;

        // Current state
        this.currentPhase = 'activity'; // activity, feedback, changeover
        this.currentStationIndex = 0;
        this.currentRound = 0; // Which rotation round
        this.secondsRemaining = 0;
        this.totalPhaseSeconds = 0;

        // Callbacks
        this.onTick = null;
        this.onPhaseChange = null;
        this.onStationComplete = null;
        this.onExamComplete = null;
        this.onAnnouncement = null;

        // Announcement tracking
        this.announcementsMade = new Set();

        // Web Worker for anti-throttling
        this.worker = null;
        try {
            this.worker = new Worker('js/timer-worker.js');
            this.worker.onmessage = (e) => {
                if (e.data === 'tick') {
                    this.tick();
                }
            };
            this.worker.onerror = (e) => {
                console.warn('Timer Worker failed (likely file:// protocol), falling back to main thread.', e);
                this.worker = null;
            };
        } catch (e) {
            console.warn('Could not create Timer Worker, using main thread fallback.', e);
            this.worker = null;
        }
    }

    /**
     * Start the timer for a specific phase
     * @param {number} seconds - Duration in seconds
     * @param {string} phase - Phase name
     */
    start(seconds, phase = 'activity') {
        this.stop(); // Clear any existing interval first

        this.secondsRemaining = seconds;
        this.totalPhaseSeconds = seconds;
        this.currentPhase = phase;
        this.isRunning = true;
        this.isPaused = false;
        this.startTime = Date.now();
        this.totalPausedDuration = 0;
        this.announcementsMade.clear();

        this.announcementsMade.clear();

        // Use Web Worker if available, otherwise setInterval
        if (this.worker) {
            this.worker.postMessage({ command: 'start', interval: 100 });
        } else {
            if (this.interval) clearInterval(this.interval);
            this.interval = setInterval(() => this.tick(), 100);
        }

        console.log(`Timer started: ${seconds}s for ${phase} phase`);
    }

    tick() {
        if (!this.isRunning || this.isPaused) return;

        // Calculate elapsed time with drift correction
        const now = Date.now();
        const elapsed = (now - this.startTime - this.totalPausedDuration) / 1000;
        this.secondsRemaining = Math.max(0, this.totalPhaseSeconds - elapsed);

        // Trigger tick callback
        if (this.onTick) {
            this.onTick({
                secondsRemaining: this.secondsRemaining,
                totalSeconds: this.totalPhaseSeconds,
                phase: this.currentPhase,
                progress: 1 - (this.secondsRemaining / this.totalPhaseSeconds)
            });
        }

        // Check for announcements
        this.checkAnnouncements();

        // Check for phase completion
        if (this.secondsRemaining <= 0) {
            this.onPhaseComplete();
        }
    }

    checkAnnouncements() {
        const remaining = Math.ceil(this.secondsRemaining);

        // 2-minute warning during activity
        if (this.currentPhase === 'activity' && remaining === 120 && !this.announcementsMade.has('2min')) {
            this.announcementsMade.add('2min');
            if (this.onAnnouncement) {
                this.onAnnouncement('twoMinWarning', remaining);
            }
        }

        // 1-minute warning
        if (remaining === 60 && !this.announcementsMade.has('1min')) {
            this.announcementsMade.add('1min');
            if (this.onAnnouncement) {
                this.onAnnouncement('oneMinWarning', remaining);
            }
        }

        // 30-second warning
        if (remaining === 30 && !this.announcementsMade.has('30sec')) {
            this.announcementsMade.add('30sec');
            if (this.onAnnouncement) {
                this.onAnnouncement('thirtySecWarning', remaining);
            }
        }

        // 10-second countdown
        if (remaining <= 10 && remaining > 0) {
            const key = `countdown${remaining}`;
            if (!this.announcementsMade.has(key)) {
                this.announcementsMade.add(key);
                if (this.onAnnouncement) {
                    this.onAnnouncement('countdown', remaining);
                }
            }
        }
    }

    onPhaseComplete() {
        this.stop();

        if (this.onPhaseChange) {
            this.onPhaseChange({
                completedPhase: this.currentPhase,
                stationIndex: this.currentStationIndex
            });
        }
    }

    /**
     * Pause the timer
     */
    pause() {
        if (!this.isRunning || this.isPaused) return;

        this.isPaused = true;
        this.pausedTime = Date.now();

        console.log(`Timer paused at ${this.formatTime(this.secondsRemaining)}`);
    }

    /**
     * Resume the timer
     */
    resume() {
        if (!this.isRunning || !this.isPaused) return;

        // Add paused duration to total
        this.totalPausedDuration += Date.now() - this.pausedTime;
        this.isPaused = false;

        console.log(`Timer resumed at ${this.formatTime(this.secondsRemaining)}`);
    }

    /**
     * Stop the timer completely
     */
    stop() {
        // Stop worker interval
        if (this.worker) {
            this.worker.postMessage({ command: 'stop' });
        }

        if (this.interval) {
            clearInterval(this.interval);
            this.interval = null;
        }
        this.isRunning = false;
        this.isPaused = false;
    }

    /**
     * Reset timer for current phase
     */
    reset() {
        this.stop();
        this.secondsRemaining = this.totalPhaseSeconds;
        this.announcementsMade.clear();
    }

    /**
     * Skip to next phase
     */
    skipPhase() {
        this.secondsRemaining = 0;
        this.onPhaseComplete();
    }

    /**
     * Restart current station from the beginning
     */
    restartStation() {
        this.stop();
        this.currentPhase = 'activity';
        this.announcementsMade.clear();
    }

    /**
     * Format seconds to MM:SS
     * @param {number} seconds 
     * @returns {string}
     */
    formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }

    /**
     * Get progress percentage (0-100)
     */
    getProgress() {
        if (this.totalPhaseSeconds === 0) return 0;
        return ((this.totalPhaseSeconds - this.secondsRemaining) / this.totalPhaseSeconds) * 100;
    }

    /**
     * Check if time is in warning zone (under 2 mins)
     */
    isWarning() {
        return this.secondsRemaining <= 120 && this.secondsRemaining > 30;
    }

    /**
     * Check if time is critical (under 30 secs)
     */
    /**
     * Check if time is critical (under 30 secs)
     */
    isCritical() {
        return this.secondsRemaining <= 30;
    }

    /**
     * Export current state for persistence
     */
    exportState() {
        return {
            secondsRemaining: this.secondsRemaining,
            totalPhaseSeconds: this.totalPhaseSeconds,
            currentPhase: this.currentPhase,
            isRunning: this.isRunning,
            isPaused: this.isPaused,
            announcementsMade: Array.from(this.announcementsMade)
        };
    }

    /**
     * Import state from persistence
     */
    importState(state) {
        if (!state) return;

        this.stop();

        this.secondsRemaining = state.secondsRemaining;
        this.totalPhaseSeconds = state.totalPhaseSeconds;
        this.currentPhase = state.currentPhase;
        this.announcementsMade = new Set(state.announcementsMade || []);

        // We restore strictly as paused to allow user to resume manually
        this.isRunning = false;
        this.isPaused = false;

        console.log('Timer state imported:', state);
    }
}

// Create global instance
window.timer = new Timer();
