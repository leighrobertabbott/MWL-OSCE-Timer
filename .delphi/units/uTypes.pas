unit uTypes;

{*******************************************************************************
  OSCE Timing System - Types and Constants
  Shared types, constants, and color definitions
*******************************************************************************}

interface

uses
  System.SysUtils, System.Generics.Collections, Vcl.Graphics;

type
  // Exam phase enumeration
  TExamPhase = (phRead, phActivity, phFeedback, phChangeover);

  // Station record
  TStation = record
    ID: Integer;
    Name: string;
    ActivityTime: Integer;  // minutes
    FeedbackTime: Integer;  // minutes
    Color: TColor;
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
  // Color palette - matching CSS variables
  CLR_BG_PRIMARY    = $00121212;
  CLR_BG_SECONDARY  = $001E1E1E;
  CLR_BG_CARD       = $00252525;
  CLR_BG_ELEVATED   = $002D2D2D;

  CLR_TEXT_PRIMARY  = $00F5F5F5;
  CLR_TEXT_SECONDARY = $00A0A0A0;
  CLR_TEXT_MUTED    = $00666666;

  CLR_BORDER        = $00333333;
  CLR_BORDER_SUBTLE = $002A2A2A;

  CLR_ACCENT        = $00FF9E4A;  // #4a9eff in BGR
  CLR_ACCENT_HOVER  = $00FFAB5A;

  CLR_PHASE_READ      = $00F755A8;  // Purple
  CLR_PHASE_ACTIVITY  = $005EC522;  // Green
  CLR_PHASE_FEEDBACK  = $00F6823B;  // Blue
  CLR_PHASE_CHANGEOVER = $000B9EF5; // Orange

  CLR_DANGER  = $004444EF;
  CLR_WARNING = $0008B3EA;

  CLR_NHS_BLUE = $00B85E00;  // #005EB8

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

  PHASE_COLORS: array[TExamPhase] of TColor = (
    CLR_PHASE_READ,
    CLR_PHASE_ACTIVITY,
    CLR_PHASE_FEEDBACK,
    CLR_PHASE_CHANGEOVER
  );

  // Default stations
  DEFAULT_STATION_COLORS: array[0..7] of TColor = (
    $008110B9,  // Green
    $00F6823B,  // Blue
    $00F65C8B,  // Purple
    $009948EC,  // Pink
    $000B9EF5,  // Orange
    $00D4B606,  // Cyan
    $001684CC,  // Lime
    $005E3FF4   // Rose
  );

function PhaseToColor(APhase: TExamPhase): TColor;
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

function PhaseToColor(APhase: TExamPhase): TColor;
begin
  Result := PHASE_COLORS[APhase];
end;

function NextPhase(APhase: TExamPhase): TExamPhase;
begin
  case APhase of
    phRead:      Result := phActivity;
    phActivity:  Result := phFeedback;
    phFeedback:  Result := phChangeover;
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
