unit uStationsFMX;

{*******************************************************************************
  OSCE Timing System - Stations Management (FMX Version)
  Station CRUD operations and data management
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.UITypes, System.Math,
  System.Generics.Collections, uTypesFMX;

type
  TStationsManager = class
  private
    FStations: TStationList;
    FNextID: Integer;

    function GetRandomColor: TAlphaColor;
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
begin
  inherited Create;
  FStations := TStationList.Create;
  FNextID := 1;
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

function TStationsManager.GetRandomColor: TAlphaColor;
begin
  Result := DEFAULT_STATION_COLORS[Random(Length(DEFAULT_STATION_COLORS))];
end;

function TStationsManager.Add(const AName: string; AActivityTime,
  AFeedbackTime: Integer): TStation;
begin
  Result.ID := FNextID;
  Inc(FNextID);
  Result.Name := AName;
  Result.ActivityTime := AActivityTime;
  Result.FeedbackTime := AFeedbackTime;
  Result.Color := GetRandomColor;
  FStations.Add(Result);
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
      Break;
    end;
  end;
end;

function TStationsManager.Remove(AID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := FStations.Count - 1 downto 0 do
  begin
    if FStations[I].ID = AID then
    begin
      FStations.Delete(I);
      Result := True;
      Break;
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
    Result.Color := 0;
  end;
end;

function TStationsManager.GetByID(AID: Integer): TStation;
var
  I: Integer;
begin
  Result.ID := -1;
  for I := 0 to FStations.Count - 1 do
  begin
    if FStations[I].ID = AID then
    begin
      Result := FStations[I];
      Break;
    end;
  end;
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
  Result := S.ActivityTime * 60;
end;

function TStationsManager.GetFeedbackSeconds(AIndex: Integer): Integer;
var
  S: TStation;
begin
  S := GetByIndex(AIndex);
  Result := S.FeedbackTime * 60;
end;

function TStationsManager.GetTotalSeconds(AIndex: Integer): Integer;
var
  S: TStation;
begin
  S := GetByIndex(AIndex);
  Result := S.TotalTime * 60;
end;

function TStationsManager.GetMaxActivityTime: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FStations.Count - 1 do
    if FStations[I].ActivityTime > Result then
      Result := FStations[I].ActivityTime;
end;

function TStationsManager.GetMaxTotalTime: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FStations.Count - 1 do
    if FStations[I].TotalTime > Result then
      Result := FStations[I].TotalTime;
end;

function TStationsManager.GetTotalExamTime(AChangeoverSeconds,
  ANumCandidates: Integer): Integer;
var
  MaxTime: Integer;
begin
  MaxTime := GetMaxTotalTime * 60;
  Result := (MaxTime * FStations.Count) + (AChangeoverSeconds * (FStations.Count - 1));
  Result := Result * Ceil(ANumCandidates / FStations.Count);
end;

function TStationsManager.ExportToJSON: string;
var
  JArray: TJSONArray;
  JObj: TJSONObject;
  S: TStation;
begin
  JArray := TJSONArray.Create;
  try
    for S in FStations do
    begin
      JObj := TJSONObject.Create;
      JObj.AddPair('id', TJSONNumber.Create(S.ID));
      JObj.AddPair('name', S.Name);
      JObj.AddPair('activityTime', TJSONNumber.Create(S.ActivityTime));
      JObj.AddPair('feedbackTime', TJSONNumber.Create(S.FeedbackTime));
      JObj.AddPair('color', TJSONNumber.Create(Integer(S.Color)));
      JArray.AddElement(JObj);
    end;
    Result := JArray.ToJSON;
  finally
    JArray.Free;
  end;
end;

procedure TStationsManager.ImportFromJSON(const AJSON: string);
var
  JArray: TJSONArray;
  JObj: TJSONObject;
  I: Integer;
  S: TStation;
begin
  FStations.Clear;
  FNextID := 1;

  JArray := TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  if JArray = nil then Exit;

  try
    for I := 0 to JArray.Count - 1 do
    begin
      JObj := JArray.Items[I] as TJSONObject;
      S.ID := JObj.GetValue<Integer>('id');
      S.Name := JObj.GetValue<string>('name');
      S.ActivityTime := JObj.GetValue<Integer>('activityTime');
      S.FeedbackTime := JObj.GetValue<Integer>('feedbackTime');
      S.Color := TAlphaColor(JObj.GetValue<Integer>('color'));
      FStations.Add(S);
      if S.ID >= FNextID then
        FNextID := S.ID + 1;
    end;
  finally
    JArray.Free;
  end;
end;

initialization
  StationsManager := TStationsManager.Create;

finalization
  StationsManager.Free;

end.
