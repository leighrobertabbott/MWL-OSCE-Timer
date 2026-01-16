unit uMain;

{*******************************************************************************
  OSCE Timing System - Main Form
  Main application window with dark theme
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Menus,
  uTypes, uConfig, uVoice, uStations, uSetupFrame, uTimerFrame;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    // Header
    FPanelHeader: TPanel;
    FPanelNHSBar: TPanel;
    FLblTrust: TLabel;
    FLblSubtitle: TLabel;
    FBtnMute: TButton;

    // Content
    FPanelContent: TPanel;
    FSetupFrame: TSetupFrame;
    FTimerFrame: TTimerFrame;

    // Footer
    FPanelFooter: TPanel;
    FLblShortcuts: TLabel;
    FLblDesignedBy: TLabel;
    FLblAuthor: TLabel;
    FLblMeta: TLabel;
    FLblDisclaimer: TLabel;

    // State
    FIsExamRunning: Boolean;
    FIsMuted: Boolean;

    procedure CreateComponents;
    procedure CreateHeader;
    procedure CreateContent;
    procedure CreateFooter;
    procedure ApplyStyles;

    procedure BtnMuteClick(Sender: TObject);
    procedure OnStartExam(Sender: TObject);
    procedure OnStopExam(Sender: TObject);

    procedure ToggleMute;
    procedure CheckCrashRecovery;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Basic form setup
  Caption := 'OSCE Timing System';
  Color := CLR_BG_PRIMARY;
  Width := 1000;
  Height := 750;
  Position := poScreenCenter;
  KeyPreview := True;
  OnKeyDown := FormKeyDown;

  FIsExamRunning := False;
  FIsMuted := False;

  CreateComponents;
  ApplyStyles;

  // Load saved config
  FSetupFrame.LoadConfig(ConfigManager.LoadConfig);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Cleanup
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  CheckCrashRecovery;
end;

procedure TMainForm.CreateComponents;
begin
  CreateHeader;
  CreateContent;
  CreateFooter;
end;

procedure TMainForm.CreateHeader;
begin
  FPanelHeader := TPanel.Create(Self);
  FPanelHeader.Parent := Self;
  FPanelHeader.Align := alTop;
  FPanelHeader.Height := 80;
  FPanelHeader.BevelOuter := bvNone;
  FPanelHeader.Color := CLR_BG_PRIMARY;

  // NHS Blue bar at top
  FPanelNHSBar := TPanel.Create(FPanelHeader);
  FPanelNHSBar.Parent := FPanelHeader;
  FPanelNHSBar.Align := alTop;
  FPanelNHSBar.Height := 4;
  FPanelNHSBar.BevelOuter := bvNone;
  FPanelNHSBar.Color := CLR_NHS_BLUE;

  // Trust name
  FLblTrust := TLabel.Create(FPanelHeader);
  FLblTrust.Parent := FPanelHeader;
  FLblTrust.Left := 24;
  FLblTrust.Top := 16;
  FLblTrust.Caption := 'Mersey and West Lancashire NHS';
  FLblTrust.Font.Name := 'Segoe UI';
  FLblTrust.Font.Size := 14;
  FLblTrust.Font.Style := [fsBold];
  FLblTrust.Font.Color := clWhite;

  // Subtitle
  FLblSubtitle := TLabel.Create(FPanelHeader);
  FLblSubtitle.Parent := FPanelHeader;
  FLblSubtitle.Left := 24;
  FLblSubtitle.Top := 42;
  FLblSubtitle.Caption := 'Clinical Education OSCE Timer Application';
  FLblSubtitle.Font.Name := 'Segoe UI';
  FLblSubtitle.Font.Size := 11;
  FLblSubtitle.Font.Color := CLR_TEXT_SECONDARY;

  // Mute button
  FBtnMute := TButton.Create(FPanelHeader);
  FBtnMute.Parent := FPanelHeader;
  FBtnMute.Left := FPanelHeader.Width - 70;
  FBtnMute.Top := 24;
  FBtnMute.Width := 40;
  FBtnMute.Height := 40;
  FBtnMute.Caption := '🔊';
  FBtnMute.Font.Size := 14;
  FBtnMute.Anchors := [akTop, akRight];
  FBtnMute.OnClick := BtnMuteClick;
end;

procedure TMainForm.CreateContent;
begin
  FPanelContent := TPanel.Create(Self);
  FPanelContent.Parent := Self;
  FPanelContent.Align := alClient;
  FPanelContent.BevelOuter := bvNone;
  FPanelContent.Color := CLR_BG_PRIMARY;
  FPanelContent.Padding.Left := 24;
  FPanelContent.Padding.Right := 24;
  FPanelContent.Padding.Top := 8;
  FPanelContent.Padding.Bottom := 8;

  // Setup Frame
  FSetupFrame := TSetupFrame.Create(Self);
  FSetupFrame.Parent := FPanelContent;
  FSetupFrame.Align := alClient;
  FSetupFrame.OnStartExam := OnStartExam;

  // Timer Frame (hidden initially)
  FTimerFrame := TTimerFrame.Create(Self);
  FTimerFrame.Parent := FPanelContent;
  FTimerFrame.Align := alClient;
  FTimerFrame.Visible := False;
  FTimerFrame.OnStopExam := OnStopExam;
end;

procedure TMainForm.CreateFooter;
var
  SepPanel: TPanel;
begin
  FPanelFooter := TPanel.Create(Self);
  FPanelFooter.Parent := Self;
  FPanelFooter.Align := alBottom;
  FPanelFooter.Height := 120;
  FPanelFooter.BevelOuter := bvNone;
  FPanelFooter.Color := CLR_BG_PRIMARY;
  FPanelFooter.Padding.Left := 24;
  FPanelFooter.Padding.Right := 24;

  // Separator
  SepPanel := TPanel.Create(FPanelFooter);
  SepPanel.Parent := FPanelFooter;
  SepPanel.Align := alTop;
  SepPanel.Height := 1;
  SepPanel.BevelOuter := bvNone;
  SepPanel.Color := CLR_BORDER_SUBTLE;

  // Shortcuts
  FLblShortcuts := TLabel.Create(FPanelFooter);
  FLblShortcuts.Parent := FPanelFooter;
  FLblShortcuts.Left := 0;
  FLblShortcuts.Top := 12;
  FLblShortcuts.Width := FPanelFooter.Width;
  FLblShortcuts.Alignment := taCenter;
  FLblShortcuts.Caption := 'Shortcuts: [Space] Pause · [M] Mute · [R] Restart';
  FLblShortcuts.Font.Name := 'Segoe UI';
  FLblShortcuts.Font.Size := 9;
  FLblShortcuts.Font.Color := CLR_TEXT_MUTED;
  FLblShortcuts.Anchors := [akLeft, akTop, akRight];

  // Designed by
  FLblDesignedBy := TLabel.Create(FPanelFooter);
  FLblDesignedBy.Parent := FPanelFooter;
  FLblDesignedBy.Left := 0;
  FLblDesignedBy.Top := 36;
  FLblDesignedBy.Width := FPanelFooter.Width;
  FLblDesignedBy.Alignment := taCenter;
  FLblDesignedBy.Caption := 'DESIGNED & DEVELOPED BY';
  FLblDesignedBy.Font.Name := 'Segoe UI';
  FLblDesignedBy.Font.Size := 8;
  FLblDesignedBy.Font.Color := CLR_TEXT_MUTED;
  FLblDesignedBy.Anchors := [akLeft, akTop, akRight];

  // Author name
  FLblAuthor := TLabel.Create(FPanelFooter);
  FLblAuthor.Parent := FPanelFooter;
  FLblAuthor.Left := 0;
  FLblAuthor.Top := 50;
  FLblAuthor.Width := FPanelFooter.Width;
  FLblAuthor.Alignment := taCenter;
  FLblAuthor.Caption := 'Leigh Robert Abbott';
  FLblAuthor.Font.Name := 'Segoe UI';
  FLblAuthor.Font.Size := 11;
  FLblAuthor.Font.Style := [fsBold];
  FLblAuthor.Font.Color := CLR_TEXT_PRIMARY;
  FLblAuthor.Anchors := [akLeft, akTop, akRight];

  // Meta info
  FLblMeta := TLabel.Create(FPanelFooter);
  FLblMeta.Parent := FPanelFooter;
  FLblMeta.Left := 0;
  FLblMeta.Top := 70;
  FLblMeta.Width := FPanelFooter.Width;
  FLblMeta.Alignment := taCenter;
  FLblMeta.Caption := 'Clinical Education and Simulation • Nightingale House • leigh.abbott@merseywestlancs.nhs.uk';
  FLblMeta.Font.Name := 'Segoe UI';
  FLblMeta.Font.Size := 9;
  FLblMeta.Font.Color := CLR_TEXT_MUTED;
  FLblMeta.Anchors := [akLeft, akTop, akRight];

  // Disclaimer
  FLblDisclaimer := TLabel.Create(FPanelFooter);
  FLblDisclaimer.Parent := FPanelFooter;
  FLblDisclaimer.Left := 0;
  FLblDisclaimer.Top := 90;
  FLblDisclaimer.Width := FPanelFooter.Width;
  FLblDisclaimer.Alignment := taCenter;
  FLblDisclaimer.Caption := 'This is an internal application developed by the Clinical Education Team and is not associated with MWL''s IT Development Team.';
  FLblDisclaimer.Font.Name := 'Segoe UI';
  FLblDisclaimer.Font.Size := 8;
  FLblDisclaimer.Font.Color := CLR_TEXT_MUTED;
  FLblDisclaimer.Anchors := [akLeft, akTop, akRight];
end;

procedure TMainForm.ApplyStyles;
begin
  // Form-level styling
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Font.Color := CLR_TEXT_PRIMARY;
end;

procedure TMainForm.BtnMuteClick(Sender: TObject);
begin
  ToggleMute;
end;

procedure TMainForm.ToggleMute;
begin
  FIsMuted := not FIsMuted;
  VoiceManager.IsMuted := FIsMuted;

  if FIsMuted then
    FBtnMute.Caption := '🔇'
  else
    FBtnMute.Caption := '🔊';
end;

procedure TMainForm.OnStartExam(Sender: TObject);
var
  Config: TExamConfig;
begin
  Config := FSetupFrame.GetConfig;

  // Switch panels
  FSetupFrame.Visible := False;
  FTimerFrame.Visible := True;
  FIsExamRunning := True;

  // Start the exam
  FTimerFrame.StartExam(Config);

  VoiceManager.Speak('Exam started.', True);
end;

procedure TMainForm.OnStopExam(Sender: TObject);
begin
  FTimerFrame.StopExam;
  FTimerFrame.Visible := False;
  FSetupFrame.Visible := True;
  FIsExamRunning := False;

  VoiceManager.Speak('Exam stopped.', True);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Don't handle if focus is on an input
  if (ActiveControl is TEdit) or (ActiveControl is TMemo) or
     (ActiveControl is TComboBox) then
    Exit;

  case Key of
    VK_SPACE:
      begin
        if FIsExamRunning then
          FTimerFrame.TogglePause;
        Key := 0;
      end;

    Ord('M'):
      ToggleMute;

    Ord('R'):
      begin
        if FIsExamRunning then
          FTimerFrame.HandleKeyPress(Key);
      end;

    VK_ESCAPE:
      ; // Could close modals
  end;
end;

procedure TMainForm.CheckCrashRecovery;
var
  SavedState: string;
begin
  if ConfigManager.HasActiveState then
  begin
    if MessageDlg('An active exam session was detected from a previous visit. ' +
      'Would you like to resume where you left off?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      // TODO: Implement state restoration
      // For now, just clear the state
      ConfigManager.ClearActiveState;
    end
    else
    begin
      ConfigManager.ClearActiveState;
    end;
  end;
end;

end.
