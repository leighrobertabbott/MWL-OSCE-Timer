unit uSetupFrame;

{*******************************************************************************
  OSCE Timing System - Setup Panel Frame
  Fixed layout matching original web app
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Generics.Collections, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  uTypes, uConfig, uVoice, uStations;

type
  TAnnouncementEditor = record
    Checkbox: TCheckBox;
    Edit: TEdit;
  end;

  TStartExamEvent = procedure(Sender: TObject) of object;

  TSetupFrame = class(TFrame)
  private
    FScrollBox: TScrollBox;
    FMainPanel: TPanel;

    // General section
    FPanelGeneral: TPanel;
    FEdtStartTime: TEdit;
    FEdtNumCandidates: TEdit;
    FEdtReadTime: TEdit;
    FEdtChangeoverTime: TEdit;

    // Voice section
    FPanelVoice: TPanel;
    FCboVoice: TComboBox;
    FTrkRate: TTrackBar;
    FLblRate: TLabel;
    FTrkVolume: TTrackBar;
    FLblVolume: TLabel;
    FBtnTestVoice: TButton;

    // Stations section
    FPanelStations: TPanel;
    FBtnAddStation: TButton;
    FStationsContainer: TPanel;
    FStationEditors: TList<TPanel>;

    // Announcements section
    FPanelAnnouncements: TPanel;
    FAnnEditors: array[0..6] of TAnnouncementEditor;

    // Action buttons
    FPanelActions: TPanel;
    FBtnSave: TButton;
    FBtnExport: TButton;
    FBtnImport: TButton;
    FBtnStart: TButton;

    FOnStartExam: TStartExamEvent;

    procedure CreateUI;
    procedure CreateGeneralSection(AParent: TWinControl; ALeft, ATop, AWidth: Integer);
    procedure CreateVoiceSection(AParent: TWinControl; ALeft, ATop, AWidth: Integer);
    procedure CreateStationsSection(AParent: TWinControl; ATop, AWidth: Integer);
    procedure CreateAnnouncementsSection(AParent: TWinControl; ATop, AWidth: Integer);
    procedure CreateActionButtons(AParent: TWinControl; ATop, AWidth: Integer);

    function CreateSectionHeader(AParent: TWinControl; const ATitle: string;
      ATop: Integer): TLabel;
    function CreateFormRow(AParent: TWinControl; const ALabel: string;
      ATop, AWidth: Integer): TEdit;

    procedure RefreshStationsList;
    procedure CreateStationRow(AIndex: Integer; const AStation: TStation);
    procedure UpdateStationsHeight;
    procedure PopulateVoices;

    procedure BtnAddStationClick(Sender: TObject);
    procedure BtnDeleteStationClick(Sender: TObject);
    procedure StationFieldChange(Sender: TObject);
    procedure VoiceSelectChange(Sender: TObject);
    procedure RateChange(Sender: TObject);
    procedure VolumeChange(Sender: TObject);
    procedure BtnTestVoiceClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    procedure BtnImportClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadConfig(const AConfig: TExamConfig);
    function GetConfig: TExamConfig;

    property OnStartExam: TStartExamEvent read FOnStartExam write FOnStartExam;
  end;

implementation

{$R *.dfm}

{ TSetupFrame }

constructor TSetupFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := CLR_BG_PRIMARY;
  FStationEditors := TList<TPanel>.Create;
  OnResize := FrameResize;

  CreateUI;
  PopulateVoices;
  RefreshStationsList;
end;

destructor TSetupFrame.Destroy;
begin
  FStationEditors.Free;
  inherited;
end;

procedure TSetupFrame.FrameResize(Sender: TObject);
begin
  if FMainPanel <> nil then
  begin
    FMainPanel.Width := Width - 48;
  end;
end;

procedure TSetupFrame.CreateUI;
var
  Y, ColWidth, HalfWidth: Integer;
begin
  ColWidth := 800;
  HalfWidth := 380;

  FScrollBox := TScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align := alClient;
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.Color := CLR_BG_PRIMARY;
  FScrollBox.VertScrollBar.Tracking := True;

  FMainPanel := TPanel.Create(FScrollBox);
  FMainPanel.Parent := FScrollBox;
  FMainPanel.Left := 24;
  FMainPanel.Top := 0;
  FMainPanel.Width := ColWidth;
  FMainPanel.Height := 1500;
  FMainPanel.BevelOuter := bvNone;
  FMainPanel.Color := CLR_BG_PRIMARY;
  FMainPanel.Caption := '';

  // Title
  with TLabel.Create(FMainPanel) do
  begin
    Parent := FMainPanel;
    Left := 0;
    Top := 16;
    Caption := 'Exam Configuration';
    Font.Name := 'Segoe UI';
    Font.Size := 16;
    Font.Style := [fsBold];
    Font.Color := CLR_TEXT_PRIMARY;
  end;

  Y := 60;

  // Two columns: General and Voice side by side
  CreateGeneralSection(FMainPanel, 0, Y, HalfWidth);
  CreateVoiceSection(FMainPanel, HalfWidth + 24, Y, HalfWidth);

  Y := Y + 340;

  // Stations - full width
  CreateStationsSection(FMainPanel, Y, ColWidth);

  Y := Y + 400;

  // Announcements - full width
  CreateAnnouncementsSection(FMainPanel, Y, ColWidth);

  Y := Y + 320;

  // Action buttons
  CreateActionButtons(FMainPanel, Y, ColWidth);
end;

procedure TSetupFrame.CreateGeneralSection(AParent: TWinControl; ALeft, ATop, AWidth: Integer);
var
  Lbl: TLabel;
  Y: Integer;
begin
  FPanelGeneral := TPanel.Create(AParent);
  FPanelGeneral.Parent := AParent;
  FPanelGeneral.Left := ALeft;
  FPanelGeneral.Top := ATop;
  FPanelGeneral.Width := AWidth;
  FPanelGeneral.Height := 320;
  FPanelGeneral.BevelOuter := bvNone;
  FPanelGeneral.Color := CLR_BG_CARD;
  FPanelGeneral.Caption := '';

  Lbl := CreateSectionHeader(FPanelGeneral, 'GENERAL', 16);
  Lbl.Font.Color := CLR_ACCENT;

  Y := 50;
  FEdtStartTime := CreateFormRow(FPanelGeneral, 'Start Time', Y, AWidth - 32);
  FEdtStartTime.Text := '13:00';

  Y := Y + 65;
  FEdtNumCandidates := CreateFormRow(FPanelGeneral, 'Number of Candidates', Y, AWidth - 32);
  FEdtNumCandidates.Text := '5';
  FEdtNumCandidates.NumbersOnly := True;

  Y := Y + 65;
  FEdtReadTime := CreateFormRow(FPanelGeneral, 'Read Time (seconds)', Y, AWidth - 32);
  FEdtReadTime.Text := '60';
  FEdtReadTime.NumbersOnly := True;

  Y := Y + 65;
  FEdtChangeoverTime := CreateFormRow(FPanelGeneral, 'Changeover Time (seconds)', Y, AWidth - 32);
  FEdtChangeoverTime.Text := '60';
  FEdtChangeoverTime.NumbersOnly := True;
end;

procedure TSetupFrame.CreateVoiceSection(AParent: TWinControl; ALeft, ATop, AWidth: Integer);
var
  Lbl: TLabel;
  Y: Integer;
begin
  FPanelVoice := TPanel.Create(AParent);
  FPanelVoice.Parent := AParent;
  FPanelVoice.Left := ALeft;
  FPanelVoice.Top := ATop;
  FPanelVoice.Width := AWidth;
  FPanelVoice.Height := 320;
  FPanelVoice.BevelOuter := bvNone;
  FPanelVoice.Color := CLR_BG_CARD;
  FPanelVoice.Caption := '';

  Lbl := CreateSectionHeader(FPanelVoice, 'VOICE', 16);
  Lbl.Font.Color := CLR_ACCENT;

  Y := 50;

  // Voice selector
  Lbl := TLabel.Create(FPanelVoice);
  Lbl.Parent := FPanelVoice;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Select Voice';
  Lbl.Font.Name := 'Segoe UI';
  Lbl.Font.Size := 9;
  Lbl.Font.Color := CLR_TEXT_SECONDARY;

  FCboVoice := TComboBox.Create(FPanelVoice);
  FCboVoice.Parent := FPanelVoice;
  FCboVoice.Left := 16;
  FCboVoice.Top := Y + 20;
  FCboVoice.Width := AWidth - 32;
  FCboVoice.Style := csDropDownList;
  FCboVoice.Color := CLR_BG_ELEVATED;
  FCboVoice.Font.Name := 'Segoe UI';
  FCboVoice.Font.Size := 10;
  FCboVoice.Font.Color := CLR_TEXT_PRIMARY;
  FCboVoice.OnChange := VoiceSelectChange;

  Y := Y + 60;

  // Speech Rate
  Lbl := TLabel.Create(FPanelVoice);
  Lbl.Parent := FPanelVoice;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Speech Rate';
  Lbl.Font.Name := 'Segoe UI';
  Lbl.Font.Size := 9;
  Lbl.Font.Color := CLR_TEXT_SECONDARY;

  FTrkRate := TTrackBar.Create(FPanelVoice);
  FTrkRate.Parent := FPanelVoice;
  FTrkRate.Left := 16;
  FTrkRate.Top := Y + 18;
  FTrkRate.Width := AWidth - 80;
  FTrkRate.Height := 30;
  FTrkRate.Min := -5;
  FTrkRate.Max := 5;
  FTrkRate.Position := 0;
  FTrkRate.OnChange := RateChange;

  FLblRate := TLabel.Create(FPanelVoice);
  FLblRate.Parent := FPanelVoice;
  FLblRate.Left := AWidth - 50;
  FLblRate.Top := Y + 22;
  FLblRate.Caption := '1.0x';
  FLblRate.Font.Name := 'Consolas';
  FLblRate.Font.Size := 10;
  FLblRate.Font.Color := CLR_ACCENT;

  Y := Y + 55;

  // Volume
  Lbl := TLabel.Create(FPanelVoice);
  Lbl.Parent := FPanelVoice;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Volume';
  Lbl.Font.Name := 'Segoe UI';
  Lbl.Font.Size := 9;
  Lbl.Font.Color := CLR_TEXT_SECONDARY;

  FTrkVolume := TTrackBar.Create(FPanelVoice);
  FTrkVolume.Parent := FPanelVoice;
  FTrkVolume.Left := 16;
  FTrkVolume.Top := Y + 18;
  FTrkVolume.Width := AWidth - 80;
  FTrkVolume.Height := 30;
  FTrkVolume.Min := 0;
  FTrkVolume.Max := 100;
  FTrkVolume.Position := 100;
  FTrkVolume.OnChange := VolumeChange;

  FLblVolume := TLabel.Create(FPanelVoice);
  FLblVolume.Parent := FPanelVoice;
  FLblVolume.Left := AWidth - 50;
  FLblVolume.Top := Y + 22;
  FLblVolume.Caption := '100%';
  FLblVolume.Font.Name := 'Consolas';
  FLblVolume.Font.Size := 10;
  FLblVolume.Font.Color := CLR_ACCENT;

  Y := Y + 60;

  // Test Voice button
  FBtnTestVoice := TButton.Create(FPanelVoice);
  FBtnTestVoice.Parent := FPanelVoice;
  FBtnTestVoice.Left := 16;
  FBtnTestVoice.Top := Y;
  FBtnTestVoice.Width := 100;
  FBtnTestVoice.Height := 32;
  FBtnTestVoice.Caption := 'Test Voice';
  FBtnTestVoice.OnClick := BtnTestVoiceClick;
end;

procedure TSetupFrame.CreateStationsSection(AParent: TWinControl; ATop, AWidth: Integer);
var
  Lbl: TLabel;
begin
  FPanelStations := TPanel.Create(AParent);
  FPanelStations.Parent := AParent;
  FPanelStations.Left := 0;
  FPanelStations.Top := ATop;
  FPanelStations.Width := AWidth;
  FPanelStations.Height := 380;
  FPanelStations.BevelOuter := bvNone;
  FPanelStations.Color := CLR_BG_CARD;
  FPanelStations.Caption := '';

  Lbl := CreateSectionHeader(FPanelStations, 'STATIONS', 16);
  Lbl.Font.Color := CLR_ACCENT;

  // Add Station button
  FBtnAddStation := TButton.Create(FPanelStations);
  FBtnAddStation.Parent := FPanelStations;
  FBtnAddStation.Left := AWidth - 120;
  FBtnAddStation.Top := 12;
  FBtnAddStation.Width := 100;
  FBtnAddStation.Height := 28;
  FBtnAddStation.Caption := 'Add Station';
  FBtnAddStation.OnClick := BtnAddStationClick;

  // Container for station rows
  FStationsContainer := TPanel.Create(FPanelStations);
  FStationsContainer.Parent := FPanelStations;
  FStationsContainer.Left := 16;
  FStationsContainer.Top := 50;
  FStationsContainer.Width := AWidth - 32;
  FStationsContainer.Height := 310;
  FStationsContainer.BevelOuter := bvNone;
  FStationsContainer.Color := CLR_BG_CARD;
  FStationsContainer.Caption := '';
end;

procedure TSetupFrame.CreateAnnouncementsSection(AParent: TWinControl; ATop, AWidth: Integer);
var
  Lbl: TLabel;
  I, Y: Integer;
  AnnLabels, AnnDefaults: array[0..6] of string;
begin
  AnnLabels[0] := 'Read Start';
  AnnLabels[1] := 'Activity Start';
  AnnLabels[2] := '2-Minute Warning';
  AnnLabels[3] := 'Activity End';
  AnnLabels[4] := '1-Minute Warning';
  AnnLabels[5] := 'Round Complete';
  AnnLabels[6] := 'Changeover';

  AnnDefaults[0] := 'Please read your instructions. You have 1 minute.';
  AnnDefaults[1] := 'Please begin. You have {time} minutes.';
  AnnDefaults[2] := 'Two minutes remaining.';
  AnnDefaults[3] := 'Please stop. Begin feedback.';
  AnnDefaults[4] := 'One minute remaining.';
  AnnDefaults[5] := 'Round complete. Prepare to rotate.';
  AnnDefaults[6] := 'Please move to next station.';

  FPanelAnnouncements := TPanel.Create(AParent);
  FPanelAnnouncements.Parent := AParent;
  FPanelAnnouncements.Left := 0;
  FPanelAnnouncements.Top := ATop;
  FPanelAnnouncements.Width := AWidth;
  FPanelAnnouncements.Height := 300;
  FPanelAnnouncements.BevelOuter := bvNone;
  FPanelAnnouncements.Color := CLR_BG_CARD;
  FPanelAnnouncements.Caption := '';

  Lbl := CreateSectionHeader(FPanelAnnouncements, 'VOICE ANNOUNCEMENTS', 16);
  Lbl.Font.Color := CLR_ACCENT;

  Y := 45;
  for I := 0 to 6 do
  begin
    FAnnEditors[I].Checkbox := TCheckBox.Create(FPanelAnnouncements);
    FAnnEditors[I].Checkbox.Parent := FPanelAnnouncements;
    FAnnEditors[I].Checkbox.Left := 16;
    FAnnEditors[I].Checkbox.Top := Y + 4;
    FAnnEditors[I].Checkbox.Width := 140;
    FAnnEditors[I].Checkbox.Caption := AnnLabels[I];
    FAnnEditors[I].Checkbox.Checked := True;
    FAnnEditors[I].Checkbox.Font.Name := 'Segoe UI';
    FAnnEditors[I].Checkbox.Font.Size := 9;
    FAnnEditors[I].Checkbox.Font.Color := CLR_TEXT_PRIMARY;

    FAnnEditors[I].Edit := TEdit.Create(FPanelAnnouncements);
    FAnnEditors[I].Edit.Parent := FPanelAnnouncements;
    FAnnEditors[I].Edit.Left := 170;
    FAnnEditors[I].Edit.Top := Y;
    FAnnEditors[I].Edit.Width := AWidth - 200;
    FAnnEditors[I].Edit.Height := 26;
    FAnnEditors[I].Edit.Text := AnnDefaults[I];
    FAnnEditors[I].Edit.Color := CLR_BG_ELEVATED;
    FAnnEditors[I].Edit.Font.Name := 'Segoe UI';
    FAnnEditors[I].Edit.Font.Size := 9;
    FAnnEditors[I].Edit.Font.Color := CLR_TEXT_PRIMARY;

    Inc(Y, 34);
  end;
end;

procedure TSetupFrame.CreateActionButtons(AParent: TWinControl; ATop, AWidth: Integer);
begin
  FPanelActions := TPanel.Create(AParent);
  FPanelActions.Parent := AParent;
  FPanelActions.Left := 0;
  FPanelActions.Top := ATop;
  FPanelActions.Width := AWidth;
  FPanelActions.Height := 60;
  FPanelActions.BevelOuter := bvNone;
  FPanelActions.Color := CLR_BG_PRIMARY;
  FPanelActions.Caption := '';

  FBtnStart := TButton.Create(FPanelActions);
  FBtnStart.Parent := FPanelActions;
  FBtnStart.Left := AWidth - 120;
  FBtnStart.Top := 8;
  FBtnStart.Width := 110;
  FBtnStart.Height := 40;
  FBtnStart.Caption := 'Start Exam';
  FBtnStart.Font.Style := [fsBold];
  FBtnStart.OnClick := BtnStartClick;

  FBtnImport := TButton.Create(FPanelActions);
  FBtnImport.Parent := FPanelActions;
  FBtnImport.Left := AWidth - 240;
  FBtnImport.Top := 8;
  FBtnImport.Width := 110;
  FBtnImport.Height := 40;
  FBtnImport.Caption := 'Import File';
  FBtnImport.OnClick := BtnImportClick;

  FBtnExport := TButton.Create(FPanelActions);
  FBtnExport.Parent := FPanelActions;
  FBtnExport.Left := AWidth - 360;
  FBtnExport.Top := 8;
  FBtnExport.Width := 110;
  FBtnExport.Height := 40;
  FBtnExport.Caption := 'Export File';
  FBtnExport.OnClick := BtnExportClick;

  FBtnSave := TButton.Create(FPanelActions);
  FBtnSave.Parent := FPanelActions;
  FBtnSave.Left := AWidth - 480;
  FBtnSave.Top := 8;
  FBtnSave.Width := 110;
  FBtnSave.Height := 40;
  FBtnSave.Caption := 'Save Settings';
  FBtnSave.OnClick := BtnSaveClick;
end;

function TSetupFrame.CreateSectionHeader(AParent: TWinControl; const ATitle: string;
  ATop: Integer): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Left := 16;
  Result.Top := ATop;
  Result.Caption := ATitle;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 10;
  Result.Font.Style := [fsBold];
  Result.Font.Color := CLR_TEXT_SECONDARY;
end;

function TSetupFrame.CreateFormRow(AParent: TWinControl; const ALabel: string;
  ATop, AWidth: Integer): TEdit;
var
  Lbl: TLabel;
begin
  Lbl := TLabel.Create(AParent);
  Lbl.Parent := AParent;
  Lbl.Left := 16;
  Lbl.Top := ATop;
  Lbl.Caption := ALabel;
  Lbl.Font.Name := 'Segoe UI';
  Lbl.Font.Size := 9;
  Lbl.Font.Color := CLR_TEXT_SECONDARY;

  Result := TEdit.Create(AParent);
  Result.Parent := AParent;
  Result.Left := 16;
  Result.Top := ATop + 20;
  Result.Width := AWidth;
  Result.Height := 32;
  Result.Color := CLR_BG_ELEVATED;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 10;
  Result.Font.Color := CLR_TEXT_PRIMARY;
end;

procedure TSetupFrame.RefreshStationsList;
var
  I: Integer;
  Stations: TStationList;
begin
  for I := FStationEditors.Count - 1 downto 0 do
    FStationEditors[I].Free;
  FStationEditors.Clear;

  Stations := StationsManager.GetAll;
  for I := 0 to Stations.Count - 1 do
    CreateStationRow(I, Stations[I]);

  UpdateStationsHeight;
end;

procedure TSetupFrame.CreateStationRow(AIndex: Integer; const AStation: TStation);
var
  Row: TPanel;
  LblNum: TLabel;
  EdtName, EdtActivity, EdtFeedback: TEdit;
  LblActLabel, LblFbkLabel, LblTotalLabel, LblTotal: TLabel;
  BtnDelete: TButton;
  RowWidth: Integer;
begin
  RowWidth := FStationsContainer.Width;

  Row := TPanel.Create(FStationsContainer);
  Row.Parent := FStationsContainer;
  Row.Left := 0;
  Row.Top := AIndex * 58;
  Row.Width := RowWidth;
  Row.Height := 54;
  Row.BevelOuter := bvNone;
  Row.Color := CLR_BG_ELEVATED;
  Row.Caption := '';
  Row.Tag := AStation.ID;

  // Station number
  LblNum := TLabel.Create(Row);
  LblNum.Parent := Row;
  LblNum.Left := 12;
  LblNum.Top := 18;
  LblNum.Width := 30;
  LblNum.Caption := IntToStr(AIndex + 1);
  LblNum.Font.Name := 'Segoe UI';
  LblNum.Font.Size := 12;
  LblNum.Font.Style := [fsBold];
  LblNum.Font.Color := CLR_TEXT_SECONDARY;

  // Station name
  EdtName := TEdit.Create(Row);
  EdtName.Name := 'EdtName';
  EdtName.Parent := Row;
  EdtName.Left := 50;
  EdtName.Top := 12;
  EdtName.Width := RowWidth - 380;
  EdtName.Height := 30;
  EdtName.Text := AStation.Name;
  EdtName.Color := CLR_BG_CARD;
  EdtName.Font.Name := 'Segoe UI';
  EdtName.Font.Size := 10;
  EdtName.Font.Color := CLR_TEXT_PRIMARY;
  EdtName.Tag := AStation.ID;
  EdtName.OnChange := StationFieldChange;

  // Activity label and input
  LblActLabel := TLabel.Create(Row);
  LblActLabel.Parent := Row;
  LblActLabel.Left := RowWidth - 320;
  LblActLabel.Top := 4;
  LblActLabel.Caption := 'ACTIVITY';
  LblActLabel.Font.Name := 'Segoe UI';
  LblActLabel.Font.Size := 7;
  LblActLabel.Font.Color := CLR_TEXT_MUTED;

  EdtActivity := TEdit.Create(Row);
  EdtActivity.Name := 'EdtActivity';
  EdtActivity.Parent := Row;
  EdtActivity.Left := RowWidth - 320;
  EdtActivity.Top := 18;
  EdtActivity.Width := 60;
  EdtActivity.Height := 28;
  EdtActivity.Text := IntToStr(AStation.ActivityTime);
  EdtActivity.Color := CLR_BG_CARD;
  EdtActivity.Font.Name := 'Consolas';
  EdtActivity.Font.Size := 10;
  EdtActivity.Font.Color := CLR_TEXT_PRIMARY;
  EdtActivity.NumbersOnly := True;
  EdtActivity.Tag := AStation.ID;
  EdtActivity.OnChange := StationFieldChange;

  // Feedback label and input
  LblFbkLabel := TLabel.Create(Row);
  LblFbkLabel.Parent := Row;
  LblFbkLabel.Left := RowWidth - 240;
  LblFbkLabel.Top := 4;
  LblFbkLabel.Caption := 'FEEDBACK';
  LblFbkLabel.Font.Name := 'Segoe UI';
  LblFbkLabel.Font.Size := 7;
  LblFbkLabel.Font.Color := CLR_TEXT_MUTED;

  EdtFeedback := TEdit.Create(Row);
  EdtFeedback.Name := 'EdtFeedback';
  EdtFeedback.Parent := Row;
  EdtFeedback.Left := RowWidth - 240;
  EdtFeedback.Top := 18;
  EdtFeedback.Width := 60;
  EdtFeedback.Height := 28;
  EdtFeedback.Text := IntToStr(AStation.FeedbackTime);
  EdtFeedback.Color := CLR_BG_CARD;
  EdtFeedback.Font.Name := 'Consolas';
  EdtFeedback.Font.Size := 10;
  EdtFeedback.Font.Color := CLR_TEXT_PRIMARY;
  EdtFeedback.NumbersOnly := True;
  EdtFeedback.Tag := AStation.ID;
  EdtFeedback.OnChange := StationFieldChange;

  // Total label
  LblTotalLabel := TLabel.Create(Row);
  LblTotalLabel.Parent := Row;
  LblTotalLabel.Left := RowWidth - 160;
  LblTotalLabel.Top := 4;
  LblTotalLabel.Caption := 'TOTAL';
  LblTotalLabel.Font.Name := 'Segoe UI';
  LblTotalLabel.Font.Size := 7;
  LblTotalLabel.Font.Color := CLR_TEXT_MUTED;

  LblTotal := TLabel.Create(Row);
  LblTotal.Name := 'LblTotal';
  LblTotal.Parent := Row;
  LblTotal.Left := RowWidth - 160;
  LblTotal.Top := 20;
  LblTotal.Caption := IntToStr(AStation.TotalTime) + ' min';
  LblTotal.Font.Name := 'Consolas';
  LblTotal.Font.Size := 12;
  LblTotal.Font.Style := [fsBold];
  LblTotal.Font.Color := CLR_ACCENT;

  // Delete button
  BtnDelete := TButton.Create(Row);
  BtnDelete.Parent := Row;
  BtnDelete.Left := RowWidth - 50;
  BtnDelete.Top := 12;
  BtnDelete.Width := 36;
  BtnDelete.Height := 30;
  BtnDelete.Caption := '×';
  BtnDelete.Font.Size := 14;
  BtnDelete.Tag := AStation.ID;
  BtnDelete.OnClick := BtnDeleteStationClick;

  FStationEditors.Add(Row);
end;

procedure TSetupFrame.UpdateStationsHeight;
var
  NewHeight: Integer;
begin
  NewHeight := (FStationEditors.Count * 58) + 10;
  if NewHeight < 200 then NewHeight := 200;
  FStationsContainer.Height := NewHeight;
  FPanelStations.Height := NewHeight + 70;
end;

procedure TSetupFrame.BtnAddStationClick(Sender: TObject);
begin
  StationsManager.Add;
  RefreshStationsList;
end;

procedure TSetupFrame.BtnDeleteStationClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := TButton(Sender).Tag;
  if StationsManager.GetCount <= 1 then
  begin
    ShowMessage('You must have at least one station.');
    Exit;
  end;
  StationsManager.Remove(ID);
  RefreshStationsList;
end;

procedure TSetupFrame.StationFieldChange(Sender: TObject);
var
  Edt: TEdit;
  ID: Integer;
  Row: TPanel;
  EdtName, EdtActivity, EdtFeedback: TEdit;
  LblTotal: TLabel;
  Station: TStation;
begin
  Edt := TEdit(Sender);
  ID := Edt.Tag;
  Row := TPanel(Edt.Parent);

  EdtName := TEdit(Row.FindComponent('EdtName'));
  EdtActivity := TEdit(Row.FindComponent('EdtActivity'));
  EdtFeedback := TEdit(Row.FindComponent('EdtFeedback'));
  LblTotal := TLabel(Row.FindComponent('LblTotal'));

  if (EdtName = nil) or (EdtActivity = nil) or (EdtFeedback = nil) then Exit;

  StationsManager.Update(ID, EdtName.Text,
    StrToIntDef(EdtActivity.Text, 10),
    StrToIntDef(EdtFeedback.Text, 4));

  Station := StationsManager.GetByID(ID);
  if LblTotal <> nil then
    LblTotal.Caption := IntToStr(Station.TotalTime) + ' min';
end;

procedure TSetupFrame.VoiceSelectChange(Sender: TObject);
begin
  if FCboVoice.ItemIndex >= 0 then
    VoiceManager.SetVoiceByIndex(FCboVoice.ItemIndex);
end;

procedure TSetupFrame.RateChange(Sender: TObject);
begin
  VoiceManager.Rate := FTrkRate.Position;
  FLblRate.Caption := Format('%.1fx', [1.0 + (FTrkRate.Position / 10.0)]);
end;

procedure TSetupFrame.VolumeChange(Sender: TObject);
begin
  VoiceManager.Volume := FTrkVolume.Position;
  FLblVolume.Caption := IntToStr(FTrkVolume.Position) + '%';
end;

procedure TSetupFrame.BtnTestVoiceClick(Sender: TObject);
begin
  VoiceManager.Test;
end;

procedure TSetupFrame.BtnSaveClick(Sender: TObject);
begin
  ConfigManager.SaveConfig(GetConfig);
  VoiceManager.Speak('Settings saved.', True);
end;

procedure TSetupFrame.BtnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Filter := 'JSON files (*.json)|*.json';
    Dlg.DefaultExt := 'json';
    Dlg.FileName := 'osce-config-' + FormatDateTime('yyyy-mm-dd', Now) + '.json';
    if Dlg.Execute then
      ConfigManager.ExportConfigToFile(Dlg.FileName, GetConfig);
  finally
    Dlg.Free;
  end;
end;

procedure TSetupFrame.BtnImportClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Filter := 'JSON files (*.json)|*.json';
    if Dlg.Execute then
    begin
      LoadConfig(ConfigManager.ImportConfigFromFile(Dlg.FileName));
      VoiceManager.Speak('Configuration imported.', True);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TSetupFrame.BtnStartClick(Sender: TObject);
begin
  if StationsManager.GetCount = 0 then
  begin
    ShowMessage('Please add at least one station.');
    Exit;
  end;
  if Assigned(FOnStartExam) then
    FOnStartExam(Self);
end;

procedure TSetupFrame.PopulateVoices;
var
  I: Integer;
begin
  FCboVoice.Items.Clear;
  for I := 0 to VoiceManager.GetVoiceCount - 1 do
    FCboVoice.Items.Add(VoiceManager.GetVoiceName(I));
  if FCboVoice.Items.Count > 0 then
    FCboVoice.ItemIndex := 0;
end;

procedure TSetupFrame.LoadConfig(const AConfig: TExamConfig);
begin
  FEdtStartTime.Text := FormatDateTime('hh:nn', AConfig.StartTime);
  FEdtNumCandidates.Text := IntToStr(AConfig.NumCandidates);
  FEdtReadTime.Text := IntToStr(AConfig.ReadTime);
  FEdtChangeoverTime.Text := IntToStr(AConfig.ChangeoverTime);

  FTrkRate.Position := Round((AConfig.VoiceRate - 1.0) * 10);
  FTrkVolume.Position := Round(AConfig.VoiceVolume * 100);

  FAnnEditors[0].Checkbox.Checked := AConfig.Announcements.ReadStartEnabled;
  FAnnEditors[0].Edit.Text := AConfig.Announcements.ReadStart;
  FAnnEditors[1].Checkbox.Checked := AConfig.Announcements.ActivityStartEnabled;
  FAnnEditors[1].Edit.Text := AConfig.Announcements.ActivityStart;
  FAnnEditors[2].Checkbox.Checked := AConfig.Announcements.TwoMinWarningEnabled;
  FAnnEditors[2].Edit.Text := AConfig.Announcements.TwoMinWarning;
  FAnnEditors[3].Checkbox.Checked := AConfig.Announcements.ActivityEndEnabled;
  FAnnEditors[3].Edit.Text := AConfig.Announcements.ActivityEnd;
  FAnnEditors[4].Checkbox.Checked := AConfig.Announcements.OneMinWarningEnabled;
  FAnnEditors[4].Edit.Text := AConfig.Announcements.OneMinWarning;
  FAnnEditors[5].Checkbox.Checked := AConfig.Announcements.StationEndEnabled;
  FAnnEditors[5].Edit.Text := AConfig.Announcements.StationEnd;
  FAnnEditors[6].Checkbox.Checked := AConfig.Announcements.ChangeoverEnabled;
  FAnnEditors[6].Edit.Text := AConfig.Announcements.Changeover;
end;

function TSetupFrame.GetConfig: TExamConfig;
var
  HI, MI: Integer;
  TimeStr: string;
begin
  Result.SetDefaults;

  TimeStr := FEdtStartTime.Text;
  if (Length(TimeStr) >= 5) and TryStrToInt(Copy(TimeStr, 1, 2), HI) and
     TryStrToInt(Copy(TimeStr, 4, 2), MI) then
    Result.StartTime := EncodeTime(Word(HI), Word(MI), 0, 0);

  Result.NumCandidates := StrToIntDef(FEdtNumCandidates.Text, 5);
  Result.ReadTime := StrToIntDef(FEdtReadTime.Text, 60);
  Result.ChangeoverTime := StrToIntDef(FEdtChangeoverTime.Text, 60);

  Result.VoiceRate := 1.0 + (FTrkRate.Position / 10.0);
  Result.VoiceVolume := FTrkVolume.Position / 100.0;
  if FCboVoice.ItemIndex >= 0 then
    Result.SelectedVoice := FCboVoice.Items[FCboVoice.ItemIndex];

  Result.Announcements.ReadStartEnabled := FAnnEditors[0].Checkbox.Checked;
  Result.Announcements.ReadStart := FAnnEditors[0].Edit.Text;
  Result.Announcements.ActivityStartEnabled := FAnnEditors[1].Checkbox.Checked;
  Result.Announcements.ActivityStart := FAnnEditors[1].Edit.Text;
  Result.Announcements.TwoMinWarningEnabled := FAnnEditors[2].Checkbox.Checked;
  Result.Announcements.TwoMinWarning := FAnnEditors[2].Edit.Text;
  Result.Announcements.ActivityEndEnabled := FAnnEditors[3].Checkbox.Checked;
  Result.Announcements.ActivityEnd := FAnnEditors[3].Edit.Text;
  Result.Announcements.OneMinWarningEnabled := FAnnEditors[4].Checkbox.Checked;
  Result.Announcements.OneMinWarning := FAnnEditors[4].Edit.Text;
  Result.Announcements.StationEndEnabled := FAnnEditors[5].Checkbox.Checked;
  Result.Announcements.StationEnd := FAnnEditors[5].Edit.Text;
  Result.Announcements.ChangeoverEnabled := FAnnEditors[6].Checkbox.Checked;
  Result.Announcements.Changeover := FAnnEditors[6].Edit.Text;
end;

end.
