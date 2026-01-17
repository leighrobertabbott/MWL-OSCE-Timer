unit uMainFMX;

{*******************************************************************************
  OSCE Timing System - FireMonkey Main Form
  Modern dark-themed UI matching web version
*******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListBox,
  FMX.Effects, FMX.Ani, System.Generics.Collections, System.Math,
  uTypesFMX, uTimerLogic, uVoice, uStationsFMX, uConfigFMX;

type
  TMainForm = class(TForm)
  private
    // Background

    
    // Header  
    FNHSBar: TRectangle;
    FHeaderLayout: TLayout;
    FLblTrust: TLabel;
    FLblSubtitle: TLabel;
    FBtnMute: TRectangle;
    FBtnMuteIcon: TLabel;
    FBtnKiosk: TRectangle;
    FBtnKioskIcon: TLabel;
    
    // Main content container
    // Layouts

    FScrollBox: TVertScrollBox;
    
    // Setup Panel
    FSetupPanel: TLayout;
    FLblExamConfig: TLabel;
    
    // General Card
    FGeneralCard: TRectangle;
    FLblGeneral: TLabel;
    FEdtStartTime: TEdit;
    FEdtCandidates: TEdit;
    FEdtReadTime: TEdit;
    FEdtChangeover: TEdit;
    
    // Voice Card
    FVoiceCard: TRectangle;
    FLblVoice: TLabel;
    FCboVoice: TComboBox;
    FTrkRate: TTrackBar;
    FLblRateValue: TLabel;
    FTrkVolume: TTrackBar;
    FLblVolumeValue: TLabel;
    FBtnTestVoice: TRectangle;
    
    // Stations Card
    FStationsCard: TRectangle;
    FLblStations: TLabel;
    FBtnAddStation: TRectangle;
    FStationsLayout: TLayout;
    FStationRows: TList<TLayout>;
    
    // Announcements Card
    FAnnouncementsCard: TRectangle;
    FLblAnnouncements: TLabel;
    FAnnRowRead: TLayout;
    FAnnRowActivityStart: TLayout;
    FAnnRow2Min: TLayout;
    FAnnRowActivityEnd: TLayout;
    FAnnRow1Min: TLayout;
    FAnnRowStationEnd: TLayout;
    FAnnRowChangeover: TLayout;
    
    // Action Buttons
    FActionsLayout: TLayout;
    FBtnSave: TRectangle;
    FBtnExport: TRectangle;
    FBtnImport: TRectangle;
    FBtnStart: TRectangle;
    
    // Timer Panel (hidden initially)
    FTimerPanel: TLayout;
    FPhaseBadge: TRectangle;
    FLblPhase: TLabel;
    FLblCountdown: TLabel;
    FLblRound: TLabel;
    FLblRoundInfo: TLabel;
    
    // Progress bar
    FProgressLayout: TLayout;
    FProgressRead: TRectangle;
    FProgressActivity: TRectangle;
    FProgressFeedback: TRectangle;
    FProgressChangeover: TRectangle;
    // Fills for dynamic progress
    FProgressReadFill: TRectangle;
    FProgressActivityFill: TRectangle;
    FProgressFeedbackFill: TRectangle;
    FProgressChangeoverFill: TRectangle;
    
    // Timer controls
    FButtonLayout: TLayout;
    FBtnPause: TRectangle;
    FBtnSkip: TRectangle;
    FBtnRestart: TRectangle;
    FBtnStop: TRectangle;
    
    // Candidates
    FCandidatesHeader: TLabel;
    FCandidatesScrollBox: TScrollBox;
    FCandidatesLayout: TLayout;
    FCandidateCards: TList<TRectangle>;
    
    // Overlay & Preview
    FPauseOverlay: TRectangle;
    FLblPaused: TLabel;
    FLblPausedSub: TLabel;
    FLblNextAnnouncement: TLabel;
    FAnnouncementLayout: TLayout;
    
    // Footer
    FFooterLayout: TLayout;
    FLblShortcuts: TLabel;
    FLblCredits: TLabel;
    
    // State
    FTimer: TOSCETimer;
    FIsExamRunning: Boolean;
    FIsMuted: Boolean;

    FCurrentRound: Integer;
    FConfig: TExamConfig;
    

    
    // Skip Logic
    FSkipTransition: Boolean;
    FInSkippedPhase: Boolean;
    
    procedure CreateUI;
    procedure CreateHeader;
    procedure CreateSetupPanel;
    procedure CreateGeneralCard;
    procedure CreateVoiceCard;
    procedure CreateStationsCard;
    procedure CreateAnnouncementsCard;
    procedure CreateActionButtons;
    procedure CreateTimerPanel;
    procedure CreateFooter;
    
    function CreateCard(AParent: TFmxObject; ALeft, ATop, AWidth, AHeight: Single): TRectangle;
    function CreateButton(AParent: TFmxObject; const ACaption: string; 
      ALeft, ATop, AWidth, AHeight: Single; APrimary: Boolean): TRectangle;
    function CreateFormField(AParent: TFmxObject; const ALabel: string;
      ATop, AWidth: Single): TEdit;
    function CreateAnnouncementRow(AParent: TFmxObject; ATop: Single; 
      const ATitle, ADefaultText: string; AChecked: Boolean): TLayout;
    
    procedure RefreshStationsList;
    procedure CreateStationRow(AIndex: Integer; const AStation: TStation);
    procedure PopulateVoices;
    procedure PopulateConfig;
    

    
    procedure BtnMuteClick(Sender: TObject);
    procedure BtnKioskClick(Sender: TObject);
    procedure BtnTestVoiceClick(Sender: TObject);
    procedure BtnAddStationClick(Sender: TObject);
    procedure BtnDeleteStationClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure BtnSkipClick(Sender: TObject);
    procedure BtnRestartClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    procedure BtnImportClick(Sender: TObject);
    procedure OnVoiceChange(Sender: TObject);
    procedure TrackRateChange(Sender: TObject);
    procedure TrackVolumeChange(Sender: TObject);
    procedure OnStationTimeChange(Sender: TObject);
    procedure OnStationNameChange(Sender: TObject);
    
    procedure OnTimerTick(Sender: TObject; SecondsRemaining: Double; Progress: Double);
    procedure UpdateStationTimers(SecondsRemaining: Double);
    procedure OnPhaseChange(Sender: TObject; CompletedPhase: TExamPhase);
    procedure OnAnnouncement(Sender: TObject; AnnouncementType: string; SecondsRemaining: Integer);
    
    function GetAnnouncementText(const AType, ADefault: string): string;

    procedure ShowSetup;
    procedure ShowTimer;
    procedure UpdateCountdown(ASeconds: Double);
    procedure UpdateProgress(AProgress: Double);
    procedure SetupCandidateGrid;
    procedure UpdateCandidateGrid;


    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

const
  // Colors matching CSS
  CLR_BG_PRIMARY = $FF121212;
  CLR_BG_SECONDARY = $FF1E1E1E;
  CLR_BG_CARD = $FF2A2A2A; // Brightened for visibility
  CLR_BG_ELEVATED = $FF333333; // Brightened
  CLR_TEXT_PRIMARY = $FFF5F5F5;
  CLR_TEXT_SECONDARY = $FFA0A0A0;
  CLR_TEXT_MUTED = $FF666666;
  CLR_BORDER = $FF333333;
  CLR_ACCENT = $FF4A9EFF;
  CLR_ACCENT_HOVER = $FF5AABFF;
  CLR_NHS_BLUE = $FF005EB8;
  CLR_PHASE_READ = $FFA855F7;
  CLR_PHASE_ACTIVITY = $FF22C55E;
  CLR_PHASE_FEEDBACK = $FF3B82F6;
  CLR_PHASE_CHANGEOVER = $FFF59E0B;
  CLR_DANGER = $FFEF4444;
  CLR_WARNING = $FFEAB308;

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  
  FStationRows := TList<TLayout>.Create;
  FCandidateCards := TList<TRectangle>.Create;
  
  FTimer := TOSCETimer.Create;
  FTimer.OnTick := OnTimerTick;
  FTimer.OnPhaseChange := OnPhaseChange;
  FTimer.OnAnnouncement := OnAnnouncement;
  
  FIsExamRunning := False;
  FIsMuted := False;
  
  CreateUI;
  PopulateVoices;
  RefreshStationsList;
  OnResize := FormResize;
  OnKeyDown := FormKeyDown;
end;

destructor TMainForm.Destroy;
begin
  FTimer.Free;
  FStationRows.Free;
  FCandidateCards.Free;
  inherited;
end;

procedure TMainForm.CreateUI;
begin
  Caption := 'OSCE Timing System';
  Width := 1200;
  Height := 800;
  WindowState := TWindowState.wsMaximized; // Start maximized
  Constraints.MinWidth := 1024;
  Constraints.MinHeight := 768;
  Fill.Kind := TBrushKind.Solid;
  Fill.Color := CLR_BG_PRIMARY;
  
  CreateHeader;
  CreateSetupPanel;
  CreateTimerPanel;
  CreateFooter;
  

  
  // Announcement Section (Fixed position, scaled in FormResize)
  FAnnouncementLayout := TLayout.Create(Self);
  FAnnouncementLayout.Parent := Self;
  FAnnouncementLayout.Align := TAlignLayout.None;
  FAnnouncementLayout.Position.Y := 600;  // Will be scaled in FormResize
  FAnnouncementLayout.Width := 1200;
  FAnnouncementLayout.Height := 80; // Header + Box + Margins
  FAnnouncementLayout.Visible := False; // Hidden in setup
  
  // Header "NEXT ANNOUNCEMENT"
  var LblAnnHeader := TLabel.Create(FAnnouncementLayout);
  LblAnnHeader.Parent := FAnnouncementLayout;
  LblAnnHeader.Align := TAlignLayout.Top;
  LblAnnHeader.Height := 24;
  LblAnnHeader.Margins.Left := (1024 - (5 * 230)) / 2; // Match Candidates Grid approx center
  LblAnnHeader.Margins.Left := (1024 - (5 * 230)) / 2; // Match Candidates Grid approx center
  
  var AnnContainer := TLayout.Create(FAnnouncementLayout);
  AnnContainer.Parent := FAnnouncementLayout;
  AnnContainer.Align := TAlignLayout.Center;
  AnnContainer.Width := 1000; // Constrain width
  AnnContainer.Height := 80;
  
  LblAnnHeader.Parent := AnnContainer;
  LblAnnHeader.Margins.Left := 0;
  LblAnnHeader.Text := 'NEXT ANNOUNCEMENT';
  LblAnnHeader.StyledSettings := [];
  LblAnnHeader.TextSettings.Font.Size := 11;
  LblAnnHeader.TextSettings.FontColor := CLR_TEXT_MUTED;
  LblAnnHeader.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblAnnHeader.TextSettings.HorzAlign := TTextAlign.Leading;
  
  // Box
  var AnnBox := TRectangle.Create(AnnContainer);
  AnnBox.Parent := AnnContainer;
  AnnBox.Align := TAlignLayout.Top;
  AnnBox.Height := 50;
  // AnnBox.Top is managed by Align = Top. Use Margins for spacing.
  AnnBox.Fill.Color := CLR_BG_ELEVATED; // Dark grey
  AnnBox.Stroke.Kind := TBrushKind.None;
  AnnBox.YRadius := 4;
  AnnBox.XRadius := 4;
  AnnBox.Margins.Top := 5;
  
  FLblNextAnnouncement := TLabel.Create(AnnBox);
  FLblNextAnnouncement.Parent := AnnBox;
  FLblNextAnnouncement.Align := TAlignLayout.Client;
  FLblNextAnnouncement.Margins.Left := 20;
  FLblNextAnnouncement.Text := '--:--';
  FLblNextAnnouncement.StyledSettings := [];
  FLblNextAnnouncement.TextSettings.Font.Size := 14; 
  FLblNextAnnouncement.TextSettings.FontColor := CLR_ACCENT; // Blue time?
  FLblNextAnnouncement.TextSettings.FontColor := CLR_ACCENT; // Blue time?
  FLblNextAnnouncement.TextSettings.HorzAlign := TTextAlign.Leading;
  FLblNextAnnouncement.TextSettings.VertAlign := TTextAlign.Center;
  
  FTimerPanel.Visible := False;
end;

procedure TMainForm.CreateHeader;
begin
  // NHS Blue bar
  FNHSBar := TRectangle.Create(Self);
  FNHSBar.Parent := Self;
  FNHSBar.Align := TAlignLayout.Top;
  FNHSBar.Height := 4;
  FNHSBar.Fill.Color := CLR_NHS_BLUE;
  FNHSBar.Stroke.Kind := TBrushKind.None;
  
  // Header layout
  FHeaderLayout := TLayout.Create(Self);
  FHeaderLayout.Parent := Self;
  FHeaderLayout.Align := TAlignLayout.Top;
  FHeaderLayout.Height := 80;
  FHeaderLayout.Margins.Left := 24;
  FHeaderLayout.Margins.Right := 24;
  FHeaderLayout.Margins.Top := 16;
  
  // Trust name
  FLblTrust := TLabel.Create(FHeaderLayout);
  FLblTrust.Parent := FHeaderLayout;
  FLblTrust.Position.X := 0;
  FLblTrust.Position.Y := 0;
  FLblTrust.Text := 'Mersey and West Lancashire NHS';
  FLblTrust.StyledSettings := [];
  FLblTrust.TextSettings.Font.Size := 20;
  FLblTrust.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblTrust.TextSettings.FontColor := $FFFFFFFF;
  FLblTrust.Width := 800; // Explicit wide width to prevent wrapping
  FLblTrust.WordWrap := False; // Force single line
  FLblTrust.AutoSize := True; 
  FLblTrust.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop];
  
  // Subtitle
  FLblSubtitle := TLabel.Create(FHeaderLayout);
  FLblSubtitle.Parent := FHeaderLayout;
  FLblSubtitle.Position.X := 0;
  FLblSubtitle.Position.Y := 30;
  FLblSubtitle.Text := 'Clinical Education OSCE Timer Application';
  FLblSubtitle.StyledSettings := [];
  FLblSubtitle.TextSettings.Font.Size := 14;
  FLblSubtitle.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  FLblSubtitle.Width := 600; // Explicit width
  FLblSubtitle.AutoSize := True; // Prevent truncation
  
  // Mute button
  FBtnMute := TRectangle.Create(FHeaderLayout);
  FBtnMute.Parent := FHeaderLayout;
  FBtnMute.Align := TAlignLayout.Right;
  FBtnMute.Width := 44;
  FBtnMute.Height := 44;
  FBtnMute.Margins.Top := 8;
  FBtnMute.XRadius := 8;
  FBtnMute.YRadius := 8;
  FBtnMute.Fill.Color := CLR_BG_ELEVATED;
  FBtnMute.Stroke.Color := CLR_BORDER;
  FBtnMute.Cursor := crHandPoint;
  FBtnMute.OnClick := BtnMuteClick;
  
  FBtnMuteIcon := TLabel.Create(FBtnMute);
  FBtnMuteIcon.Parent := FBtnMute;
  FBtnMuteIcon.Align := TAlignLayout.Client;
  FBtnMuteIcon.Text := '🔊';
  FBtnMuteIcon.StyledSettings := [];
  FBtnMuteIcon.TextSettings.Font.Size := 18;
  FBtnMuteIcon.TextSettings.HorzAlign := TTextAlign.Center;
  FBtnMuteIcon.HitTest := False;
  
  // Kiosk button (Added beside Mute)
  FBtnKiosk := TRectangle.Create(FHeaderLayout);
  FBtnKiosk.Parent := FHeaderLayout;
  FBtnKiosk.Align := TAlignLayout.Right; // Stacks to left of Mute
  FBtnKiosk.Width := 44;
  FBtnKiosk.Height := 44;
  FBtnKiosk.Margins.Top := 8;
  FBtnKiosk.Margins.Right := 10; // Gap between Kiosk and Mute
  FBtnKiosk.XRadius := 8;
  FBtnKiosk.YRadius := 8;
  FBtnKiosk.Fill.Color := CLR_BG_ELEVATED;
  FBtnKiosk.Stroke.Color := CLR_BORDER;
  FBtnKiosk.Cursor := crHandPoint;
  FBtnKiosk.OnClick := BtnKioskClick;
  
  FBtnKioskIcon := TLabel.Create(FBtnKiosk);
  FBtnKioskIcon.Parent := FBtnKiosk;
  FBtnKioskIcon.Align := TAlignLayout.Client;
  FBtnKioskIcon.Text := '⛶'; // Fullscreen icon
  FBtnKioskIcon.StyledSettings := [];
  FBtnKioskIcon.TextSettings.Font.Size := 18;
  FBtnKioskIcon.TextSettings.HorzAlign := TTextAlign.Center;
  FBtnKioskIcon.HitTest := False;
end;

procedure TMainForm.CreateSetupPanel;
begin
  FScrollBox := TVertScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align := TAlignLayout.Client;
  FScrollBox.Margins.Left := 24;
  FScrollBox.Margins.Right := 24;
  FScrollBox.Margins.Bottom := 50; // Reduced from 120 to pull footer up
  
  FSetupPanel := TLayout.Create(FScrollBox);
  FSetupPanel.Parent := FScrollBox;
  FSetupPanel.Align := TAlignLayout.Top;
  FSetupPanel.Height := 1500;
  FSetupPanel.Width := 1000;
  // Centering handled in Resize

  
  // Title
  FLblExamConfig := TLabel.Create(FSetupPanel);
  FLblExamConfig.Parent := FSetupPanel;
  FLblExamConfig.Position.X := 0;
  FLblExamConfig.Position.Y := 16;
  FLblExamConfig.Text := 'Exam Configuration';
  FLblExamConfig.StyledSettings := [];
  FLblExamConfig.TextSettings.Font.Size := 20;
  FLblExamConfig.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblExamConfig.TextSettings.FontColor := CLR_TEXT_PRIMARY;
  FLblExamConfig.Width := 400; // Fix truncation "Exam..."
  FLblExamConfig.AutoSize := True;
  
  CreateGeneralCard;
  CreateVoiceCard;
  CreateStationsCard;
  CreateAnnouncementsCard;
  CreateActionButtons;
end;

procedure TMainForm.CreateGeneralCard;
var
  Y: Single;
begin
  FGeneralCard := CreateCard(FSetupPanel, 0, 60, 490, 320); // Width 490 (almost half of 1000)
  
  FLblGeneral := TLabel.Create(FGeneralCard);
  FLblGeneral.Parent := FGeneralCard;
  FLblGeneral.Position.X := 20;
  FLblGeneral.Position.Y := 16;
  FLblGeneral.Text := 'GENERAL';
  FLblGeneral.StyledSettings := [];
  FLblGeneral.TextSettings.Font.Size := 12;
  FLblGeneral.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblGeneral.TextSettings.FontColor := CLR_ACCENT;
  
  Y := 50;
  FEdtStartTime := CreateFormField(FGeneralCard, 'Start Time', Y, 340);
  FEdtStartTime.Text := '13:00';
  
  Y := Y + 65;
  FEdtCandidates := CreateFormField(FGeneralCard, 'Number of Candidates', Y, 340);
  FEdtCandidates.Text := '5';
  
  Y := Y + 65;
  FEdtReadTime := CreateFormField(FGeneralCard, 'Read Time (seconds)', Y, 340);
  FEdtReadTime.Text := '60';
  
  Y := Y + 65;
  FEdtChangeover := CreateFormField(FGeneralCard, 'Changeover Time (seconds)', Y, 340);
  FEdtChangeover.Text := '10';
end;

procedure TMainForm.CreateVoiceCard;
var
  Lbl: TLabel;
  Y: Single;
begin
  FVoiceCard := CreateCard(FSetupPanel, 510, 60, 490, 320); // Right side, Width 490
  
  FLblVoice := TLabel.Create(FVoiceCard);
  FLblVoice.Parent := FVoiceCard;
  FLblVoice.Position.X := 20;
  FLblVoice.Position.Y := 16;
  FLblVoice.Text := 'VOICE';
  FLblVoice.StyledSettings := [];
  FLblVoice.TextSettings.Font.Size := 12;
  FLblVoice.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblVoice.TextSettings.FontColor := CLR_ACCENT;
  
  Y := 50;
  
  Lbl := TLabel.Create(FVoiceCard);
  Lbl.Parent := FVoiceCard;
  Lbl.Position.X := 20;
  Lbl.Position.Y := Y;
  Lbl.Text := 'Select Voice';
  Lbl.StyledSettings := [];
  Lbl.TextSettings.Font.Size := 11;
  Lbl.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  
  FCboVoice := TComboBox.Create(FVoiceCard);
  FCboVoice.Parent := FVoiceCard;
  FCboVoice.Position.X := 20;
  FCboVoice.Position.Y := Y + 20;
  FCboVoice.Width := 450;
  FCboVoice.Height := 36;
  FCboVoice.OnChange := OnVoiceChange;
  
  Y := Y + 70;
  
  Lbl := TLabel.Create(FVoiceCard);
  Lbl.Parent := FVoiceCard;
  Lbl.Position.X := 20;
  Lbl.Position.Y := Y;
  Lbl.Text := 'Speech Rate';
  Lbl.StyledSettings := [];
  Lbl.TextSettings.Font.Size := 11;
  Lbl.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  
  FTrkRate := TTrackBar.Create(FVoiceCard);
  FTrkRate.Parent := FVoiceCard;
  FTrkRate.Position.X := 20;
  FTrkRate.Position.Y := Y + 22;
  FTrkRate.Width := 280;
  FTrkRate.Min := 0.5;
  FTrkRate.Max := 2;
  FTrkRate.Value := 1;
  FTrkRate.OnChange := TrackRateChange;
  
  FLblRateValue := TLabel.Create(FVoiceCard);
  FLblRateValue.Parent := FVoiceCard;
  FLblRateValue.Position.X := 310;
  FLblRateValue.Position.Y := Y + 24;
  FLblRateValue.Text := '1.0x';
  FLblRateValue.StyledSettings := [];
  FLblRateValue.TextSettings.Font.Size := 12;
  FLblRateValue.TextSettings.FontColor := CLR_ACCENT;
  
  Y := Y + 60;
  
  Lbl := TLabel.Create(FVoiceCard);
  Lbl.Parent := FVoiceCard;
  Lbl.Position.X := 20;
  Lbl.Position.Y := Y;
  Lbl.Text := 'Volume';
  Lbl.StyledSettings := [];
  Lbl.TextSettings.Font.Size := 11;
  Lbl.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  
  FTrkVolume := TTrackBar.Create(FVoiceCard);
  FTrkVolume.Parent := FVoiceCard;
  FTrkVolume.Position.X := 20;
  FTrkVolume.Position.Y := Y + 22;
  FTrkVolume.Width := 280;
  FTrkVolume.Min := 0;
  FTrkVolume.Max := 100;
  FTrkVolume.Value := 100;
  FTrkVolume.OnChange := TrackVolumeChange;
  
  FLblVolumeValue := TLabel.Create(FVoiceCard);
  FLblVolumeValue.Parent := FVoiceCard;
  FLblVolumeValue.Position.X := 310;
  FLblVolumeValue.Position.Y := Y + 24;
  FLblVolumeValue.Text := '100%';
  FLblVolumeValue.StyledSettings := [];
  FLblVolumeValue.TextSettings.Font.Size := 12;
  FLblVolumeValue.TextSettings.FontColor := CLR_ACCENT;
  
  Y := Y + 60;
  
  FBtnTestVoice := CreateButton(FVoiceCard, 'Test Voice', 20, Y, 100, 36, False);
  FBtnTestVoice.OnClick := BtnTestVoiceClick;
end;

procedure TMainForm.CreateStationsCard;
begin
  FStationsCard := CreateCard(FSetupPanel, 0, 400, 1000, 380); // Full width 1000 centered
  
  FLblStations := TLabel.Create(FStationsCard);
  FLblStations.Parent := FStationsCard;
  FLblStations.Position.X := 20;
  FLblStations.Position.Y := 16;
  FLblStations.Text := 'STATIONS';
  FLblStations.StyledSettings := [];
  FLblStations.TextSettings.Font.Size := 12;
  FLblStations.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblStations.TextSettings.FontColor := CLR_TEXT_SECONDARY; // Matches styled header
  
  FBtnAddStation := CreateButton(FStationsCard, 'Add Station', 880, 10, 100, 32, True); // Right aligned
  FBtnAddStation.OnClick := BtnAddStationClick;
  
  FStationsLayout := TLayout.Create(FStationsCard);
  FStationsLayout.Parent := FStationsCard;
  FStationsLayout.Position.X := 20;
  FStationsLayout.Position.Y := 50;
  FStationsLayout.Width := 960;
  FStationsLayout.Height := 320;
end;

procedure TMainForm.CreateAnnouncementsCard;
var
  Y: Single;
begin
  FAnnouncementsCard := CreateCard(FSetupPanel, 0, 800, 1000, 520);
  
  FLblAnnouncements := TLabel.Create(FAnnouncementsCard);
  FLblAnnouncements.Parent := FAnnouncementsCard;
  FLblAnnouncements.Position.X := 20;
  FLblAnnouncements.Position.Y := 16;
  FLblAnnouncements.Text := 'VOICE ANNOUNCEMENTS';
  FLblAnnouncements.StyledSettings := [];
  FLblAnnouncements.TextSettings.Font.Size := 12;
  FLblAnnouncements.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblAnnouncements.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  
  Y := 50;
  
  // Toggle announcements text
  var LblToggle: TLabel := TLabel.Create(FAnnouncementsCard);
  LblToggle.Parent := FAnnouncementsCard;
  LblToggle.Position.X := 20;
  LblToggle.Position.Y := Y;
  LblToggle.Text := 'Toggle announcements on/off. These play for the whole room.';
  LblToggle.StyledSettings := [];
  LblToggle.TextSettings.Font.Size := 11;
  LblToggle.TextSettings.FontColor := CLR_TEXT_MUTED;
  
  Y := Y + 30;
  
  FAnnRowRead := CreateAnnouncementRow(FAnnouncementsCard, Y, 'Read Start', 'Please read your instructions. You have 1 minute.', True);
  Y := Y + 60;
  FAnnRowActivityStart := CreateAnnouncementRow(FAnnouncementsCard, Y, 'Activity Start', 'Please begin. You have {time} minutes for the activity phase.', True);
  Y := Y + 60;
  FAnnRow2Min := CreateAnnouncementRow(FAnnouncementsCard, Y, '2-Minute Warning', 'Two minutes remaining.', True);
  Y := Y + 60;
  FAnnRowActivityEnd := CreateAnnouncementRow(FAnnouncementsCard, Y, 'Activity End', 'Please stop. You may now begin feedback and questions.', True);
  Y := Y + 60;
  FAnnRow1Min := CreateAnnouncementRow(FAnnouncementsCard, Y, '1-Minute Warning', 'One minute remaining.', True);
  Y := Y + 60;
  FAnnRowStationEnd := CreateAnnouncementRow(FAnnouncementsCard, Y, 'Round Complete', 'This round is now complete. Please prepare to rotate.', True);
  Y := Y + 60;
  FAnnRowChangeover := CreateAnnouncementRow(FAnnouncementsCard, Y, 'Changeover', 'Please move to your next station and read the instructions.', True);
end;

function TMainForm.CreateAnnouncementRow(AParent: TFmxObject; ATop: Single; 
  const ATitle, ADefaultText: string; AChecked: Boolean): TLayout;
var
  Chk: TCheckBox;
  InputBg: TRectangle;
  Input: TEdit;
begin
  Result := TLayout.Create(AParent);
  Result.Parent := AParent;
  Result.Position.X := 20;
  Result.Position.Y := ATop;
  Result.Width := 960;
  Result.Height := 50;
  
  // Container Background (Dark Row)
  var Bg: TRectangle := TRectangle.Create(Result);
  Bg.Parent := Result;
  Bg.Align := TAlignLayout.Client;
  Bg.Fill.Color := CLR_BG_ELEVATED; // Slightly lighter than card
  Bg.Stroke.Kind := TBrushKind.None;
  Bg.XRadius := 4;
  Bg.YRadius := 4;
  
  // Checkbox
  Chk := TCheckBox.Create(Result);
  Chk.Parent := Result;
  Chk.Position.X := 15;
  Chk.Position.Y := 15;
  Chk.Width := 200;
  Chk.Text := ATitle;
  Chk.IsChecked := AChecked;
  Chk.StyledSettings := [];
  Chk.TextSettings.Font.Size := 12;
  Chk.TextSettings.Font.Style := [TFontStyle.fsBold];
  Chk.TextSettings.FontColor := CLR_TEXT_PRIMARY;
  
  // Text Input
  InputBg := TRectangle.Create(Result);
  InputBg.Parent := Result;
  InputBg.Position.X := 250;
  InputBg.Position.Y := 8;
  InputBg.Width := 690;
  InputBg.Height := 34;
  InputBg.Fill.Color := TAlphaColorRec.White; // High contrast: White BG
  InputBg.Stroke.Color := CLR_BORDER;
  InputBg.XRadius := 4;
  InputBg.YRadius := 4;
  
  Input := TEdit.Create(InputBg);
  Input.Parent := InputBg;
  Input.Align := TAlignLayout.Client;
  Input.Margins.Left := 8;
  Input.Margins.Right := 8;
  Input.Text := ADefaultText;
  Input.StyledSettings := [];
  Input.TextSettings.FontColor := TAlphaColorRec.Black; // High contrast: Black Text
end;

procedure TMainForm.CreateActionButtons;
begin
  FActionsLayout := TLayout.Create(FSetupPanel);
  FActionsLayout.Parent := FSetupPanel;
  FActionsLayout.Position.X := 0;
  FActionsLayout.Position.Y := 1340; // Below announcements
  FActionsLayout.Width := 1000;
  FActionsLayout.Height := 60;
  
  FBtnStart := CreateButton(FActionsLayout, 'Start Exam', 890, 8, 110, 44, True);
  FBtnStart.OnClick := BtnStartClick;
  
  FBtnImport := CreateButton(FActionsLayout, 'Import File', 770, 8, 110, 44, False);
  FBtnImport.OnClick := BtnImportClick;
  
  FBtnExport := CreateButton(FActionsLayout, 'Export File', 650, 8, 110, 44, False);
  FBtnExport.OnClick := BtnExportClick;
  
  FBtnSave := CreateButton(FActionsLayout, 'Save Settings', 520, 8, 120, 44, False);
  FBtnSave.OnClick := BtnSaveClick;
end;

procedure TMainForm.CreateTimerPanel;
begin
  FTimerPanel := TLayout.Create(Self);
  FTimerPanel.Parent := Self;
  FTimerPanel.Align := TAlignLayout.Client;
  
  // Phase badge (Fixed position, horizontally centered at top)
  FPhaseBadge := TRectangle.Create(FTimerPanel);
  FPhaseBadge.Parent := FTimerPanel;
  FPhaseBadge.Position.X := (1200 - 100) / 2;
  FPhaseBadge.Position.Y := 20;
  FPhaseBadge.Width := 100;
  FPhaseBadge.Height := 36;
  FPhaseBadge.XRadius := 18;
  FPhaseBadge.YRadius := 18;
  FPhaseBadge.Anchors := [TAnchorKind.akTop];
  FPhaseBadge.Fill.Color := CLR_PHASE_READ;
  FPhaseBadge.Stroke.Kind := TBrushKind.None;
  
  FLblPhase := TLabel.Create(FPhaseBadge);
  FLblPhase.Parent := FPhaseBadge;
  FLblPhase.Align := TAlignLayout.Client;
  FLblPhase.Text := 'READ';
  FLblPhase.StyledSettings := [];
  FLblPhase.TextSettings.Font.Size := 13;
  FLblPhase.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblPhase.TextSettings.FontColor := $FFFFFFFF;
  FLblPhase.TextSettings.HorzAlign := TTextAlign.Center;
  
  // Countdown (Fixed position)
  FLblCountdown := TLabel.Create(FTimerPanel);
  FLblCountdown.Parent := FTimerPanel;
  FLblCountdown.Position.X := 0;
  FLblCountdown.Position.Y := 60;
  FLblCountdown.Width := 1200;
  FLblCountdown.Height := 180;
  FLblCountdown.Text := '00:00';
  FLblCountdown.StyledSettings := [];
  FLblCountdown.TextSettings.Font.Size := 160;
  FLblCountdown.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblCountdown.TextSettings.FontColor := CLR_WARNING;
  FLblCountdown.TextSettings.HorzAlign := TTextAlign.Center;
  FLblCountdown.TextSettings.Font.Family := 'Consolas';
  FLblCountdown.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  
  // Round info (Fixed position)
  FLblRound := TLabel.Create(FTimerPanel);
  FLblRound.Parent := FTimerPanel;
  FLblRound.Position.X := 0;
  FLblRound.Position.Y := 230;
  FLblRound.Width := 1200;
  FLblRound.Height := 50;
  FLblRound.Text := 'Round 1';
  FLblRound.StyledSettings := [];
  FLblRound.TextSettings.Font.Size := 32;
  FLblRound.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblRound.TextSettings.FontColor := CLR_TEXT_PRIMARY;
  FLblRound.TextSettings.HorzAlign := TTextAlign.Center;
  FLblRound.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  
  FLblRoundInfo := TLabel.Create(FTimerPanel);
  FLblRoundInfo.Parent := FTimerPanel;
  FLblRoundInfo.Position.X := 0;
  FLblRoundInfo.Position.Y := 275;
  FLblRoundInfo.Width := 1200;
  FLblRoundInfo.Height := 30;
  FLblRoundInfo.Text := '5 candidates at 5 stations';
  FLblRoundInfo.StyledSettings := [];
  FLblRoundInfo.TextSettings.Font.Size := 18;
  FLblRoundInfo.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  FLblRoundInfo.TextSettings.HorzAlign := TTextAlign.Center;
  FLblRoundInfo.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  
  // Progress Bar Container (Fixed position)
  FProgressLayout := TLayout.Create(FTimerPanel);
  FProgressLayout.Parent := FTimerPanel;
  FProgressLayout.Position.X := 100;
  FProgressLayout.Position.Y := 320;
  FProgressLayout.Width := 1000;
  FProgressLayout.Height := 50;
  FProgressLayout.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  
  // Progress Segments (positioned at bottom of layout)
  FProgressRead := TRectangle.Create(FProgressLayout);
  FProgressRead.Parent := FProgressLayout;
  FProgressRead.Height := 8;
  FProgressRead.Align := TAlignLayout.None; // Manual pos
  FProgressRead.Position.Y := 30; // Bottom part
  FProgressRead.Fill.Color := CLR_PHASE_READ;
  FProgressRead.Stroke.Kind := TBrushKind.None;

  // Add Label for Read
  var LblRead: TLabel := TLabel.Create(FProgressLayout);
  LblRead.Parent := FProgressRead; // Parent to Rect so it moves with it? No, Parent to Layout
  LblRead.Parent := FProgressLayout;
  LblRead.Position.Y := 5;
  LblRead.Text := 'READ';
  LblRead.StyledSettings := [];
  LblRead.TextSettings.Font.Size := 12;
  LblRead.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblRead.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  LblRead.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  LblRead.Tag := 10; 

  
  
  FProgressActivity := TRectangle.Create(FProgressLayout);
  FProgressActivity.Parent := FProgressLayout;
  FProgressActivity.Height := 8;
  FProgressActivity.Position.Y := 30;
  FProgressActivity.Fill.Color := CLR_PHASE_ACTIVITY;
  FProgressActivity.Stroke.Kind := TBrushKind.None;

  var LblActivity: TLabel := TLabel.Create(FProgressLayout);
  LblActivity.Parent := FProgressLayout;
  LblActivity.Position.Y := 5;
  LblActivity.Text := 'ACTIVITY';
  LblActivity.StyledSettings := [];
  LblActivity.TextSettings.Font.Size := 12;
  LblActivity.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblActivity.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  LblActivity.Tag := 20;

  
  
  FProgressFeedback := TRectangle.Create(FProgressLayout);
  FProgressFeedback.Parent := FProgressLayout;
  FProgressFeedback.Height := 8;
  FProgressFeedback.Position.Y := 30;
  FProgressFeedback.Fill.Color := CLR_PHASE_FEEDBACK;
  FProgressFeedback.Stroke.Kind := TBrushKind.None;

  var LblFeedback: TLabel := TLabel.Create(FProgressLayout);
  LblFeedback.Parent := FProgressLayout;
  LblFeedback.Position.Y := 5;
  LblFeedback.Text := 'FEEDBACK';
  LblFeedback.StyledSettings := [];
  LblFeedback.TextSettings.Font.Size := 12;
  LblFeedback.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblFeedback.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  LblFeedback.Tag := 30;

  
  
  FProgressChangeover := TRectangle.Create(FProgressLayout);
  FProgressChangeover.Parent := FProgressLayout;
  FProgressChangeover.Position.Y := 30;
  FProgressChangeover.Height := 8; // Explicitly set height
  FProgressChangeover.Fill.Color := CLR_PHASE_CHANGEOVER;
  FProgressChangeover.Stroke.Kind := TBrushKind.None;

  var LblChangeover: TLabel := TLabel.Create(FProgressLayout);
  LblChangeover.Parent := FProgressLayout;
  LblChangeover.Position.Y := 5;
  LblChangeover.Text := 'CHANGEOVER';
  LblChangeover.StyledSettings := [];
  LblChangeover.TextSettings.Font.Size := 12;
  LblChangeover.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblChangeover.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  LblChangeover.Tag := 40;

  // Fills for Progress Bars (Children of the segment rects)
  FProgressReadFill := TRectangle.Create(FProgressRead);
  FProgressReadFill.Parent := FProgressRead;
  FProgressReadFill.Align := TAlignLayout.Left;
  FProgressReadFill.Width := 0;
  FProgressReadFill.Fill.Color := CLR_PHASE_READ; // Bright
  FProgressReadFill.Stroke.Kind := TBrushKind.None;
  FProgressRead.Fill.Color := $40A855F7; // 25% Alpha of Purple
  
  
  FProgressActivityFill := TRectangle.Create(FProgressActivity);
  FProgressActivityFill.Parent := FProgressActivity;
  FProgressActivityFill.Align := TAlignLayout.Left;
  FProgressActivityFill.Width := 0;
  FProgressActivityFill.Fill.Color := CLR_PHASE_ACTIVITY;
  FProgressActivityFill.Stroke.Kind := TBrushKind.None;
  FProgressActivity.Fill.Color := $4022C55E; // 25% Alpha Green
  
  FProgressFeedbackFill := TRectangle.Create(FProgressFeedback);
  FProgressFeedbackFill.Parent := FProgressFeedback;
  FProgressFeedbackFill.Align := TAlignLayout.Left;
  FProgressFeedbackFill.Width := 0;
  FProgressFeedbackFill.Fill.Color := CLR_PHASE_FEEDBACK;
  FProgressFeedbackFill.Stroke.Kind := TBrushKind.None;
  FProgressFeedback.Fill.Color := $403B82F6; 
  
  FProgressChangeoverFill := TRectangle.Create(FProgressChangeover);
  FProgressChangeoverFill.Parent := FProgressChangeover;
  FProgressChangeoverFill.Align := TAlignLayout.Left;
  FProgressChangeoverFill.Width := 0;
  FProgressChangeoverFill.Fill.Color := CLR_PHASE_CHANGEOVER;
  FProgressChangeoverFill.Stroke.Kind := TBrushKind.None;
  FProgressChangeover.Fill.Color := $40F59E0B;
  
  // Buttons moved to Bottom Stack logic below (after Candidates)
  
  // === CANDIDATES GRID (Fixed position, scaled in FormResize) ===
  FCandidatesScrollBox := TScrollBox.Create(FTimerPanel);
  FCandidatesScrollBox.Parent := FTimerPanel;
  FCandidatesScrollBox.Align := TAlignLayout.None;
  FCandidatesScrollBox.Position.Y := 460;  // Will be scaled in FormResize
  FCandidatesScrollBox.Width := 1200;
  FCandidatesScrollBox.Height := 230;
  FCandidatesScrollBox.ShowScrollBars := True;
  
  FCandidatesLayout := TLayout.Create(FCandidatesScrollBox);
  FCandidatesLayout.Parent := FCandidatesScrollBox;
  FCandidatesLayout.Align := TAlignLayout.None;
  
  // === "CANDIDATES" HEADER (Fixed position, scaled in FormResize) ===
  FCandidatesHeader := TLabel.Create(FTimerPanel);
  FCandidatesHeader.Parent := FTimerPanel;
  FCandidatesHeader.Align := TAlignLayout.None;
  FCandidatesHeader.Position.Y := 440;  // Will be scaled in FormResize
  FCandidatesHeader.Width := 1200;
  FCandidatesHeader.Height := 24;
  FCandidatesHeader.Text := 'CANDIDATES';
  FCandidatesHeader.StyledSettings := [];
  FCandidatesHeader.TextSettings.Font.Size := 12;
  FCandidatesHeader.TextSettings.FontColor := CLR_TEXT_MUTED;
  FCandidatesHeader.TextSettings.Font.Style := [TFontStyle.fsBold];
  FCandidatesHeader.TextSettings.HorzAlign := TTextAlign.Center;
  
  // === CONTROL BUTTONS (Fixed position, will be scaled in FormResize) ===
  FButtonLayout := TLayout.Create(FTimerPanel);
  FButtonLayout.Parent := FTimerPanel;
  FButtonLayout.Align := TAlignLayout.None;
  FButtonLayout.Position.Y := 380;  // Will be scaled in FormResize
  FButtonLayout.Width := 1200;
  FButtonLayout.Height := 60;
  
  // Buttons centered directly in ButtonLayout
  // For ~1000px usable width, start at X = 180
  var BtnStartX: Single := 180;
  
  FBtnPause := CreateButton(FButtonLayout, 'Pause', BtnStartX, 6, 140, 48, True);
  TRectangle(FBtnPause).Fill.Color := CLR_WARNING;
  TLabel(TRectangle(FBtnPause).Children[0]).TextSettings.FontColor := $FF1A1A1A;
  
  FBtnSkip := CreateButton(FButtonLayout, 'Skip Phase', BtnStartX + 160, 6, 140, 48, False);
  
  FBtnRestart := CreateButton(FButtonLayout, 'Restart Round', BtnStartX + 320, 6, 160, 48, False);
  
  FBtnStop := CreateButton(FButtonLayout, 'Stop Exam', BtnStartX + 500, 6, 140, 48, False);
  TRectangle(FBtnStop).Fill.Color := CLR_DANGER;
  
  FBtnPause.OnClick := BtnPauseClick;
  FBtnSkip.OnClick := BtnSkipClick;
  FBtnRestart.OnClick := BtnRestartClick;
  FBtnStop.OnClick := BtnStopClick;
  
  // Pause Overlay (Hidden by default)
  // We want it ON TOP to block interaction, BUT handle clicks on it.
  FPauseOverlay := TRectangle.Create(FTimerPanel);
  FPauseOverlay.Parent := FTimerPanel;
  FPauseOverlay.Align := TAlignLayout.Client;
  FPauseOverlay.Fill.Color := $CC000000; // Semi-transparent black
  FPauseOverlay.Stroke.Kind := TBrushKind.None;
  FPauseOverlay.Visible := False;
  FPauseOverlay.OnClick := BtnPauseClick; // Clicking overlay resumes
  FPauseOverlay.Cursor := crHandPoint;
  
  FLblPaused := TLabel.Create(FPauseOverlay);
  FLblPaused.Parent := FPauseOverlay;
  FLblPaused.Align := TAlignLayout.Center;
  FLblPaused.Text := 'PAUSED';
  FLblPaused.StyledSettings := [];
  FLblPaused.TextSettings.Font.Size := 48;
  FLblPaused.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblPaused.TextSettings.FontColor := $FFFFFFFF;
  FLblPaused.TextSettings.HorzAlign := TTextAlign.Center;
  FLblPaused.AutoSize := False; // Fixed width to prevent truncation
  FLblPaused.Width := 600;
  FLblPaused.Height := 80;
  FLblPaused.AutoSize := False;
  
  FLblPausedSub := TLabel.Create(FPauseOverlay);
  FLblPausedSub.Parent := FPauseOverlay;
  FLblPausedSub.Position.X := (Width - 400) / 2;
  FLblPausedSub.Position.Y := (Height / 2) + 60;
  FLblPausedSub.Width := 400;
  FLblPausedSub.Text := 'Press Space to Resume';
  FLblPausedSub.StyledSettings := [];
  FLblPausedSub.TextSettings.Font.Size := 16;
  FLblPausedSub.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  FLblPausedSub.TextSettings.HorzAlign := TTextAlign.Center;
  FLblPausedSub.Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop]; // Keep centered relative to parent center roughly
end;

procedure TMainForm.CreateFooter;
begin
  FFooterLayout := TLayout.Create(Self);
  FFooterLayout.Parent := Self;
  FFooterLayout.Align := TAlignLayout.None;
  FFooterLayout.Position.Y := 700; // Will be scaled in FormResize
  FFooterLayout.Width := 1200;
  FFooterLayout.Height := 100; // Increased to fit all text
  
  FLblShortcuts := TLabel.Create(FFooterLayout);
  FLblShortcuts.Parent := FFooterLayout;
  FLblShortcuts.Align := TAlignLayout.Top;
  FLblShortcuts.Height := 24;
  FLblShortcuts.Text := 'Shortcuts: [Space] Pause · [M] Mute · [R] Restart';
  FLblShortcuts.StyledSettings := [];
  FLblShortcuts.TextSettings.Font.Size := 11;
  FLblShortcuts.TextSettings.FontColor := CLR_TEXT_MUTED;
  FLblShortcuts.TextSettings.HorzAlign := TTextAlign.Center;
  
  FLblCredits := TLabel.Create(FFooterLayout);
  FLblCredits.Parent := FFooterLayout;
  FLblCredits.Align := TAlignLayout.Client;
  FLblCredits.Margins.Top := 10;
  FLblCredits.Text := 'DESIGNED & DEVELOPED BY'#13#10'Leigh Robert Abbott'#13#10'Clinical Education and Simulation · leigh.abbott@merseywestlancs.nhs.uk';
  FLblCredits.StyledSettings := [];
  FLblCredits.TextSettings.Font.Size := 10;
  FLblCredits.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  FLblCredits.TextSettings.HorzAlign := TTextAlign.Center;
  FLblCredits.TextSettings.VertAlign := TTextAlign.Leading;
end;

function TMainForm.CreateCard(AParent: TFmxObject; ALeft, ATop, AWidth, AHeight: Single): TRectangle;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := ALeft;
  Result.Position.Y := ATop;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Fill.Color := CLR_BG_CARD;
  Result.Stroke.Color := CLR_BORDER;
  Result.XRadius := 8;
  Result.YRadius := 8;
end;

function TMainForm.CreateButton(AParent: TFmxObject; const ACaption: string;
  ALeft, ATop, AWidth, AHeight: Single; APrimary: Boolean): TRectangle;
var
  Lbl: TLabel;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := ALeft;
  Result.Position.Y := ATop;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.XRadius := 8;
  Result.YRadius := 8;
  Result.Cursor := crHandPoint;
  
  if APrimary then
  begin
    Result.Fill.Color := CLR_ACCENT;
    Result.Stroke.Kind := TBrushKind.None;
  end
  else
  begin
    Result.Fill.Color := CLR_BG_ELEVATED;
    Result.Stroke.Color := CLR_BORDER;
  end;
  
  Lbl := TLabel.Create(Result);
  Lbl.Parent := Result;
  Lbl.Align := TAlignLayout.Client;
  Lbl.Text := ACaption;
  Lbl.StyledSettings := [];
  Lbl.TextSettings.Font.Size := 12;
  Lbl.TextSettings.FontColor := $FFFFFFFF;
  Lbl.TextSettings.HorzAlign := TTextAlign.Center;
  Lbl.HitTest := False;
end;

function TMainForm.CreateFormField(AParent: TFmxObject; const ALabel: string;
  ATop, AWidth: Single): TEdit;
var
  Lbl: TLabel;
  Bg: TRectangle;
begin
  Lbl := TLabel.Create(Self);
  Lbl.Parent := AParent;
  Lbl.Position.X := 20;
  Lbl.Position.Y := ATop;
  Lbl.Text := ALabel;
  Lbl.StyledSettings := [];
  Lbl.TextSettings.Font.Size := 11;
  Lbl.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  
  // Custom styled input container
  Bg := TRectangle.Create(Self);
  Bg.Parent := AParent;
  Bg.Position.X := 20;
  Bg.Position.Y := ATop + 22;
  Bg.Width := AWidth;
  Bg.Height := 36;
  Bg.Fill.Color := CLR_BG_PRIMARY; // Darker input bg
  Bg.Stroke.Color := CLR_BORDER;
  Bg.XRadius := 4;
  Bg.YRadius := 4;
  
  Result := TEdit.Create(Self);
  Result.Parent := Bg;
  Result.Align := TAlignLayout.Client;
  Result.Margins.Left := 8;
  Result.Margins.Right := 8;
  // Use standard style but ensure text is visible on default white background
  Result.StyledSettings := []; 
  Result.TextSettings.Font.Size := 14;
  Result.TextSettings.FontColor := TAlphaColorRec.Black;
end;

procedure TMainForm.RefreshStationsList;
var
  I: Integer;
  Stations: TStationList;
begin
  // Free all existing UI row controls before rebuilding
  for I := FStationRows.Count - 1 downto 0 do
    FStationRows[I].Free;
  FStationRows.Clear;
  
  // Calculate Station Layout Height
  Stations := StationsManager.GetAll;
  FStationsLayout.Height := Max(320, Stations.Count * 65);
  FStationsCard.Height := FStationsLayout.Height + 60;
  
  // Shift subsequent cards down
  FAnnouncementsCard.Position.Y := FStationsCard.Position.Y + FStationsCard.Height + 20;
  FActionsLayout.Position.Y := FAnnouncementsCard.Position.Y + FAnnouncementsCard.Height + 20;
  FSetupPanel.Height := FActionsLayout.Position.Y + 100;
  
  for I := 0 to Stations.Count - 1 do
    CreateStationRow(I, Stations[I]);
end;

procedure TMainForm.CreateStationRow(AIndex: Integer; const AStation: TStation);
var
  Row: TLayout;
  Card: TRectangle;
  NumBadge: TRectangle;
  LblNum, LblActLabel, LblFbkLabel, LblTotalLabel, LblTotal: TLabel;
  EdtName, EdtActivity, EdtFeedback: TEdit;
  BtnDelete: TRectangle;
begin
  Row := TLayout.Create(FStationsLayout);
  Row.Parent := FStationsLayout;
  Row.Position.X := 0;
  Row.Position.Y := AIndex * 58;
  Row.Width := 960;
  Row.Height := 60; // Taller row for better spacing
  Row.Tag := AStation.ID;
  
  Card := TRectangle.Create(Row);
  Card.Parent := Row;
  Card.Align := TAlignLayout.Client;
  Card.Fill.Color := CLR_BG_ELEVATED;
  Card.Stroke.Kind := TBrushKind.None;
  Card.XRadius := 8;
  Card.YRadius := 8;
  
  // Number badge
  NumBadge := TRectangle.Create(Card);
  NumBadge.Parent := Card;
  NumBadge.Position.X := 12;
  NumBadge.Position.Y := 7;
  NumBadge.Width := 40;
  NumBadge.Height := 40;
  NumBadge.Fill.Color := CLR_BG_CARD;
  NumBadge.Stroke.Kind := TBrushKind.None;
  NumBadge.XRadius := 4;
  NumBadge.YRadius := 4;
  
  LblNum := TLabel.Create(NumBadge);
  LblNum.Parent := NumBadge;
  LblNum.Align := TAlignLayout.Client;
  LblNum.Text := IntToStr(AIndex + 1);
  LblNum.StyledSettings := [];
  LblNum.TextSettings.Font.Size := 14;
  LblNum.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblNum.TextSettings.FontColor := CLR_TEXT_SECONDARY;
  LblNum.TextSettings.HorzAlign := TTextAlign.Center;
  
  // Station name
  // Styled container for name
  var NameBg: TRectangle := TRectangle.Create(Card);
  NameBg.Parent := Card;
  NameBg.Position.X := 64;
  NameBg.Position.Y := 10;
  NameBg.Width := 320;
  NameBg.Height := 34;
  NameBg.Fill.Color := CLR_BG_PRIMARY;
  NameBg.Stroke.Color := CLR_BORDER;
  NameBg.XRadius := 4;
  NameBg.YRadius := 4;

  EdtName := TEdit.Create(NameBg);
  EdtName.Parent := NameBg;
  EdtName.Align := TAlignLayout.Client;
  EdtName.Margins.Left := 5;
  EdtName.Text := AStation.Name;
  EdtName.Tag := AStation.ID;
  EdtName.StyledSettings := [];
  EdtName.TextSettings.FontColor := TAlphaColorRec.Black;
  EdtName.OnChange := OnStationNameChange;
  
  // Activity
  LblActLabel := TLabel.Create(Card);
  LblActLabel.Parent := Card;
  LblActLabel.Position.X := 400;
  LblActLabel.Position.Y := 4;
  LblActLabel.Text := 'ACTIVITY';
  LblActLabel.StyledSettings := [];
  LblActLabel.TextSettings.Font.Size := 8;
  LblActLabel.TextSettings.FontColor := CLR_TEXT_MUTED;
  
  var ActBg: TRectangle := TRectangle.Create(Card);
  ActBg.Parent := Card;
  ActBg.Position.X := 400;
  ActBg.Position.Y := 18;
  ActBg.Width := 60;
  ActBg.Height := 28;
  ActBg.Fill.Color := CLR_BG_PRIMARY;
  ActBg.Stroke.Color := CLR_BORDER;
  ActBg.XRadius := 4;
  ActBg.YRadius := 4;

  EdtActivity := TEdit.Create(ActBg);
  EdtActivity.Parent := ActBg;
  EdtActivity.Align := TAlignLayout.Client;
  EdtActivity.Margins.Left := 4;
  EdtActivity.Text := IntToStr(AStation.ActivityTime);
  EdtActivity.Tag := AStation.ID;
  EdtActivity.StyledSettings := [];
  EdtActivity.TextSettings.FontColor := TAlphaColorRec.Black;
  EdtActivity.OnChange := OnStationTimeChange;
  
  // Feedback
  LblFbkLabel := TLabel.Create(Card);
  LblFbkLabel.Parent := Card;
  LblFbkLabel.Position.X := 475;
  LblFbkLabel.Position.Y := 4;
  LblFbkLabel.Text := 'FEEDBACK';
  LblFbkLabel.StyledSettings := [];
  LblFbkLabel.TextSettings.Font.Size := 8;
  LblFbkLabel.TextSettings.FontColor := CLR_TEXT_MUTED;
  
  var FbkBg: TRectangle := TRectangle.Create(Card);
  FbkBg.Parent := Card;
  FbkBg.Position.X := 475;
  FbkBg.Position.Y := 18;
  FbkBg.Width := 60;
  FbkBg.Height := 28;
  FbkBg.Fill.Color := CLR_BG_PRIMARY;
  FbkBg.Stroke.Color := CLR_BORDER;
  FbkBg.XRadius := 4;
  FbkBg.YRadius := 4;

  EdtFeedback := TEdit.Create(FbkBg);
  EdtFeedback.Parent := FbkBg;
  EdtFeedback.Align := TAlignLayout.Client;
  EdtFeedback.Margins.Left := 4;
  EdtFeedback.Text := IntToStr(AStation.FeedbackTime);
  EdtFeedback.Tag := AStation.ID;
  EdtFeedback.StyledSettings := [];
  EdtFeedback.TextSettings.FontColor := TAlphaColorRec.Black;
  EdtFeedback.OnChange := OnStationTimeChange;
  
  // Total
  LblTotalLabel := TLabel.Create(Card);
  LblTotalLabel.Parent := Card;
  LblTotalLabel.Position.X := 550;
  LblTotalLabel.Position.Y := 4;
  LblTotalLabel.Text := 'TOTAL';
  LblTotalLabel.StyledSettings := [];
  LblTotalLabel.TextSettings.Font.Size := 8;
  LblTotalLabel.TextSettings.FontColor := CLR_TEXT_MUTED;
  
  LblTotal := TLabel.Create(Card);
  LblTotal.Parent := Card;
  LblTotal.Position.X := 550;
  LblTotal.Position.Y := 20;
  LblTotal.Text := IntToStr(AStation.TotalTime) + ' min';
  LblTotal.StyledSettings := [];
  LblTotal.TextSettings.Font.Size := 14;
  LblTotal.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTotal.TextSettings.FontColor := CLR_ACCENT;
  
  // Delete button
  BtnDelete := CreateButton(Card, '×', 690, 10, 34, 34, False);
  BtnDelete.Tag := AStation.ID;
  BtnDelete.OnClick := BtnDeleteStationClick;
  
  FStationRows.Add(Row);
end;

procedure TMainForm.PopulateVoices;
var
  I: Integer;
begin
  FCboVoice.Items.Clear;
  for I := 0 to VoiceManager.GetVoiceCount - 1 do
    FCboVoice.Items.Add(VoiceManager.GetVoiceName(I));
  if FCboVoice.Items.Count > 0 then
    FCboVoice.ItemIndex := 0;
end;

procedure TMainForm.BtnMuteClick(Sender: TObject);
begin
  FIsMuted := not FIsMuted;
  VoiceManager.IsMuted := FIsMuted;
  if FIsMuted then
    FBtnMuteIcon.Text := '🔇'
  else
    FBtnMuteIcon.Text := '🔊';
end;

procedure TMainForm.BtnTestVoiceClick(Sender: TObject);
begin
  VoiceManager.Test;
end;

procedure TMainForm.BtnAddStationClick(Sender: TObject);
begin
  StationsManager.Add;
  RefreshStationsList;
end;

procedure TMainForm.BtnDeleteStationClick(Sender: TObject);
begin
  if StationsManager.GetCount <= 1 then
  begin
    ShowMessage('You must have at least one station.');
    Exit;
  end;
  StationsManager.Remove(TRectangle(Sender).Tag);
  RefreshStationsList;
end;

procedure TMainForm.OnStationTimeChange(Sender: TObject);
var
  Edt: TEdit;
  StationID, ActivityTime, FeedbackTime: Integer;
  Station: TStation;
  Row: TLayout;
  I: Integer;
  LblTotal: TLabel;
  Child: TFmxObject;
begin
  Edt := TEdit(Sender);
  StationID := Edt.Tag;
  
  // Get current station data
  Station := StationsManager.GetByID(StationID);
  if Station.ID = 0 then Exit;
  
  // Read current values from the UI
  // Find the row with this station ID
  for I := 0 to FStationRows.Count - 1 do
  begin
    Row := FStationRows[I];
    if Row.Tag = StationID then
    begin
      // Find activity and feedback edits in this row
      ActivityTime := Station.ActivityTime;
      FeedbackTime := Station.FeedbackTime;
      
      // Traverse children to find the edits
      for Child in Row.Children do
      begin
        if Child is TRectangle then
        begin
          var Card := TRectangle(Child);
          for var SubChild in Card.Children do
          begin
            if SubChild is TRectangle then
            begin
              var Bg := TRectangle(SubChild);
              for var EditChild in Bg.Children do
              begin
                if EditChild is TEdit then
                begin
                  var Ed := TEdit(EditChild);
                  if Ed.Tag = StationID then
                  begin
                    // Determine by position which field this is
                    if Bg.Position.X < 450 then
                      ActivityTime := StrToIntDef(Ed.Text, Station.ActivityTime)
                    else if Bg.Position.X < 550 then
                      FeedbackTime := StrToIntDef(Ed.Text, Station.FeedbackTime);
                  end;
                end;
              end;
            end;
          end;
          
          // Find and update the Total label
          for var SubChild2 in Card.Children do
          begin
            if SubChild2 is TLabel then
            begin
              var Lbl := TLabel(SubChild2);
              if (Lbl.Position.X >= 550) and (Lbl.Position.Y > 10) then
              begin
                Lbl.Text := IntToStr(ActivityTime + FeedbackTime) + ' min';
                Break;
              end;
            end;
          end;
        end;
      end;
      
      // Update station in manager
      StationsManager.Update(StationID, Station.Name, ActivityTime, FeedbackTime);
      Break;
    end;
  end;
end;

procedure TMainForm.OnStationNameChange(Sender: TObject);
var
  Edt: TEdit;
  StationID: Integer;
  Station: TStation;
begin
  Edt := TEdit(Sender);
  StationID := Edt.Tag;
  
  // Get current station data
  Station := StationsManager.GetByID(StationID);
  if Station.ID = 0 then Exit;
  
  // Update station name
  StationsManager.Update(StationID, Edt.Text, Station.ActivityTime, Station.FeedbackTime);
end;

procedure TMainForm.BtnStartClick(Sender: TObject);
begin
  if StationsManager.GetCount = 0 then
  begin
    ShowMessage('Please add at least one station.');
    Exit;
  end;
  
  PopulateConfig; // Update config from UI
  
  FCurrentRound := 1;
  ShowTimer;
  FTimer.Start(StrToIntDef(FEdtReadTime.Text, 60), phRead);
  VoiceManager.Speak(FConfig.Announcements.ReadStart, True); // Use config
end;

procedure TMainForm.BtnStopClick(Sender: TObject);
begin
  FTimer.Stop;
  ShowSetup;
  VoiceManager.Speak('Exam stopped.', True);
end;

procedure TMainForm.BtnPauseClick(Sender: TObject);
var
  Lbl: TLabel;
begin
  if FTimer.IsPaused then
  begin
    FTimer.Resume;
    Lbl := TLabel(FBtnPause.Children[0]);
    Lbl.Text := 'Pause';
    FPauseOverlay.Visible := False;
    VoiceManager.Speak('Timer resumed.', True);
  end
  else
  begin
    FTimer.Pause;
    Lbl := TLabel(FBtnPause.Children[0]);
    Lbl.Text := 'Resume';
    FPauseOverlay.Visible := True;
    FLblPaused.Text := 'PAUSED';
    VoiceManager.Speak('Timer paused.', True);
  end;
end;


procedure TMainForm.BtnSkipClick(Sender: TObject);
begin
  // Force phase change
  FTimer.Stop; 
  FSkipTransition := True; // Flag that we skipped manually
  OnPhaseChange(Self, FTimer.CurrentPhase);
end;

procedure TMainForm.BtnRestartClick(Sender: TObject);
begin
  // Restart current phase
  FTimer.Stop; // Pause first
  
  // Restart current phase logic
  
  case FTimer.CurrentPhase of
    phRead: FTimer.Start(StrToIntDef(FEdtReadTime.Text, 60), phRead);
    phActivity: FTimer.Start(StationsManager.GetMaxActivityTime * 60, phActivity);
    phChangeover: FTimer.Start(StrToIntDef(FEdtChangeover.Text, 10), phChangeover);
    phFeedback: FTimer.Start(StationsManager.GetMaxTotalTime * 60 - StationsManager.GetMaxActivityTime * 60, phFeedback);
  end;
  VoiceManager.Speak('Round restarted.', True);
end;

procedure TMainForm.BtnSaveClick(Sender: TObject);
begin
  PopulateConfig;
  ConfigManager.SaveConfig(FConfig);
  VoiceManager.Speak('Settings saved.', True);
end;

procedure TMainForm.BtnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  PopulateConfig; // ensure FConfig is up to date
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Filter := 'JSON Config|*.json';
    Dlg.DefaultExt := 'json';
    if Dlg.Execute then
    begin
        ConfigManager.ExportConfigToFile(Dlg.FileName, FConfig);
        ShowMessage('Configuration exported to ' + ExtractFileName(Dlg.FileName));
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.BtnImportClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  NewConfig: TExamConfig;
  
  // Helper to update announcement row UI
  procedure UpdateAnnRow(Row: TLayout; const Text: string; Enabled: Boolean);
  begin
      if (Row = nil) or (Row.ChildrenCount < 4) then Exit;
      if (Row.Children[1] is TCheckBox) then
         TCheckBox(Row.Children[1]).IsChecked := Enabled;
      if (Row.Children[3] is TRectangle) and (TRectangle(Row.Children[3]).ChildrenCount > 0) then
         TEdit(TRectangle(Row.Children[3]).Children[0]).Text := Text;
  end;
  
begin
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Filter := 'JSON Config|*.json';
    if Dlg.Execute then
    begin
        NewConfig := ConfigManager.ImportConfigFromFile(Dlg.FileName);
        
        // Update UI Fields
        FEdtStartTime.Text := FormatDateTime('hh:nn', NewConfig.StartTime);
        FEdtCandidates.Text := IntToStr(NewConfig.NumCandidates);
        FEdtReadTime.Text := IntToStr(NewConfig.ReadTime);
        FEdtChangeover.Text := IntToStr(NewConfig.ChangeoverTime);
        
        FTrkRate.Value := NewConfig.VoiceRate;
        FTrkVolume.Value := NewConfig.VoiceVolume;
        // Voice selection omitted for simplicity as names vary by OS, but potentially map it
        
        // Announcements
        with NewConfig.Announcements do
        begin
            UpdateAnnRow(FAnnRowRead, ReadStart, ReadStartEnabled);
            UpdateAnnRow(FAnnRowActivityStart, ActivityStart, ActivityStartEnabled);
            UpdateAnnRow(FAnnRow2Min, TwoMinWarning, TwoMinWarningEnabled);
            UpdateAnnRow(FAnnRowActivityEnd, ActivityEnd, ActivityEndEnabled);
            UpdateAnnRow(FAnnRow1Min, OneMinWarning, OneMinWarningEnabled);
            UpdateAnnRow(FAnnRowStationEnd, StationEnd, StationEndEnabled);
            UpdateAnnRow(FAnnRowChangeover, Changeover, ChangeoverEnabled);
        end;
        
        ShowMessage('Configuration imported successfully.');
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.OnVoiceChange(Sender: TObject);
begin
  if FCboVoice.ItemIndex >= 0 then
  begin
    VoiceManager.SetVoiceByIndex(FCboVoice.ItemIndex);
  end;
end;

procedure TMainForm.TrackRateChange(Sender: TObject);
begin
  FLblRateValue.Text := Format('%.1fx', [FTrkRate.Value]);
end;

procedure TMainForm.TrackVolumeChange(Sender: TObject);
begin
  FLblVolumeValue.Text := IntToStr(Round(FTrkVolume.Value)) + '%';
  VoiceManager.Volume := Round(FTrkVolume.Value);
end;

procedure TMainForm.PopulateConfig;
begin
  FConfig.SetDefaults;
  FConfig.NumCandidates := StrToIntDef(FEdtCandidates.Text, 5);
  FConfig.ReadTime := StrToIntDef(FEdtReadTime.Text, 60);
  FConfig.ChangeoverTime := StrToIntDef(FEdtChangeover.Text, 60);
  
  // Save Stations from UI
  if Assigned(FStationRows) then
  begin
    for var I := 0 to FStationRows.Count - 1 do
    begin
        // We know the structure from CreateStationRow
        // Row -> Card -> [NameBg->Edt, ActBg->Edt, FbkBg->Edt]
        // But scanning children by Type is safer or assuming order.
        // Let's assume tags are reliable or update directly if we can find them.
        var Row := FStationRows[I];
        if Row.ChildrenCount > 0 then
        begin
            var Card := TRectangle(Row.Children[0]); // First child is Card
            
            var EName, EAct, EFbk: TEdit;
            EName := nil; EAct := nil; EFbk := nil;
            var ID: Integer := -1;
            
            // Scan for edits
            // Structure: 
            // NameBg (Rect) -> Edit
            // ActBg (Rect) -> Edit
            // FbkBg (Rect) -> Edit
            // All are children of Card.
            
            for var J := 0 to Card.ChildrenCount - 1 do
            begin
                if Card.Children[J] is TRectangle then
                begin
                    var Bg := TRectangle(Card.Children[J]);
                    if Bg.ChildrenCount > 0 then
                    begin
                        if Bg.Children[0] is TEdit then
                        begin
                             var Edt := TEdit(Bg.Children[0]);
                             // NameBg X=120, ActBg X=400, FbkBg X=475
                             
                             if Bg.Position.X = 120 then EName := Edt
                             else if Bg.Position.X = 400 then EAct := Edt
                             else if Bg.Position.X = 475 then EFbk := Edt;
                             
                             if Edt.Tag > 0 then ID := Edt.Tag;
                        end;
                    end;
                end;
            end;
            
            if (ID > -1) and Assigned(EName) and Assigned(EAct) and Assigned(EFbk) then
            begin
                StationsManager.Update(ID, EName.Text, StrToIntDef(EAct.Text, 8), StrToIntDef(EFbk.Text, 2));
            end;
        end;
    end;
  end;
  
  // Announcements
  // Helper to extract values from Layout structure: 1=Chk, 3=Rect(Input)
  with FConfig.Announcements do
  begin
      if FAnnRowRead.ChildrenCount > 3 then 
      begin
        ReadStartEnabled := TCheckBox(FAnnRowRead.Children[1]).IsChecked;
        ReadStart := TEdit(TRectangle(FAnnRowRead.Children[3]).Children[0]).Text;
      end;
      
      if FAnnRowActivityStart.ChildrenCount > 3 then
      begin
        ActivityStartEnabled := TCheckBox(FAnnRowActivityStart.Children[1]).IsChecked;
        ActivityStart := TEdit(TRectangle(FAnnRowActivityStart.Children[3]).Children[0]).Text;
      end;

      if FAnnRow2Min.ChildrenCount > 3 then
      begin
        TwoMinWarningEnabled := TCheckBox(FAnnRow2Min.Children[1]).IsChecked;
        TwoMinWarning := TEdit(TRectangle(FAnnRow2Min.Children[3]).Children[0]).Text;
      end;

      if FAnnRowActivityEnd.ChildrenCount > 3 then
      begin
        ActivityEndEnabled := TCheckBox(FAnnRowActivityEnd.Children[1]).IsChecked;
        ActivityEnd := TEdit(TRectangle(FAnnRowActivityEnd.Children[3]).Children[0]).Text;
      end;

      if FAnnRow1Min.ChildrenCount > 3 then
      begin
        OneMinWarningEnabled := TCheckBox(FAnnRow1Min.Children[1]).IsChecked;
        OneMinWarning := TEdit(TRectangle(FAnnRow1Min.Children[3]).Children[0]).Text;
      end;

      if FAnnRowStationEnd.ChildrenCount > 3 then
      begin
        StationEndEnabled := TCheckBox(FAnnRowStationEnd.Children[1]).IsChecked;
        StationEnd := TEdit(TRectangle(FAnnRowStationEnd.Children[3]).Children[0]).Text;
      end;

      if FAnnRowChangeover.ChildrenCount > 3 then
      begin
        ChangeoverEnabled := TCheckBox(FAnnRowChangeover.Children[1]).IsChecked;
        Changeover := TEdit(TRectangle(FAnnRowChangeover.Children[3]).Children[0]).Text;
      end;
  end;
end;

procedure TMainForm.OnTimerTick(Sender: TObject; SecondsRemaining: Double; Progress: Double);
begin
  UpdateCountdown(SecondsRemaining);
  UpdateProgress(Progress);
  UpdateStationTimers(SecondsRemaining);
  
  // Logic for Next Announcement
  var NextText: string := '';
  var NextTime: string := '';
  
  if FTimer.CurrentPhase = phActivity then
  begin
       // Check for 2 min, 1 min, or End warnings
       
       var Ann := FConfig.Announcements;
       
       if (SecondsRemaining > 120) and Ann.TwoMinWarningEnabled then
       begin
            NextTime := FormatSeconds(Round(SecondsRemaining - 120));
            NextText := '2-minute warning';
       end
       else if (SecondsRemaining > 60) and Ann.OneMinWarningEnabled then
       begin
            NextTime := FormatSeconds(Round(SecondsRemaining - 60));
            NextText := '1-minute warning';
       end
       else if Ann.ActivityEndEnabled then
       begin
            NextTime := FormatSeconds(Round(SecondsRemaining));
            NextText := 'Activity End';
       end;
  end;
  
  if NextText <> '' then
  begin
      FLblNextAnnouncement.Text := NextTime + '   ' + NextText;
      FLblNextAnnouncement.TextSettings.FontColor := CLR_ACCENT; 
  end
  else
  begin
      FLblNextAnnouncement.Text := '--:--   No upcoming announcements';
      FLblNextAnnouncement.TextSettings.FontColor := CLR_TEXT_MUTED;
  end;
end;

procedure TMainForm.UpdateStationTimers(SecondsRemaining: Double);
var
  PhaseMax, Elapsed: Double;
  ShouldUpdate: Boolean;
  StationDuration: Double;
begin
  ShouldUpdate := False;
  Elapsed := 0;

  if (StationsManager.GetCount > 0) then
  begin
      if FTimer.CurrentPhase = phActivity then
      begin
          PhaseMax := StationsManager.GetMaxActivityTime * 60;
          Elapsed := PhaseMax - SecondsRemaining;
          ShouldUpdate := True;
      end
      else if FTimer.CurrentPhase = phFeedback then
      begin
          PhaseMax := StationsManager.GetMaxTotalTime * 60 - StationsManager.GetMaxActivityTime * 60;
          Elapsed := PhaseMax - SecondsRemaining;
          ShouldUpdate := True;
      end;
  end;

  for var I := 0 to FCandidateCards.Count - 1 do
  begin
     var Card := FCandidateCards[I];
     var LblTimer: TLabel := nil;
     var LblStatus: TLabel := nil;
     
     if Card.ChildrenCount > 0 then
     begin
        for var J := 0 to Card.ChildrenCount - 1 do 
        begin
           // Timer Badge (Tag 41) -> Label
           if (Card.Children[J] is TRectangle) and (Card.Children[J].Tag = 41) then
           begin
                if TRectangle(Card.Children[J]).ChildrenCount > 0 then
                   LblTimer := TLabel(TRectangle(Card.Children[J]).Children[0]); 
           end;
           
           // Status Label (Tag 30)
           if (Card.Children[J] is TLabel) and (Card.Children[J].Tag = 30) then
              LblStatus := TLabel(Card.Children[J]);
        end;
     end;

     if Assigned(LblTimer) then
     begin
         if ShouldUpdate then
         begin
             var TotalPos := Max(StationsManager.GetCount, FCandidateCards.Count);
             var StationIdx := ((I + FCurrentRound - 1) mod TotalPos) + 1; 
             
             if StationIdx <= StationsManager.GetCount then
             begin
                 var Station := StationsManager.GetByIndex(StationIdx - 1); // 0-based
                 var StRem: Double;
                 
                 // Logic: 
                 // 1. If Skipped to Feedback -> Equalize to Global Timer
                 // 2. If Normal Activity -> Check for Early Finish
                 // 3. If Normal Feedback -> Show Feedback Time
                 
                 if (FTimer.CurrentPhase = phFeedback) and FInSkippedPhase then
                 begin
                     // Forced Sync for Feedback Skip
                     StRem := SecondsRemaining;
                     // Status is already handled by OnPhaseChange's call to UpdateCandidateGrid (FEEDBACK)
                 end
                 else if FTimer.CurrentPhase = phActivity then
                 begin
                      // Check Activity Remaining
                      var ActDuration := Station.ActivityTime * 60;
                      var ActRem := ActDuration - Elapsed;
                      
                      if ActRem > 0 then
                      begin
                          // Still in Activity
                          StRem := ActRem;
                          // Ensure Status is correct (might have been updated by cycle?)
                          // UpdateCandidateGrid sets it to ACTIVITY initially.
                          if Assigned(LblStatus) and (LblStatus.Text <> 'ACTIVITY') then
                          begin
                               LblStatus.Text := 'ACTIVITY';
                               LblStatus.TextSettings.FontColor := CLR_PHASE_ACTIVITY;
                          end;
                      end
                      else
                      begin
                          // Activity Finished -> Early Feedback
                          // Calculate Feedback Remaining
                          // Feedback starts when Activity ends (at ActDuration)
                          // Time passed in Feedback = Elapsed - ActDuration
                          // Feedback Rem = FeedbackDuration - (Elapsed - ActDuration)
                          var FeedDuration := Station.FeedbackTime * 60;
                          var TimeInFeed := Elapsed - ActDuration;
                          StRem := FeedDuration - TimeInFeed;
                          
                          // Update Status to FEEDBACK
                          if Assigned(LblStatus) then
                          begin
                               LblStatus.Text := 'FEEDBACK';
                               LblStatus.TextSettings.FontColor := CLR_PHASE_FEEDBACK;
                          end;
                      end;
                 end
                 else
                 begin
                      // Normal Feedback Phase
                      // Station Duration is Feedback Time
                      StationDuration := Station.FeedbackTime * 60;
                      StRem := StationDuration - Elapsed;
                 end;

                 if StRem < 0 then StRem := 0;
                 LblTimer.Text := FormatSeconds(Round(StRem));
                 
                 if StRem = 0 then 
                    LblTimer.TextSettings.FontColor := CLR_TEXT_MUTED
                 else
                    LblTimer.TextSettings.FontColor := CLR_TEXT_PRIMARY;
             end
             else
             begin
                  // Rest Station: Show global phase remaining time
                  LblTimer.Text := FormatSeconds(Round(SecondsRemaining));
                  
                  if SecondsRemaining <= 0 then 
                     LblTimer.TextSettings.FontColor := CLR_TEXT_MUTED
                  else
                     LblTimer.TextSettings.FontColor := CLR_TEXT_PRIMARY;
             end;
         end
         else
         begin
              LblTimer.Text := '--:--';
              LblTimer.TextSettings.FontColor := CLR_TEXT_MUTED;
         end;
     end;
  end;
end;

procedure TMainForm.OnPhaseChange(Sender: TObject; CompletedPhase: TExamPhase);
begin
  if FPauseOverlay.Visible then
    FPauseOverlay.Visible := False;

  // Update Skip State for the NEW phase
  FInSkippedPhase := FSkipTransition;
  FSkipTransition := False; // Reset Trigger



  case CompletedPhase of
    phRead:
      begin
        VoiceManager.Speak(GetAnnouncementText('Activity Start', 'Please begin. You have ' + IntToStr(StationsManager.GetMaxActivityTime) + ' minutes.'), True);
        FTimer.Start(StationsManager.GetMaxActivityTime * 60, phActivity);
        FPhaseBadge.Fill.Color := CLR_PHASE_ACTIVITY;
        FLblPhase.Text := 'ACTIVITY';
      end;
    phActivity:
      begin
        VoiceManager.Speak(GetAnnouncementText('Activity End', 'Please stop. Begin feedback.'), True);
        FTimer.Start(StationsManager.GetMaxFeedbackTime * 60, phFeedback);
        FPhaseBadge.Fill.Color := CLR_PHASE_FEEDBACK;
        FLblPhase.Text := 'FEEDBACK';
      end;
    phFeedback:
      begin
        VoiceManager.Speak(GetAnnouncementText('Round Complete', 'Round complete. Prepare to rotate.'), True);
        FTimer.Start(StrToIntDef(FEdtChangeover.Text, 10), phChangeover);
        FPhaseBadge.Fill.Color := CLR_PHASE_CHANGEOVER;
        FLblPhase.Text := 'CHANGEOVER';
      end;
    phChangeover:
      begin
        Inc(FCurrentRound);
        // Rotation Logic: Total positions = Max(Stations, Candidates)
        if FCurrentRound > Max(StationsManager.GetCount, StrToIntDef(FEdtCandidates.Text, 5)) then
        begin
          VoiceManager.Speak('Exam complete. Thank you all for participating.', True);
          ShowSetup;
        end
        else
        begin
          FLblRound.Text := 'Round ' + IntToStr(FCurrentRound);
          
          if FEdtReadTime.Text = '0' then
          begin
             VoiceManager.Speak(GetAnnouncementText('Activity Start', 'Please begin.'), True);
             FTimer.Start(StationsManager.GetMaxActivityTime * 60, phActivity);
             FPhaseBadge.Fill.Color := CLR_PHASE_ACTIVITY;
             FLblPhase.Text := 'ACTIVITY';
          end
          else
          begin
             VoiceManager.Speak(GetAnnouncementText('Changeover', 'Please move to your next station and read the instructions.'), True);
             FTimer.Start(StrToIntDef(FEdtReadTime.Text, 60), phRead);
             FPhaseBadge.Fill.Color := CLR_PHASE_READ;
             FLblPhase.Text := 'READ';
          end;
        end;
      end;
  end;
  // Ensure candidates are updated for the new phase (AFTER timer start so CurrentPhase is correct)
  UpdateCandidateGrid;
  UpdateStationTimers(FTimer.SecondsRemaining);
end;

procedure TMainForm.OnAnnouncement(Sender: TObject; AnnouncementType: string; SecondsRemaining: Integer);
begin
  if AnnouncementType = 'twoMinWarning' then
  begin
    if FConfig.Announcements.TwoMinWarningEnabled then
      VoiceManager.Speak(GetAnnouncementText('2-Minute Warning', 'Two minutes remaining.'), True);
  end
  else if AnnouncementType = 'oneMinWarning' then
  begin
    if FConfig.Announcements.OneMinWarningEnabled then
      VoiceManager.Speak(GetAnnouncementText('1-Minute Warning', 'One minute remaining.'), True);
  end
  else if AnnouncementType = 'thirtySecWarning' then
  begin
    VoiceManager.Speak('30 seconds remaining.', True);
  end
  else if AnnouncementType = 'countdown' then
  begin
    // Optional: Speak countdown numbers
    if SecondsRemaining <= 5 then
      VoiceManager.Speak(IntToStr(SecondsRemaining), True);
  end;
end;

function PhaseToColor(APhase: TExamPhase): TAlphaColor;
begin
  case APhase of
    phRead: Result := CLR_PHASE_READ;
    phActivity: Result := CLR_PHASE_ACTIVITY;
    phFeedback: Result := CLR_PHASE_FEEDBACK;
    phChangeover: Result := CLR_PHASE_CHANGEOVER;
  else
    Result := CLR_TEXT_PRIMARY;
  end;
end;

procedure TMainForm.UpdateCountdown(ASeconds: Double);
var
  M, S: Integer;
begin
  M := Trunc(ASeconds) div 60;
  S := Trunc(ASeconds) mod 60;
  FLblCountdown.Text := Format('%.2d:%.2d', [M, S]);
  
  if (FTimer.CurrentPhase = phActivity) and (ASeconds <= 60) then
    FLblCountdown.TextSettings.FontColor := CLR_DANGER
  else if (FTimer.CurrentPhase = phActivity) and (ASeconds <= 120) then
    FLblCountdown.TextSettings.FontColor := CLR_WARNING
  else
    FLblCountdown.TextSettings.FontColor := PhaseToColor(FTimer.CurrentPhase);
end;

procedure TMainForm.ShowSetup;
begin
  FTimerPanel.Visible := False;
  FScrollBox.Visible := True;
  if Assigned(FAnnouncementLayout) then FAnnouncementLayout.Visible := False;
  FIsExamRunning := False;
  FormResize(Self); // Update Footer alignment
end;

procedure TMainForm.ShowTimer;
begin
  FScrollBox.Visible := False;
  FTimerPanel.Visible := True;
  if Assigned(FAnnouncementLayout) then FAnnouncementLayout.Visible := True;
  FIsExamRunning := True;
  FormResize(Self); // Update Footer alignment & layout
  
  FLblRound.Text := 'Round ' + IntToStr(FCurrentRound);
  FLblRoundInfo.Text := FEdtCandidates.Text + ' candidates at ' + IntToStr(StationsManager.GetCount) + ' stations';
  FPhaseBadge.Fill.Color := CLR_PHASE_READ;
  FLblPhase.Text := 'READ';
  
  // Setup progress bar segments based on times
  // Using 1000px total width
  FProgressRead.Width := 200;
  FProgressRead.Position.X := 0;
  FProgressActivity.Width := 400;
  FProgressActivity.Position.X := 200;
  FProgressFeedback.Width := 200;
  FProgressFeedback.Position.X := 600;
  FProgressChangeover.Width := 200;
  FProgressChangeover.Position.X := 800;

  // Update Label Positions (Tag 10,20,30,40)
  for var I := 0 to FProgressLayout.ChildrenCount - 1 do
  begin
    if FProgressLayout.Children[I] is TLabel then
    begin
        var L := TLabel(FProgressLayout.Children[I]);
        if L.Tag = 10 then L.Position.X := FProgressRead.Position.X;
        if L.Tag = 20 then L.Position.X := FProgressActivity.Position.X;
        if L.Tag = 30 then L.Position.X := FProgressFeedback.Position.X;
        if L.Tag = 40 then L.Position.X := FProgressChangeover.Position.X;
    end;
  end;
  
  SetupCandidateGrid;
  FormResize(nil); // Force layout update
end;

procedure TMainForm.SetupCandidateGrid;
var
  I: Integer;
  Card: TRectangle;
  LblName, LblStation, LblStatus: TLabel;
  NumCandidates: Integer;
  CardWidth, CardHeight: Single;
  CardsPerRow, Row, Col, NumRows: Integer;
begin
  for I := FCandidateCards.Count - 1 downto 0 do
    FCandidateCards[I].Free;
  FCandidateCards.Clear;
  
  NumCandidates := StrToIntDef(FEdtCandidates.Text, 5);
  CardWidth := 160;
  CardHeight := 100;
  CardsPerRow := 6;
  NumRows := ((NumCandidates - 1) div CardsPerRow) + 1;
  
  // Set layout width for horizontal scrolling if needed
  FCandidatesLayout.Width := Min(NumCandidates, CardsPerRow) * (CardWidth + 10) + 20;
  FCandidatesLayout.Height := NumRows * (CardHeight + 10) + 10;
  
  for I := 0 to NumCandidates - 1 do
  begin
    Row := I div CardsPerRow;
    Col := I mod CardsPerRow;
    
    Card := TRectangle.Create(FCandidatesLayout);
    Card.Parent := FCandidatesLayout;
    Card.Position.X := 10 + (Col * (CardWidth + 10));
    Card.Position.Y := 10 + (Row * (CardHeight + 10));
    Card.Width := CardWidth;
    Card.Height := CardHeight;
    Card.Fill.Color := CLR_BG_ELEVATED;
    Card.Stroke.Color := CLR_BORDER;
    Card.XRadius := 6;
    Card.YRadius := 6;
    
    // Candidate Name
    LblName := TLabel.Create(Card);
    LblName.Parent := Card;
    LblName.Position.X := 15;
    LblName.Position.Y := 15;
    LblName.Text := 'Candidate ' + IntToStr(I + 1);
    LblName.StyledSettings := [];
    LblName.TextSettings.Font.Size := 14;
    LblName.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblName.TextSettings.FontColor := CLR_TEXT_PRIMARY;
    
    // Station
    LblStation := TLabel.Create(Card);
    LblStation.Parent := Card;
    LblStation.Position.X := 15;
    LblStation.Position.Y := 40;
    LblStation.Width := 130; // Reduced width to make room for timer
    LblStation.Height := 40; // Allow 2 lines
    LblStation.WordWrap := True; // Allow wrapping for long names
    LblStation.StyledSettings := [];
    LblStation.TextSettings.Font.Size := 12;
    LblStation.TextSettings.FontColor := CLR_TEXT_SECONDARY;
    LblStation.TextSettings.VertAlign := TTextAlign.Leading;

    // Timer Badge (Background)
    var TimerBadge: TRectangle := TRectangle.Create(Card);
    TimerBadge.Parent := Card;
    TimerBadge.Width := 60;
    TimerBadge.Height := 24;
    TimerBadge.Position.X := CardWidth - 70; // Specific position
    TimerBadge.Position.Y := 68; // aligned with status
    TimerBadge.Fill.Color := CLR_BG_PRIMARY; // Inner dark
    TimerBadge.Stroke.Kind := TBrushKind.None;
    TimerBadge.XRadius := 4;
    TimerBadge.YRadius := 4;
    TimerBadge.Tag := 41;

    // Timer Label
    var LblTimer: TLabel := TLabel.Create(TimerBadge);
    LblTimer.Parent := TimerBadge;
    LblTimer.Align := TAlignLayout.Client;
    LblTimer.Text := '--:--';
    LblTimer.StyledSettings := [];
    LblTimer.TextSettings.Font.Size := 12;
    LblTimer.TextSettings.FontColor := CLR_TEXT_PRIMARY; // White
    LblTimer.TextSettings.HorzAlign := TTextAlign.Center;
    LblTimer.Tag := 40;
    
    // Rotation Calculation with Rest Support
    var TotalPos := Max(StationsManager.GetCount, NumCandidates);
    var StationIdx := ((I + FCurrentRound - 1) mod TotalPos) + 1;
    
    if StationIdx > StationsManager.GetCount then
    begin
        LblStation.Text := 'REST STATION';
        LblStation.TextSettings.FontColor := CLR_TEXT_MUTED;
    end
    else
    begin
        LblStation.Text := 'Station ' + IntToStr(StationIdx);
        LblStation.TextSettings.FontColor := CLR_TEXT_SECONDARY;
    end;

    LblStation.StyledSettings := [];
    LblStation.TextSettings.Font.Size := 12;
    
    // Status Badge
    LblStatus := TLabel.Create(Card);
    LblStatus.Parent := Card;
    LblStatus.Align := TAlignLayout.Bottom;
    LblStatus.Height := 24;
    LblStatus.Margins.Bottom := 10;
    LblStatus.Margins.Left := 15;
    LblStatus.Text := 'READING';
    LblStatus.StyledSettings := [];
    LblStatus.TextSettings.Font.Size := 11;
    LblStatus.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblStatus.TextSettings.FontColor := CLR_PHASE_READ;
    
    // Tagging for reliable retrieval
    LblName.Tag := 10;
    LblStation.Tag := 20;
    LblStatus.Tag := 30;
    
    FCandidateCards.Add(Card);
  end;
end;

procedure TMainForm.UpdateCandidateGrid;
var
  I: Integer;
  Card: TRectangle;
  LblStatus, LblStation: TLabel;
  NumCandidates: Integer;
  PhaseName: string;
begin
  NumCandidates := FCandidateCards.Count;
  
  case FTimer.CurrentPhase of
    phRead: PhaseName := 'READING';
    phActivity: PhaseName := 'ACTIVITY';
    phFeedback: PhaseName := 'FEEDBACK';
    phChangeover: PhaseName := 'CHANGEOVER';
  end;
  
  for I := 0 to NumCandidates - 1 do
  begin
    Card := FCandidateCards[I];
    LblStation := nil;
    LblStatus := nil;
    
    // Reliable retrieval using Tags
    if Card.ChildrenCount > 0 then
    begin
         for var J := 0 to Card.ChildrenCount - 1 do
         begin
            if Card.Children[J] is TLabel then
            begin
                var L := TLabel(Card.Children[J]);
                if L.Tag = 20 then LblStation := L;
                if L.Tag = 30 then LblStatus := L;
            end;
         end;
         
         if Assigned(LblStatus) then 
         begin
            LblStatus.StyledSettings := []; // Ensure style is stripped
            LblStatus.Text := PhaseName;
            LblStatus.TextSettings.FontColor := PhaseToColor(FTimer.CurrentPhase);
         end;
         
         if Assigned(LblStation) and Assigned(LblStatus) then 
         begin
             var TotalPos := Max(StationsManager.GetCount, NumCandidates);
             var StationIdx := ((I + FCurrentRound - 1) mod TotalPos) + 1;
             
             if StationIdx > StationsManager.GetCount then
             begin
                 LblStation.Text := 'REST STATION';
                 LblStatus.Text := 'RESTING'; 
                 LblStatus.TextSettings.FontColor := CLR_TEXT_MUTED;
             end
             else
             begin
                 // Fetch Real Station Name
                 // StationIdx is 1-based here, Manager uses 0-based? 
                 // Manager Add returns ID. List is TList. 
                 // Let's use GetByIndex (0-based)
                 var RealStation := StationsManager.GetByIndex(StationIdx - 1);
                 LblStation.Text := 'Station ' + IntToStr(StationIdx) + ': ' + RealStation.Name;
             end;
         end;
    end;
  end;
end;

procedure TMainForm.UpdateProgress(AProgress: Double);
begin
  // Calculate total seconds for current phase to determine progress width
  var FullWidth: Single;

  // Reset all fills to 0
  FProgressReadFill.Width := 0;
  FProgressActivityFill.Width := 0;
  FProgressFeedbackFill.Width := 0;
  FProgressChangeoverFill.Width := 0;
  
  case FTimer.CurrentPhase of
    phRead: 
    begin
        FullWidth := FProgressRead.Width;
        FProgressReadFill.Width := FullWidth * AProgress;
    end;
    phActivity:
    begin
        // Keep previous full
        FProgressReadFill.Width := FProgressRead.Width;
        FullWidth := FProgressActivity.Width;
        FProgressActivityFill.Width := FullWidth * AProgress;
    end;
    phFeedback:
    begin
        FProgressReadFill.Width := FProgressRead.Width;
        FProgressActivityFill.Width := FProgressActivity.Width;
        FullWidth := FProgressFeedback.Width;
        FProgressFeedbackFill.Width := FullWidth * AProgress;
    end;
    phChangeover:
    begin
        FProgressReadFill.Width := FProgressRead.Width;
        FProgressActivityFill.Width := FProgressActivity.Width;
        FProgressFeedbackFill.Width := FProgressFeedback.Width;
        FullWidth := FProgressChangeover.Width;
        FProgressChangeoverFill.Width := FullWidth * AProgress;
    end;
  end;
end;

procedure TMainForm.BtnKioskClick(Sender: TObject);
begin
  if BorderStyle = TFmxFormBorderStyle.None then
  begin
    BorderStyle := TFmxFormBorderStyle.Sizeable;
    WindowState := TWindowState.wsMaximized;
    FBtnKioskIcon.Text := '⛶';
  end
  else
  begin
    BorderStyle := TFmxFormBorderStyle.None;
    WindowState := TWindowState.wsMaximized;
    FBtnKioskIcon.Text := '✕';
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
var
  TargetWidth: Single;
  M: Single;
  ScaleY: Single;
  RefHeight: Single;
begin
  TargetWidth := 1000;
  if Width < 1024 then TargetWidth := Width - 48;
  
  M := Max(0, (Width - TargetWidth) / 2);
  
  if Assigned(FSetupPanel) then
  begin
    FSetupPanel.Margins.Left := M;
    FSetupPanel.Margins.Right := M;
  end;
  
  // Scale factor based on height (reference = 800)
  RefHeight := 800;
  ScaleY := Height / RefHeight;
  
  if Assigned(FTimerPanel) and FTimerPanel.Visible then
  begin
    // Scale Y positions and sizes for timer elements (Ultra Compact - Header Bleed V2)
    if Assigned(FPhaseBadge) then
    begin
      // Move badge UP into the Header empty space (centered)
      FPhaseBadge.Position.Y := -65 * ScaleY; 
      FPhaseBadge.Height := 30 * ScaleY;
    end;
    
    if Assigned(FLblCountdown) then
    begin
      FLblCountdown.Position.Y := -25 * ScaleY; // Starts overlapping panel top
      FLblCountdown.Height := 120 * ScaleY;
      FLblCountdown.TextSettings.Font.Size := 100 * ScaleY;
      FLblCountdown.Width := FTimerPanel.Width;
      FLblCountdown.Position.X := 0;
    end;
    
    if Assigned(FLblRound) then
    begin
      FLblRound.Position.Y := 90 * ScaleY;
      FLblRound.Height := 40 * ScaleY;
      FLblRound.TextSettings.Font.Size := 28 * ScaleY;
      FLblRound.Width := FTimerPanel.Width;
      FLblRound.Position.X := 0;
    end;
    
    if Assigned(FLblRoundInfo) then
    begin
      FLblRoundInfo.Position.Y := 130 * ScaleY;
      FLblRoundInfo.Height := 24 * ScaleY;
      FLblRoundInfo.TextSettings.Font.Size := 16 * ScaleY;
      FLblRoundInfo.Width := FTimerPanel.Width;
      FLblRoundInfo.Position.X := 0;
    end;
    
    if Assigned(FProgressLayout) then
    begin
      FProgressLayout.Position.Y := 160 * ScaleY;
      FProgressLayout.Height := 40 * ScaleY;
      FProgressLayout.Width := 1000;
      FProgressLayout.Position.X := (FTimerPanel.Width - 1000) / 2;
    end;
    
    // Scale button layout position and size
    var BtnScale := ScaleY;
    var BtnHeight := 48 * BtnScale;
    var BtnStartX := (FTimerPanel.Width - 640) / 2;
    
    if Assigned(FButtonLayout) then
    begin
      FButtonLayout.Position.Y := 210 * ScaleY;
      FButtonLayout.Height := 60 * ScaleY;
      FButtonLayout.Width := FTimerPanel.Width;
    end;
    
    FBtnPause.Position.X := BtnStartX;
    FBtnPause.Height := BtnHeight;
    FBtnSkip.Position.X := BtnStartX + 160;
    FBtnSkip.Height := BtnHeight;
    FBtnRestart.Position.X := BtnStartX + 320;
    FBtnRestart.Height := BtnHeight;
    FBtnStop.Position.X := BtnStartX + 500;
    FBtnStop.Height := BtnHeight;
    
    // Scale Candidates Header position
    if Assigned(FCandidatesHeader) then
    begin
      FCandidatesHeader.Position.Y := 270 * ScaleY;
      FCandidatesHeader.Width := FTimerPanel.Width;
    end;
    
    // Scale Candidates Scrollbox position and size    
    if Assigned(FCandidatesScrollBox) then
    begin
      FCandidatesScrollBox.Position.Y := 300 * ScaleY;
      FCandidatesScrollBox.Height := 230 * ScaleY;
      FCandidatesScrollBox.Width := FTimerPanel.Width;
    end;
    
    // Center Next Announcement
    FLblNextAnnouncement.Width := FTimerPanel.Width;
    FLblNextAnnouncement.Position.X := 0;
    
    // Center Candidate Grid if it fits
    if Assigned(FCandidatesLayout) then
    begin
       if FCandidatesLayout.Width < FTimerPanel.Width then
         FCandidatesLayout.Position.X := (FTimerPanel.Width - FCandidatesLayout.Width) / 2
       else
         FCandidatesLayout.Position.X := 0;
    end;
    
    // Scale Announcement Layout position
    if Assigned(FAnnouncementLayout) then
    begin
      FAnnouncementLayout.Position.Y := 620 * ScaleY;
      FAnnouncementLayout.Width := Width;
    end;
    
    end;

  // Footer Logic (Global)
  if Assigned(FFooterLayout) then
  begin
    if Assigned(FTimerPanel) and FTimerPanel.Visible then
    begin
       // Timer Mode: Fixed/Scaled
       FFooterLayout.Align := TAlignLayout.None;
       FFooterLayout.Position.Y := 700 * ScaleY;
       FFooterLayout.Width := Width;
       FFooterLayout.Height := 100 * ScaleY;
    end
    else
    begin
       // Setup Mode: Bottom aligned
       FFooterLayout.Align := TAlignLayout.Bottom;
       FFooterLayout.Height := 100;
       FFooterLayout.Width := Width;
    end;
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if not FIsExamRunning then Exit;
  
  if Key = vkSpace then
    BtnPauseClick(Sender)
  else if (UpCase(KeyChar) = 'M') then
    BtnMuteClick(Sender)
  else if (UpCase(KeyChar) = 'R') then
    FBtnRestart.OnClick(FBtnRestart);
end;

function TMainForm.GetAnnouncementText(const AType, ADefault: string): string;
var
  I: Integer;
  Row: TLayout;
  Chk: TCheckBox;

begin
  Result := ADefault;
  // Iterate announcement rows to find matching title
  if Assigned(FAnnouncementsCard) then
  begin
    for I := 0 to FAnnouncementsCard.ChildrenCount - 1 do
    begin
        if FAnnouncementsCard.Children[I] is TLayout then
        begin
            Row := TLayout(FAnnouncementsCard.Children[I]);
            if (Row.ChildrenCount > 1) and (Row.Children[0] is TCheckBox) then // Only check rows with Checkbox
            begin
                 Chk := TCheckBox(Row.Children[0]); // Checkbox is first child
                 if (Chk.Text = AType) then
                 begin
                     if not Chk.IsChecked then Exit(''); // Disabled
                     
                     // Find the edit box (it's inside a rectangle usually, but let's check structure)
                     // Structure was: Row -> [CheckBox, Rect -> Edit]
                     if (Row.ChildrenCount > 1) and (Row.Children[1] is TRectangle) then
                     begin
                         var Rect := TRectangle(Row.Children[1]);
                         if (Rect.ChildrenCount > 0) and (Rect.Children[0] is TEdit) then
                            Result := TEdit(Rect.Children[0]).Text;
                     end;
                     Break;
                 end;
            end;
        end;
    end;
  end;
end;

end.
