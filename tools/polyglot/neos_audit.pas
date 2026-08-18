{ NeOS Profile Auditor in Free Pascal (FPC) }
program NeosAudit;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes;

const
  RequiredFilesCount = 6;
  RequiredFiles: array[1..RequiredFilesCount] of string = (
    'profile/profiledef.sh',
    'profile/pacman.conf',
    'profile/grub/grub.cfg',
    'profile/syslinux/syslinux.cfg',
    'profile/packages.x86_64',
    'profile/airootfs/etc/pacman.d/neos-mirrorlist'
  );

var
  RootDir, FullPath, Line, PkgPath: string;
  I, PkgCount: Integer;
  PkgList: TStringList;
  PkgFile: TextFile;

begin
  if ParamCount >= 1 then
    RootDir := ParamStr(1)
  else
    RootDir := '.';

  WriteLn(#27'[1;36m[Pascal::Audit]'#27'[0m Auditing NeOS profile structure at: ', RootDir);

  for I := 1 to RequiredFilesCount do
  begin
    FullPath := IncludeTrailingPathDelimiter(RootDir) + RequiredFiles[I];
    if not FileExists(FullPath) then
    begin
      WriteLn(StdErr, '❌ Missing required profile file: ', FullPath);
      Halt(1);
    end;
  end;

  PkgPath := IncludeTrailingPathDelimiter(RootDir) + 'profile/packages.x86_64';
  if not FileExists(PkgPath) then
  begin
    WriteLn(StdErr, '❌ packages.x86_64 missing at: ', PkgPath);
    Halt(1);
  end;

  PkgList := TStringList.Create;
  try
    AssignFile(PkgFile, PkgPath);
    Reset(PkgFile);
    PkgCount := 0;
    while not Eof(PkgFile) do
    begin
      ReadLn(PkgFile, Line);
      Line := Trim(Line);
      if (Line <> '') and (Line[1] <> '#') then
      begin
        if PkgList.IndexOf(Line) >= 0 then
        begin
          WriteLn(StdErr, '❌ Duplicate package entry found in Pascal audit: ', Line);
          CloseFile(PkgFile);
          Halt(1);
        end;
        PkgList.Add(Line);
        Inc(PkgCount);
      end;
    end;
    CloseFile(PkgFile);
    WriteLn(#27'[1;32m✓ Free Pascal Audit Passed! Verified ', PkgCount, ' unique packages.'#27'[0m');
  finally
    PkgList.Free;
  end;
end.
