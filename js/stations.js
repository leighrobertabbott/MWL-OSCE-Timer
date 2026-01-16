/**
 * OSCE Timing System - Stations Module
 * Station configuration and management
 */

class StationsManager {
    constructor() {
        // Default OSCE stations as per requirements
        this.stations = [
            {
                id: 1,
                name: 'History Taking',
                activityTime: 10, // minutes
                feedbackTime: 4,  // minutes
                totalTime: 14,
                color: '#10b981'
            },
            {
                id: 2,
                name: 'Manual BP',
                activityTime: 8,
                feedbackTime: 6,
                totalTime: 14,
                color: '#3b82f6'
            },
            {
                id: 3,
                name: 'Capillary Blood Glucose',
                activityTime: 9,
                feedbackTime: 5,
                totalTime: 14,
                color: '#8b5cf6'
            },
            {
                id: 4,
                name: 'Observations & Handwashing',
                activityTime: 9,
                feedbackTime: 5,
                totalTime: 14,
                color: '#ec4899'
            },
            {
                id: 5,
                name: 'Urinalysis & Peak Flow',
                activityTime: 10,
                feedbackTime: 4,
                totalTime: 14,
                color: '#f59e0b'
            }
        ];

        this.nextId = 6;
    }

    /**
     * Get all stations
     */
    getAll() {
        return [...this.stations];
    }

    /**
     * Get station by index
     */
    getByIndex(index) {
        return this.stations[index] || null;
    }

    /**
     * Get station by ID
     */
    getById(id) {
        return this.stations.find(s => s.id === id) || null;
    }

    /**
     * Get number of stations
     */
    getCount() {
        return this.stations.length;
    }

    /**
     * Add a new station
     */
    add(name = 'New Station', activityTime = 10, feedbackTime = 4) {
        const station = {
            id: this.nextId++,
            name,
            activityTime,
            feedbackTime,
            totalTime: activityTime + feedbackTime,
            color: this.getRandomColor()
        };
        this.stations.push(station);
        return station;
    }

    /**
     * Update a station
     */
    update(id, updates) {
        const station = this.getById(id);
        if (!station) return null;

        Object.assign(station, updates);
        station.totalTime = station.activityTime + station.feedbackTime;
        return station;
    }

    /**
     * Remove a station
     */
    remove(id) {
        const index = this.stations.findIndex(s => s.id === id);
        if (index === -1) return false;

        this.stations.splice(index, 1);
        return true;
    }

    /**
     * Reorder stations
     */
    reorder(fromIndex, toIndex) {
        const [station] = this.stations.splice(fromIndex, 1);
        this.stations.splice(toIndex, 0, station);
    }

    /**
     * Get activity time in seconds
     */
    getActivitySeconds(index) {
        const station = this.getByIndex(index);
        return station ? station.activityTime * 60 : 0;
    }

    /**
     * Get feedback time in seconds
     */
    getFeedbackSeconds(index) {
        const station = this.getByIndex(index);
        return station ? station.feedbackTime * 60 : 0;
    }

    /**
     * Get total station time in seconds
     */
    getTotalSeconds(index) {
        const station = this.getByIndex(index);
        return station ? station.totalTime * 60 : 0;
    }

    /**
     * Calculate total exam time
     */
    getTotalExamTime(changeoverSeconds, numCandidates) {
        const stationTime = this.stations.reduce((sum, s) => sum + s.totalTime, 0);
        const changeoverTime = (this.stations.length - 1) * (changeoverSeconds / 60);
        const totalPerRound = stationTime + changeoverTime;
        return totalPerRound * numCandidates;
    }

    /**
     * Export configuration
     */
    export() {
        return JSON.stringify({
            stations: this.stations,
            nextId: this.nextId
        });
    }

    /**
     * Import configuration
     */
    import(json) {
        try {
            const data = JSON.parse(json);
            this.stations = data.stations || [];
            this.nextId = data.nextId || this.stations.length + 1;
            return true;
        } catch (e) {
            console.error('Failed to import stations:', e);
            return false;
        }
    }

    /**
     * Reset to defaults
     */
    reset() {
        this.stations = [
            { id: 1, name: 'History Taking', activityTime: 10, feedbackTime: 4, totalTime: 14, color: '#10b981' },
            { id: 2, name: 'Manual BP', activityTime: 8, feedbackTime: 6, totalTime: 14, color: '#3b82f6' },
            { id: 3, name: 'Capillary Blood Glucose', activityTime: 9, feedbackTime: 5, totalTime: 14, color: '#8b5cf6' },
            { id: 4, name: 'Observations & Handwashing', activityTime: 9, feedbackTime: 5, totalTime: 14, color: '#ec4899' },
            { id: 5, name: 'Urinalysis & Peak Flow', activityTime: 10, feedbackTime: 4, totalTime: 14, color: '#f59e0b' }
        ];
        this.nextId = 6;
    }

    getRandomColor() {
        const colors = ['#10b981', '#3b82f6', '#8b5cf6', '#ec4899', '#f59e0b', '#06b6d4', '#84cc16', '#f43f5e'];
        return colors[Math.floor(Math.random() * colors.length)];
    }
}

// Create global instance
window.stationsManager = new StationsManager();
