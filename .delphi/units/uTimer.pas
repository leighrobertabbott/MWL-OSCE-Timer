unit uTimer;

{*******************************************************************************
  OSCE Timing System - Precision Timer
  High-resolution timer with drift correction
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.Diagnostics, System.Math,
  Vcl.ExtCtrls, System.Generics.Collections, uTypes;

type
  TTimerTickEvent = procedure(Sender: TObject; SecondsRemaining: Double;
    Progress: Double) of object;
  TPhaseChangeEvent = procedure(Sender: TObject; CompletedPhase: TExamPhase) of object;
  TAnnouncementEvent = procedure(Sender: TObject; AnnouncementType: string;
    SecondsRemaining: Integer) of object;

  TOSCETimer = class
  private
    FTimer: TTimer;
    FStopwatch: TStopwatch;
    FIsRunning: Boolean;
    FIsPaused: Boolean;
    FPausedTime: Int64;
    FTotalPausedDuration: Int64;

    FCurrentPhase: TExamPhase;
    FSecondsRemaining: Double;
    FTotalPhaseSeconds: Integer;

    FAnnouncementsMade: TList<string>;

    FOnTick: TTimerTickEvent;
    FOnPhaseChange: TPhaseChangeEvent;
    FOnAnnouncement: TAnnouncementEvent;

    procedure TimerTick(Sender: TObject);
    procedure CheckAnnouncements;
    procedure HandlePhaseComplete;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start(ASeconds: Integer; APhase: TExamPhase);
    procedure Stop;
    procedure Pause;
    procedure Resume;
    procedure Reset;
    procedure SkipPhase;

    function FormatTime(ASeconds: Double): string;
    function GetProgress: Double;
    function IsWarning: Boolean;
    function IsCritical: Boolean;

    // State persistence
    procedure ExportState(out ASecondsRemaining: Double; out ATotalSeconds: Integer;
      out APhase: TExamPhase; out AIsRunning, AIsPaused: Boolean);
    procedure ImportState(ASecondsRemaining: Double; ATotalSeconds: Integer;
      APhase: TExamPhase);

    property IsRunning: Boolean read FIsRunning;
    property IsPaused: Boolean read FIsPaused write FIsPaused;
    property CurrentPhase: TExamPhase read FCurrentPhase;
    property SecondsRemaining: Double read FSecondsRemaining;
    property TotalPhaseSeconds: Integer read FTotalPhaseSeconds;

    property OnTick: TTimerTickEvent read FOnTick write FOnTick;
    property OnPhaseChange: TPhaseChangeEvent read FOnPhaseChange write FOnPhaseChange;
    property OnAnnouncement: TAnnouncementEvent read FOnAnnouncement write FOnAnnouncement;
  end;

implementation

{ TOSCETimer }

constructor TOSCETimer.Create;
begin
  inherited Create;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;  // 100ms tick
  FTimer.Enabled := False;
  FTimer.OnTimer := TimerTick;

  FAnnouncementsMade := TList<string>.Create;
  FIsRunning := False;
  FIsPaused := False;
end;

destructor TOSCETimer.Destroy;
begin
  FTimer.Free;
  FAnnouncementsMade.Free;
  inherited;
end;

procedure TOSCETimer.Start(ASeconds: Integer; APhase: TExamPhase);
begin
  Stop;

  FSecondsRemaining := ASeconds;
  FTotalPhaseSeconds := ASeconds;
  FCurrentPhase := APhase;
  FIsRunning := True;
  FIsPaused := False;
  FTotalPausedDuration := 0;
  FAnnouncementsMade.Clear;

  FStopwatch := TStopwatch.StartNew;
  FTimer.Enabled := True;
end;

procedure TOSCETimer.Stop;
begin
  FTimer.Enabled := False;
  FStopwatch.Stop;
  FIsRunning := False;
  FIsPaused := False;
end;

procedure TOSCETimer.Pause;
begin
  if not FIsRunning or FIsPaused then Exit;

  FIsPaused := True;
  FPausedTime := FStopwatch.ElapsedMilliseconds;
end;

procedure TOSCETimer.Resume;
begin
  if not FIsRunning or not FIsPaused then Exit;

  FTotalPausedDuration := FTotalPausedDuration +
    (FStopwatch.ElapsedMilliseconds - FPausedTime);
  FIsPaused := False;
end;

procedure TOSCETimer.Reset;
begin
  Stop;
  FSecondsRemaining := FTotalPhaseSeconds;
  FAnnouncementsMade.Clear;
end;

procedure TOSCETimer.SkipPhase;
begin
  FSecondsRemaining := 0;
  HandlePhaseComplete;
end;

procedure TOSCETimer.TimerTick(Sender: TObject);
var
  ElapsedMs: Int64;
  ElapsedSec: Double;
begin
  if not FIsRunning or FIsPaused then Exit;

  // Calculate elapsed with drift correction
  ElapsedMs := FStopwatch.ElapsedMilliseconds - FTotalPausedDuration;
  ElapsedSec := ElapsedMs / 1000.0;
  FSecondsRemaining := FTotalPhaseSeconds - ElapsedSec;

  if FSecondsRemaining < 0 then
    FSecondsRemaining := 0;

  // Fire tick event
  if Assigned(FOnTick) then
    FOnTick(Self, FSecondsRemaining, GetProgress);

  // Check for announcements
  CheckAnnouncements;

  // Check for phase complete
  if FSecondsRemaining <= 0 then
    HandlePhaseComplete;
end;

procedure TOSCETimer.CheckAnnouncements;
var
  Remaining: Integer;
  Key: string;
begin
  Remaining := Ceil(FSecondsRemaining);

  // 2-minute warning during activity
  if (FCurrentPhase = phActivity) and (Remaining = 120) then
  begin
    if not FAnnouncementsMade.Contains('2min') then
    begin
      FAnnouncementsMade.Add('2min');
      if Assigned(FOnAnnouncement) then
        FOnAnnouncement(Self, 'twoMinWarning', Remaining);
    end;
  end;

  // 1-minute warning
  if Remaining = 60 then
  begin
    if not FAnnouncementsMade.Contains('1min') then
    begin
      FAnnouncementsMade.Add('1min');
      if Assigned(FOnAnnouncement) then
        FOnAnnouncement(Self, 'oneMinWarning', Remaining);
    end;
  end;

  // 30-second warning
  if Remaining = 30 then
  begin
    if not FAnnouncementsMade.Contains('30sec') then
    begin
      FAnnouncementsMade.Add('30sec');
      if Assigned(FOnAnnouncement) then
        FOnAnnouncement(Self, 'thirtySecWarning', Remaining);
    end;
  end;

  // 10-second countdown
  if (Remaining <= 10) and (Remaining > 0) then
  begin
    Key := 'countdown' + IntToStr(Remaining);
    if not FAnnouncementsMade.Contains(Key) then
    begin
      FAnnouncementsMade.Add(Key);
      if Assigned(FOnAnnouncement) then
        FOnAnnouncement(Self, 'countdown', Remaining);
    end;
  end;
end;

procedure TOSCETimer.HandlePhaseComplete;
begin
  Stop;
  if Assigned(FOnPhaseChange) then
    FOnPhaseChange(Self, FCurrentPhase);
end;

function TOSCETimer.FormatTime(ASeconds: Double): string;
var
  Mins, Secs: Integer;
  TotalSecs: Integer;
begin
  TotalSecs := Ceil(ASeconds);
  if TotalSecs < 0 then TotalSecs := 0;
  Mins := TotalSecs div 60;
  Secs := TotalSecs mod 60;
  Result := Format('%.2d:%.2d', [Mins, Secs]);
end;

function TOSCETimer.GetProgress: Double;
begin
  if FTotalPhaseSeconds = 0 then
    Result := 0
  else
    Result := 1.0 - (FSecondsRemaining / FTotalPhaseSeconds);
end;

function TOSCETimer.IsWarning: Boolean;
begin
  Result := (FSecondsRemaining <= 120) and (FSecondsRemaining > 30);
end;

function TOSCETimer.IsCritical: Boolean;
begin
  Result := FSecondsRemaining <= 30;
end;

procedure TOSCETimer.ExportState(out ASecondsRemaining: Double;
  out ATotalSeconds: Integer; out APhase: TExamPhase;
  out AIsRunning, AIsPaused: Boolean);
begin
  ASecondsRemaining := FSecondsRemaining;
  ATotalSeconds := FTotalPhaseSeconds;
  APhase := FCurrentPhase;
  AIsRunning := FIsRunning;
  AIsPaused := FIsPaused;
end;

procedure TOSCETimer.ImportState(ASecondsRemaining: Double;
  ATotalSeconds: Integer; APhase: TExamPhase);
begin
  Stop;
  FSecondsRemaining := ASecondsRemaining;
  FTotalPhaseSeconds := ATotalSeconds;
  FCurrentPhase := APhase;
  FAnnouncementsMade.Clear;
  // Timer remains stopped - user must resume manually
end;

end.
