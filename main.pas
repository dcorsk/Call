unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql56conn, sqldb, IBConnection, db, FileUtil, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Menus, Windows,mmsystem;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    Data: TDataSource;
    FBData: TDataSource;
    FB: TIBConnection;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Connect: TMySQL56Connection;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Query: TSQLQuery;
    FBTrans: TSQLTransaction;
    FBQuery: TSQLQuery;
    Transaction: TSQLTransaction;
    Timer1: TTimer;
    Timer2: TTimer;
    TrayIcon1: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure WriteLog(str:string);
    procedure SoundPlay;
  private

  public
    TimeButton,sp:Integer;
    telname:string;
  end;


var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.Timer1Timer(Sender: TObject);
begin

  TimeButton:=TimeButton-1;
  Button1.Caption:='Закрыть окно ('+IntToStr(TimeButton)+' сек) ';
  if TimeButton=0 then Timer1.Enabled:=False;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
var UN,SQL,ADR,TEL,block:String;
begin
  TrayIcon1.Hint:='Панель отслеживания звонков (ждунчик)';
  if TimeButton<=0 then
     Connect.Connected:=True
  else
     exit;
  Application.ProcessMessages;
  SQL:='SELECT uniqueid,calldate,src FROM cdr where status="NEW" and did="300" order by calldate limit 1';
  Query.SQL.Clear;
  Query.SQL.Add(SQL);
  Query.Open;
  if not Query.Eof then begin
    TrayIcon1.Hint:='Панель отслеживания звонков (входящий звонок)';
    Timer2.Enabled:=False;
    TEL:=Query.FieldByName('src').AsString;
    UN:=Query.FieldByName('uniqueid').AsString;
    Label2.Caption:='от '+TEL;
    Label5.Caption:='Время : '+Query.FieldByName('calldate').AsString;
    TrayIcon1.BalloonHint := DateTimetoStr(Now)+' Входящий звонок от '+TEL+' в '+Query.FieldByName('calldate').AsString;
    WriteLog(TrayIcon1.BalloonHint);
    Query.Close;
    TrayIcon1.BalloonTitle:='Оповещение для СисАдмина';
    TrayIcon1.ShowBalloonHint;
    Query.SQL.Clear;
    SQL:='update cdr set status="OLD" where uniqueid="'+UN+'"';
    Query.sql.add(SQL);
    Query.ExecSQL;
    Transaction.Commit;
    Query.SQL.Clear;
    Query.Close;
    Show;
  end;
  Query.Close;
  Connect.Connected:=False;
end;

procedure TMainForm.WriteLog(str: string);
var f:text;
begin
  AssignFile(f,'call.log');
  Append(f);
  WriteLN(f,str);
  CloseFile(f);
end;

procedure TMainForm.SoundPlay;
begin

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  TrayIcon1.Hint:='Панель отслеживания звонков (отображение)';
  MainForm.Caption:='Входящий звонок';
  if not Timer2.Enabled then begin
    Label1.Caption:='Оповещение о начале входящего звонка ';
    if sp=0 then TimeButton:=10;
    Label1.Font.Color:=clBlack;
    Timer1.Enabled:=True;
    Timer2.Enabled:=False;
    PlaySound('664112.wav', 0, SND_ASYNC);
  end else
    MainForm.Visible:=False;
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
  Halt;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var HM: THandle;
begin
 HM := OpenMutex(MUTEX_ALL_ACCESS, false, 'Call');
  if (HM <> 0) then begin
    MessageDlg('Уще запущено отслеживание звонков!!!',mtError, [mbOk], 0);
    halt;
  end;
  if HM = 0 then HM := CreateMutex(nil, false, 'Call');
  Connect.Connected:=True;
  TimeButton:=0;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Timer1StopTimer(MainForm);
end;

procedure TMainForm.Timer1StopTimer(Sender: TObject);
begin
  MainForm.Visible:=False;
  TrayIcon1.Hint:='Панель отслеживания звонков (ждун)';
  Timer2.Enabled:=True;
  TimeButton:=0;
end;

end.

