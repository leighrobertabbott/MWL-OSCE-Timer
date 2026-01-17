# MWL-OSCE Timer

**Professional OSCE Examination Timing System**

A comprehensive timing solution for **Objective Structured Clinical Examinations (OSCE)** developed for **Mersey and West Lancashire NHS Teaching Hospitals**.

This repository contains two implementations:
- **Web Application** - Browser-based, cross-platform solution
- **Desktop Application** - Native Windows application built with Delphi FMX

---

## 📋 Overview

OSCE examinations require precise timing coordination across multiple stations with candidates rotating through each station. This system provides:

- **Multi-phase timing**: Read → Activity → Feedback → Changeover
- **Voice announcements**: Automated speech synthesis for phase transitions and warnings
- **Candidate tracking**: Real-time status display for all candidates at their stations
- **Station management**: Configure individual stations with different durations
- **Rest station support**: Designate stations as rest periods

---

## 🖥️ Web Application

### Features
- Cross-platform (runs in any modern browser)
- Text-to-speech voice announcements
- Responsive design (desktop and mobile)
- Settings persistence via localStorage
- Import/Export configuration files (JSON)
- Crash recovery with state restoration

### Files Structure
```
/
├── index.html          # Main application UI
├── css/
│   └── styles.css      # Application styling
└── js/
    ├── app.js          # Main application controller
    ├── timer.js        # Timer logic and phase management
    ├── timer-worker.js # Web Worker for background timing
    ├── voice.js        # Speech synthesis module
    └── stations.js     # Station management
```

### Running the Web App
Simply open `index.html` in a modern web browser. No server required.

For the best experience, use Chrome, Edge, or Firefox for full voice synthesis support.

---

## 🪟 Desktop Application (Delphi FMX)

### Features
- Native Windows performance
- Integrated Windows Speech API (SAPI)
- Starts maximized for projection/display use
- No browser dependencies
- Professional dark theme UI

### Files Structure
```
/.delphi/
├── OSCETimerFMX.dpr       # Main project file
├── OSCETimerFMX.dproj     # Delphi project configuration
├── uMainFMX.pas           # Main form and UI creation
└── units/
    ├── uTimerLogic.pas    # Timer state machine
    ├── uVoice.pas         # Windows SAPI integration
    ├── uStationsFMX.pas   # Station data management
    ├── uConfigFMX.pas     # Configuration handling
    └── uTypesFMX.pas      # Type definitions
```

### Building
**Requirements**: Embarcadero RAD Studio (Delphi) 12.0 or later

1. Open `OSCETimerFMX.dproj` in RAD Studio
2. Select **Win32** target platform
3. Build and Run (F9)

### Pre-built Binary
A compiled executable `OSCETimerFMX.exe` is included for immediate use.

---

## ⚙️ Configuration

### General Settings
| Setting | Description | Default |
|---------|-------------|---------|
| Start Time | Scheduled exam start time | 13:00 |
| Number of Candidates | Total candidates in rotation | 5 |
| Read Time | Duration to read instructions (seconds) | 60 |
| Changeover Time | Time between stations (seconds) | 60 |

### Station Settings
Each station can be configured with:
- **Station Name**: Descriptive name (e.g., "History Taking")
- **Activity Duration**: Time for the main activity phase (minutes)
- **Feedback Duration**: Time for examiner feedback (minutes)
- **Is Rest Station**: Toggle for rest/break stations

### Voice Settings
- **Voice Selection**: Choose from available system voices
- **Speech Rate**: Adjust announcement speed (0.5x - 2.0x)

### Announcements
Customizable voice prompts for:
- Read phase start
- Activity phase start
- 2-minute warning
- Activity end
- 1-minute warning
- Station complete
- Changeover instruction

---

## 🔄 Exam Flow

```
┌─────────────────────────────────────────────────────────┐
│                      ROUND 1                             │
├──────────┬───────────┬───────────┬─────────────────────┤
│  READ    │  ACTIVITY │  FEEDBACK │    CHANGEOVER       │
│  1 min   │   5 min   │   2 min   │      1 min          │
├──────────┴───────────┴───────────┴─────────────────────┤
│  "Read your          "Begin!"     "Stop!"   "Move to   │
│   instructions"                              next       │
│                       ↓                      station"   │
│                 2-min warning                           │
│                 1-min warning                           │
└─────────────────────────────────────────────────────────┘
                            ↓
                      ROUND 2...N
```

Each round consists of:
1. **Read Phase**: Candidates read station instructions
2. **Activity Phase**: Main clinical task with timed warnings
3. **Feedback Phase**: Examiner provides feedback/questions
4. **Changeover**: Candidates rotate to next station

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Space` | Pause/Resume |
| `M` | Toggle Mute |
| `R` | Restart current phase |

---

## 📤 Import/Export

Both applications support configuration import/export via JSON files:

```json
{
  "settings": {
    "startTime": "13:00",
    "numCandidates": 6,
    "readTime": 60,
    "changeoverTime": 60
  },
  "stations": [
    {
      "name": "History Taking",
      "activityDuration": 5,
      "feedbackDuration": 2,
      "isRest": false
    }
  ],
  "announcements": {
    "readStart": "Please read your instructions.",
    "activityStart": "Please begin."
  }
}
```

---

## 🎨 UI Overview

### Setup Panel
Configure all exam parameters before starting:
- General timing settings
- Station configuration with add/remove/reorder
- Voice settings and announcement customization
- Import/Export/Save buttons

### Timer Panel
Active during examination:
- Large countdown display (color-coded by phase)
- Current phase badge
- Progress bar showing phase segments
- Control buttons (Pause, Skip, Restart, Stop)
- Candidate cards showing current station and status
- Next announcement preview

---

## 👨‍💻 Developer

**Leigh Robert Abbott**  
Clinical Education and Simulation  
Mersey and West Lancashire NHS Teaching Hospitals  
📧 leigh.abbott@merseywestlancs.nhs.uk

---

## 📄 License

This is an internal NHS application developed for Clinical Education purposes.

---

## 🔧 Troubleshooting

### Web App
- **No voice?** Check browser permissions for speech synthesis
- **Settings not saving?** Ensure localStorage is not disabled

### Desktop App
- **No voice?** Verify Windows SAPI voices are installed (Control Panel → Speech)
- **Build error?** Ensure all unit dependencies are in the search path

### Installation Issues
- **"Windows protected your PC" (SmartScreen)**:
  - This warning appears because the application allows native system access and is not digitally signed (common for internal tools).
  - To run: Click **More info** (under the text) → **Run anyway**.
  - This only happens the first time you run it.

---

## 🆕 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01 | Initial release with full parity between Web and Desktop |
