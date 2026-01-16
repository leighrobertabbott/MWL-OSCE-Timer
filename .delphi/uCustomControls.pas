unit uCustomControls;

{*******************************************************************************
  OSCE Timing System - Custom Styled Controls
  Owner-drawn VCL controls with modern dark theme styling
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Forms,
  uTypes;

type
  // Modern styled button with rounded corners and accent colors
  TStyledButton = class(TCustomControl)
  private
    FCaption: string;
    FButtonStyle: (bsPrimary, bsSecondary, bsDanger, bsWarning);
    FIsHovered: Boolean;
    FIsPressed: Boolean;
    FOnClick: TNotifyEvent;
    procedure SetCaption(const Value: string);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Caption: string read FCaption write SetCaption;
    property ButtonStyle: (bsPrimary, bsSecondary, bsDanger, bsWarning) read FButtonStyle write FButtonStyle;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  // Modern styled edit box with dark theme
  TStyledEdit = class(TCustomControl)
  private
    FEdit: TEdit;
    FIsFocused: Boolean;
    procedure EditChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetText: string;
    procedure SetText(const Value: string);
    property Text: string read GetText write SetText;
  end;

  // Modern styled panel with optional border and shadow
  TStyledPanel = class(TCustomControl)
  private
    FBorderRadius: Integer;
    FBorderColor: TColor;
    FShowBorder: Boolean;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property BorderRadius: Integer read FBorderRadius write FBorderRadius;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property ShowBorder: Boolean read FShowBorder write FShowBorder;
  end;

  // Draw helper functions
  procedure DrawRoundedRect(Canvas: TCanvas; Rect: TRect; Radius: Integer;
    FillColor, BorderColor: TColor; HasBorder: Boolean = True);

implementation

uses
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

procedure DrawRoundedRect(Canvas: TCanvas; Rect: TRect; Radius: Integer;
  FillColor, BorderColor: TColor; HasBorder: Boolean);
var
  Graphics: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Path: TGPGraphicsPath;
  R: TGPRectF;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    R := MakeRect(Rect.Left + 0.5, Rect.Top + 0.5,
      Rect.Width - 1.0, Rect.Height - 1.0);

    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(R.X, R.Y, Radius * 2, Radius * 2, 180, 90);
      Path.AddArc(R.X + R.Width - Radius * 2, R.Y, Radius * 2, Radius * 2, 270, 90);
      Path.AddArc(R.X + R.Width - Radius * 2, R.Y + R.Height - Radius * 2, Radius * 2, Radius * 2, 0, 90);
      Path.AddArc(R.X, R.Y + R.Height - Radius * 2, Radius * 2, Radius * 2, 90, 90);
      Path.CloseFigure;

      // Fill
      Brush := TGPSolidBrush.Create(MakeColor(255,
        GetRValue(FillColor), GetGValue(FillColor), GetBValue(FillColor)));
      try
        Graphics.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      // Border
      if HasBorder then
      begin
        Pen := TGPPen.Create(MakeColor(255,
          GetRValue(BorderColor), GetGValue(BorderColor), GetBValue(BorderColor)), 1);
        try
          Graphics.DrawPath(Pen, Path);
        finally
          Pen.Free;
        end;
      end;
    finally
      Path.Free;
    end;
  finally
    Graphics.Free;
  end;
end;

{ TStyledButton }

constructor TStyledButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 36;
  FButtonStyle := bsPrimary;
  FIsHovered := False;
  FIsPressed := False;
  Cursor := crHandPoint;
  DoubleBuffered := True;
end;

procedure TStyledButton.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Invalidate;
  end;
end;

procedure TStyledButton.CMMouseEnter(var Message: TMessage);
begin
  FIsHovered := True;
  Invalidate;
end;

procedure TStyledButton.CMMouseLeave(var Message: TMessage);
begin
  FIsHovered := False;
  Invalidate;
end;

procedure TStyledButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsPressed := True;
    Invalidate;
  end;
end;

procedure TStyledButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TStyledButton.Click;
begin
  inherited;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TStyledButton.Paint;
var
  FillColor, BorderColor, TextColor: TColor;
  R: TRect;
  TextFlags: Cardinal;
begin
  inherited;

  // Determine colors based on style and state
  case FButtonStyle of
    bsPrimary:
      begin
        if FIsPressed then
          FillColor := $00D68B38  // Darker blue
        else if FIsHovered then
          FillColor := $00FFAB5A  // Lighter blue
        else
          FillColor := CLR_ACCENT;  // #4a9eff
        BorderColor := FillColor;
        TextColor := clWhite;
      end;
    bsSecondary:
      begin
        if FIsPressed then
          FillColor := $00404040
        else if FIsHovered then
          FillColor := $00383838
        else
          FillColor := CLR_BG_ELEVATED;
        BorderColor := CLR_BORDER;
        TextColor := CLR_TEXT_PRIMARY;
      end;
    bsDanger:
      begin
        if FIsPressed then
          FillColor := $002222CC
        else if FIsHovered then
          FillColor := $003333DD
        else
          FillColor := CLR_DANGER;
        BorderColor := FillColor;
        TextColor := clWhite;
      end;
    bsWarning:
      begin
        if FIsPressed then
          FillColor := $000080CC
        else if FIsHovered then
          FillColor := $000090DD
        else
          FillColor := CLR_WARNING;
        BorderColor := FillColor;
        TextColor := clWhite;
      end;
  end;

  R := ClientRect;
  DrawRoundedRect(Canvas, R, 6, FillColor, BorderColor, True);

  // Draw text
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 10;
  Canvas.Font.Color := TextColor;
  Canvas.Font.Style := [];
  Canvas.Brush.Style := bsClear;

  TextFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE;
  DrawText(Canvas.Handle, PChar(FCaption), Length(FCaption), R, TextFlags);
end;

{ TStyledEdit }

constructor TStyledEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 200;
  Height := 36;
  DoubleBuffered := True;

  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.BorderStyle := bsNone;
  FEdit.Color := CLR_BG_ELEVATED;
  FEdit.Font.Name := 'Segoe UI';
  FEdit.Font.Size := 10;
  FEdit.Font.Color := CLR_TEXT_PRIMARY;
  FEdit.OnChange := EditChange;
  FEdit.OnEnter := EditEnter;
  FEdit.OnExit := EditExit;

  FIsFocused := False;
end;

procedure TStyledEdit.Resize;
begin
  inherited;
  FEdit.Left := 12;
  FEdit.Top := (Height - FEdit.Height) div 2;
  FEdit.Width := Width - 24;
end;

procedure TStyledEdit.EditChange(Sender: TObject);
begin
  // Propagate if needed
end;

procedure TStyledEdit.EditEnter(Sender: TObject);
begin
  FIsFocused := True;
  Invalidate;
end;

procedure TStyledEdit.EditExit(Sender: TObject);
begin
  FIsFocused := False;
  Invalidate;
end;

function TStyledEdit.GetText: string;
begin
  Result := FEdit.Text;
end;

procedure TStyledEdit.SetText(const Value: string);
begin
  FEdit.Text := Value;
end;

procedure TStyledEdit.Paint;
var
  BorderColor: TColor;
begin
  inherited;

  if FIsFocused then
    BorderColor := CLR_ACCENT
  else
    BorderColor := CLR_BORDER;

  DrawRoundedRect(Canvas, ClientRect, 8, CLR_BG_ELEVATED, BorderColor, True);

  // Repaint the edit on top
  FEdit.Invalidate;
end;

{ TStyledPanel }

constructor TStyledPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBorderRadius := 12;
  FBorderColor := CLR_BORDER;
  FShowBorder := True;
  DoubleBuffered := True;
  Color := CLR_BG_CARD;
end;

procedure TStyledPanel.Paint;
begin
  inherited;
  DrawRoundedRect(Canvas, ClientRect, FBorderRadius, Color, FBorderColor, FShowBorder);
end;

end.
