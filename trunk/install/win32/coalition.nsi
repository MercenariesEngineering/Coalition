!include "Sections.nsh"


Icon "images\coalition.ico"
UninstallIcon "${NSISDIR}\contrib\graphics\icons\classic-uninstall.ico"

InstallDir $PROGRAMFILES\Coalition

Page components
Page directory

Page instfiles

Section "Common Files" 
SectionIn RO
	SetShellVarContext current

	CreateDirectory "$INSTDIR"
	CreateDirectory "$SMPROGRAMS\Coalition"

	ExecWait 'net stop CoalitionServer'

	; Write the registry
	WriteRegStr HKLM "Software\Mercenaries Engineering\Coalition" "Installdir" $INSTDIR

	; Write the uninstall keys for Windows
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Coalition" "DisplayName" "Coalition"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Coalition" "DisplayIcon" '"$INSTDIR\coalition.ico"'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Coalition" "UninstallString" '"$INSTDIR\uninstall.exe"'
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Coalition" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Coalition" "NoRepair" 1

	; Set output path to the installation directory.
	WriteUninstaller "uninstall.exe"

	CreateShortCut "$SMPROGRAMS\Coalition\Configuration File.lnk" "$INSTDIR\coalition.ini" "" ""

	; Set output path to the installation directory.
__INSTALL_FILES__
SectionEnd

Section /o "Server (the master computer)" 
	SetShellVarContext current

	WriteRegStr HKLM "Software\Mercenaries Engineering\Coalition" "Datadir" "$APPDATA\Coalition"

	CreateShortCut "$SMPROGRAMS\Coalition\Coalition Server Monitor.lnk" "http://localhost:19211" "" "$INSTDIR\coalition.ico"
	CreateShortCut "$SMPROGRAMS\Coalition\Coalition Server Start.lnk" "net" "start CoalitionServer" "$INSTDIR\server_start.ico"
	CreateShortCut "$SMPROGRAMS\Coalition\Coalition Server Stop.lnk" "net" "stop CoalitionServer" "$INSTDIR\server_stop.ico"
	CreateShortCut "$SMPROGRAMS\Coalition\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe"
	CreateShortCut "$DESKTOP\Coalition Server Monitor.lnk" "http://localhost:19211" "" "$INSTDIR\coalition.ico"
	CreateShortCut "$DESKTOP\Coalition Server Start.lnk" "net" "start CoalitionServer" "$INSTDIR\server_start.ico"
	CreateShortCut "$DESKTOP\Coalition Server Stop.lnk" "net" "stop CoalitionServer" "$INSTDIR\server_stop.ico"

	ExecWait '"$INSTDIR\server" -remove'
	ExecWait '"$INSTDIR\server" -install -auto'
	ExecWait 'net start CoalitionServer'
SectionEnd

Section "Worker (computers composing the farm)"
	SetShellVarContext current
	CreateShortCut "$SMPROGRAMS\Coalition\Coalition Worker Start.lnk" "$INSTDIR\worker.exe" "" "$INSTDIR\worker_start.ico"
	CreateShortCut "$SMPROGRAMS\Coalition\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
	CreateShortCut "$DESKTOP\Coalition Worker Start.lnk" "$INSTDIR\worker.exe" "" "$INSTDIR\worker_start.ico"
SectionEnd

Section "Autorun the worker on idle"
	ExecWait 'schtasks /Create /TN "Coalition Worker" /SC ONIDLE /IT /I 1 /TR "\"$INSTDIR\worker.exe\""'
SectionEnd

Section "Uninstall"
	SetShellVarContext current

	; ** Ask the user for a confirmation
	IfSilent noUninstallWarning
		MessageBox MB_YESNO|MB_ICONQUESTION  "Do you want to uninstall Coalition from this computer ?" IDYES Uninstall_yes
			Quit
		Uninstall_yes:
noUninstallWarning:

	ExecWait 'schtasks /Delete /TN "Coalition Worker" /F'
	ExecWait 'net stop CoalitionServer'
	ExecWait '"$INSTDIR\server" -remove'
	Delete $INSTDIR\uninstall.exe ; delete self (see explanation below why this works) 
	RMDir /r "$SMPROGRAMS\Coalition"
	Delete "$DESKTOP\Coalition Server Monitor.lnk"
	Delete "$DESKTOP\Coalition Server Start.lnk"
	Delete "$DESKTOP\Coalition Server Stop.lnk"
	Delete "$DESKTOP\Coalition Worker Start.lnk"
	DeleteRegKey HKLM "Software\Mercenaries Engineering\Coalition"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Coalition"
__REMOVE_FILES__
Sectionend

Name "Coalition v1.0"
OutFile "Coalition v1.0.exe"