unit uVoice;

{*******************************************************************************
  OSCE Timing System - Voice Synthesis Module
  Microsoft SAPI integration for text-to-speech
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Variants,
  Winapi.Windows, Winapi.ActiveX, Winapi.MMSystem, System.Win.ComObj;

type
  TVoiceInfo = record
    Name: string;
    Language: string;
  end;

  TVoiceManager = class
  private
    FVoice: OleVariant;
    FVoices: TList<TVoiceInfo>;
    FSelectedVoiceIndex: Integer;
    FRate: Integer;        // -10 to 10
    FVolume: Integer;      // 0 to 100
    FIsMuted: Boolean;
    FSpeakQueue: TStringList;
    FIsSpeaking: Boolean;

    procedure LoadVoices;
    procedure ProcessQueue;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Speak(const AText: string; APriority: Boolean = False);
    procedure Cancel;
    procedure Test;

    // Audio beeps
    procedure PlayBeep(AFrequency: Integer = 800; ADuration: Integer = 200);
    procedure PlayAttentionBeeps;
    procedure PlayWarningBeeps;
    procedure PlayTick;
    procedure PlayComplete;
    procedure PlayStartBeep;
    procedure PlayEndBeep;

    // Voice selection
    function GetVoiceCount: Integer;
    function GetVoiceName(AIndex: Integer): string;
    procedure SetVoiceByIndex(AIndex: Integer);
    procedure SetVoiceByName(const AName: string);

    // Properties
    property Rate: Integer read FRate write FRate;
    property Volume: Integer read FVolume write FVolume;
    property IsMuted: Boolean read FIsMuted write FIsMuted;
    property Voices: TList<TVoiceInfo> read FVoices;
    property SelectedVoiceIndex: Integer read FSelectedVoiceIndex;
  end;

var
  VoiceManager: TVoiceManager;

implementation

{ TVoiceManager }

constructor TVoiceManager.Create;
begin
  inherited Create;
  FVoices := TList<TVoiceInfo>.Create;
  FSpeakQueue := TStringList.Create;
  FRate := 0;
  FVolume := 100;
  FIsMuted := False;
  FIsSpeaking := False;
  FSelectedVoiceIndex := -1;

  try
    CoInitialize(nil);
    FVoice := CreateOleObject('SAPI.SpVoice');
    LoadVoices;
  except
    on E: Exception do
      // SAPI not available - silent fail
      FVoice := Unassigned;
  end;
end;

destructor TVoiceManager.Destroy;
begin
  Cancel;
  FSpeakQueue.Free;
  FVoices.Free;

  if not VarIsEmpty(FVoice) then
    FVoice := Unassigned;

  CoUninitialize;
  inherited;
end;

procedure TVoiceManager.LoadVoices;
var
  VoicesCollection: OleVariant;
  VoiceItem: OleVariant;
  I, Count: Integer;
  Info: TVoiceInfo;
  Desc: string;
begin
  FVoices.Clear;

  if VarIsEmpty(FVoice) then Exit;

  try
    VoicesCollection := FVoice.GetVoices;
    Count := VoicesCollection.Count;

    for I := 0 to Count - 1 do
    begin
      VoiceItem := VoicesCollection.Item(I);
      Desc := VoiceItem.GetDescription;

      Info.Name := Desc;
      // Try to extract language from description
      if Pos('English', Desc) > 0 then
        Info.Language := 'en'
      else
        Info.Language := '';

      FVoices.Add(Info);
    end;

    // Select first English voice as default
    for I := 0 to FVoices.Count - 1 do
    begin
      if FVoices[I].Language = 'en' then
      begin
        SetVoiceByIndex(I);
        Break;
      end;
    end;

    // Fallback to first voice
    if (FSelectedVoiceIndex < 0) and (FVoices.Count > 0) then
      SetVoiceByIndex(0);

  except
    // Ignore errors during voice loading
  end;
end;

function TVoiceManager.GetVoiceCount: Integer;
begin
  Result := FVoices.Count;
end;

function TVoiceManager.GetVoiceName(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < FVoices.Count) then
    Result := FVoices[AIndex].Name
  else
    Result := '';
end;

procedure TVoiceManager.SetVoiceByIndex(AIndex: Integer);
var
  VoicesCollection: OleVariant;
begin
  if VarIsEmpty(FVoice) then Exit;
  if (AIndex < 0) or (AIndex >= FVoices.Count) then Exit;

  try
    VoicesCollection := FVoice.GetVoices;
    FVoice.Voice := VoicesCollection.Item(AIndex);
    FSelectedVoiceIndex := AIndex;
  except
    // Ignore
  end;
end;

procedure TVoiceManager.SetVoiceByName(const AName: string);
var
  I: Integer;
begin
  for I := 0 to FVoices.Count - 1 do
  begin
    if SameText(FVoices[I].Name, AName) then
    begin
      SetVoiceByIndex(I);
      Exit;
    end;
  end;
end;

procedure TVoiceManager.Speak(const AText: string; APriority: Boolean);
begin
  if FIsMuted then Exit;
  if VarIsEmpty(FVoice) then Exit;

  if APriority then
    Cancel;

  FSpeakQueue.Add(AText);
  ProcessQueue;
end;

procedure TVoiceManager.ProcessQueue;
var
  Text: string;
begin
  if FIsSpeaking then Exit;
  if FSpeakQueue.Count = 0 then Exit;

  Text := FSpeakQueue[0];
  FSpeakQueue.Delete(0);

  FIsSpeaking := True;
  try
    FVoice.Rate := FRate;
    FVoice.Volume := FVolume;
    // Speak asynchronously (SVSFlagsAsync = 1)
    FVoice.Speak(Text, 1);
  except
    // Ignore speech errors
  end;
  FIsSpeaking := False;

  // Process next item
  if FSpeakQueue.Count > 0 then
    ProcessQueue;
end;

procedure TVoiceManager.Cancel;
begin
  FSpeakQueue.Clear;
  FIsSpeaking := False;

  if not VarIsEmpty(FVoice) then
  begin
    try
      // SVSFPurgeBeforeSpeak = 2
      FVoice.Speak('', 2);
    except
      // Ignore
    end;
  end;
end;

procedure TVoiceManager.Test;
begin
  Speak('This is a test of the voice announcement system. The timer is ready.', True);
end;

procedure TVoiceManager.PlayBeep(AFrequency, ADuration: Integer);
begin
  if FIsMuted then Exit;

  // Use Windows Beep function (runs in separate thread)
  TThread.CreateAnonymousThread(
    procedure
    begin
      Winapi.Windows.Beep(AFrequency, ADuration);
    end
  ).Start;
end;

procedure TVoiceManager.PlayAttentionBeeps;
begin
  if FIsMuted then Exit;

  TThread.CreateAnonymousThread(
    procedure
    begin
      Winapi.Windows.Beep(600, 150);
      Sleep(50);
      Winapi.Windows.Beep(800, 150);
      Sleep(50);
      Winapi.Windows.Beep(1000, 300);
    end
  ).Start;
end;

procedure TVoiceManager.PlayWarningBeeps;
begin
  if FIsMuted then Exit;

  TThread.CreateAnonymousThread(
    procedure
    begin
      Winapi.Windows.Beep(800, 200);
      Sleep(50);
      Winapi.Windows.Beep(600, 200);
      Sleep(50);
      Winapi.Windows.Beep(400, 300);
    end
  ).Start;
end;

procedure TVoiceManager.PlayTick;
begin
  if FIsMuted then Exit;
  PlayBeep(1200, 50);
end;

procedure TVoiceManager.PlayComplete;
begin
  if FIsMuted then Exit;

  TThread.CreateAnonymousThread(
    procedure
    begin
      Winapi.Windows.Beep(523, 150);  // C5
      Sleep(50);
      Winapi.Windows.Beep(659, 150);  // E5
      Sleep(50);
      Winapi.Windows.Beep(784, 300);  // G5
    end
  ).Start;
end;

procedure TVoiceManager.PlayStartBeep;
begin
  if FIsMuted then Exit;
  PlayBeep(800, 300);
end;

procedure TVoiceManager.PlayEndBeep;
begin
  if FIsMuted then Exit;
  PlayBeep(400, 400);
end;

initialization
  VoiceManager := TVoiceManager.Create;

finalization
  VoiceManager.Free;

end.
