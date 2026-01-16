unit uStations;

{*******************************************************************************
  OSCE Timing System - Stations Management
  Station CRUD operations and data management
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  Vcl.Graphics, uTypes;

type
  TStationsManager = class
  private
    FStations: TStationList;
    FNextID: Integer;

    function GetRandomColor: TColor;
  public
    constructor Create;
    destructor Destroy; override;

    // CRUD operations
    function Add(const AName: string = 'New Station';
      AActivityTime: Integer = 10; AFeedbackTime: Integer = 4): TStation;
    function Update(AID: Integer; const AName: string;
      AActivityTime, AFeedbackTime: Integer): Boolean;
    function Remove(AID: Integer): Boolean;
    procedure Reorder(AFromIndex, AToIndex: Integer);
    procedure Reset;

    // Getters
    function GetAll: TStationList;
    function GetByIndex(AIndex: Integer): TStation;
    function GetByID(AID: Integer): TStation;
    function GetCount: Integer;

    // Time calculations
    function GetActivitySeconds(AIndex: Integer): Integer;
    function GetFeedbackSeconds(AIndex: Integer): Integer;
    function GetTotalSeconds(AIndex: Integer): Integer;
    function GetMaxActivityTime: Integer;  // in minutes
    function GetMaxTotalTime: Integer;     // in minutes
    function GetTotalExamTime(AChangeoverSeconds, ANumCandidates: Integer): Integer;

    // Serialization
    function ExportToJSON: string;
    procedure ImportFromJSON(const AJSON: string);

    property Stations: TStationList read FStations;
  end;

var
  StationsManager: TStationsManager;

implementation

{ TStationsManager }

constructor TStationsManager.Create;
var
  S: TStation;
begin
  inherited Create;
  FStations := TStationList.Create;
  FNextID := 1;

  // Initialize with default stations
  Reset;
end;

destructor TStationsManager.Destroy;
begin
  FStations.Free;
  inherited;
end;

procedure TStationsManager.Reset;
var
  S: TStation;
begin
  FStations.Clear;
  FNextID := 1;

  // Station 1: History Taking
  S.ID := FNextID; Inc(FNextID);
  S.Name := 'History Taking';
  S.ActivityTime := 10;
  S.FeedbackTime := 4;
  S.Color := DEFAULT_STATION_COLORS[0];
  FStations.Add(S);

  // Station 2: Manual BP
  S.ID := FNextID; Inc(FNextID);
  S.Name := 'Manual BP';
  S.ActivityTime := 8;
  S.FeedbackTime := 6;
  S.Color := DEFAULT_STATION_COLORS[1];
  FStations.Add(S);

  // Station 3: Capillary Blood Glucose
  S.ID := FNextID; Inc(FNextID);
  S.Name := 'Capillary Blood Glucose';
  S.ActivityTime := 9;
  S.FeedbackTime := 5;
  S.Color := DEFAULT_STATION_COLORS[2];
  FStations.Add(S);

  // Station 4: Observations & Handwashing
  S.ID := FNextID; Inc(FNextID);
  S.Name := 'Observations & Handwashing';
  S.ActivityTime := 9;
  S.FeedbackTime := 5;
  S.Color := DEFAULT_STATION_COLORS[3];
  FStations.Add(S);

  // Station 5: Urinalysis & Peak Flow
  S.ID := FNextID; Inc(FNextID);
  S.Name := 'Urinalysis & Peak Flow';
  S.ActivityTime := 10;
  S.FeedbackTime := 4;
  S.Color := DEFAULT_STATION_COLORS[4];
  FStations.Add(S);
end;

function TStationsManager.Add(const AName: string;
  AActivityTime, AFeedbackTime: Integer): TStation;
var
  S: TStation;
begin
  S.ID := FNextID;
  Inc(FNextID);
  S.Name := AName;
  S.ActivityTime := AActivityTime;
  S.FeedbackTime := AFeedbackTime;
  S.Color := GetRandomColor;

  FStations.Add(S);
  Result := S;
end;

function TStationsManager.Update(AID: Integer; const AName: string;
  AActivityTime, AFeedbackTime: Integer): Boolean;
var
  I: Integer;
  S: TStation;
begin
  Result := False;
  for I := 0 to FStations.Count - 1 do
  begin
    if FStations[I].ID = AID then
    begin
      S := FStations[I];
      S.Name := AName;
      S.ActivityTime := AActivityTime;
      S.FeedbackTime := AFeedbackTime;
      FStations[I] := S;
      Result := True;
      Exit;
    end;
  end;
end;

function TStationsManager.Remove(AID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FStations.Count - 1 do
  begin
    if FStations[I].ID = AID then
    begin
      FStations.Delete(I);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TStationsManager.Reorder(AFromIndex, AToIndex: Integer);
var
  S: TStation;
begin
  if (AFromIndex < 0) or (AFromIndex >= FStations.Count) then Exit;
  if (AToIndex < 0) or (AToIndex >= FStations.Count) then Exit;

  S := FStations[AFromIndex];
  FStations.Delete(AFromIndex);
  FStations.Insert(AToIndex, S);
end;

function TStationsManager.GetAll: TStationList;
begin
  Result := FStations;
end;

function TStationsManager.GetByIndex(AIndex: Integer): TStation;
begin
  if (AIndex >= 0) and (AIndex < FStations.Count) then
    Result := FStations[AIndex]
  else
  begin
    Result.ID := -1;
    Result.Name := '';
    Result.ActivityTime := 0;
    Result.FeedbackTime := 0;
  end;
end;

function TStationsManager.GetByID(AID: Integer): TStation;
var
  I: Integer;
begin
  for I := 0 to FStations.Count - 1 do
  begin
    if FStations[I].ID = AID then
    begin
      Result := FStations[I];
      Exit;
    end;
  end;

  Result.ID := -1;
  Result.Name := '';
end;

function TStationsManager.GetCount: Integer;
begin
  Result := FStations.Count;
end;

function TStationsManager.GetActivitySeconds(AIndex: Integer): Integer;
var
  S: TStation;
begin
  S := GetByIndex(AIndex);
  if S.ID >= 0 then
    Result := S.ActivityTime * 60
  else
    Result := 0;
end;

function TStationsManager.GetFeedbackSeconds(AIndex: Integer): Integer;
var
  S: TStation;
begin
  S := GetByIndex(AIndex);
  if S.ID >= 0 then
    Result := S.FeedbackTime * 60
  else
    Result := 0;
end;

function TStationsManager.GetTotalSeconds(AIndex: Integer): Integer;
var
  S: TStation;
begin
  S := GetByIndex(AIndex);
  if S.ID >= 0 then
    Result := S.TotalTime * 60
  else
    Result := 0;
end;

function TStationsManager.GetMaxActivityTime: Integer;
var
  I, Max: Integer;
begin
  Max := 0;
  for I := 0 to FStations.Count - 1 do
  begin
    if FStations[I].ActivityTime > Max then
      Max := FStations[I].ActivityTime;
  end;
  Result := Max;
end;

function TStationsManager.GetMaxTotalTime: Integer;
var
  I, Max: Integer;
begin
  Max := 0;
  for I := 0 to FStations.Count - 1 do
  begin
    if FStations[I].TotalTime > Max then
      Max := FStations[I].TotalTime;
  end;
  Result := Max;
end;

function TStationsManager.GetTotalExamTime(AChangeoverSeconds,
  ANumCandidates: Integer): Integer;
var
  I, StationMins, ChangeoverMins: Integer;
begin
  StationMins := 0;
  for I := 0 to FStations.Count - 1 do
    Inc(StationMins, FStations[I].TotalTime);

  ChangeoverMins := (FStations.Count - 1) * (AChangeoverSeconds div 60);
  Result := (StationMins + ChangeoverMins) * ANumCandidates;
end;

function TStationsManager.ExportToJSON: string;
var
  JArr: TJSONArray;
  JObj, JRoot: TJSONObject;
  I: Integer;
  S: TStation;
begin
  JRoot := TJSONObject.Create;
  JArr := TJSONArray.Create;

  try
    for I := 0 to FStations.Count - 1 do
    begin
      S := FStations[I];
      JObj := TJSONObject.Create;
      JObj.AddPair('id', TJSONNumber.Create(S.ID));
      JObj.AddPair('name', S.Name);
      JObj.AddPair('activityTime', TJSONNumber.Create(S.ActivityTime));
      JObj.AddPair('feedbackTime', TJSONNumber.Create(S.FeedbackTime));
      JObj.AddPair('color', IntToStr(S.Color));
      JArr.AddElement(JObj);
    end;

    JRoot.AddPair('stations', JArr);
    JRoot.AddPair('nextId', TJSONNumber.Create(FNextID));

    Result := JRoot.ToJSON;
  finally
    JRoot.Free;
  end;
end;

procedure TStationsManager.ImportFromJSON(const AJSON: string);
var
  JRoot, JObj: TJSONObject;
  JArr: TJSONArray;
  I: Integer;
  S: TStation;
begin
  FStations.Clear;

  try
    JRoot := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
    if JRoot = nil then Exit;

    try
      JArr := JRoot.GetValue<TJSONArray>('stations');
      if JArr = nil then Exit;

      for I := 0 to JArr.Count - 1 do
      begin
        JObj := JArr.Items[I] as TJSONObject;
        S.ID := JObj.GetValue<Integer>('id');
        S.Name := JObj.GetValue<string>('name');
        S.ActivityTime := JObj.GetValue<Integer>('activityTime');
        S.FeedbackTime := JObj.GetValue<Integer>('feedbackTime');
        S.Color := StrToIntDef(JObj.GetValue<string>('color'), DEFAULT_STATION_COLORS[I mod 8]);
        FStations.Add(S);
      end;

      FNextID := JRoot.GetValue<Integer>('nextId');
    finally
      JRoot.Free;
    end;
  except
    // On parse error, keep existing data
  end;
end;

function TStationsManager.GetRandomColor: TColor;
begin
  Result := DEFAULT_STATION_COLORS[Random(Length(DEFAULT_STATION_COLORS))];
end;

initialization
  Randomize;
  StationsManager := TStationsManager.Create;

finalization
  StationsManager.Free;

end.
