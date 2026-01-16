program OSCETimerFMX;

{*******************************************************************************
  OSCE Timing System - FireMonkey Version
  Professional examination timing system with modern UI
  
  Developed by Leigh Robert Abbott
  Clinical Education and Simulation
  Mersey and West Lancashire NHS
  
  Version: 2.0 (FireMonkey)
*******************************************************************************}

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainFMX in 'uMainFMX.pas' {MainForm},
  uTypesFMX in 'units\uTypesFMX.pas',
  uTimerLogic in 'units\uTimerLogic.pas',
  uVoice in 'units\uVoice.pas',
  uStationsFMX in 'units\uStationsFMX.pas',
  uConfigFMX in 'units\uConfigFMX.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
