unit uTimerFrame;

{*******************************************************************************
  OSCE Timing System - Timer Panel Frame
  Running exam display with countdown and controls
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, System.Generics.Collections,
  uTypes, uTimer, uStations, uVoice, uConfig, uConfirmDialog;

type
  TStopExamEvent = procedure(Sender: TObject) of object;

  TTimerFrame = class(TFrame)
  private
    // Timer display
    FPanelPhase: TPanel;
    FLblPhase: TLabel;
    FLblCountdown: TLabel;
    FLblCountdownLabel: TLabel;
    FLblStationName: TLabel;
    FLblStationDesc: TLabel;

    // Progress bar
    FPanelProgress: TPanel;
    FProgressSegments: array[TExamPhase] of TPanel;
    FProgressFills: array[TExamPhase] of TPanel;
    FProgressLabels: TPanel;

    // Controls
    FPanelControls: TPanel;
    FBtnPause: TButton;
    FBtnSkip: TButton;
    FBtnRestart: TButton;
    FBtnStop: TButton;

    // Pause overlay
    FPauseOverlay: TPanel;
    FLblPaused: TLabel;
    FLblPauseHint: TLabel;
    FLblPauseTime: TLabel;

    // Candidates grid
    FPanelCandidates: TPanel;
    FScrollBoxCandidates: TScrollBox;
    FCandidateCards: TList<TPanel>;

    // Next announcement
    FPanelAnnouncement: TPanel;
    FLblAnnTime: TLabel;
    FLblAnnText: TLabel;

    // State
    FTimer: TOSCETimer;
    FCurrentPhase: TExamPhase;
    FCurrentRound: Integer;
    FNumCandidates: Integer;
    FTotalPositions: Integer;
    FReadTime: Integer;
    FChangeoverTime: Integer;
    FCandidates: TCandidateList;
    FAnnouncements: TAnnouncementSettings;
    FActivityPhaseDuration: Integer;
    FFeedbackPhaseDuration: Integer;

    FOnStopExam: TStopExamEvent;

    procedure CreateComponents;
    procedure CreateTimerDisplay;
    procedure CreateProgressBar;
    procedure CreateControls;
    procedure CreatePauseOverlay;
    procedure CreateCandidatesGrid;
    procedure CreateAnnouncementPreview;
    procedure ApplyStyles;

    procedure RenderCandidatesProgress;
    procedure UpdateDisplay;
    procedure UpdateProgressBar(AProgress: Double);
    procedure UpdateNextAnnouncement(ASecondsRemaining: Double);
    procedure UpdateCandidateTimers(ASecondsRemaining: Double);

    // Timer callbacks
    procedure OnTimerTick(Sender: TObject; SecondsRemaining: Double; Progress: Double);
    procedure OnPhaseChange(Sender: TObject; CompletedPhase: TExamPhase);
    procedure OnAnnouncement(Sender: TObject; AnnouncementType: string; SecondsRemaining: Integer);

    // Control handlers
    procedure BtnPauseClick(Sender: TObject);
    procedure BtnSkipClick(Sender: TObject);
    procedure BtnRestartClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);

    // Phase management
    procedure TransitionToPhase(APhase: TExamPhase);
    procedure StartReadPhase;
    procedure StartActivityPhase;
    procedure StartFeedbackPhase;
    procedure StartChangeoverPhase;
    procedure StartRound;
    procedure FinishExam;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure StartExam(const AConfig: TExamConfig);
    procedure StopExam;
    procedure TogglePause;
    procedure HandleKeyPress(AKey: Word);

    property OnStopExam: TStopExamEvent read FOnStopExam write FOnStopExam;
  end;

implementation

{$R *.dfm}

{ TTimerFrame }

constructor TTimerFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Color := CLR_BG_PRIMARY;
  FCandidateCards := TList<TPanel>.Create;
  FCandidates := TCandidateList.Create;

  FTimer := TOSCETimer.Create;
  FTimer.OnTick := OnTimerTick;
  FTimer.OnPhaseChange := OnPhaseChange;
  FTimer.OnAnnouncement := OnAnnouncement;

  CreateComponents;
  ApplyStyles;
end;

destructor TTimerFrame.Destroy;
begin
  FTimer.Free;
  FCandidates.Free;
  FCandidateCards.Free;
  inherited;
end;

procedure TTimerFrame.CreateComponents;
begin
  CreateTimerDisplay;
  CreateProgressBar;
  CreateControls;
  CreatePauseOverlay;
  CreateCandidatesGrid;
  CreateAnnouncementPreview;
end;

procedure TTimerFrame.CreateTimerDisplay;
begin
  // Phase indicator
  FPanelPhase := TPanel.Create(Self);
  FPanelPhase.Parent := Self;
  FPanelPhase.Left := (Width - 150) div 2;
  FPanelPhase.Top := 20;
  FPanelPhase.Width := 150;
  FPanelPhase.Height := 32;
  FPanelPhase.BevelOuter := bvNone;
  FPanelPhase.Color := CLR_PHASE_ACTIVITY;
  FPanelPhase.Anchors := [akTop];

  FLblPhase := TLabel.Create(FPanelPhase);
  FLblPhase.Parent := FPanelPhase;
  FLblPhase.Align := alClient;
  FLblPhase.Alignment := taCenter;
  FLblPhase.Layout := tlCenter;
  FLblPhase.Caption := 'ACTIVITY';
  FLblPhase.Font.Name := 'Segoe UI';
  FLblPhase.Font.Size := 10;
  FLblPhase.Font.Style := [fsBold];
  FLblPhase.Font.Color := clWhite;

  // Main countdown
  FLblCountdown := TLabel.Create(Self);
  FLblCountdown.Parent := Self;
  FLblCountdown.Left := 0;
  FLblCountdown.Top := 70;
  FLblCountdown.Width := Width;
  FLblCountdown.Height := 100;
  FLblCountdown.Alignment := taCenter;
  FLblCountdown.Caption := '00:00';
  FLblCountdown.Font.Name := 'Consolas';
  FLblCountdown.Font.Size := 72;
  FLblCountdown.Font.Style := [fsBold];
  FLblCountdown.Font.Color := CLR_TEXT_PRIMARY;
  FLblCountdown.Anchors := [akLeft, akTop, akRight];

  // Countdown label
  FLblCountdownLabel := TLabel.Create(Self);
  FLblCountdownLabel.Parent := Self;
  FLblCountdownLabel.Left := 0;
  FLblCountdownLabel.Top := 175;
  FLblCountdownLabel.Width := Width;
  FLblCountdownLabel.Height := 20;
  FLblCountdownLabel.Alignment := taCenter;
  FLblCountdownLabel.Caption := 'TIME REMAINING';
  FLblCountdownLabel.Font.Name := 'Segoe UI';
  FLblCountdownLabel.Font.Size := 9;
  FLblCountdownLabel.Font.Color := CLR_TEXT_MUTED;
  FLblCountdownLabel.Anchors := [akLeft, akTop, akRight];

  // Station name
  FLblStationName := TLabel.Create(Self);
  FLblStationName.Parent := Self;
  FLblStationName.Left := 0;
  FLblStationName.Top := 205;
  FLblStationName.Width := Width;
  FLblStationName.Height := 28;
  FLblStationName.Alignment := taCenter;
  FLblStationName.Caption := 'Round 1';
  FLblStationName.Font.Name := 'Segoe UI';
  FLblStationName.Font.Size := 16;
  FLblStationName.Font.Style := [fsBold];
  FLblStationName.Font.Color := CLR_TEXT_PRIMARY;
  FLblStationName.Anchors := [akLeft, akTop, akRight];

  // Station description
  FLblStationDesc := TLabel.Create(Self);
  FLblStationDesc.Parent := Self;
  FLblStationDesc.Left := 0;
  FLblStationDesc.Top := 235;
  FLblStationDesc.Width := Width;
  FLblStationDesc.Height := 20;
  FLblStationDesc.Alignment := taCenter;
  FLblStationDesc.Caption := '5 candidates at 5 stations';
  FLblStationDesc.Font.Name := 'Segoe UI';
  FLblStationDesc.Font.Size := 10;
  FLblStationDesc.Font.Color := CLR_TEXT_SECONDARY;
  FLblStationDesc.Anchors := [akLeft, akTop, akRight];
end;

procedure TTimerFrame.CreateProgressBar;
var
  Phase: TExamPhase;
  X, W: Integer;
  Lbl: TLabel;
  LblPanel: TPanel;
  Labels: array[TExamPhase] of string;
begin
  Labels[phRead] := 'Read';
  Labels[phActivity] := 'Activity';
  Labels[phFeedback] := 'Feedback';
  Labels[phChangeover] := 'Changeover';

  FPanelProgress := TPanel.Create(Self);
  FPanelProgress.Parent := Self;
  FPanelProgress.Left := 40;
  FPanelProgress.Top := 270;
  FPanelProgress.Width := Width - 80;
  FPanelProgress.Height := 40;
  FPanelProgress.BevelOuter := bvNone;
  FPanelProgress.Color := CLR_BG_PRIMARY;
  FPanelProgress.Anchors := [akLeft, akTop, akRight];

  W := (FPanelProgress.Width - 6) div 4;  // 4 segments with gaps
  X := 0;

  for Phase := Low(TExamPhase) to High(TExamPhase) do
  begin
    // Segment background
    FProgressSegments[Phase] := TPanel.Create(FPanelProgress);
    FProgressSegments[Phase].Parent := FPanelProgress;
    FProgressSegments[Phase].Left := X;
    FProgressSegments[Phase].Top := 0;
    FProgressSegments[Phase].Width := W;
    FProgressSegments[Phase].Height := 8;
    FProgressSegments[Phase].BevelOuter := bvNone;
    FProgressSegments[Phase].Color := CLR_BG_ELEVATED;

    // Fill
    FProgressFills[Phase] := TPanel.Create(FProgressSegments[Phase]);
    FProgressFills[Phase].Parent := FProgressSegments[Phase];
    FProgressFills[Phase].Left := 0;
    FProgressFills[Phase].Top := 0;
    FProgressFills[Phase].Width := 0;
    FProgressFills[Phase].Height := 8;
    FProgressFills[Phase].BevelOuter := bvNone;
    FProgressFills[Phase].Color := PHASE_COLORS[Phase];

    Inc(X, W + 2);
  end;

  // Labels
  FProgressLabels := TPanel.Create(FPanelProgress);
  FProgressLabels.Parent := FPanelProgress;
  FProgressLabels.Left := 0;
  FProgressLabels.Top := 12;
  FProgressLabels.Width := FPanelProgress.Width;
  FProgressLabels.Height := 20;
  FProgressLabels.BevelOuter := bvNone;
  FProgressLabels.Color := CLR_BG_PRIMARY;

  W := FProgressLabels.Width div 4;
  X := 0;
  for Phase := Low(TExamPhase) to High(TExamPhase) do
  begin
    Lbl := TLabel.Create(FProgressLabels);
    Lbl.Parent := FProgressLabels;
    Lbl.Left := X;
    Lbl.Top := 0;
    Lbl.Width := W;
    Lbl.Caption := Labels[Phase];
    Lbl.Font.Size := 8;
    Lbl.Font.Color := CLR_TEXT_MUTED;
    Inc(X, W);
  end;
end;

procedure TTimerFrame.CreateControls;
begin
  FPanelControls := TPanel.Create(Self);
  FPanelControls.Parent := Self;
  FPanelControls.Left := 0;
  FPanelControls.Top := 320;
  FPanelControls.Width := Width;
  FPanelControls.Height := 50;
  FPanelControls.BevelOuter := bvNone;
  FPanelControls.Color := CLR_BG_PRIMARY;
  FPanelControls.Anchors := [akLeft, akTop, akRight];

  // Pause
  FBtnPause := TButton.Create(FPanelControls);
  FBtnPause.Parent := FPanelControls;
  FBtnPause.Left := (FPanelControls.Width - 420) div 2;
  FBtnPause.Top := 8;
  FBtnPause.Width := 100;
  FBtnPause.Height := 36;
  FBtnPause.Caption := 'Pause';
  FBtnPause.OnClick := BtnPauseClick;

  // Skip Phase
  FBtnSkip := TButton.Create(FPanelControls);
  FBtnSkip.Parent := FPanelControls;
  FBtnSkip.Left := FBtnPause.Left + 110;
  FBtnSkip.Top := 8;
  FBtnSkip.Width := 100;
  FBtnSkip.Height := 36;
  FBtnSkip.Caption := 'Skip Phase';
  FBtnSkip.OnClick := BtnSkipClick;

  // Restart
  FBtnRestart := TButton.Create(FPanelControls);
  FBtnRestart.Parent := FPanelControls;
  FBtnRestart.Left := FBtnSkip.Left + 110;
  FBtnRestart.Top := 8;
  FBtnRestart.Width := 100;
  FBtnRestart.Height := 36;
  FBtnRestart.Caption := 'Restart Round';
  FBtnRestart.OnClick := BtnRestartClick;

  // Stop
  FBtnStop := TButton.Create(FPanelControls);
  FBtnStop.Parent := FPanelControls;
  FBtnStop.Left := FBtnRestart.Left + 110;
  FBtnStop.Top := 8;
  FBtnStop.Width := 100;
  FBtnStop.Height := 36;
  FBtnStop.Caption := 'Stop Exam';
  FBtnStop.OnClick := BtnStopClick;
end;

procedure TTimerFrame.CreatePauseOverlay;
begin
  FPauseOverlay := TPanel.Create(Self);
  FPauseOverlay.Parent := Self;
  FPauseOverlay.Align := alClient;
  FPauseOverlay.BevelOuter := bvNone;
  FPauseOverlay.Color := CLR_BG_PRIMARY;
  FPauseOverlay.Visible := False;

  FLblPaused := TLabel.Create(FPauseOverlay);
  FLblPaused.Parent := FPauseOverlay;
  FLblPaused.Left := 0;
  FLblPaused.Top := 150;
  FLblPaused.Width := Width;
  FLblPaused.Height := 60;
  FLblPaused.Alignment := taCenter;
  FLblPaused.Caption := 'PAUSED';
  FLblPaused.Font.Name := 'Segoe UI';
  FLblPaused.Font.Size := 36;
  FLblPaused.Font.Style := [fsBold];
  FLblPaused.Font.Color := CLR_WARNING;
  FLblPaused.Anchors := [akLeft, akTop, akRight];

  FLblPauseHint := TLabel.Create(FPauseOverlay);
  FLblPauseHint.Parent := FPauseOverlay;
  FLblPauseHint.Left := 0;
  FLblPauseHint.Top := 220;
  FLblPauseHint.Width := Width;
  FLblPauseHint.Height := 24;
  FLblPauseHint.Alignment := taCenter;
  FLblPauseHint.Caption := 'Press Resume or Space to continue';
  FLblPauseHint.Font.Name := 'Segoe UI';
  FLblPauseHint.Font.Size := 11;
  FLblPauseHint.Font.Color := CLR_TEXT_SECONDARY;
  FLblPauseHint.Anchors := [akLeft, akTop, akRight];

  FLblPauseTime := TLabel.Create(FPauseOverlay);
  FLblPauseTime.Parent := FPauseOverlay;
  FLblPauseTime.Left := 0;
  FLblPauseTime.Top := 260;
  FLblPauseTime.Width := Width;
  FLblPauseTime.Height := 20;
  FLblPauseTime.Alignment := taCenter;
  FLblPauseTime.Caption := 'Paused at: --:--';
  FLblPauseTime.Font.Name := 'Consolas';
  FLblPauseTime.Font.Size := 10;
  FLblPauseTime.Font.Color := CLR_TEXT_MUTED;
  FLblPauseTime.Anchors := [akLeft, akTop, akRight];
end;

procedure TTimerFrame.CreateCandidatesGrid;
var
  Lbl: TLabel;
begin
  FPanelCandidates := TPanel.Create(Self);
  FPanelCandidates.Parent := Self;
  FPanelCandidates.Left := 0;
  FPanelCandidates.Top := 380;
  FPanelCandidates.Width := Width;
  FPanelCandidates.Height := 180;
  FPanelCandidates.BevelOuter := bvNone;
  FPanelCandidates.Color := CLR_BG_PRIMARY;
  FPanelCandidates.Anchors := [akLeft, akTop, akRight, akBottom];

  Lbl := TLabel.Create(FPanelCandidates);
  Lbl.Parent := FPanelCandidates;
  Lbl.Left := 16;
  Lbl.Top := 0;
  Lbl.Caption := 'CANDIDATES';
  Lbl.Font.Size := 10;
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Color := CLR_TEXT_SECONDARY;

  FScrollBoxCandidates := TScrollBox.Create(FPanelCandidates);
  FScrollBoxCandidates.Parent := FPanelCandidates;
  FScrollBoxCandidates.Left := 0;
  FScrollBoxCandidates.Top := 24;
  FScrollBoxCandidates.Width := FPanelCandidates.Width;
  FScrollBoxCandidates.Height := FPanelCandidates.Height - 24;
  FScrollBoxCandidates.BorderStyle := bsNone;
  FScrollBoxCandidates.Color := CLR_BG_PRIMARY;
  FScrollBoxCandidates.Anchors := [akLeft, akTop, akRight, akBottom];
end;

procedure TTimerFrame.CreateAnnouncementPreview;
var
  Lbl: TLabel;
begin
  FPanelAnnouncement := TPanel.Create(Self);
  FPanelAnnouncement.Parent := Self;
  FPanelAnnouncement.Left := 0;
  FPanelAnnouncement.Top := 570;
  FPanelAnnouncement.Width := Width;
  FPanelAnnouncement.Height := 60;
  FPanelAnnouncement.BevelOuter := bvNone;
  FPanelAnnouncement.Color := CLR_BG_PRIMARY;
  FPanelAnnouncement.Anchors := [akLeft, akRight, akBottom];

  Lbl := TLabel.Create(FPanelAnnouncement);
  Lbl.Parent := FPanelAnnouncement;
  Lbl.Left := 16;
  Lbl.Top := 0;
  Lbl.Caption := 'NEXT ANNOUNCEMENT';
  Lbl.Font.Size := 10;
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Color := CLR_TEXT_SECONDARY;

  FLblAnnTime := TLabel.Create(FPanelAnnouncement);
  FLblAnnTime.Parent := FPanelAnnouncement;
  FLblAnnTime.Left := 16;
  FLblAnnTime.Top := 28;
  FLblAnnTime.Caption := '--:--';
  FLblAnnTime.Font.Name := 'Consolas';
  FLblAnnTime.Font.Size := 12;
  FLblAnnTime.Font.Style := [fsBold];
  FLblAnnTime.Font.Color := CLR_ACCENT;

  FLblAnnText := TLabel.Create(FPanelAnnouncement);
  FLblAnnText.Parent := FPanelAnnouncement;
  FLblAnnText.Left := 80;
  FLblAnnText.Top := 30;
  FLblAnnText.Caption := 'No upcoming announcements';
  FLblAnnText.Font.Size := 10;
  FLblAnnText.Font.Color := CLR_TEXT_SECONDARY;
end;

procedure TTimerFrame.ApplyStyles;
begin
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Font.Color := CLR_TEXT_PRIMARY;
end;

procedure TTimerFrame.StartExam(const AConfig: TExamConfig);
var
  I: Integer;
  C: TCandidate;
begin
  // Initialize exam state
  FAnnouncements := AConfig.Announcements;
  FReadTime := AConfig.ReadTime;
  FChangeoverTime := AConfig.ChangeoverTime;
  FNumCandidates := AConfig.NumCandidates;

  FCurrentRound := 0;
  FTotalPositions := Max(StationsManager.GetCount, FNumCandidates);

  // Initialize candidates
  FCandidates.Clear;
  for I := 0 to FNumCandidates - 1 do
  begin
    C.ID := I + 1;
    C.CurrentPosition := I;
    C.CompletedStations := 0;
    FCandidates.Add(C);
  end;

  RenderCandidatesProgress;
  TransitionToPhase(phRead);
end;

procedure TTimerFrame.StopExam;
begin
  FTimer.Stop;
  ConfigManager.ClearActiveState;
end;

procedure TTimerFrame.TogglePause;
begin
  if FTimer.IsPaused then
  begin
    FTimer.Resume;
    FPauseOverlay.Visible := False;
    FBtnPause.Caption := 'Pause';
    VoiceManager.Speak('Timer resumed.', True);
  end
  else
  begin
    FTimer.Pause;
    FPauseOverlay.Visible := True;
    FPauseOverlay.BringToFront;
    FLblPauseTime.Caption := 'Paused at: ' + FormatSeconds(Round(FTimer.SecondsRemaining));
    FBtnPause.Caption := 'Resume';
    VoiceManager.Speak('Timer paused.', True);
  end;
end;

procedure TTimerFrame.HandleKeyPress(AKey: Word);
begin
  case AKey of
    VK_SPACE: TogglePause;
  end;
end;

procedure TTimerFrame.TransitionToPhase(APhase: TExamPhase);
begin
  FCurrentPhase := APhase;

  case APhase of
    phRead: StartReadPhase;
    phActivity: StartActivityPhase;
    phFeedback: StartFeedbackPhase;
    phChangeover: StartChangeoverPhase;
  end;

  UpdateDisplay;
  RenderCandidatesProgress;
end;

procedure TTimerFrame.StartReadPhase;
begin
  if FAnnouncements.ReadStartEnabled then
  begin
    VoiceManager.PlayAttentionBeeps;
    VoiceManager.Speak(FAnnouncements.ReadStart, True);
  end
  else
    VoiceManager.PlayAttentionBeeps;

  FTimer.Start(FReadTime, phRead);
end;

procedure TTimerFrame.StartActivityPhase;
var
  MaxActivity: Integer;
begin
  MaxActivity := StationsManager.GetMaxActivityTime;
  FActivityPhaseDuration := MaxActivity * 60;
  FFeedbackPhaseDuration := 0;

  FTimer.Start(FActivityPhaseDuration, phActivity);

  if FAnnouncements.ActivityStartEnabled then
  begin
    var Msg := StringReplace(FAnnouncements.ActivityStart, '{time}',
      IntToStr(MaxActivity), [rfReplaceAll]);
    VoiceManager.Speak(Msg, True);
  end;
  VoiceManager.PlayStartBeep;
end;

procedure TTimerFrame.StartFeedbackPhase;
var
  MaxTotal, MaxActivity: Integer;
begin
  if FAnnouncements.ActivityEndEnabled then
  begin
    VoiceManager.PlayWarningBeeps;
    VoiceManager.Speak(FAnnouncements.ActivityEnd, True);
  end;

  MaxActivity := StationsManager.GetMaxActivityTime;
  MaxTotal := StationsManager.GetMaxTotalTime;
  FFeedbackPhaseDuration := (MaxTotal - MaxActivity) * 60;

  FTimer.Start(FFeedbackPhaseDuration, phFeedback);
end;

procedure TTimerFrame.StartChangeoverPhase;
begin
  if FAnnouncements.StationEndEnabled then
  begin
    VoiceManager.Speak(FAnnouncements.StationEnd, True);
  end;
  VoiceManager.PlayEndBeep;

  FTimer.Start(FChangeoverTime, phChangeover);

  if FAnnouncements.ChangeoverEnabled then
    VoiceManager.Speak(FAnnouncements.Changeover, True);
end;

procedure TTimerFrame.StartRound;
begin
  if FCurrentRound >= FTotalPositions then
  begin
    FinishExam;
    Exit;
  end;

  if FReadTime > 0 then
    TransitionToPhase(phRead)
  else
    TransitionToPhase(phActivity);
end;

procedure TTimerFrame.FinishExam;
begin
  FTimer.Stop;
  VoiceManager.PlayComplete;
  VoiceManager.Speak('The OSCE examination is now complete. Thank you all for participating.', True);

  FLblCountdown.Caption := 'DONE';
  FLblPhase.Caption := 'EXAM COMPLETE';
  FPanelPhase.Color := CLR_PHASE_ACTIVITY;
end;

procedure TTimerFrame.RenderCandidatesProgress;
var
  I, X, Y: Integer;
  Card: TPanel;
  LblName, LblStation, LblStatus, LblTimer: TLabel;
  ProgressBar, ProgressFill: TPanel;
  C: TCandidate;
  Stations: TStationList;
  StationName, StationDisplay: string;
  ProgressPct: Double;
begin
  // Clear existing cards
  for I := FCandidateCards.Count - 1 downto 0 do
    FCandidateCards[I].Free;
  FCandidateCards.Clear;

  Stations := StationsManager.GetAll;
  X := 8;
  Y := 8;

  for I := 0 to FCandidates.Count - 1 do
  begin
    C := FCandidates[I];

    // Determine station info
    if C.CurrentPosition < Stations.Count then
    begin
      StationName := Format('Station %d', [C.CurrentPosition + 1]);
      StationDisplay := Stations[C.CurrentPosition].Name;
    end
    else
    begin
      StationName := 'Rest';
      StationDisplay := 'Rest Station';
    end;

    // Create card
    Card := TPanel.Create(FScrollBoxCandidates);
    Card.Parent := FScrollBoxCandidates;
    Card.Left := X;
    Card.Top := Y;
    Card.Width := 180;
    Card.Height := 70;
    Card.BevelOuter := bvNone;
    Card.Color := CLR_BG_CARD;
    Card.Tag := I;

    // Candidate name
    LblName := TLabel.Create(Card);
    LblName.Name := 'LblName';
    LblName.Parent := Card;
    LblName.Left := 8;
    LblName.Top := 8;
    LblName.Caption := Format('Candidate %d', [C.ID]);
    LblName.Font.Style := [fsBold];
    LblName.Font.Color := CLR_TEXT_PRIMARY;

    // Station badge
    LblStation := TLabel.Create(Card);
    LblStation.Name := 'LblStation';
    LblStation.Parent := Card;
    LblStation.Left := Card.Width - 70;
    LblStation.Top := 8;
    LblStation.Caption := StationName;
    LblStation.Font.Size := 8;
    LblStation.Font.Color := CLR_TEXT_MUTED;

    // Status
    LblStatus := TLabel.Create(Card);
    LblStatus.Name := 'LblStatus';
    LblStatus.Parent := Card;
    LblStatus.Left := 8;
    LblStatus.Top := 28;
    LblStatus.Caption := '';
    LblStatus.Font.Size := 8;
    LblStatus.Font.Style := [fsBold];
    LblStatus.Font.Color := CLR_PHASE_ACTIVITY;

    // Timer
    LblTimer := TLabel.Create(Card);
    LblTimer.Name := 'LblTimer';
    LblTimer.Parent := Card;
    LblTimer.Left := Card.Width - 50;
    LblTimer.Top := 28;
    LblTimer.Caption := '--:--';
    LblTimer.Font.Name := 'Consolas';
    LblTimer.Font.Size := 9;
    LblTimer.Font.Color := CLR_TEXT_SECONDARY;

    // Progress bar
    ProgressPct := C.CompletedStations / FTotalPositions;

    ProgressBar := TPanel.Create(Card);
    ProgressBar.Parent := Card;
    ProgressBar.Left := 8;
    ProgressBar.Top := 52;
    ProgressBar.Width := Card.Width - 16;
    ProgressBar.Height := 4;
    ProgressBar.BevelOuter := bvNone;
    ProgressBar.Color := CLR_BG_ELEVATED;

    ProgressFill := TPanel.Create(ProgressBar);
    ProgressFill.Parent := ProgressBar;
    ProgressFill.Left := 0;
    ProgressFill.Top := 0;
    ProgressFill.Width := Round(ProgressBar.Width * ProgressPct);
    ProgressFill.Height := 4;
    ProgressFill.BevelOuter := bvNone;
    ProgressFill.Color := CLR_ACCENT;

    FCandidateCards.Add(Card);

    // Layout
    Inc(X, Card.Width + 8);
    if X + Card.Width > FScrollBoxCandidates.Width then
    begin
      X := 8;
      Inc(Y, Card.Height + 8);
    end;
  end;
end;

procedure TTimerFrame.UpdateDisplay;
var
  RestCount: Integer;
begin
  // Phase indicator
  FLblPhase.Caption := PHASE_NAMES[FCurrentPhase];
  FPanelPhase.Color := PHASE_COLORS[FCurrentPhase];

  // Station info
  FLblStationName.Caption := Format('Round %d', [FCurrentRound + 1]);
  RestCount := Max(0, FNumCandidates - StationsManager.GetCount);
  if RestCount > 0 then
    FLblStationDesc.Caption := Format('%d candidates at %d stations + %d rest',
      [FNumCandidates, StationsManager.GetCount, RestCount])
  else
    FLblStationDesc.Caption := Format('%d candidates at %d stations',
      [FNumCandidates, StationsManager.GetCount]);

  // Countdown label
  case FCurrentPhase of
    phRead: FLblCountdownLabel.Caption := 'READ TIME - REVIEW INSTRUCTIONS';
    phActivity: FLblCountdownLabel.Caption := 'ACTIVITY TIME REMAINING';
    phFeedback: FLblCountdownLabel.Caption := 'FEEDBACK/QUESTIONS TIME';
    phChangeover: FLblCountdownLabel.Caption := 'CHANGEOVER - MOVE TO NEXT STATION';
  end;
end;

procedure TTimerFrame.UpdateProgressBar(AProgress: Double);
var
  Phase: TExamPhase;
  CurrentIdx, PhaseIdx: Integer;
begin
  CurrentIdx := Ord(FCurrentPhase);

  for Phase := Low(TExamPhase) to High(TExamPhase) do
  begin
    PhaseIdx := Ord(Phase);

    if PhaseIdx < CurrentIdx then
      FProgressFills[Phase].Width := FProgressSegments[Phase].Width
    else if PhaseIdx = CurrentIdx then
      FProgressFills[Phase].Width := Round(FProgressSegments[Phase].Width * AProgress)
    else
      FProgressFills[Phase].Width := 0;
  end;
end;

procedure TTimerFrame.UpdateNextAnnouncement(ASecondsRemaining: Double);
var
  Remaining: Integer;
  NextTime, NextText: string;
begin
  Remaining := Ceil(ASecondsRemaining);
  NextTime := '';
  NextText := '';

  case FCurrentPhase of
    phActivity:
      begin
        if Remaining > 120 then
        begin
          NextTime := FormatSeconds(Remaining - 120);
          NextText := '2-minute warning';
        end
        else if Remaining > 60 then
        begin
          NextTime := FormatSeconds(Remaining - 60);
          NextText := '1-minute warning';
        end
        else if Remaining > 0 then
        begin
          NextTime := FormatSeconds(Remaining);
          NextText := 'Activity phase ends';
        end;
      end;

    phFeedback:
      begin
        if Remaining > 60 then
        begin
          NextTime := FormatSeconds(Remaining - 60);
          NextText := '1-minute warning';
        end
        else if Remaining > 0 then
        begin
          NextTime := FormatSeconds(Remaining);
          NextText := 'Station complete';
        end;
      end;

    phChangeover:
      begin
        NextTime := FormatSeconds(Remaining);
        NextText := 'Next station begins';
      end;
  end;

  if NextTime = '' then
  begin
    FLblAnnTime.Caption := '--:--';
    FLblAnnText.Caption := 'No upcoming announcements';
  end
  else
  begin
    FLblAnnTime.Caption := NextTime;
    FLblAnnText.Caption := NextText;
  end;
end;

procedure TTimerFrame.UpdateCandidateTimers(ASecondsRemaining: Double);
var
  I: Integer;
  Card: TPanel;
  LblStatus, LblTimer: TLabel;
  StatusText: string;
  StatusColor: TColor;
begin
  for I := 0 to FCandidateCards.Count - 1 do
  begin
    Card := FCandidateCards[I];
    LblStatus := TLabel(Card.FindComponent('LblStatus'));
    LblTimer := TLabel(Card.FindComponent('LblTimer'));

    case FCurrentPhase of
      phRead:
        begin
          StatusText := 'READING';
          StatusColor := CLR_PHASE_READ;
        end;
      phActivity:
        begin
          StatusText := 'ACTIVITY';
          StatusColor := CLR_PHASE_ACTIVITY;
        end;
      phFeedback:
        begin
          StatusText := 'FEEDBACK';
          StatusColor := CLR_PHASE_FEEDBACK;
        end;
      phChangeover:
        begin
          StatusText := 'CHANGEOVER';
          StatusColor := CLR_PHASE_CHANGEOVER;
        end;
    end;

    if LblStatus <> nil then
    begin
      LblStatus.Caption := StatusText;
      LblStatus.Font.Color := StatusColor;
    end;

    if LblTimer <> nil then
      LblTimer.Caption := FormatSeconds(Round(ASecondsRemaining));
  end;
end;

procedure TTimerFrame.OnTimerTick(Sender: TObject; SecondsRemaining: Double;
  Progress: Double);
begin
  // Update countdown
  FLblCountdown.Caption := FormatSeconds(Round(SecondsRemaining));

  // Countdown styling
  if FTimer.IsCritical then
  begin
    FLblCountdown.Font.Color := CLR_DANGER;
  end
  else if FTimer.IsWarning then
  begin
    FLblCountdown.Font.Color := CLR_WARNING;
  end
  else
  begin
    FLblCountdown.Font.Color := CLR_TEXT_PRIMARY;
  end;

  UpdateProgressBar(Progress);
  UpdateNextAnnouncement(SecondsRemaining);
  UpdateCandidateTimers(SecondsRemaining);
end;

procedure TTimerFrame.OnPhaseChange(Sender: TObject; CompletedPhase: TExamPhase);
var
  NextPhase: TExamPhase;
  I: Integer;
  C: TCandidate;
begin
  NextPhase := uTypes.NextPhase(CompletedPhase);

  if NextPhase = phRead then
  begin
    // Round complete - rotate candidates
    for I := 0 to FCandidates.Count - 1 do
    begin
      C := FCandidates[I];
      C.CurrentPosition := (C.CurrentPosition + 1) mod FTotalPositions;
      Inc(C.CompletedStations);
      FCandidates[I] := C;
    end;

    Inc(FCurrentRound);
    StartRound;
  end
  else
  begin
    TransitionToPhase(NextPhase);
  end;
end;

procedure TTimerFrame.OnAnnouncement(Sender: TObject; AnnouncementType: string;
  SecondsRemaining: Integer);
begin
  if AnnouncementType = 'twoMinWarning' then
  begin
    if (FCurrentPhase = phActivity) and FAnnouncements.TwoMinWarningEnabled then
    begin
      VoiceManager.PlayBeep(800, 200);
      VoiceManager.Speak(FAnnouncements.TwoMinWarning, True);
    end;
  end
  else if AnnouncementType = 'oneMinWarning' then
  begin
    if FAnnouncements.OneMinWarningEnabled then
    begin
      VoiceManager.PlayBeep(600, 200);
      VoiceManager.Speak(FAnnouncements.OneMinWarning, True);
    end;
  end
  else if AnnouncementType = 'thirtySecWarning' then
  begin
    VoiceManager.PlayBeep(1000, 150);
  end
  else if AnnouncementType = 'countdown' then
  begin
    if SecondsRemaining <= 5 then
      VoiceManager.PlayTick;
  end;
end;

procedure TTimerFrame.BtnPauseClick(Sender: TObject);
begin
  TogglePause;
end;

procedure TTimerFrame.BtnSkipClick(Sender: TObject);
begin
  if TConfirmDlg.Execute('Skip Current Phase?',
    Format('Are you sure you want to skip the %s phase?', [PHASE_NAMES[FCurrentPhase]])) then
  begin
    VoiceManager.Speak('Skipping to next phase.', True);
    FTimer.SkipPhase;
  end;
end;

procedure TTimerFrame.BtnRestartClick(Sender: TObject);
begin
  if TConfirmDlg.Execute('Restart Round?',
    Format('Are you sure you want to restart Round %d?', [FCurrentRound + 1])) then
  begin
    FTimer.Stop;
    VoiceManager.Speak('Restarting round.', True);
    StartRound;
  end;
end;

procedure TTimerFrame.BtnStopClick(Sender: TObject);
begin
  if TConfirmDlg.Execute('Stop Exam?',
    'Are you sure you want to stop the exam? All progress will be lost.') then
  begin
    StopExam;
    if Assigned(FOnStopExam) then
      FOnStopExam(Self);
  end;
end;

end.
