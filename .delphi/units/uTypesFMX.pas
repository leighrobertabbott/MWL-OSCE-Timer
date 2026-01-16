unit uTypesFMX;

{*******************************************************************************
  OSCE Timing System - Types and Constants (FMX Version)
  Shared types, constants, and color definitions for FireMonkey
*******************************************************************************}

interface

uses
  System.SysUtils, System.UITypes, System.Generics.Collections;

type
  // Exam phase enumeration
  TExamPhase = (phRead, phActivity, phFeedback, phChangeover);

  // Station record
  TStation = record
    ID: Integer;
    Name: string;
    ActivityTime: Integer;  // minutes
    FeedbackTime: Integer;  // minutes
    Color: TAlphaColor;
    function TotalTime: Integer;
  end;
  PStation = ^TStation;

  TStationList = TList<TStation>;

  // Candidate tracking record
  TCandidate = record
    ID: Integer;
    CurrentPosition: Integer;
    CompletedStations: Integer;
  end;

  TCandidateList = TList<TCandidate>;

  // Announcement settings
  TAnnouncementSettings = record
    ReadStart: string;
    ReadStartEnabled: Boolean;
    ActivityStart: string;
    ActivityStartEnabled: Boolean;
    TwoMinWarning: string;
    TwoMinWarningEnabled: Boolean;
    ActivityEnd: string;
    ActivityEndEnabled: Boolean;
    OneMinWarning: string;
    OneMinWarningEnabled: Boolean;
    StationEnd: string;
    StationEndEnabled: Boolean;
    Changeover: string;
    ChangeoverEnabled: Boolean;
    procedure SetDefaults;
  end;

  // Configuration record
  TExamConfig = record
    StartTime: TTime;
    NumCandidates: Integer;
    ReadTime: Integer;        // seconds
    ChangeoverTime: Integer;  // seconds
    VoiceRate: Single;
    VoiceVolume: Single;
    SelectedVoice: string;
    Announcements: TAnnouncementSettings;
    procedure SetDefaults;
  end;

const
  // Color palette - matching CSS variables (ARGB format for FMX)
  CLR_BG_PRIMARY    = $FF121212;
  CLR_BG_SECONDARY  = $FF1E1E1E;
  CLR_BG_CARD       = $FF252525;
  CLR_BG_ELEVATED   = $FF2D2D2D;

  CLR_TEXT_PRIMARY  = $FFF5F5F5;
  CLR_TEXT_SECONDARY = $FFA0A0A0;
  CLR_TEXT_MUTED    = $FF666666;

  CLR_BORDER        = $FF333333;
  CLR_BORDER_SUBTLE = $FF2A2A2A;

  CLR_ACCENT        = $FF4A9EFF;
  CLR_ACCENT_HOVER  = $FF5AABFF;

  CLR_PHASE_READ      = $FFA855F7;  // Purple
  CLR_PHASE_ACTIVITY  = $FF22C55E;  // Green
  CLR_PHASE_FEEDBACK  = $FF3B82F6;  // Blue
  CLR_PHASE_CHANGEOVER = $FFF59E0B; // Orange

  CLR_DANGER  = $FFEF4444;
  CLR_WARNING = $FFEAB308;

  CLR_NHS_BLUE = $FF005EB8;

  // Phase names
  PHASE_NAMES: array[TExamPhase] of string = (
    'READ', 'ACTIVITY', 'FEEDBACK', 'CHANGEOVER'
  );

  PHASE_LABELS: array[TExamPhase] of string = (
    'Reading Period',
    'Activity',
    'Feedback & Questions',
    'Changeover'
  );

  PHASE_COLORS: array[TExamPhase] of TAlphaColor = (
    CLR_PHASE_READ,
    CLR_PHASE_ACTIVITY,
    CLR_PHASE_FEEDBACK,
    CLR_PHASE_CHANGEOVER
  );

  // Default station colors
  DEFAULT_STATION_COLORS: array[0..7] of TAlphaColor = (
    $FF22C55E,  // Green
    $FF3B82F6,  // Blue
    $FFA855F7,  // Purple
    $FFEC4899,  // Pink
    $FFF59E0B,  // Orange
    $FF06B6D4,  // Cyan
    $FF84CC16,  // Lime
    $FFEF4444   // Rose
  );

function PhaseToColor(APhase: TExamPhase): TAlphaColor;
function NextPhase(APhase: TExamPhase): TExamPhase;
function FormatSeconds(ASeconds: Integer): string;

implementation

{ TStation }

function TStation.TotalTime: Integer;
begin
  Result := ActivityTime + FeedbackTime;
end;

{ TAnnouncementSettings }

procedure TAnnouncementSettings.SetDefaults;
begin
  ReadStart := 'Please read your instructions. You have 1 minute.';
  ReadStartEnabled := True;
  ActivityStart := 'Please begin. You have {time} minutes for the activity phase.';
  ActivityStartEnabled := True;
  TwoMinWarning := 'Two minutes remaining.';
  TwoMinWarningEnabled := True;
  ActivityEnd := 'Please stop. You may now begin feedback and questions.';
  ActivityEndEnabled := True;
  OneMinWarning := 'One minute remaining.';
  OneMinWarningEnabled := True;
  StationEnd := 'This round is now complete. Please prepare to rotate.';
  StationEndEnabled := True;
  Changeover := 'Please move to your next station and read the instructions.';
  ChangeoverEnabled := True;
end;

{ TExamConfig }

procedure TExamConfig.SetDefaults;
begin
  StartTime := EncodeTime(13, 0, 0, 0);
  NumCandidates := 5;
  ReadTime := 60;
  ChangeoverTime := 60;
  VoiceRate := 1.0;
  VoiceVolume := 1.0;
  SelectedVoice := '';
  Announcements.SetDefaults;
end;

{ Helper Functions }

function PhaseToColor(APhase: TExamPhase): TAlphaColor;
begin
  Result := PHASE_COLORS[APhase];
end;

function NextPhase(APhase: TExamPhase): TExamPhase;
begin
  case APhase of
    phRead:       Result := phActivity;
    phActivity:   Result := phFeedback;
    phFeedback:   Result := phChangeover;
    phChangeover: Result := phRead;
  else
    Result := phRead;
  end;
end;

function FormatSeconds(ASeconds: Integer): string;
var
  Mins, Secs: Integer;
begin
  Mins := ASeconds div 60;
  Secs := ASeconds mod 60;
  Result := Format('%.2d:%.2d', [Mins, Secs]);
end;

end.
