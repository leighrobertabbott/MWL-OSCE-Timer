unit uConfigFMX;

{*******************************************************************************
  OSCE Timing System - Configuration Persistence (FMX Version)
  Settings storage and crash recovery
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.IniFiles,
  System.IOUtils, uTypesFMX;

type
  TConfigManager = class
  private
    FConfigPath: string;
    FStatePath: string;

    function GetConfigFilePath: string;
    function GetStateFilePath: string;
  public
    constructor Create;

    // Configuration
    procedure SaveConfig(const AConfig: TExamConfig);
    function LoadConfig: TExamConfig;
    procedure ExportConfigToFile(const AFilePath: string; const AConfig: TExamConfig);
    function ImportConfigFromFile(const AFilePath: string): TExamConfig;

    // Crash recovery state
    procedure SaveActiveState(const AJSON: string);
    function LoadActiveState: string;
    procedure ClearActiveState;
    function HasActiveState: Boolean;
  end;

var
  ConfigManager: TConfigManager;

implementation

{ TConfigManager }

constructor TConfigManager.Create;
var
  AppDataPath: string;
begin
  inherited Create;

  // Use AppData\Local for config storage
  AppDataPath := TPath.Combine(TPath.GetHomePath, 'OSCETimer');
  if not TDirectory.Exists(AppDataPath) then
    TDirectory.CreateDirectory(AppDataPath);

  FConfigPath := TPath.Combine(AppDataPath, 'config.ini');
  FStatePath := TPath.Combine(AppDataPath, 'active_state.json');
end;

function TConfigManager.GetConfigFilePath: string;
begin
  Result := FConfigPath;
end;

function TConfigManager.GetStateFilePath: string;
begin
  Result := FStatePath;
end;

procedure TConfigManager.SaveConfig(const AConfig: TExamConfig);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FConfigPath);
  try
    // General
    Ini.WriteTime('General', 'StartTime', AConfig.StartTime);
    Ini.WriteInteger('General', 'NumCandidates', AConfig.NumCandidates);
    Ini.WriteInteger('General', 'ReadTime', AConfig.ReadTime);
    Ini.WriteInteger('General', 'ChangeoverTime', AConfig.ChangeoverTime);

    // Voice
    Ini.WriteFloat('Voice', 'Rate', AConfig.VoiceRate);
    Ini.WriteFloat('Voice', 'Volume', AConfig.VoiceVolume);
    Ini.WriteString('Voice', 'SelectedVoice', AConfig.SelectedVoice);

    // Announcements
    Ini.WriteString('Announcements', 'ReadStart', AConfig.Announcements.ReadStart);
    Ini.WriteBool('Announcements', 'ReadStartEnabled', AConfig.Announcements.ReadStartEnabled);
    Ini.WriteString('Announcements', 'ActivityStart', AConfig.Announcements.ActivityStart);
    Ini.WriteBool('Announcements', 'ActivityStartEnabled', AConfig.Announcements.ActivityStartEnabled);
    Ini.WriteString('Announcements', 'TwoMinWarning', AConfig.Announcements.TwoMinWarning);
    Ini.WriteBool('Announcements', 'TwoMinWarningEnabled', AConfig.Announcements.TwoMinWarningEnabled);
    Ini.WriteString('Announcements', 'ActivityEnd', AConfig.Announcements.ActivityEnd);
    Ini.WriteBool('Announcements', 'ActivityEndEnabled', AConfig.Announcements.ActivityEndEnabled);
    Ini.WriteString('Announcements', 'OneMinWarning', AConfig.Announcements.OneMinWarning);
    Ini.WriteBool('Announcements', 'OneMinWarningEnabled', AConfig.Announcements.OneMinWarningEnabled);
    Ini.WriteString('Announcements', 'StationEnd', AConfig.Announcements.StationEnd);
    Ini.WriteBool('Announcements', 'StationEndEnabled', AConfig.Announcements.StationEndEnabled);
    Ini.WriteString('Announcements', 'Changeover', AConfig.Announcements.Changeover);
    Ini.WriteBool('Announcements', 'ChangeoverEnabled', AConfig.Announcements.ChangeoverEnabled);
  finally
    Ini.Free;
  end;
end;

function TConfigManager.LoadConfig: TExamConfig;
var
  Ini: TIniFile;
begin
  Result.SetDefaults;

  if not TFile.Exists(FConfigPath) then Exit;

  Ini := TIniFile.Create(FConfigPath);
  try
    // General
    Result.StartTime := Ini.ReadTime('General', 'StartTime', Result.StartTime);
    Result.NumCandidates := Ini.ReadInteger('General', 'NumCandidates', Result.NumCandidates);
    Result.ReadTime := Ini.ReadInteger('General', 'ReadTime', Result.ReadTime);
    Result.ChangeoverTime := Ini.ReadInteger('General', 'ChangeoverTime', Result.ChangeoverTime);

    // Voice
    Result.VoiceRate := Ini.ReadFloat('Voice', 'Rate', Result.VoiceRate);
    Result.VoiceVolume := Ini.ReadFloat('Voice', 'Volume', Result.VoiceVolume);
    Result.SelectedVoice := Ini.ReadString('Voice', 'SelectedVoice', Result.SelectedVoice);

    // Announcements
    Result.Announcements.ReadStart := Ini.ReadString('Announcements', 'ReadStart', Result.Announcements.ReadStart);
    Result.Announcements.ReadStartEnabled := Ini.ReadBool('Announcements', 'ReadStartEnabled', True);
    Result.Announcements.ActivityStart := Ini.ReadString('Announcements', 'ActivityStart', Result.Announcements.ActivityStart);
    Result.Announcements.ActivityStartEnabled := Ini.ReadBool('Announcements', 'ActivityStartEnabled', True);
    Result.Announcements.TwoMinWarning := Ini.ReadString('Announcements', 'TwoMinWarning', Result.Announcements.TwoMinWarning);
    Result.Announcements.TwoMinWarningEnabled := Ini.ReadBool('Announcements', 'TwoMinWarningEnabled', True);
    Result.Announcements.ActivityEnd := Ini.ReadString('Announcements', 'ActivityEnd', Result.Announcements.ActivityEnd);
    Result.Announcements.ActivityEndEnabled := Ini.ReadBool('Announcements', 'ActivityEndEnabled', True);
    Result.Announcements.OneMinWarning := Ini.ReadString('Announcements', 'OneMinWarning', Result.Announcements.OneMinWarning);
    Result.Announcements.OneMinWarningEnabled := Ini.ReadBool('Announcements', 'OneMinWarningEnabled', True);
    Result.Announcements.StationEnd := Ini.ReadString('Announcements', 'StationEnd', Result.Announcements.StationEnd);
    Result.Announcements.StationEndEnabled := Ini.ReadBool('Announcements', 'StationEndEnabled', True);
    Result.Announcements.Changeover := Ini.ReadString('Announcements', 'Changeover', Result.Announcements.Changeover);
    Result.Announcements.ChangeoverEnabled := Ini.ReadBool('Announcements', 'ChangeoverEnabled', True);
  finally
    Ini.Free;
  end;
end;

procedure TConfigManager.ExportConfigToFile(const AFilePath: string;
  const AConfig: TExamConfig);
var
  JRoot, JAnn: TJSONObject;
begin
  JRoot := TJSONObject.Create;
  try
    JRoot.AddPair('startTime', FormatDateTime('hh:nn', AConfig.StartTime));
    JRoot.AddPair('numCandidates', TJSONNumber.Create(AConfig.NumCandidates));
    JRoot.AddPair('readTime', TJSONNumber.Create(AConfig.ReadTime));
    JRoot.AddPair('changeoverTime', TJSONNumber.Create(AConfig.ChangeoverTime));
    JRoot.AddPair('voiceRate', TJSONNumber.Create(AConfig.VoiceRate));
    JRoot.AddPair('voiceVolume', TJSONNumber.Create(AConfig.VoiceVolume));
    JRoot.AddPair('selectedVoice', AConfig.SelectedVoice);

    JAnn := TJSONObject.Create;
    JAnn.AddPair('readStart', AConfig.Announcements.ReadStart);
    JAnn.AddPair('activityStart', AConfig.Announcements.ActivityStart);
    JAnn.AddPair('twoMinWarning', AConfig.Announcements.TwoMinWarning);
    JAnn.AddPair('activityEnd', AConfig.Announcements.ActivityEnd);
    JAnn.AddPair('oneMinWarning', AConfig.Announcements.OneMinWarning);
    JAnn.AddPair('stationEnd', AConfig.Announcements.StationEnd);
    JAnn.AddPair('changeover', AConfig.Announcements.Changeover);
    JRoot.AddPair('announcements', JAnn);

    TFile.WriteAllText(AFilePath, JRoot.Format(2));
  finally
    JRoot.Free;
  end;
end;

function TConfigManager.ImportConfigFromFile(const AFilePath: string): TExamConfig;
var
  JSON: string;
  JRoot, JAnn: TJSONObject;
  TimeStr: string;
  HI, MI: Integer;
begin
  Result.SetDefaults;

  if not TFile.Exists(AFilePath) then Exit;

  try
    JSON := TFile.ReadAllText(AFilePath);
    JRoot := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
    if JRoot = nil then Exit;

    try
      TimeStr := JRoot.GetValue<string>('startTime');
      if TryStrToInt(Copy(TimeStr, 1, 2), HI) and TryStrToInt(Copy(TimeStr, 4, 2), MI) then
        Result.StartTime := EncodeTime(Word(HI), Word(MI), 0, 0);

      Result.NumCandidates := JRoot.GetValue<Integer>('numCandidates');
      Result.ReadTime := JRoot.GetValue<Integer>('readTime');
      Result.ChangeoverTime := JRoot.GetValue<Integer>('changeoverTime');
      Result.VoiceRate := JRoot.GetValue<Double>('voiceRate');
      Result.VoiceVolume := JRoot.GetValue<Double>('voiceVolume');
      Result.SelectedVoice := JRoot.GetValue<string>('selectedVoice');

      if JRoot.TryGetValue<TJSONObject>('announcements', JAnn) then
      begin
        Result.Announcements.ReadStart := JAnn.GetValue<string>('readStart');
        Result.Announcements.ActivityStart := JAnn.GetValue<string>('activityStart');
        Result.Announcements.TwoMinWarning := JAnn.GetValue<string>('twoMinWarning');
        Result.Announcements.ActivityEnd := JAnn.GetValue<string>('activityEnd');
        Result.Announcements.OneMinWarning := JAnn.GetValue<string>('oneMinWarning');
        Result.Announcements.StationEnd := JAnn.GetValue<string>('stationEnd');
        Result.Announcements.Changeover := JAnn.GetValue<string>('changeover');
      end;
    finally
      JRoot.Free;
    end;
  except
    // Return defaults on error
  end;
end;

procedure TConfigManager.SaveActiveState(const AJSON: string);
begin
  TFile.WriteAllText(FStatePath, AJSON);
end;

function TConfigManager.LoadActiveState: string;
begin
  if TFile.Exists(FStatePath) then
    Result := TFile.ReadAllText(FStatePath)
  else
    Result := '';
end;

procedure TConfigManager.ClearActiveState;
begin
  if TFile.Exists(FStatePath) then
    TFile.Delete(FStatePath);
end;

function TConfigManager.HasActiveState: Boolean;
begin
  Result := TFile.Exists(FStatePath);
end;

initialization
  ConfigManager := TConfigManager.Create;

finalization
  ConfigManager.Free;

end.
