/**
 * OSCE Timing System - Voice Synthesis Module
 * Handles Web Speech API integration and audio feedback
 */

class VoiceManager {
    constructor() {
        this.synth = window.speechSynthesis;
        this.voices = [];
        this.selectedVoice = null;
        this.rate = 1.0;
        this.pitch = 1.0;
        this.volume = 1.0;
        this.isMuted = false;
        this.audioContext = null;

        // Queue for announcements
        this.queue = [];
        this.isSpeaking = false;

        // Anti-GC: Keep strong reference to current utterance
        this.currentUtterance = null;

        // Initialize voices
        this.initVoices();
    }

    initVoices() {
        // Chrome loads voices asynchronously
        if (this.synth.onvoiceschanged !== undefined) {
            this.synth.onvoiceschanged = () => this.loadVoices();
        }
        // Try loading immediately for Firefox/Safari
        this.loadVoices();
    }

    loadVoices() {
        this.voices = this.synth.getVoices();

        // Prefer English voices
        const englishVoices = this.voices.filter(v => v.lang.startsWith('en'));

        // Try to find a good default voice
        this.selectedVoice =
            englishVoices.find(v => v.name.includes('Google') && v.name.includes('UK')) ||
            englishVoices.find(v => v.name.includes('Google')) ||
            englishVoices.find(v => v.name.includes('Microsoft')) ||
            englishVoices[0] ||
            this.voices[0];

        // Populate voice selector if it exists
        this.populateVoiceSelector();

        console.log(`Loaded ${this.voices.length} voices. Selected: ${this.selectedVoice?.name}`);
    }

    populateVoiceSelector() {
        const selector = document.getElementById('voiceSelect');
        if (!selector) return;

        selector.innerHTML = '';

        // Group voices by language
        const grouped = {};
        this.voices.forEach(voice => {
            const lang = voice.lang.split('-')[0].toUpperCase();
            if (!grouped[lang]) grouped[lang] = [];
            grouped[lang].push(voice);
        });

        // Add English voices first
        if (grouped['EN']) {
            const optgroup = document.createElement('optgroup');
            optgroup.label = 'English';
            grouped['EN'].forEach(voice => {
                const option = document.createElement('option');
                option.value = voice.name;
                option.textContent = `${voice.name} (${voice.lang})`;
                if (voice === this.selectedVoice) option.selected = true;
                optgroup.appendChild(option);
            });
            selector.appendChild(optgroup);
        }

        // Add other languages
        Object.keys(grouped).sort().forEach(lang => {
            if (lang === 'EN') return;
            const optgroup = document.createElement('optgroup');
            optgroup.label = lang;
            grouped[lang].forEach(voice => {
                const option = document.createElement('option');
                option.value = voice.name;
                option.textContent = `${voice.name} (${voice.lang})`;
                optgroup.appendChild(option);
            });
            selector.appendChild(optgroup);
        });
    }

    setVoice(voiceName) {
        const voice = this.voices.find(v => v.name === voiceName);
        if (voice) {
            this.selectedVoice = voice;
            console.log(`Voice changed to: ${voice.name}`);
        }
    }

    setRate(rate) {
        this.rate = Math.max(0.5, Math.min(2, rate));
    }

    setPitch(pitch) {
        this.pitch = Math.max(0.5, Math.min(2, pitch));
    }

    setVolume(volume) {
        this.volume = Math.max(0, Math.min(1, volume));
    }

    setMuted(muted) {
        this.isMuted = muted;
        if (muted) {
            this.cancel();
        }
    }

    /**
     * Speak text with the current voice settings
     * @param {string} text - Text to speak
     * @param {boolean} priority - If true, cancels current speech
     */
    speak(text, priority = false) {
        if (this.isMuted) return;

        if (priority) {
            this.cancel();
        }

        // Add to queue
        this.queue.push(text);
        this.processQueue();
    }

    processQueue() {
        if (this.isSpeaking || this.queue.length === 0) return;

        const text = this.queue.shift();
        this.isSpeaking = true;

        const utterance = new SpeechSynthesisUtterance(text);
        utterance.voice = this.selectedVoice;
        utterance.rate = this.rate;
        utterance.pitch = this.pitch;
        utterance.volume = this.volume;

        utterance.onend = () => {
            this.isSpeaking = false;
            this.processQueue();
        };

        utterance.onerror = (e) => {
            console.error('Speech error:', e);
            this.isSpeaking = false;
            this.processQueue();
        };

        // Keep reference to prevent Garbage Collection
        this.currentUtterance = utterance;

        this.synth.speak(utterance);
    }

    /**
     * Ensure AudioContext is running (User Interaction)
     */
    async resume() {
        if (this.audioContext && this.audioContext.state === 'suspended') {
            try {
                await this.audioContext.resume();
                console.log('AudioContext resumed');
            } catch (e) {
                console.error('Failed to resume AudioContext:', e);
            }
        }
    }

    /**
     * Cancel all speech
     */
    cancel() {
        this.synth.cancel();
        this.queue = [];
        this.isSpeaking = false;
        this.currentUtterance = null;
    }

    /**
     * Play a beep sound at a specific frequency
     * @param {number} frequency - Frequency in Hz
     * @param {number} duration - Duration in ms
     * @param {string} type - Wave type (sine, square, sawtooth, triangle)
     */
    playBeep(frequency = 800, duration = 200, type = 'sine') {
        if (this.isMuted) return;

        try {
            if (!this.audioContext) {
                this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            }

            // Ensure context is running
            if (this.audioContext.state === 'suspended') {
                this.audioContext.resume();
            }

            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();

            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);

            oscillator.frequency.value = frequency;
            oscillator.type = type;

            gainNode.gain.setValueAtTime(this.volume * 0.3, this.audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + duration / 1000);

            oscillator.start(this.audioContext.currentTime);
            oscillator.stop(this.audioContext.currentTime + duration / 1000);
        } catch (e) {
            console.error('Audio error:', e);
        }
    }

    /**
     * Play a sequence of beeps for attention
     */
    playAttentionBeeps() {
        if (this.isMuted) return;

        this.playBeep(600, 150);
        setTimeout(() => this.playBeep(800, 150), 200);
        setTimeout(() => this.playBeep(1000, 300), 400);
    }

    /**
     * Play warning beeps (descending)
     */
    playWarningBeeps() {
        if (this.isMuted) return;

        this.playBeep(800, 200);
        setTimeout(() => this.playBeep(600, 200), 250);
        setTimeout(() => this.playBeep(400, 300), 500);
    }

    /**
     * Play a single tick for countdown
     */
    playTick() {
        if (this.isMuted) return;
        this.playBeep(1200, 50, 'square');
    }

    /**
     * Play completion chime
     */
    playComplete() {
        if (this.isMuted) return;

        this.playBeep(523, 150); // C5
        setTimeout(() => this.playBeep(659, 150), 150); // E5
        setTimeout(() => this.playBeep(784, 300), 300); // G5
    }

    /**
     * Play start beep (Activity Start)
     */
    playStartBeep() {
        if (this.isMuted) return;
        this.playBeep(800, 300);
    }

    /**
     * Play end beep (Changeover)
     */
    playEndBeep() {
        if (this.isMuted) return;
        this.playBeep(400, 400);
    }

    /**
     * Test the current voice
     */
    test() {
        this.speak("This is a test of the voice announcement system. The timer is ready.", true);
    }
}

// Create global instance
window.voiceManager = new VoiceManager();
