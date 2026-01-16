/**
 * OSCE Timing System - Main Application
 * Coordinates all modules and handles UI interactions
 */

class OSCEApp {
    constructor() {
        // State
        this.isExamRunning = false;
        this.currentRound = 0; // Current rotation round (0 to numStations-1)
        this.currentPhase = 'read'; // read, activity, feedback, changeover
        this.numCandidates = 5;
        this.readTime = 60; // seconds (read instructions time)
        this.changeoverTime = 60; // seconds
        this.startTime = '13:00';

        // Track candidates through stations
        this.candidateProgress = [];

        // Announcements (room-wide, generic - no station-specific content)
        this.announcements = {
            readStart: 'Please read your instructions. You have 1 minute.',
            activityStart: 'Please begin. You have {time} minutes for the activity phase.',
            twoMinWarning: 'Two minutes remaining.',
            activityEnd: 'Please stop. You may now begin feedback and questions.',
            oneMinWarning: 'One minute remaining.',
            stationEnd: 'This round is now complete. Please prepare to rotate.',
            changeover: 'Please move to your next station and read the instructions.'
        };

        // State Machine
        this.PHASE_FLOW = {
            'read': 'activity',
            'activity': 'feedback',
            'feedback': 'changeover',
            'changeover': 'read'
        };

        /**
         * DOM Elements cache
         */
        this.elements = {};

        // Initialize
        this.init();
    }

    init() {
        this.setup();

        // Initial state
        this.currentRound = 0;
        this.numCandidates = 0;
        this.totalPositions = 0;

        // Initialize candidates based on stations
        const stations = window.stationsManager.getAll();
        if (stations.length > 0) {
            this.numCandidates = stations.length;
            this.totalPositions = stations.length;
            this.initializeCandidates();
        }
    }

    setup() {
        this.cacheElements();
        this.bindEvents();
        this.renderStations();
        this.loadSettings();
        this.setupTimer();
        this.optimizeForMobile();

        // Check for crashed state
        const savedState = localStorage.getItem('osce_active_state');
        if (savedState) {
            this.elements.crashModal.classList.remove('hidden');
        }

        console.log('OSCE Timing System initialized');
    }

    optimizeForMobile() {
        // Auto-collapse setup details on mobile for concise view
        if (window.innerWidth < 768) {
            document.querySelectorAll('details.setup-card').forEach(d => {
                d.removeAttribute('open');
            });
        }
    }

    cacheElements() {
        // Panels
        this.elements.setupPanel = document.getElementById('setupPanel');
        this.elements.timerPanel = document.getElementById('timerPanel');

        // Crash Recovery Modal
        this.elements.crashModal = document.createElement('div');
        this.elements.crashModal.className = 'modal hidden';
        this.elements.crashModal.id = 'crashModal';
        this.elements.crashModal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Resume Exam?</h2>
                </div>
                <div class="modal-body">
                    <p>An active exam session was detected from a previous visit. Would you like to resume where you left off?</p>
                </div>
                <div class="modal-footer">
                    <button id="crashDiscardBtn" class="btn btn-secondary">Discard & Start Over</button>
                    <button id="crashResumeBtn" class="btn btn-primary">Resume Exam</button>
                </div>
            </div>
        `;
        document.body.appendChild(this.elements.crashModal);

        // Setup controls
        this.elements.startTime = document.getElementById('startTime');
        this.elements.numCandidates = document.getElementById('numCandidates');
        this.elements.readTime = document.getElementById('readTime');
        this.elements.changeoverTime = document.getElementById('changeoverTime');
        this.elements.voiceSelect = document.getElementById('voiceSelect');
        this.elements.voiceRate = document.getElementById('voiceRate');
        this.elements.voiceRateValue = document.getElementById('voiceRateValue');
        this.elements.voiceVolume = document.getElementById('voiceVolume');
        this.elements.voiceVolumeValue = document.getElementById('voiceVolumeValue');
        this.elements.stationsList = document.getElementById('stationsList');

        // Announcement inputs
        this.elements.annReadStart = document.getElementById('annReadStart');
        this.elements.annActivityStart = document.getElementById('annActivityStart');
        this.elements.annTwoMinWarning = document.getElementById('annTwoMinWarning');
        this.elements.annActivityEnd = document.getElementById('annActivityEnd');
        this.elements.annOneMinWarning = document.getElementById('annOneMinWarning');
        this.elements.annStationEnd = document.getElementById('annStationEnd');
        this.elements.annChangeover = document.getElementById('annChangeover');

        // Announcement enable toggles
        this.elements.annReadStartEnabled = document.getElementById('annReadStartEnabled');
        this.elements.annActivityStartEnabled = document.getElementById('annActivityStartEnabled');
        this.elements.annTwoMinWarningEnabled = document.getElementById('annTwoMinWarningEnabled');
        this.elements.annActivityEndEnabled = document.getElementById('annActivityEndEnabled');
        this.elements.annOneMinWarningEnabled = document.getElementById('annOneMinWarningEnabled');
        this.elements.annStationEndEnabled = document.getElementById('annStationEndEnabled');
        this.elements.annChangeoverEnabled = document.getElementById('annChangeoverEnabled');

        // Buttons
        this.elements.testVoiceBtn = document.getElementById('testVoiceBtn');
        this.elements.addStationBtn = document.getElementById('addStationBtn');
        this.elements.saveSettingsBtn = document.getElementById('saveConfigBtn');
        this.elements.exportConfigBtn = document.getElementById('exportConfigBtn');
        this.elements.importConfigBtn = document.getElementById('importConfigBtn');
        this.elements.startExamBtn = document.getElementById('startExamBtn');
        this.elements.pauseBtn = document.getElementById('pauseBtn');
        this.elements.skipPhaseBtn = document.getElementById('skipPhaseBtn');
        this.elements.restartStationBtn = document.getElementById('restartStationBtn');
        this.elements.stopExamBtn = document.getElementById('stopExamBtn');
        this.elements.muteBtn = document.getElementById('muteBtn');

        // Crash buttons
        this.elements.crashDiscardBtn = document.getElementById('crashDiscardBtn');
        this.elements.crashResumeBtn = document.getElementById('crashResumeBtn');

        // Timer display
        this.elements.phaseIndicator = document.getElementById('phaseIndicator');
        this.elements.countdown = document.getElementById('countdown');
        this.elements.countdownLabel = document.getElementById('countdownLabel');
        this.elements.currentStationName = document.getElementById('currentStationName');
        this.elements.currentStationDesc = document.getElementById('currentStationDesc');
        this.elements.progressFills = {
            read: document.querySelector('#seg-read .progress-fill'),
            activity: document.querySelector('#seg-activity .progress-fill'),
            feedback: document.querySelector('#seg-feedback .progress-fill'),
            changeover: document.querySelector('#seg-changeover .progress-fill')
        };
        this.elements.activityMarker = document.getElementById('activityMarker');
        this.elements.pauseOverlay = document.getElementById('pauseOverlay');
        this.elements.pauseTime = document.getElementById('pauseTime');
        this.elements.candidatesProgress = document.getElementById('candidatesProgress');
        this.elements.nextAnnouncement = document.getElementById('nextAnnouncement');

        // Modal
        this.elements.confirmModal = document.getElementById('confirmModal');
        this.elements.modalTitle = document.getElementById('modalTitle');
        this.elements.modalMessage = document.getElementById('modalMessage');
        this.elements.modalConfirm = document.getElementById('modalConfirm');
        this.elements.modalCancel = document.getElementById('modalCancel');
    }

    bindEvents() {
        // Voice settings
        this.elements.voiceSelect?.addEventListener('change', (e) => {
            window.voiceManager.setVoice(e.target.value);
        });

        this.elements.voiceRate?.addEventListener('input', (e) => {
            const rate = parseFloat(e.target.value);
            window.voiceManager.setRate(rate);
            this.elements.voiceRateValue.textContent = `${rate.toFixed(1)}x`;
        });

        this.elements.voiceVolume?.addEventListener('input', (e) => {
            const volume = parseFloat(e.target.value);
            window.voiceManager.setVolume(volume);
            this.elements.voiceVolumeValue.textContent = `${Math.round(volume * 100)}%`;
        });

        this.elements.testVoiceBtn?.addEventListener('click', () => {
            window.voiceManager.test();
        });

        // Station management
        this.elements.addStationBtn?.addEventListener('click', () => this.addStation());

        // Config buttons
        this.elements.saveSettingsBtn?.addEventListener('click', () => this.saveSettings());
        this.elements.exportConfigBtn?.addEventListener('click', () => this.exportConfig());
        this.elements.importConfigBtn?.addEventListener('click', () => this.importConfig());

        // Exam control
        this.elements.startExamBtn?.addEventListener('click', () => this.startExam());
        this.elements.pauseBtn?.addEventListener('click', () => this.togglePause());
        this.elements.skipPhaseBtn?.addEventListener('click', () => this.confirmSkipPhase());
        this.elements.restartStationBtn?.addEventListener('click', () => this.confirmRestartRound());
        this.elements.stopExamBtn?.addEventListener('click', () => this.confirmStopExam());

        // Mute toggle
        this.elements.muteBtn?.addEventListener('click', () => this.toggleMute());

        // Modal buttons
        this.elements.modalCancel?.addEventListener('click', () => this.hideModal());

        // Crash Recovery Buttons
        this.elements.crashDiscardBtn?.addEventListener('click', () => {
            localStorage.removeItem('osce_active_state');
            this.elements.crashModal.classList.add('hidden');
        });
        this.elements.crashResumeBtn?.addEventListener('click', () => this.restoreState());

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => this.handleKeyboard(e));

        // Save announcements on change
        ['annReadStart', 'annActivityStart', 'annTwoMinWarning', 'annActivityEnd', 'annOneMinWarning', 'annStationEnd', 'annChangeover'].forEach(id => {
            this.elements[id]?.addEventListener('change', () => this.updateAnnouncements());
        });

        // Update station totals when read time changes
        this.elements.readTime?.addEventListener('change', () => this.renderStations());

        // Window Resize for Responsive Setup
        window.addEventListener('resize', () => this.handleResize());
    }

    handleResize() {
        // Force expand on desktop
        if (window.innerWidth >= 768) {
            document.querySelectorAll('details.setup-card').forEach(d => {
                if (!d.hasAttribute('open')) {
                    d.setAttribute('open', '');
                }
            });
        }
    }

    setupTimer() {
        window.timer.onTick = (data) => this.onTimerTick(data);
        window.timer.onPhaseChange = (data) => this.onPhaseChange(data);
        window.timer.onAnnouncement = (type, remaining) => this.onAnnouncement(type, remaining);
    }

    // ==================== Station Management ====================

    renderStations() {
        const stations = window.stationsManager.getAll();
        const readTimeMinutes = Math.round((parseInt(this.elements.readTime?.value) || 60) / 60);

        this.elements.stationsList.innerHTML = stations.map((station, index) => `
            <div class="station-item" data-id="${station.id}">
                <div class="station-number">${index + 1}</div>
                <input type="text" class="station-name-input" value="${this.escapeHtml(station.name)}" 
                       onchange="app.updateStation(${station.id}, 'name', this.value)">
                <div class="station-time-group">
                    <label>Activity</label>
                    <input type="number" class="station-time-input" value="${station.activityTime}" min="1" max="60"
                           onchange="app.updateStation(${station.id}, 'activityTime', parseInt(this.value))">
                </div>
                <div class="station-time-group">
                    <label>Feedback</label>
                    <input type="number" class="station-time-input" value="${station.feedbackTime}" min="1" max="60"
                           onchange="app.updateStation(${station.id}, 'feedbackTime', parseInt(this.value))">
                </div>
                <div class="station-time-group">
                    <label>Total</label>
                    <span class="station-total">${station.totalTime + readTimeMinutes} min</span>
                </div>
                <button class="station-delete-btn" onclick="app.confirmDeleteStation(${station.id})" title="Delete station">×</button>
            </div>
        `).join('');
    }

    addStation() {
        window.stationsManager.add();
        this.renderStations();
    }

    updateStation(id, field, value) {
        window.stationsManager.update(id, { [field]: value });
        this.renderStations();
    }

    confirmDeleteStation(id) {
        const station = window.stationsManager.getById(id);
        if (!station) return;

        if (window.stationsManager.getCount() <= 1) {
            alert('You must have at least one station.');
            return;
        }

        this.showModal(
            'Delete Station',
            `Are you sure you want to delete "${station.name}"?`,
            () => {
                window.stationsManager.remove(id);
                this.renderStations();
            }
        );
    }

    // ==================== Config Management ====================

    updateAnnouncements() {
        this.announcements = {
            readStart: this.elements.annReadStart?.value || this.announcements.readStart,
            activityStart: this.elements.annActivityStart?.value || this.announcements.activityStart,
            twoMinWarning: this.elements.annTwoMinWarning?.value || this.announcements.twoMinWarning,
            activityEnd: this.elements.annActivityEnd?.value || this.announcements.activityEnd,
            oneMinWarning: this.elements.annOneMinWarning?.value || this.announcements.oneMinWarning,
            stationEnd: this.elements.annStationEnd?.value || this.announcements.stationEnd,
            changeover: this.elements.annChangeover?.value || this.announcements.changeover
        };
    }

    getConfig() {
        return {
            startTime: this.elements.startTime?.value || '13:00',
            numCandidates: parseInt(this.elements.numCandidates?.value) || 5,
            readTime: parseInt(this.elements.readTime?.value) || 60,
            changeoverTime: parseInt(this.elements.changeoverTime?.value) || 60,
            voiceRate: parseFloat(this.elements.voiceRate?.value) || 1,
            voiceVolume: parseFloat(this.elements.voiceVolume?.value) || 1,
            selectedVoice: this.elements.voiceSelect?.value || '',
            announcements: { ...this.announcements },
            stations: window.stationsManager.export()
        };
    }

    saveSettings() {
        const config = this.getConfig();
        localStorage.setItem('osceConfig', JSON.stringify(config));
        window.voiceManager.speak('Settings saved.', true);
    }

    exportConfig() {
        const config = this.getConfig();
        const dateStr = new Date().toISOString().split('T')[0];
        const blob = new Blob([JSON.stringify(config, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `osce-config-${dateStr}.json`;
        a.click();
        URL.revokeObjectURL(url);
    }

    loadSettings() {
        const saved = localStorage.getItem('osceConfig');
        if (!saved) return;

        try {
            const config = JSON.parse(saved);
            this.applyConfig(config);
        } catch (e) {
            console.error('Failed to load settings:', e);
        }
    }

    importConfig() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.json';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = (evt) => {
                try {
                    const config = JSON.parse(evt.target.result);
                    this.applyConfig(config);
                    window.voiceManager.speak('Configuration imported.', true);
                } catch (err) {
                    alert('Invalid configuration file.');
                }
            };
            reader.readAsText(file);
        };
        input.click();
    }

    applyConfig(config) {
        if (config.startTime) this.elements.startTime.value = config.startTime;
        if (config.numCandidates) this.elements.numCandidates.value = config.numCandidates;
        if (config.changeoverTime) this.elements.changeoverTime.value = config.changeoverTime;
        if (config.voiceRate) {
            this.elements.voiceRate.value = config.voiceRate;
            this.elements.voiceRateValue.textContent = `${config.voiceRate.toFixed(1)}x`;
            window.voiceManager.setRate(config.voiceRate);
        }
        if (config.voiceVolume) {
            this.elements.voiceVolume.value = config.voiceVolume;
            this.elements.voiceVolumeValue.textContent = `${Math.round(config.voiceVolume * 100)}%`;
            window.voiceManager.setVolume(config.voiceVolume);
        }
        if (config.announcements) {
            this.announcements = config.announcements;
            // this.elements.annStationStart.value = config.announcements.stationStart || ''; // Removed as it doesn't exist
            this.elements.annTwoMinWarning.value = config.announcements.twoMinWarning || '';
            this.elements.annActivityEnd.value = config.announcements.activityEnd || '';
            this.elements.annOneMinWarning.value = config.announcements.oneMinWarning || '';
            this.elements.annStationEnd.value = config.announcements.stationEnd || '';
            this.elements.annChangeover.value = config.announcements.changeover || '';
        }
        if (config.stations) {
            window.stationsManager.import(config.stations);
            this.renderStations();
        }
    }

    // ==================== Exam Control ====================

    startExam() {
        if (this.isExamRunning) return;

        // Wake up audio engine
        window.voiceManager.resume();

        // Get configuration
        this.updateAnnouncements();
        this.startTime = this.elements.startTime?.value || '13:00';
        this.numCandidates = parseInt(this.elements.numCandidates?.value) || 5;
        this.changeoverTime = parseInt(this.elements.changeoverTime?.value) || 60;

        if (window.stationsManager.getCount() === 0) {
            alert('Please add at least one station.');
            return;
        }

        // Initialize state
        this.isExamRunning = true;
        this.currentRound = 0; // Start at round 0
        this.currentPhase = 'read';
        this.readTime = parseInt(this.elements.readTime?.value) || 60;

        const numStations = window.stationsManager.getCount();

        // Calculate total positions needed (stations + rest stations if more candidates than stations)
        this.totalPositions = Math.max(numStations, this.numCandidates);
        this.numStations = numStations;

        // Initialize candidate progress - each candidate starts at a different position
        // Positions 0 to numStations-1 are real stations, positions >= numStations are rest
        this.candidateProgress = [];
        for (let i = 0; i < this.numCandidates; i++) {
            this.candidateProgress.push({
                id: i + 1,
                // Candidate positions: 0 to totalPositions-1, wrapping around
                currentPosition: i,
                completedStations: 0
            });
        }

        // Switch to timer panel
        this.elements.setupPanel.classList.add('hidden');
        this.elements.timerPanel.classList.remove('hidden');

        // Render candidates
        this.renderCandidatesProgress();

        // Start first round
        this.transitionToPhase('read');

        console.log('Exam started');
    }

    startRound() {
        // Check if exam is complete (all rounds done - need totalPositions rounds for everyone to visit all stations)
        if (this.currentRound >= this.totalPositions) {
            this.finishExam();
            return;
        }

        // Start with read phase (if read time > 0)
        if (this.readTime > 0) {
            this.currentPhase = 'read';
            this.updateDisplay();

            // Announce read start
            if (this.isAnnouncementEnabled('readStart')) {
                window.voiceManager.playAttentionBeeps();
                setTimeout(() => {
                    window.voiceManager.speak(this.announcements.readStart, true);
                }, 800);
            } else {
                window.voiceManager.playAttentionBeeps();
            }

            // Start timer for read phase
            window.timer.start(this.readTime, 'read');
        } else {
            // Skip read phase if readTime is 0
            this.startActivityPhase();
        }
    }

    initializeCandidates() {
        this.candidateProgress = [];
        for (let i = 0; i < this.numCandidates; i++) {
            this.candidateProgress.push({
                id: i + 1,
                currentPosition: i,
                completedStations: 0
            });
        }
    }

    renderCandidatesProgress() {
        if (!this.elements.candidatesProgress) return;
        const stations = window.stationsManager.getAll();
        const numStations = stations.length;

        this.elements.candidatesProgress.innerHTML = this.candidateProgress.map(candidate => {
            let stationDisplay = '';
            let stationName = '';

            if (candidate.currentPosition < numStations) {
                const station = stations[candidate.currentPosition];
                stationDisplay = `Station ${candidate.currentPosition + 1}`;
                stationName = station ? this.escapeHtml(station.name) : 'Unknown';
            } else {
                stationDisplay = 'Rest Station';
                stationName = 'Resting';
            }

            const isFinished = candidate.completedStations >= this.totalPositions;
            if (isFinished) {
                stationDisplay = 'Finished';
                stationName = 'Exam Complete';
            }

            let progressPercent = (candidate.completedStations / this.totalPositions) * 100;

            // Timer for this specific candidate's station
            const timerHtml = `<span class="station-timer">--:--</span>`;
            const statusHtml = `<span class="station-status"></span>`;

            return `
                <div class="candidate-card">
                    <div class="candidate-header">
                        <span class="candidate-name">Candidate ${candidate.id}</span>
                        <span class="candidate-station">${stationName}: ${stationDisplay}</span>
                    </div>
                    <div class="candidate-meta">
                        ${statusHtml}
                        ${timerHtml}
                    </div>
                    <div class="candidate-progress">
                        <div class="candidate-progress-fill" style="width: ${progressPercent}%"></div>
                    </div>
                </div>
            `;
        }).join('');
    }

    updateDisplay() {
        // Update phase indicator
        const phaseNames = {
            read: 'Reading Period',
            activity: 'Activity',
            feedback: 'Feedback & Questions',
            changeover: 'Changeover'
        };
        const currentPhaseName = phaseNames[this.currentPhase] || this.currentPhase;

        if (this.elements.phaseIndicator) {
            this.elements.phaseIndicator.textContent = `${currentPhaseName} (Round ${this.currentRound + 1})`;
            this.elements.phaseIndicator.className = `phase-indicator phase-${this.currentPhase}`;
        }

        // Highlight Active Station
        const stations = window.stationsManager.getAll();
        const stationName = "Current Round";
        const stationDesc = this.currentPhase === 'read' ? 'Read Instructions' :
            this.currentPhase === 'changeover' ? 'Rotate Stations' : 'Active';

        if (this.elements.currentStationName) this.elements.currentStationName.textContent = stationName;
        if (this.elements.currentStationDesc) this.elements.currentStationDesc.textContent = stationDesc;

        // Visual progress segments
        Object.keys(this.elements.progressFills).forEach(key => {
            const fill = this.elements.progressFills[key];
            if (fill) {
                if (key === this.currentPhase) {
                    fill.style.opacity = '1';
                } else {
                    fill.style.opacity = '0.3';
                }
            }
        });

        // Activity marker styling
        if (this.elements.activityMarker) {
            this.elements.activityMarker.className = `activity-marker ${this.currentPhase === 'activity' ? 'active' : ''}`;
        }
    }

    updateProgressBar(progress) {
        // Find current phase fill and set width
        const currentFill = this.elements.progressFills[this.currentPhase];
        if (currentFill) {
            currentFill.style.width = `${progress * 100}%`;
        }

        // Reset others ?? - Actually simpler to just rely on opacity for now
    }

    updateNextAnnouncement(seconds) {
        if (!this.elements.nextAnnouncement) return;

        // Simple preview logic
        if (this.currentPhase === 'activity') {
            if (seconds > 120) this.elements.nextAnnouncement.textContent = 'Next: 2 Minute Warning';
            else if (seconds > 60) this.elements.nextAnnouncement.textContent = 'Next: 1 Minute Warning';
            else if (seconds > 0) this.elements.nextAnnouncement.textContent = 'Next: End of Activity';
        } else if (this.currentPhase === 'read') {
            this.elements.nextAnnouncement.textContent = 'Next: Start Activity';
        } else {
            this.elements.nextAnnouncement.textContent = '';
        }
    }

    updateCandidateTimers(data) {
        // Handle read/changeover phases simply
        if (this.currentPhase === 'read' || this.currentPhase === 'changeover') {
            const cards = this.elements.candidatesProgress.querySelectorAll('.candidate-card');
            cards.forEach(card => {
                const statusBadge = card.querySelector('.station-status');
                const timerEl = card.querySelector('.station-timer');

                if (statusBadge) {
                    const statusText = this.currentPhase === 'read' ? 'READING' : 'CHANGEOVER';
                    statusBadge.textContent = statusText;
                    statusBadge.className = `station-status status-${this.currentPhase}`;
                }
                if (timerEl) timerEl.textContent = '--:--';
            });
            return;
        }

        // Calculate Round Elapsed Time for Activity/Feedback phases
        let roundElapsed = 0;
        if (this.currentPhase === 'activity') {
            roundElapsed = (this.activityPhaseDuration || 0) - data.secondsRemaining;
        } else if (this.currentPhase === 'feedback') {
            roundElapsed = (this.activityPhaseDuration || 0) + ((this.feedbackPhaseDuration || 0) - data.secondsRemaining);
        } else {
            return;
        }

        const cards = this.elements.candidatesProgress.querySelectorAll('.candidate-card');
        const stations = window.stationsManager.getAll();
        const numStations = stations.length;

        cards.forEach((card, index) => {
            const candidate = this.candidateProgress[index];
            const timerEl = card.querySelector('.station-timer');
            const statusBadge = card.querySelector('.station-status');

            if (candidate.currentPosition >= numStations) {
                // REST STATION
                if (statusBadge) {
                    statusBadge.textContent = 'REST';
                    statusBadge.className = 'station-status status-waiting';
                }
                if (timerEl) timerEl.textContent = '--:--';
                if (timerEl) timerEl.classList.remove('expired');
                return;
            }

            const station = stations[candidate.currentPosition];
            // Safety check
            if (!station) return;

            const activitySeconds = station.activityTime * 60;
            const feedbackSeconds = station.feedbackTime * 60;

            let statusText = '';
            let statusClass = '';
            let timeToShow = 0;
            let isExpired = false;

            if (roundElapsed < activitySeconds) {
                // In Activity Phase
                statusText = 'ACTIVITY';
                statusClass = 'status-activity';
                timeToShow = activitySeconds - roundElapsed;
            } else if (roundElapsed < (activitySeconds + feedbackSeconds)) {
                // In Feedback Phase
                statusText = 'FEEDBACK';
                statusClass = 'status-feedback';
                timeToShow = (activitySeconds + feedbackSeconds) - roundElapsed;
            } else {
                // Finished Both
                statusText = 'WAITING';
                statusClass = 'status-waiting';
                timeToShow = 0;
                isExpired = true;
            }

            // Update DOM
            if (statusBadge) {
                statusBadge.textContent = statusText;
                statusBadge.className = `station-status ${statusClass}`;
            }
            if (timerEl) {
                timerEl.textContent = window.timer.formatTime(Math.max(0, Math.ceil(timeToShow)));
                if (isExpired) timerEl.classList.add('expired');
                else timerEl.classList.remove('expired');
            }
        });
    }

    transitionToPhase(phase) {
        console.log(`Transitioning to phase: ${phase}`);
        this.currentPhase = phase;

        switch (phase) {
            case 'activity':
                this.startActivityPhase();
                break;

            case 'feedback':
                this.startFeedbackPhase();
                break;

            case 'changeover':
                this.startChangeoverPhase();
                break;

            case 'read':
                this.startReadPhase();
                break;
        }

        this.renderCandidatesProgress();
        this.updateDisplay();
    }

    startActivityPhase() {
        console.log('STARTING ACTIVITY PHASE');
        this.currentPhase = 'activity';
        this.updateDisplay();

        const stations = window.stationsManager.getAll();
        if (stations.length === 0) return;

        const maxActivityTime = Math.max(...stations.map(s => s.activityTime));
        const seconds = maxActivityTime * 60;
        this.activityPhaseDuration = seconds;
        this.feedbackPhaseDuration = 0;

        window.timer.start(seconds, 'activity');

        window.voiceManager.speak(this.announcements.activityStart, true);
        window.voiceManager.playStartBeep();
    }

    startFeedbackPhase() {
        window.voiceManager.playWarningBeeps();
        window.voiceManager.speak(this.announcements.activityEnd, true);

        const stations = window.stationsManager.getAll();
        const maxActivityTime = Math.max(...stations.map(s => s.activityTime));
        const maxTotalTime = Math.max(...stations.map(s => s.activityTime + s.feedbackTime));

        const seconds = Math.max(0, (maxTotalTime - maxActivityTime) * 60);

        this.feedbackPhaseDuration = seconds;
        window.timer.start(seconds, 'feedback');
    }

    startChangeoverPhase() {
        window.voiceManager.speak(this.announcements.stationEnd, true);
        window.voiceManager.playEndBeep();

        const seconds = this.changeoverTime;
        window.timer.start(seconds, 'changeover');
    }

    startReadPhase() {
        const seconds = this.readTime;
        window.timer.start(seconds, 'read');
        window.voiceManager.speak(this.announcements.readStart, true);
    }

    finishExam() {
        this.stopExam();
        alert('Exam Completed!');
    }


    togglePause() {
        if (!this.isExamRunning) return;

        // Wake up audio engine
        window.voiceManager.resume();

        const pauseText = this.elements.pauseBtn.querySelector('.pause-text');
        const resumeText = this.elements.pauseBtn.querySelector('.resume-text');

        if (window.timer.isPaused) {
            // Resume
            window.timer.resume();
            this.elements.pauseOverlay.classList.add('hidden');
            if (pauseText) pauseText.classList.remove('hidden');
            if (resumeText) resumeText.classList.add('hidden');

            window.voiceManager.speak('Timer resumed.', true);
        } else {
            // Pause
            window.timer.pause();
            this.elements.pauseOverlay.classList.remove('hidden');
            this.elements.pauseTime.textContent = `Paused at: ${window.timer.formatTime(window.timer.secondsRemaining)}`;
            if (pauseText) pauseText.classList.add('hidden');
            if (resumeText) resumeText.classList.remove('hidden');

            window.voiceManager.speak('Timer paused.', true);
        }
    }

    confirmSkipPhase() {
        this.showModal(
            'Skip Current Phase?',
            `Are you sure you want to skip the ${this.currentPhase} phase? This will immediately move to the next phase.`,
            () => {
                window.voiceManager.speak('Skipping to next phase.', true);
                window.timer.skipPhase();
            }
        );
    }

    confirmRestartRound() {
        this.showModal(
            'Restart Round?',
            `Are you sure you want to restart Round ${this.currentRound + 1}? The timer will reset to the beginning of this round.`,
            () => {
                window.timer.stop();
                this.currentPhase = 'activity';
                window.voiceManager.speak('Restarting round.', true);
                setTimeout(() => this.startRound(), 500);
            }
        );
    }

    confirmStopExam() {
        this.showModal(
            'Stop Exam?',
            'Are you sure you want to stop the exam? All progress will be lost.',
            () => {
                this.stopExam();
            }
        );
    }

    stopExam() {
        window.timer.stop();
        this.isExamRunning = false;

        // Clear saved state
        localStorage.removeItem('osce_active_state');

        // Switch back to setup panel
        this.elements.timerPanel.classList.add('hidden');
        this.elements.setupPanel.classList.remove('hidden');

        window.voiceManager.speak('Exam stopped.', true);
        console.log('Exam stopped');
    }

    // ==================== Timer Callbacks ====================

    onTimerTick(data) {
        // Update countdown display
        this.elements.countdown.textContent = window.timer.formatTime(data.secondsRemaining);

        // Update countdown styling based on time remaining
        this.elements.countdown.classList.remove('warning', 'critical');
        if (window.timer.isCritical()) {
            this.elements.countdown.classList.add('critical');
        } else if (window.timer.isWarning()) {
            this.elements.countdown.classList.add('warning');
        }

        // Update progress bar
        this.updateProgressBar(data.progress);

        // Update next announcement preview
        this.updateNextAnnouncement(data.secondsRemaining);

        // Update station-specific timers
        this.updateCandidateTimers(data);

        // Save state on every tick
        this.saveState();
    }

    onPhaseChange(data) {
        console.log('Phase Change:', data);
        const { completedPhase } = data;

        // Strict State Machine Transition
        const nextPhase = this.PHASE_FLOW[completedPhase];

        if (!nextPhase) {
            console.error('Invalid phase flow:', completedPhase);
            return;
        }

        if (nextPhase === 'read') {
            // Cycle Complete: Move to next round

            // Rotate candidates
            this.candidateProgress.forEach(c => {
                c.currentPosition = (c.currentPosition + 1) % this.totalPositions;
                c.completedStations++;
            });
            this.renderCandidatesProgress();

            // Increment Round
            this.currentRound++;
            this.startRound();
        } else {
            // Intra-round transition
            this.transitionToPhase(nextPhase);
        }
    }


    onAnnouncement(type, remaining) {
        switch (type) {
            case 'twoMinWarning':
                if (this.currentPhase === 'activity' && this.isAnnouncementEnabled('twoMinWarning')) {
                    window.voiceManager.playBeep(800, 200);
                    setTimeout(() => {
                        window.voiceManager.speak(this.announcements.twoMinWarning, true);
                    }, 300);
                }
                break;

            case 'oneMinWarning':
                if (this.isAnnouncementEnabled('oneMinWarning')) {
                    window.voiceManager.playBeep(600, 200);
                    setTimeout(() => {
                        window.voiceManager.speak(this.announcements.oneMinWarning, true);
                    }, 300);
                }
                break;

            case 'thirtySecWarning':
                window.voiceManager.playBeep(1000, 150);
                break;

            case 'countdown':
                if (remaining <= 5) {
                    window.voiceManager.playTick();
                }
                break;
        }
    }

    onExamComplete() {
        window.timer.stop();
        this.isExamRunning = false;

        window.voiceManager.playComplete();
        setTimeout(() => {
            window.voiceManager.speak('The OSCE examination is now complete. Thank you all for participating.', true);
        }, 800);

        // Show completion message
        this.elements.countdown.textContent = 'DONE';
        this.elements.phaseIndicator.innerHTML = '<span class="phase-label">EXAM COMPLETE</span>';
        this.elements.phaseIndicator.className = 'phase-indicator activity';
        this.elements.phaseIndicator.style.background = '';

        console.log('Exam complete');
    }

    // ==================== Display Updates ====================

    updateDisplay() {
        const numStations = window.stationsManager.getCount();

        // Update round info (not station - all candidates are at different stations)
        this.elements.currentStationName.textContent = `Round ${this.currentRound + 1}`;
        const restCount = Math.max(0, this.numCandidates - numStations);
        const restText = restCount > 0 ? ` + ${restCount} rest` : '';
        this.elements.currentStationDesc.textContent = `${this.numCandidates} candidates at ${numStations} stations${restText}`;

        // Update phase indicator
        this.elements.phaseIndicator.className = `phase-indicator ${this.currentPhase}`;
        const phaseLabel = this.elements.phaseIndicator.querySelector('.phase-label');
        if (phaseLabel) {
            phaseLabel.textContent = this.currentPhase.toUpperCase();
        }

        // Update countdown label
        const labels = {
            read: 'Read Time - Review Instructions',
            activity: 'Activity Time Remaining',
            feedback: 'Feedback/Questions Time',
            changeover: 'Changeover - Move to Next Station'
        };
        this.elements.countdownLabel.textContent = labels[this.currentPhase] || 'Time Remaining';
    }

    updateProgressBar(progress) {
        const phases = ['read', 'activity', 'feedback', 'changeover'];
        const currentIndex = phases.indexOf(this.currentPhase);

        phases.forEach((phase, index) => {
            const fillEl = this.elements.progressFills[phase];
            if (!fillEl) return;

            if (index < currentIndex) {
                // Past phase - full
                fillEl.style.width = '100%';
            } else if (index === currentIndex) {
                // Current phase - progress
                fillEl.style.width = `${progress * 100}%`;
            } else {
                // Future phase - empty
                fillEl.style.width = '0%';
            }
        });
    }

    updateNextAnnouncement(secondsRemaining) {
        let nextTime = '';
        let nextText = '';

        const remaining = Math.ceil(secondsRemaining);

        if (this.currentPhase === 'activity') {
            if (remaining > 120) {
                nextTime = window.timer.formatTime(remaining - 120);
                nextText = '2-minute warning';
            } else if (remaining > 60) {
                nextTime = window.timer.formatTime(remaining - 60);
                nextText = '1-minute warning';
            } else if (remaining > 0) {
                nextTime = window.timer.formatTime(remaining);
                nextText = 'Activity phase ends';
            }
        } else if (this.currentPhase === 'feedback') {
            if (remaining > 60) {
                nextTime = window.timer.formatTime(remaining - 60);
                nextText = '1-minute warning';
            } else if (remaining > 0) {
                nextTime = window.timer.formatTime(remaining);
                nextText = 'Station complete';
            }
        } else if (this.currentPhase === 'changeover') {
            nextTime = window.timer.formatTime(remaining);
            nextText = 'Next station begins';
        }

        const timeSpan = this.elements.nextAnnouncement.querySelector('.announcement-time');
        const textSpan = this.elements.nextAnnouncement.querySelector('.announcement-text');

        if (timeSpan) timeSpan.textContent = nextTime || '--:--';
        if (textSpan) textSpan.textContent = nextText || 'No upcoming announcements';
    }

    updateCandidateTimers(data) {
        // Handle read/changeover phases simply
        if (this.currentPhase === 'read' || this.currentPhase === 'changeover') {
            const cards = this.elements.candidatesProgress.querySelectorAll('.candidate-card');
            cards.forEach(card => {
                const statusBadge = card.querySelector('.station-status');
                const timerEl = card.querySelector('.station-timer');

                if (statusBadge) {
                    const statusText = this.currentPhase === 'read' ? 'READING' : 'CHANGEOVER';
                    statusBadge.textContent = statusText;
                    statusBadge.className = `station-status status-${this.currentPhase}`;
                }
                // Determine if we should show a timer for these phases? 
                // Currently generic phases don't show per-station timers usually, 
                // but let's clear them just in case or leave as is.
                if (timerEl) timerEl.textContent = '--:--';
            });
            return;
        }

        // Calculate Round Elapsed Time for Activity/Feedback phases
        let roundElapsed = 0;
        if (this.currentPhase === 'activity') {
            roundElapsed = (this.activityPhaseDuration || 0) - data.secondsRemaining;
        } else if (this.currentPhase === 'feedback') {
            roundElapsed = (this.activityPhaseDuration || 0) + ((this.feedbackPhaseDuration || 0) - data.secondsRemaining);
        } else {
            return;
        }

        const cards = this.elements.candidatesProgress.querySelectorAll('.candidate-card');
        const stations = window.stationsManager.getAll();
        const numStations = stations.length;

        cards.forEach((card, index) => {
            const candidate = this.candidateProgress[index];
            const timerEl = card.querySelector('.station-timer');
            const statusBadge = card.querySelector('.station-status');

            if (candidate.currentPosition >= numStations) {
                // REST STATION
                if (statusBadge) {
                    statusBadge.textContent = 'REST';
                    statusBadge.className = 'station-status status-waiting';
                }
                if (timerEl) timerEl.textContent = '--:--';
                if (timerEl) timerEl.classList.remove('expired');
                return;
            }

            const station = stations[candidate.currentPosition];
            // Safety check
            if (!station) return;

            const activitySeconds = station.activityTime * 60;
            const feedbackSeconds = station.feedbackTime * 60;

            let statusText = '';
            let statusClass = '';
            let timeToShow = 0;
            let isExpired = false;

            if (roundElapsed < activitySeconds) {
                // In Activity Phase
                statusText = 'ACTIVITY';
                statusClass = 'status-activity';
                timeToShow = activitySeconds - roundElapsed;
            } else if (roundElapsed < (activitySeconds + feedbackSeconds)) {
                // In Feedback Phase
                statusText = 'FEEDBACK';
                statusClass = 'status-feedback';
                timeToShow = (activitySeconds + feedbackSeconds) - roundElapsed;
            } else {
                // Finished Both
                statusText = 'WAITING';
                statusClass = 'status-waiting';
                timeToShow = 0;
                isExpired = true;
            }

            // Update DOM
            if (statusBadge) {
                statusBadge.textContent = statusText;
                statusBadge.className = `station-status ${statusClass}`;
            }
            if (timerEl) {
                timerEl.textContent = window.timer.formatTime(Math.max(0, Math.ceil(timeToShow)));
                if (isExpired) timerEl.classList.add('expired');
                else timerEl.classList.remove('expired');
            }
        });
    }

    renderCandidatesProgress() {
        const stations = window.stationsManager.getAll();
        const numStations = stations.length;

        this.elements.candidatesProgress.innerHTML = this.candidateProgress.map((candidate) => {
            let stationName, stationDisplay, timeLimit = 0;

            if (candidate.currentPosition >= numStations) {
                // Candidate is at a rest station
                stationName = 'REST';
                stationDisplay = 'Rest Station';
                timeLimit = 0; // No limit for rest
            } else {
                // Candidate is at a real station
                const station = stations[candidate.currentPosition];
                stationName = `Station ${candidate.currentPosition + 1}`;
                stationDisplay = station?.name || 'Unknown';

                // Determine time limit based on current phase
                if (this.currentPhase === 'activity') {
                    timeLimit = station.activityTime * 60;
                } else if (this.currentPhase === 'feedback') {
                    timeLimit = station.feedbackTime * 60;
                }
            }

            const progressPercent = (candidate.completedStations / this.totalPositions) * 100;
            // Always render timer div for consistency in Activity/Feedback phases
            const timerHtml = `<div class="station-timer">--:--</div>`;
            const statusHtml = `<span class="station-status"></span>`;

            return `
                <div class="candidate-card">
                    <div class="candidate-header">
                        <span class="candidate-name">Candidate ${candidate.id}</span>
                        <span class="candidate-station">${stationName}: ${stationDisplay}</span>
                    </div>
                    <div class="candidate-meta">
                        ${statusHtml}
                        ${timerHtml}
                    </div>
                    <div class="candidate-progress">
                        <div class="candidate-progress-fill" style="width: ${progressPercent}%"></div>
                    </div>
                </div>
            `;
        }).join('');
    }

    // ==================== Keyboard & Modal ====================

    handleKeyboard(e) {
        // Ignore if typing in input
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.tagName === 'SELECT') {
            return;
        }

        switch (e.code) {
            case 'Space':
                e.preventDefault();
                if (this.isExamRunning) {
                    this.togglePause();
                }
                break;

            case 'KeyM':
                this.toggleMute();
                break;

            case 'KeyR':
                if (this.isExamRunning) {
                    this.confirmRestartRound();
                }
                break;

            case 'Escape':
                this.hideModal();
                break;
        }
    }

    toggleMute() {
        const isMuted = !window.voiceManager.isMuted;
        window.voiceManager.setMuted(isMuted);

        const soundIcon = this.elements.muteBtn.querySelector('.icon-sound');
        const mutedIcon = this.elements.muteBtn.querySelector('.icon-muted');

        soundIcon.classList.toggle('hidden', isMuted);
        mutedIcon.classList.toggle('hidden', !isMuted);
    }

    showModal(title, message, onConfirm) {
        this.elements.modalTitle.textContent = title;
        this.elements.modalMessage.textContent = message;
        this.elements.confirmModal.classList.remove('hidden');

        // Set up confirm handler
        this.elements.modalConfirm.onclick = () => {
            // Disable button to prevent double-clicks
            this.elements.modalConfirm.disabled = true;
            this.hideModal();

            try {
                if (onConfirm) onConfirm();
            } catch (e) {
                console.error('Modal action failed:', e);
            } finally {
                // Re-enable after a short delay
                setTimeout(() => {
                    this.elements.modalConfirm.disabled = false;
                }, 500);
            }
        };
    }

    hideModal() {
        this.elements.confirmModal.classList.add('hidden');
    }

    // ==================== Utilities ====================

    isAnnouncementEnabled(type) {
        const toggleMap = {
            readStart: this.elements.annReadStartEnabled,
            activityStart: this.elements.annActivityStartEnabled,
            twoMinWarning: this.elements.annTwoMinWarningEnabled,
            activityEnd: this.elements.annActivityEndEnabled,
            oneMinWarning: this.elements.annOneMinWarningEnabled,
            stationEnd: this.elements.annStationEndEnabled,
            changeover: this.elements.annChangeoverEnabled
        };
        const toggle = toggleMap[type];
        return toggle ? toggle.checked : true;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    // ==================== Persistence ====================

    saveState() {
        if (!this.isExamRunning) return;

        const state = {
            timestamp: Date.now(),
            currentRound: this.currentRound,
            currentPhase: this.currentPhase,
            candidateProgress: this.candidateProgress,
            activityPhaseDuration: this.activityPhaseDuration,
            feedbackPhaseDuration: this.feedbackPhaseDuration,
            readTime: this.readTime,
            changeoverTime: this.changeoverTime,
            numCandidates: this.numCandidates,
            totalPositions: this.totalPositions,
            timerState: window.timer.exportState()
        };

        localStorage.setItem('osce_active_state', JSON.stringify(state));
    }

    restoreState() {
        try {
            const json = localStorage.getItem('osce_active_state');
            if (!json) return;

            const state = JSON.parse(json);
            console.log('Restoring state from:', new Date(state.timestamp));

            // Restore App properties
            this.currentRound = state.currentRound;
            this.currentPhase = state.currentPhase;
            this.candidateProgress = state.candidateProgress;
            this.activityPhaseDuration = state.activityPhaseDuration;
            this.feedbackPhaseDuration = state.feedbackPhaseDuration;
            this.readTime = state.readTime;
            this.changeoverTime = state.changeoverTime;
            this.numCandidates = state.numCandidates;
            this.totalPositions = state.totalPositions;

            // Re-setup UI
            this.elements.setupPanel.classList.add('hidden');
            this.elements.timerPanel.classList.remove('hidden');
            this.elements.crashModal.classList.add('hidden');

            this.renderCandidatesProgress();
            this.updateDisplay();

            // Restore Timer
            this.isExamRunning = true;
            window.timer.importState(state.timerState);

            // Wake up audio logic
            window.voiceManager.resume();

            // Update paused UI
            this.elements.pauseOverlay.classList.remove('hidden');
            this.elements.pauseTime.textContent = `Resumed from: ${window.timer.formatTime(window.timer.secondsRemaining)}`;

            // Ensure pause button shows "Resume"
            window.timer.isPaused = true;
            const pauseText = this.elements.pauseBtn.querySelector('.pause-text');
            const resumeText = this.elements.pauseBtn.querySelector('.resume-text');
            if (pauseText) pauseText.classList.add('hidden');
            if (resumeText) resumeText.classList.remove('hidden');

            window.voiceManager.speak('Exam restored. Press Resume to continue.', true);

        } catch (e) {
            console.error('Failed to restore state:', e);
            alert('Could not restore previous session. Starting fresh.');
            localStorage.removeItem('osce_active_state');
        }
    }
}

// Create global app instance
window.app = new OSCEApp();
