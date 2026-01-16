unit uConfirmDialog;

{*******************************************************************************
  OSCE Timing System - Confirmation Dialog
  Modal dialog for user confirmations
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, uTypes;

type
  TConfirmDlg = class(TForm)
  private
    FPanelMain: TPanel;
    FLblTitle: TLabel;
    FLblMessage: TLabel;
    FBtnCancel: TButton;
    FBtnConfirm: TButton;

    procedure CreateComponents;
    procedure ApplyStyles;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnConfirmClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    class function Execute(const ATitle, AMessage: string;
      ADangerMode: Boolean = True): Boolean;
  end;

implementation

{ TConfirmDlg }

constructor TConfirmDlg.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);

  BorderStyle := bsNone;
  Position := poMainFormCenter;
  Width := 400;
  Height := 200;
  Color := CLR_BG_PRIMARY;

  CreateComponents;
  ApplyStyles;
end;

procedure TConfirmDlg.CreateComponents;
begin
  // Main panel (modal card)
  FPanelMain := TPanel.Create(Self);
  FPanelMain.Parent := Self;
  FPanelMain.Align := alClient;
  FPanelMain.BevelOuter := bvNone;
  FPanelMain.Color := CLR_BG_SECONDARY;
  FPanelMain.Padding.Left := 32;
  FPanelMain.Padding.Right := 32;
  FPanelMain.Padding.Top := 32;
  FPanelMain.Padding.Bottom := 32;

  // Title
  FLblTitle := TLabel.Create(Self);
  FLblTitle.Parent := FPanelMain;
  FLblTitle.Align := alTop;
  FLblTitle.Height := 30;
  FLblTitle.Caption := 'Confirm Action';
  FLblTitle.Font.Name := 'Segoe UI';
  FLblTitle.Font.Size := 14;
  FLblTitle.Font.Style := [fsBold];
  FLblTitle.Font.Color := CLR_TEXT_PRIMARY;

  // Message
  FLblMessage := TLabel.Create(Self);
  FLblMessage.Parent := FPanelMain;
  FLblMessage.Align := alTop;
  FLblMessage.Top := FLblTitle.Top + FLblTitle.Height + 8;
  FLblMessage.Height := 60;
  FLblMessage.Caption := 'Are you sure you want to proceed?';
  FLblMessage.Font.Name := 'Segoe UI';
  FLblMessage.Font.Size := 10;
  FLblMessage.Font.Color := CLR_TEXT_SECONDARY;
  FLblMessage.WordWrap := True;

  // Buttons panel
  FBtnCancel := TButton.Create(Self);
  FBtnCancel.Parent := FPanelMain;
  FBtnCancel.Width := 100;
  FBtnCancel.Height := 36;
  FBtnCancel.Left := FPanelMain.Width - 64 - 212;
  FBtnCancel.Top := FPanelMain.Height - 64 - 36;
  FBtnCancel.Anchors := [akRight, akBottom];
  FBtnCancel.Caption := 'Cancel';
  FBtnCancel.OnClick := BtnCancelClick;

  FBtnConfirm := TButton.Create(Self);
  FBtnConfirm.Parent := FPanelMain;
  FBtnConfirm.Width := 100;
  FBtnConfirm.Height := 36;
  FBtnConfirm.Left := FPanelMain.Width - 64 - 100;
  FBtnConfirm.Top := FPanelMain.Height - 64 - 36;
  FBtnConfirm.Anchors := [akRight, akBottom];
  FBtnConfirm.Caption := 'Confirm';
  FBtnConfirm.OnClick := BtnConfirmClick;
end;

procedure TConfirmDlg.ApplyStyles;
begin
  // Style buttons
  FBtnCancel.Font.Name := 'Segoe UI';
  FBtnCancel.Font.Size := 10;

  FBtnConfirm.Font.Name := 'Segoe UI';
  FBtnConfirm.Font.Size := 10;
end;

procedure TConfirmDlg.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TConfirmDlg.BtnConfirmClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

class function TConfirmDlg.Execute(const ATitle, AMessage: string;
  ADangerMode: Boolean): Boolean;
var
  Dlg: TConfirmDlg;
begin
  Dlg := TConfirmDlg.Create(Application.MainForm);
  try
    Dlg.FLblTitle.Caption := ATitle;
    Dlg.FLblMessage.Caption := AMessage;

    Result := Dlg.ShowModal = mrOk;
  finally
    Dlg.Free;
  end;
end;

end.
