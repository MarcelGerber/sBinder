﻿/*
AddChatMessage-Farbe: {ffffff} weiß
AddChatMessage-Akzentfarbe: {88aa62} olivgrün (wird auch von API selbst verwendet)
*/

ListLines Off
SetBatchLines -1
if(!A_IsCompiled AND !InStr(A_ScriptName, ".exe"))
	Menu, Tray, Icon, %A_ScriptDir%\logo.ico
else{
	Menu, Tray, UseErrorLevel
	Menu, Tray, Icon, %A_ScriptFullPath%, 1
}
Menu, Tray, Icon,,, 1

gosub GetArgs
NoAdminMode := InStr(FullArgs, "--no-admin")
IniRead, RunAsAdmin, %A_AppData%\sBinder\global.ini, RunAsAdmin, %A_ScriptFullPath%, 1
if(!A_IsAdmin AND A_OSVersion != "WIN_XP" AND !NoAdminMode AND RunAsAdmin){
	Run *RunAs "%A_ScriptFullPath%" %FullArgsQuoted%,, UseErrorLevel
	if(ErrorLevel){
		MsgBox, 0x126, Administatorrechte benötigt, Es wird empfohlen, den sBinder mit Administratorrechten zu starten, da so sichergestellt werden kann, dass er im Spiel auch wirklich verwendbar ist.`nKlickst du auf "Weiter", so wird er - auf eigenes Risiko - ohne Adminrechte gestartet.`n`nWillst du diese Abfrage nicht mehr sehen, so kannst du sie unter "Datei > Einstellungen > Erweiterte Optionen > Mit Administratorrechten starten" deaktivieren.
		IfMsgBox, TryAgain
			Reload
		IfMsgBox, Cancel
			ExitApp
	} else
		ExitApp
}

#NoEnv
#Persistent
#KeyHistory 0
OnExit, BeforeExit
CoordMode, Mouse, Client
SetWorkingDir, %A_ScriptDir%
FileCreateDir, %A_Temp%\sBinder\Trucking
FileCreateDir, %A_AppData%\sBinder
FileCreateDir, %A_AppData%\sBinder\Design
gosub Variables
gosub Arrays

GroupAdd, GTASA, ahk_class Grand theft auto San Andreas ahk_exe gta_sa.exe
GroupAdd, GTASA, Keybinder testen (Debug) ahk_class AutoHotkeyGUI

if(LastUsedBuild = 0){
	if(A_ScriptDir = A_Desktop OR A_ScriptDir = A_DesktopCommon){
		MsgBox, 35, sBinder verschieben?, Du hast den sBinder vom Desktop aus gestartet.`nAllerdings wird er einige Dateien erstellen.`nWillst du den sBinder daher in einen anderen Ordner verschieben und nur eine Verknüpfung auf dem Desktop erstellen?`n`nMit einem Klick auf Ja wird der sBinder in einen von dir wählbaren Ordner verschoben und eine Verknüpfung auf dem Desktop erstellt, mit Nein wird der sBinder auf dem Desktop belassen. Mit Abbrechen wird er beendet, ohne Daten zu erstellen.
		IfMsgBox, Cancel
			ExitApp
		IfMsgBox, Yes
		{
			FileSelectFolder, newfolder,, 3, Wähle den neuen Ordner des sBinders:
			if(!ErrorLevel){
				FileCreateShortcut, %A_ScriptName%, sBinder.lnk, %newfolder%, sBinder by IcedWave
				FileDelete, sBinder_move.bat
				FileAppend, @echo off`nping 1.1.1.1 -n 1 -w 800`nmove "%A_ScriptFullPath%" "%newfolder%\%A_ScriptName%"`nping 1.1.1.1 -n 1 -w 800`nstart "" "%newfolder%\%A_ScriptName%"`ndel "%A_ScriptDir%\sBinder_move.bat", sBinder_move.bat
				Run, %RunPrivileges%sBinder_move.bat
				ExitApp
			}
		}
	}
	;Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., Lizenz wird geladen..., sBinder: Lizenz wird geladen
	InfoProgress("Bitte habe etwas Geduld...", "Lizenz wird geladen...", "sBinder: Lizenz wird geladen")
	Gui, LicenseGUI:Add, Edit, r25 w500 ReadOnly, % HTTPData("http://saplayer.lima-city.de/l/sBinder-license2")
	Gui, LicenseGUI:Add, Button, Default gAccept, Akzeptieren
	Gui, LicenseGUI:Add, Button, gExit x+10, Ablehnen
	;Progress, Off
	InfoProgress()
	Gui, LicenseGUI:Show,, sBinder: Lizenz
	return
}
if(LastUsedBuild != Build)
	IniWrite, %Build%, %INIFile%, Settings, LastUsedBuild
if(!FileExist(A_AppData "\sBinder\bg.png")){
	;Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., Schriftzug (Bild) wird heruntergeladen..., sBinder Download
	InfoProgress("Bitte habe etwas Geduld...", "Schriftzug (Bild) wird heruntergeladen...", "sBinder Download")
	URLDownloadToFile, http://saplayer.lima-city.de/l/sBinder-bg, %A_AppData%\sBinder\bg.png
	;Progress, Off
	InfoProgress()
}
if(UseAPI AND !FileExist(A_AppData "\sBinder\Open-SAMP-API.dll")){
	MsgBox, 36, Open-SAMP-API.dll herunterladen?, Die Open-SAMP-API.dll wurde nicht gefunden. Dies kann folgende Gründe haben:`n• Erster Start des sBinders`n• Löschen des AppData-Ordners`n• Aktivierung der API-Nutzung in den Einstellungen`n`nMit einem Klick auf Ja wird die Open-SAMP-API.dll heruntergeladen, wenn du auf Nein klickst, wird die API nicht genutzt. Du kannst die Nutzung der API jederzeit in den Optionen aktivieren oder deaktivieren.`n`n`nWas bringt mir die API?`nMit der API werden die zahlreichen Informationen, die der sBinder dir bietet, wirklich nur dir angezeigt. Außerdem wird der Spielablauf weniger blockiert und die Eingabe in Dialoge (wie auch die Passworteingabe) nicht gestört.
	IfMsgBox, No
	{
		UseAPI := 0
		IniWrite, 0, %INIFile%, Settings, UseAPI
	}
	IfMsgBox, Yes
	{
		MsgBox, 36, Virustotal?, Willst du die Virustotal-Analyse der Open-SAMP-API.dll ansehen?
		IfMsgBox, Yes
		{
			Run, http://saplayer.lima-city.de/l/virustotal-API
			Sleep, 2000
			MsgBox, 36, Download fortsetzen?, Willst du die Open-SAMP-API.dll wirklich herunterladen?
			IfMsgBox, No
			{
				UseAPI := 0
				IniWrite, 0, %INIFile%, Settings, UseAPI
			}
		}
		if(UseAPI){
			;Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., API.dll wird heruntergeladen..., sBinder Download
			InfoProgress("Bitte habe etwas Geduld...", "Open-SAMP-API.dll wird heruntergeladen...", "sBinder Download")
			URLDownloadToFile, http://saplayer.lima-city.de/l/API, %A_AppData%\sBinder\Open-SAMP-API.dll
			;Progress, Off
			InfoProgress()
		}
	}
}
/* Download der API 1.0
if(UseAPI){
	FileGetSize, api_size, % A_AppData "\sBinder\API.dll"
	if(api_size < 380000){
		Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., Neue API.dll wird heruntergeladen..., sBinder Download
		URLDownloadToFile, http://saplayer.lima-city.de/l/API, %A_AppData%\sBinder\API.dll
		Progress, Off
	}
}
*/
if(UseAPI){
	hModule := DllCall("LoadLibrary", Str, A_AppData "\sBinder\Open-SAMP-API.dll")
	if(hModule == -1 || hModule == 0){
		MsgBox, 48, API-Fehler, Die Open-SAMP-API.dll konnte nicht gefunden werden.`nDaher wird sie nicht genutzt.
		UseAPI := 0
		IniWrite, %UseAPI%, %INIFile%, Settings, UseAPI
	}
	else{
		Init_func := DllCall("GetProcAddress", UInt, hModule, AStr, "Init")
		SetParam_func := DllCall("GetProcAddress", UInt, hModule, AStr, "SetParam")
		AddChatMessage_func := DllCall("GetProcAddress", UInt, hModule, AStr, "AddChatMessage")
		SendChat_func := DllCall("GetProcAddress", UInt, hModule, AStr, "SendChat")
		IsDialogOpen_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsDialogOpen")
		IsChatOpen_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsChatOpen")
		IsMenuOpen_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsMenuOpen")
		ShowDialog_func := DllCall("GetProcAddress", UInt, hModule, AStr, "ShowDialog")
		GetVehicleModelId_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetVehicleModelId")
		SetParam_func := DllCall("GetProcAddress", UInt, hModule, AStr, "SetParam")
		IsPlayerInAnyVehicle_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsPlayerInAnyVehicle")
		GetPlayerPosition_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetPlayerPosition")
		
		TextCreate_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextCreate")
		TextDestroy_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextDestroy")
		TextSetColor_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextSetColor")
		TextSetPos_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextSetPos")
		TextSetString_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextSetString")
		TextSetShadow_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextSetShadow")
		TextSetShown_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextSetShown")
		TextUpdate_func := DllCall("GetProcAddress", UInt, hModule, AStr, "TextUpdate")
		DestroyAllVisual_func := DllCall("GetProcAddress", UInt, hModule, AStr, "DestroyAllVisual")
		
		SetParam("process", "gta_sa.exe")
		SetParam("use_window", "0")
	}
}

AddChatMessage(Text, color=0xFF6600, nosplit=0, indent=0){
	global UseAPI, AddChatMessage_func
	max_len := UseAPI ? 130 : 123
	newtext := Object()
	Colors := Object()
	Colors[1] := color
	in_debug_win := WinActive("ahk_class AutoHotkeyGUI")
	i := 1
	if(!UseAPI OR in_debug_win)
		Text := RegExReplace(Text, "Ui)\{[a-f\d]{6}\}")
	if(nosplit)
		newtext[1] := Text
	else{
		pos := 0
		loop, Parse, text, %A_Space%`n
		{
			delimitBefore := SubStr(text, pos, 1)
			pos += StrLen(A_LoopField) + 1
			newline := delimitBefore = "`n"
			if((newline AND newtext[i] != "") OR StrLen(newtext[i] A_LoopField) >= max_len){
				if(RegExMatch(newtext[i] := Trim(newtext[i]), "i)^.*\{([a-f\d]{6})\}", m))
					color := Colors[i+1] := "0x" m1
				else
					Colors[i+1] := color
				i ++
				if(indent)
					newtext[i] := newline ? "  " : "    "
			}
			newtext[i] .= A_LoopField " "
		}
	}
	for i, Text in newtext
	{
		if(UseAPI AND !in_debug_win){
			StringReplace, Text, Text, `%, `%`%, All
			res := DllCall(AddChatMessage_func, AStr, Text)
			Sleep, 20
		}
		else
			SendChat("/echo " Trim(Text))
	}
	return i*res
}
GetChatLineCount(){
	global chatlogpath
	FileRead, file, %chatlogpath%
	StringReplace, file, file, `n, `n, UseErrorLevel
	return ErrorLevel
}
GetChatLine(Line, ByRef Output, timestamp=0, color=0){
	return GetChatLine_abs(GetChatLineCount() - line, Output, timestamp, color)
}
GetChatLine_abs(Line, ByRef Output, timestamp=0, color=0){
	global chatlogpath
	output := ""
	FileRead, file, %chatlogpath%
	loop, Parse, file, `n, `r
	{
		if(A_Index = line){
			output := A_LoopField
			break
		}
	}
	file := ""
	if(!timestamp)
		output := RegExReplace(output, "U)^\[\d{2}:\d{2}:\d{2}\] ")
	if(!color)
		output := RegExReplace(output, "Ui)\{[a-f0-9]{6}\}")
	return
}
GetPlayerPosition(ByRef flo_posX, ByRef flo_posY, ByRef flo_posZ){
	global GetPlayerPosition_func
	return DllCall(GetPlayerPosition_func, FloatP, flo_posX, FloatP, flo_posY, FloatP, flo_posZ)
}
GetVehicleModel(){
	global GetVehicleModelId_func, UseAPI
	if(UseAPI)
		return DllCall(GetVehicleModelId_func)
	else
		return 0
}
IsChatOpen(){
	global IsChatOpen_func
	return DllCall(IsChatOpen_func)
}
IsDialogOpen(){
	global IsDialogOpen_func
	return DllCall(IsDialogOpen_func)
}
IsMenuOpen(){
	global IsMenuOpen_func
	return DllCall(IsMenuOpen_func)
}
IsPlayerInAnyVehicle(){
	global IsPlayerInAnyVehicle_func
	return DllCall(IsPlayerInAnyVehicle_func)
}
SendChat(Text, spamcount=3, GoToTextbinds=1){
	global UseAPI, SendChat_func, UseTimerActive
	static lastsend, count
	if(spamcount){
		if(A_TickCount - lastsend < 900){
			if(count >= spamcount){
				Sleep, 900
				count := 0
			}
			count ++
		}
		else
			count := 0
	}
	lastsend := A_TickCount
	
	if (GoToTextbinds AND UseTimerActive AND (Text = "/use gold" OR Text = "/use donut" OR Text = "/use green" OR Text = "/use lsd"))
		gosub :b0:%Text%
	
	if(UseAPI AND !WinActive("ahk_class AutoHotkeyGUI"))
		res := DllCall(SendChat_func, AStr, Text)
	else{
		KeyWait, Enter
		SendInput, t{bs}
		if(WinActive("ahk_class AutoHotkeyGUI"))
			SendInput, % "[" A_Hour ":" A_Min ":" A_Sec "] "
		SendInput, % "{Raw}" Text
		SendInput, {enter}
	}
	return res
}
SetParam(str_Name, str_Value){
	global SetParam_func
	return DllCall(SetParam_func, AStr, str_Name, AStr, str_Value)
}
ShowDialog(Style, Title, Text, Button="OK", Button2="Schließen", Id=522){
	global ShowDialog_func, UseAPI
	KeyWait, Enter
	Sleep, 200
	if(UseAPI AND !WinActive("ahk_class AutoHotkeyGUI"))
		return DllCall(ShowDialog_func, Int, Id, Int, Style, AStr, Title, AStr, Text, AStr, Button, AStr, Button2)
	else if(WinActive("ahk_class AutoHotkeyGUI"))
		MsgBox, 64, % RegExReplace(Title, "Ui)\{[a-f\d]{6}\}"), % RegExReplace(Text, "Ui)\{[a-f\d]{6}\}")
}
TextCreate(Font, fontsize, bold, italic, x, y, color, text, shadow, show){
	global TextCreate_func
	return DllCall(TextCreate_func, AStr, Font, Int, fontsize, UChar, bold, UChar, italic, Int, x, Int, y, UInt, color, AStr, text, UChar, shadow, UChar, show)
}
TextDestroy(id){
	global TextDestroy_func
	return DllCall(TextDestroy_func,Int,id)
}
TextSetColor(TextIndex, Color){
	global TextSetColor_func
	return DllCall(TextSetColor_func, Int, TextIndex, Int64, Color)
}
TextSetPos(TextIndex, PosX, PosY){
	global TextSetPos_func
	return DllCall(TextSetPos_func, Int, TextIndex, Int, PosX, Int, PosY)
}
TextSetShadow(id, shadow){
	global TextSetShadow_func
	return DllCall(TextSetShadow_func, Int, id, UChar, shadow)
}
TextSetString(TextIndex, Text){
	global TextSetString_func
	return DllCall(TextSetString_func, Int, TextIndex, AStr, Text)
}
TextSetShown(id, show){
	global TextSetShown_func
	return DllCall(TextSetShown_func, Int, id, UChar, show)
}
TextUpdate(id, Font, Fontsize, bold, italic){
	global TextUpdate_func
	return DllCall(TextUpdate_func, Int, id, AStr, Font, int, Fontsize, UChar, bold, UChar, italic)
}

ArrayMatch(str, arr, options="Ui", mode=0){
	out := 0
	for i, k in arr
	{
		if(k AND RegExMatch(str, options ")" k)){
			out := (mode = 0 ? i : mode = 1 ? A_Index)
			break
		}
	}
	return out
}
ArrayMultiSort(arr, sortby=1, reverse=0){
	newarr := Object()
	sort := Object()
	loop, % arr._MaxIndex()
	{
		for i, k in arr
		{
			k := k[sortby]
			if(sort["low"] = "" OR k < sort["low"]){
				sort["low"] := k
				sort["i"] := i
			}
		}
		newarr.Insert(arr[sort["i"]])
		arr.Remove(sort["i"])
		sort["low"] := ""
	}
	if(reverse)
		return ArrayReverse(newarr)
	return newarr
}
ArrayParse(input, mode=1, delimiter="|", parse=":"){
	output := Object()
	if(mode = 1){
		pos := 1
		while(RegExMatch(input, "U)(.+)\Q" parse "\E(.+)(\Q" delimiter "\E|$)", m, pos)){
			pos += StrLen(m)
			output[m1] := m2
		}
	}
	return output
}
ArrayReverse(arr){
	max := arr._maxIndex()
	newarr := Object()
	loop, % max
		newarr.Insert(arr[max+1-A_Index])
	return newarr
}
ArraySort(arr, option="", order=""){
	str := ""
	for i, k in arr
		str .= k "`n"
	str := SubStr(str, 1, -1)
	Sort, str, %option%
	newarr := Object()
	loop, Parse, str, `n
		newarr.Insert(A_LoopField)
	return newarr
}
between(var, min, max){
	if var between %min% and %max%
		return 1
	return 0
}
BindReplace(String){
	global Nickname
	StringReplace, String, String, [Name], %Nickname%, All
	while(InStr(String, "[ID " A_Index "]"))
		StringReplace, String, String, % "[ID " A_Index "]", % PlayerInput("Gib die " A_Index ". ID ein: "), All
	if(SubStr(String, 1, 11) = "[InputMode]"){
		String := RegExReplace(String, "!|#|\+|\^", "{$0}")
		StringReplace, String, String, [InputMode]
		StringReplace, String, String, ~, {enter}, All
		while(!A_IsSuspended AND String){
			wait2 := ""
			pos1 := RegExMatch(String, "\[Wait (\d*?)\]", wait)
			if(!pos1)
				pos1 := 1
			StringReplace, String, String, [Wait %wait1%]
			BindOutput := SubStr(String, 1, pos1 - 1)
			if(!BindOutput)
				BindOutput := String
			StringReplace, String, String, %BindOutput%
			pos := 0
			while(pos := RegExMatch(BindOutput, "i)(\{enter\}|^)t/(.*?)\{enter\}", textbind, pos+1)){
				if(IsLabel("::/" textbind2)){
					gosub, % "::/" textbind2
					StringReplace, BindOutput, BindOutput, t/%textbind2%{enter}
				}
				else if(IsLabel(":b0:/" textbind2))
					gosub, % ":b0:/" textbind2
			}
			KeyWait, Enter
			SendInput, %BindOutput%
			Sleep, %wait1%
		}
	}
	else{
		StringReplace, String, String, [Wait, ~[Wait, All
		String := RegExReplace(String, "~+", "~")
		BindOutput := StrSplit(String, "~")
		while(!A_IsSuspended AND BindOutput._maxIndex() >= A_Index){
			currentPart := BindOutput[A_Index]
			if(RegExMatch(currentPart, "\[Wait (\d*?)\]", wait)){
				Sleep, %wait1%
				StringReplace, currentPart, currentPart, [Wait %wait1%]
			}
			if(IsLabel("::" currentPart) AND !A_IsSuspended)
				gosub % "::" currentPart
			else {
				if(IsLabel(":b0:" currentPart) AND !A_IsSuspended)
					gosub % ":b0:" currentPart
				if (!A_IsSuspended AND currentPart != "")
					SendChat(Trim(currentPart),, 0)
			}
		}
	}
}
ChatLine(firstline, instr, lines=5, regex=0){
	loop, %lines%
	{
		GetChatLine(firstline + A_Index - 1, chat)
		if(!regex && InStr(chat, instr))
			return chat
		else if(regex && RegExMatch(chat, instr))
			return chat
	}
	return
}
ChatLine_abs(firstline, instr, lines=5, regex=0, chatindex=0){
	loop, %lines%
	{
		line := GetChatLineCount() - (firstline + A_Index - 1)
		if (line <= chatindex)
			break
		GetChatLine(firstline + A_Index - 1, chat)
		if(!regex && InStr(chat, instr))
			return chat
		else if(regex && RegExMatch(chat, instr))
			return chat
	}
	return
}
WaitForChatLine(firstline, instr, lines=5, iterations=25, regex=0){
	StartTS := A_TickCount
	chatindex := GetChatLineCount()
	loop, %iterations%
	{
		chat := ChatLine_abs(firstline, instr, lines, regex, chatindex)
		if (chat != "")
			return chat
		Sleep, 75
	}
}
clearping(host, timeout=500){
	if host is number
		ping := host
	else
		ping := ping(host, 32, timeout)
	if(ping > 0)
		return ping " ms"
	if(ping = -1)
		return "Interner Fehler"
	if(ping = -2)
		return "Der Host wurde nicht gefunden"
	if(ping = -3)
		return "Die Anfrage konnte nicht korrekt versendet werden"
	if(ping = -4)
		return "Der Ping ist größer als " timeout " ms"
	if(ping = -5)
		return "Die Anfrage konnte nicht korrekt empfangen werden"
	if(ping = -6)
		return "Das Netzwerk ist nicht erreichbar"
	if(ping = -7)
		return "Der Host ist nicht erreichbar"
}
date(time, null=0, seconds=1){
	if(!time){
		if(null = 1)
			return "Nie"
		else if(null = 2)
			return "0 Sekunden"
		else
			return
	}
	out := SubStr(RTrim(((temp := Floor(time/3600)) ? temp " Stunde" (temp = 1 ? "" : "n") " und " : "") ((temp := Mod(Floor(time/60), 60)) ? temp " Minute" (temp = 1 ? "" : "n") " und " : "") ((temp := Floor(Mod(time, 60))) ? temp " Sekunde" (temp = 1 ? "" : "n") "____" : "")), 1, -4)
	if(!seconds)
		out := RegExReplace(out, "( und )?\d+ Sekunden?")
	return out
}
Dlg_Color(Color=0, hGui=0){ ;https://github.com/maul-esel/FormsFramework/tree/master/Dlg //majkinetor, maul.esel
	clr := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF)
	VarSetCapacity(CHOOSECOLOR, 0x24, 0), VarSetCapacity(CUSTOM, 64, 0)
	, NumPut(0x24, CHOOSECOLOR, 0)      ; DWORD lStructSize 
	, NumPut(hGui, CHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
	, NumPut(clr, CHOOSECOLOR, 12)     ; clr.rgbResult 
	, NumPut(&CUSTOM, CHOOSECOLOR, 16)     ; COLORREF *lpCustColors
	, NumPut(0x00000103, CHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT
	nRC := DllCall("comdlg32\ChooseColor", "Str", CHOOSECOLOR)  ; Display the dialog
	if((errorlevel != 0) OR (nRC = 0))
		return 0
	clr := NumGet(CHOOSECOLOR, 12) 
	oldFormat := A_FormatInteger
	SetFormat, integer, hex  ; Show RGB color extracted below in hex format.
	Color := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
	StringTrimLeft, Color, Color, 2
	loop, % 6-strlen(Color) 
		Color := 0 Color 
	Color := "0x" Color 
	SetFormat, integer, %oldFormat%
	return [Color]
}
Dlg_Font(Name, Style="", Color=0, Effects=true, hGui=0) {
	PtrType := A_PtrSize ? "Ptr" : "UInt"
	PtrSize := A_PtrSize ? A_PtrSize : 4
	LogPixels := DllCall("GetDeviceCaps", PtrType, DllCall("GetDC", PtrType, hGui), "uint", 90)	;LOGPIXELSY
	VarSetCapacity(LOGFONT, 28 + 32 * (A_IsUnicode ? 2 : 1), 0)
	Effects := 0x041 + (Effects ? 0x100 : 0)  ;CF_EFFECTS = 0x100, CF_SCREENFONTS=1, CF_INITTOLOGFONTSTRUCT = 0x40
	StrPut(Name, &LOGFONT+28, 32)
	clr := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF)
	if(InStr(Style, "bold"))
		NumPut(700, LOGFONT, 16, "UInt")
   if(InStr(Style, "italic"))
		NumPut(255, LOGFONT, 20, "Char")
   if(InStr(Style, "underline"))
		NumPut(1, LOGFONT, 21, "Char")
   if(InStr(Style, "strikeout"))
		NumPut(1, LOGFONT, 22, "Char")
   if(RegExMatch(Style, "s[1-9][0-9]*", s)){
		StringTrimLeft, s, s, 1      
		s := -DllCall("MulDiv", "int", s, "int", LogPixels, "int", 72)
		NumPut(s, LOGFONT, 0, "Int")			; set size
	}
	else
		NumPut(16, LOGFONT, 0)         ; set default size
	size := 28 + 8 * PtrSize
    , VarSetCapacity(CHOOSEFONT, size, 0)
    , NumPut(size,	 CHOOSEFONT, 00, "UInt")		; DWORD lStructSize
    , NumPut(hGui,    CHOOSEFONT, 04, PtrType)		; HWND hwndOwner (makes dialog "modal").
    , NumPut(&LOGFONT,CHOOSEFONT, 04 + 2 * PtrSize, PtrType)	; LPLOGFONT lpLogFont
    , NumPut(Effects, CHOOSEFONT, 08 + 3 * PtrSize, "UInt")
    , NumPut(clr,	 CHOOSEFONT, 12 + 3 * PtrSize, "UInt")	; rgbColors
	r := DllCall("comdlg32\ChooseFont" . (A_IsUnicode ? "W" : "A"), PtrType, &CHOOSEFONT)  ; Display the dialog. ; NOTE: omitting the encoding ternary makes it fail on AHK classic
	if(!r)
		return 0
	Name := StrGet(&LOGFONT + 28, 32)
	Style := "s" NumGet(CHOOSEFONT, 4 + 3 * A_PtrSize, "UInt") // 10
	old := A_FormatInteger
	SetFormat, integer, hex                      ; Show RGB color extracted below in hex format.
	Color := NumGet(CHOOSEFONT, 12 + 3 * PtrSize, "UInt")
	SetFormat, integer, %old%
	Style := ""
	if(NumGet(LOGFONT, 16) >= 700)
		Style .= "bold "
	if(NumGet(LOGFONT, 20, "UChar"))
		Style .= "italic "
	if(NumGet(LOGFONT, 21, "UChar"))
		Style .= "underline "
	if(NumGet(LOGFONT, 22, "UChar"))
		Style .= "strikeout "
	s := NumGet(LOGFONT, 0, "Int")
	Style .= "s" Abs(DllCall("MulDiv", "int", abs(s), "int", 72, "int", LogPixels))
	oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 
    Color := (Color & 0xff00) + ((Color & 0xff0000) >> 16) + ((Color & 0xff) << 16) 
    StringTrimLeft, Color, Color, 2 
    loop, % 6-strlen(Color) 
		Color=0%Color% 
    Color=0x%Color% 
    SetFormat, integer, %oldFormat% 
	return {Name: Name, Style: Style, Color: Color}
}
DownloadToString(url, encoding="cp1250"){ ;http://www.autohotkey.com/board/topic/89198-simple-download-bin-tostring-und-tofile/ //Bentschi
	static a := "AutoHotkey/" A_AhkVersion
	if(!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
		return 0
	c := s := 0, o := ""
	if(f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr")){
		to := 0
		while(DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s>0){
			VarSetCapacity(b, s, 0)
			DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
			o .= StrGet(&b, r>>(encoding="utf-16"||encoding="cp1200"), encoding)
		}
		DllCall("wininet\InternetCloseHandle", "ptr", f)
	}
	DllCall("wininet\InternetCloseHandle", "ptr", h)
	return o
}
FormatTime(stamp="", format=""){
	FormatTime, out, %stamp%, %format%
	return out
}
GetCPULoad_Short(){ ;http://www.autohotkey.com/board/topic/7127-monitor-when-cpu-becomes-idle/ //shimanov, toralf, MultiCore-Kompatibilität von Brainside (Guest)
	Static IdleTime, Tick 
	global ProcessorCount
	SetBatchLines, -1 
	OldIdleTime := IdleTime
	OldTick := Tick
	VarSetCapacity( IdleTicks,8,0)
	DllCall("kernel32.dll\GetSystemTimes", "uint",&IdleTicks, "uint",0, "uint",0) 
	IdleTime := *(&IdleTicks) 
	Loop 7					
		IdleTime += *( &IdleTicks + A_Index ) << ( 8 * A_Index ) 
	Tick := A_TickCount 
	Return 100 - 0.01*(IdleTime - OldIdleTime) / (Tick - OldTick) / ProcessorCount
}
GetChatLines(firstline, lines="", timestamp=0, color=0){
	if(!lines)
		lines := firstline
	global chatlogpath
	FileRead, file, %chatlogpath%
	StringReplace, file, file, `n, `n, UseErrorLevel
	chatindex := ErrorLevel
	output := ""
	loop, Parse, file, `n, `r
	{
		if(A_Index > chatindex - firstline AND A_Index <= chatindex - firstline + lines)
			output .= (output ? "`n" : "") A_LoopField
	}
	file := ""
	if(!timestamp)
		output := RegExReplace(output, "Um`a)^\[\d{2}:\d{2}:\d{2}\] ")
	if(!color)
		output := RegExReplace(output, "Ui)\{[a-f0-9]{6}\}")
	return output
}
GetPlayerId(){
	global Nickname
	if(!id := GetPlayerIdByName(Nickname))
		id := "[ID]"
	return id
}
GetPlayerIdByName(name){
	SendChat("/id " name)
	chat := WaitForChatLine(0, "ID: ")
	RegExMatch(chat, "U)ID: \((\d{1,3})\) ", chat)
	if(!chat1)
		chat1 := name
	return chat1
}
GetPlayerNameById(id){
	SendChat("/id " id)
	chat := WaitForChatLine(0, "ID: ")
	RegExMatch(chat, "U)ID: \(\Q" id "\E\) (.+) Level: ", chat)
	if(!chat1)
		chat1 := id
	return chat1
}
HTTPData(url, default="", encoding="cp1250", brton=0){
	global DownloadMode
	static useragent := "AutoHotkey/" A_AhkVersion
	if(DownloadMode = 0){
		if(!out := DownloadToString(url, encoding))
			return default " [Error 0-1]"
		if(brton)
			StringReplace, out, out, <br>, `n, All
		return out
	}
	else if(DownloadMode = 1){
		URLDownloadToFile, %url%, %A_Temp%\sBinder\sbinder.tmp
		if(ErrorLevel)
			return default " [Error 1-1]"
		FileRead, out, %A_Temp%\sBinder\sbinder.tmp
		if(ErrorLevel)
			return default " [Error 1-2]"
		FileDelete, %A_Temp%\sBinder\sbinder.tmp
		if(brton)
			StringReplace, out, out, <br>, `n, All
		return (out ? out : default " [Error 1-0]")
	}
	else{
		static WebRequest
		if(!WebRequest AND !WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1"))
			return default " [Error 2-1]"
		try{
			WebRequest.Open("GET", url)
			WebRequest.setRequestHeader("User-Agent", useragent)
			WebRequest.setRequestHeader("Cache-Control", "no-cache, no-store") ; Caching deaktivieren
			WebRequest.Send()
		}
		catch
			return default " [Error 2-2]"
		out := WebRequest.ResponseText
		if(DownloadMode = "GetHeaders")
			MsgBox, % WebRequest.GetAllResponseHeaders()
		if(brton)
			StringReplace, out, out, <br>, `n, All
		return (out != "" ? out : default " [Error 2-0]")
	}
	return default " [Error X]"
}
InfoProgress(text="", title="", windowName=""){
	global GUIs
	Gui, InfoProgress:Destroy
	if(text OR subtitle OR windowName){
		Gui, InfoProgress:Color, FFFFFF
		Gui, InfoProgress:-caption +border +Hwndtemp2
		GUIs["InfoProgress"] := temp2
		Gui, InfoProgress:Font, s13 bold
		Gui, InfoProgress:Add, Text,, %title%
		Gui, InfoProgress:Font
		Gui, InfoProgress:Font, s10
		Gui, InfoProgress:Add, Text,, %text%
		Gui, InfoProgress:Font
		Gui, InfoProgress:Show, NA, %windowName%
	}
	else
		GUIs.Delete("InfoProgress")
}
is(var, is){
	if var is %is%
		return true
}
IsIP(input){
	if(RegExMatch(input, "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d+)$") OR RegExMatch(input, "^.+\..+$"))
		return 1
	return 0
}
IsFrak(fraknum, tog=0){
	global
	if(!frakbinds AND tog)
		return 0
	else if(Frak = fraknum)
		return 1
	return 0
}
IsURL(url){
	if(RegExMatch(url, "i)^https?://.*\..*"))
		return 1
	return 0
}
LeadingZero(num, zeros=2){
	loop, % (zeros-StrLen(num))
		num := "0" num
	return num
}
List(arr, pre="", sort=0, max=63, delimit="   "){
	l := strlen(delimit)
	if(sort)
		arr := ArraySort(arr)
	str := pre
	first := 1
	for i, k in arr
	{
		if(StrLen(str)+StrLen(k) > max-l){
			AddChatMessage(str)
			str := pre
			first := 1
		}
		str .= (first ? "" : delimit) k
		first := 0
	}
	if(str)
		AddChatMessage(str)
}
mixWord(input, level=3){
	if(StrLen(input) <= 1)
		return input
	chars := Object()
	in := input
	chars_num := StrLen(in)
	loop{
		loop, %level%
		{
			loop, Parse, in
				chars[A_Index] := A_LoopField
			output := ""
			loop, %chars_num%
			{
				Random, rand, 0, 1
				if(rand = 0)
					output .= chars[A_Index]
				else
					output := chars[A_Index] output
			}
			in := output
		}
	} until output != input OR A_Index > 5
	return output
}
NewHotkey(Hotkey, Label){
	global OldHotkeys, OldHotkeyLabels
	Errors := 0
	Hotkey, %Hotkey%, %Label%, UseErrorLevel
	Errors += ErrorLevel
	Hotkey, %Hotkey%, On, UseErrorLevel
	Errors += ErrorLevel
	OldHotkeys.Insert(Hotkey)
	OldHotkeyLabels.Insert(Label)
	return Errors
}
NextNovaLocation(pos_x="", pos_y="", pos_z=""){
	global hModule
	static Locations, last := Object(), IsPlayerInAnyInterior_func
	if(!Locations){
		IsPlayerInInterior_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsPlayerInInterior")
		Locations_raw := "Lagerverkauf|1449|2350|12|1,LV Productions|-224|2601|64|1,Adminbase|-456|2593|50|1,Toter Flughafen|214|2502|18|1,Raffinerie|264|1415|12|1,Fort Carson|-125|1101|21|1,SAM AG Base|-1943|486|34|1,Zombotech|-1954|617|35|1,SF Bank|-1808|533|35|1,Police Department SF|-1699|697|25|1,SF Bahnhof|-1984|145|28|2,Feuerwehr SF|-2023|82|28|1,TÜV|-2027|-99|35|1,Radio SF|-2520|-618|133|1,Sägewerk|-2003|-2414|31|1,Angelpine|-2164|-2392|30|1,Mount Chiliad|-2309|-1636|484|1,Angelpine Tankstelle|-1623|-2695|48|1,Funpark SF|-2112|-445|39|1,Stadthalle SF|-1498|919|7|1,Heißluftballon SF|-1494|803|7|1,SF Werkstatt|-2036|177|29|1,Flugzeugträger|-1335|483|12|1,Pier 69|-1661|1387|7|1,SF Kirche|-1985|1118|54|1,24/7 SF|-2443|754|35|1,Bootsanlegesteg SF|-2946|482|5|1,SARD Base SF|-2663|611|14|1,Verwahrplatz SF|-2603|687|28|1,Donutladen SF|-2766|789|53|1,SF Carshop|-2427|1023|50|1,Paintball Arena|-2277|2290|5|1,Las Barrancas|-824|1438|14|1,Staudamm LV|-734|2052|60|1,Big Ear|-359|1590|77|1,Army Base|61|1838|18|1,LV Airport|1538|1598|11|2.2,Otto's Autohaus|-1650|1217|7|1,SF Kran|-1547|127|3|1,Premium Autohaus|-1588|40|17|1,Carheal-Shop|-1722|-118|3|1,SF Airport|-1524|-230|13|2.2,Flyshop SF|-1262|38|14|1,Erzmine|826|851|12|1,Heißluftballon LV|926|835|13|1,FBI Base|1026|1174|11|1,Caligula's Autohaus|2436|1653|11|1,NewComer Autohaus|1652|2191|11|1,Four Dragons Casino|2031|1010|11|1,Hitmen Base|1875|701|11|1,Rebellen Base|2774|914|11|1,Oldtimer Autohaus|225|19|2|1,Farm|-65|8|3|1,Fleischberg|-119|-353|1|1,Kraftwerk SF|-1019|-662|32|1,Truckstop Autohaus|-53|-1141|1|1,Truckstop Tankstelle|-88|-1170|2|1,Wohnmobilkaufhaus|-71|-1587|3|1,OC Taufsee|-758|-2020|5|1,LCN Base|323|-1192|76|1,tripleb's Hütte|1443|-631|96|1,Xraid's Hütte|1331|-632|109|1,Vinewood Auffahrt|1376|-921|34|1,Motorradladen SF|-2591|62|4|1,Wheel Arch Angels|-2712|218|4|1,Justin's Farm|-1096|-1644|76|1,Piertreppe|399|-1792|7|0.6,LS Pier|370|-1861|8|1.6,LS Pierparkplatz|416|-2000|8|0.8,Heißluftballon LS|307|-1867|3|0.7,Strandautohaus|536|-1812|6|1,Pier PNS|488|-1739|11|1,Hafenklause|942|-1967|6|1,Busspawn|1263|-1822|13|1,24/7 Stadthalle|1353|-1758|13|1,LS Stadthalle|1478|-1745|13|1,Ornungsamt Base|1587|-1636|13|1,Police Department LS|1519|-1554|18|1,Noobspawn|1120|-1478|16|1,Taxistand|1051|-1366|13|1,Donutladen LS|1038|-1339|14|1,Verwahrplatz LS|927|-1229|17|1,Fahrschule|776|-1329|13|1,Market Station|815|-1344|13|1,Friedhof|867|-1102|24|1,Dillimore|685|-572|16|1,Dillimore Tankstelle|658|-562|16|1,Dillimore Pub|683|-477|16|1,Autovermietung|547|-1282|17|1,BSN PNS|1023|-1026|32|1,BSN Tankstelle|1005|-941|42|1,LS Burger Shot Nord|1213|-904|43|1.5,24/7 BSN|1316|-904|39|1,LS Bank|1464|-1013|27|1,Bankparkplatz|1577|-1030|24|1,Lottoladen|1632|-1169|24|1,Startower|1572|-1336|16|1,Straßenreinigung|1519|-1281|14|1,Glen Park|1954|-1203|18|1,LS Office|1787|-1300|13|1,Noobautohaus|2126|-1130|25|1,Noobhotel|2231|-1160|26|1,IKEA|2349|-1414|24|1,Basketballplatz|2291|-1527|27|1,Stuntpark|1917|-1427|10|1,Grove Street|2485|-1666|13|1,GS Binco|2245|-1664|15|1,Fitnesscenter|2227|-1723|13|1,LS Arena|2690|-1697|10|1,GS Autohaus|2783|-1615|11|1,Pig Pen|2421|-1223|25|1,GS Kneipe (Ten Green Bottles)|2317|-1650|14|1,Ballas Base|2511|-2009|13|1,Truck-Autohaus|2456|-2098|13|1,LS Docks|2760|-2451|13|1,LS Train Station|2186|-2277|13|1,LS Airport|1940|-2443|13|2.2,Los Vagos Base|2260|-1038|53|1,LS Bahnhof|1721|-1947|13|1,Alhambra|1834|-1683|13|1,PNS East LS|2077|-1831|13|1,GS Tankstelle|1936|-1772|13|1,SAPlayer's Hütte|-595|-1057|23|1,Ammunation LS|1369|-1280|14|1,GS Ammunation|2401|-1981|14|1,FastFood AG|-1803|908|26|1,SF Burger Shot Süd|-2335|-167|36|1,SF Cluckin' Bell Süd|-2673|260|5|1,SF Cluckin' Bell Nord|-1817|617|35|1,SF Burger Shot Mitte|-1912|830|35|1,SF Carshop Tankstelle|-2419|969|45|1,SF Burger Shot Nord|-2356|1007|51|1,SF Tankstelle Ost|-1675|431|7|1,SF PNS|-1906|285|41|1,SF Tankstelle West|-2032|161|29|1,Nova Transportlogistik GmbH|-521|-487|27|1,LS Burger Shot Süd|813|-1617|14|1,LS Cluckin' Bell West|927|-1353|13|1,TransFender LS|1041|-1026|32|1,LS Cluckin' Bell Grove|2398|-1897|14|1,Loco Low Co.|2645|-2039|14|1,TransFender LV|2387|1043|11|1,LV Tankstelle|639|1684|7|1,Heiliges Huhn|-237|2663|64|1,Heilige Kuh|-857|1536|23|1,SF Tunnel|-1019|-985|91|2.5,LS Casino|575|-1386|14|1,Yakuza Base|-2608|1354|7|1,SF Rifa Base|-2718|-320|7|1,LV West Tankstelle|-1316|2694|50|1,SF Trailerspawn|-1730|101|5|1,SARD Base LS|2024|-1425|16|1,Feuerwache San Andreas|1745|-1143|24|1"
		Locations := Object()
		loop, Parse, Locations_raw, `,
		{
			RegExMatch(A_LoopField, "^(.+)\|(-?\d+)\|(-?\d+)\|(-?\d+)\|([\d\.]+)$", L)
			Locations.Insert({Name: L1, x: L2, y: L3, z: L4, mult: L5})
		}
		Locations_raw := ""
	}
	max := Object()
	if(A_TickCount - last["call"] < 100 AND last["call"])
		return {Name: last["Name"], Distance: last["Distance"]}
	if(AnyInterior := DllCall(IsPlayerInInterior_func))
		return {Name: "[Innenraum]", distance: "-"}
	if(pos_x = "" OR pos_y = "" OR pos_z = "")
		GetPlayerPosition(pos_x, pos_y, pos_z)
	x := Round(pos_x), y := Round(pos_y), z := Round(pos_z)
	;AddChatMessage(x "  " y "  " z)
	if((x = 1133 AND y = -2038 AND z = 69) OR (x = 2004 AND y = -1358 AND z = 24) OR (x = 363 AND y = -2052 AND z = 8) OR (x = 1205 AND y = -890 AND z = 43))
		return {Name: "[Login]", distance: "-"}
	for i, k in Locations
	{
		d := Pythagoras(pos_x - k["x"], pos_y - k["y"], pos_z - k["z"])
		d_mult := d / k["mult"]
		if(d_mult < max["distance_mult"] OR max["distance_mult"] = ""){
			max["distance_mult"] := d_mult
			max["distance"] := d
			max["Name"] := k["Name"]
		}
	}
	last := max
	last["call"] := A_TickCount
	return max
}
number_format(num){
	return RegExReplace(num, "\B(?=(\d{3})+(?!\d))", ".")
}
OverlayReplace(text, InVehicle){
	static called, GetPlayerHealth_func, GetPlayerArmor_func, GetPlayerId_func, GetPlayerMoney_func, GetZoneName_func, GetCityName_func, GetVehicleHealth_func, GetFramerate_func, GetVehicleSpeed_func, GetVehicleModelId_func, GetVehicleModelName_func, IsVehicleLocked_func, IsVehicleEngineEnabled_func, IsVehicleLightEnabled_func, old_id
	global UseAPI, Nickname, hModule, LastUseLsd, NextUseGreenDonutGold
	if(!UseAPI)
		return
	if(!called){
		called := 1
		GetPlayerHealth_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetPlayerHealth")
		GetPlayerArmor_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetPlayerArmor")
		GetPlayerId_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetPlayerId")
		GetPlayerMoney_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetPlayerMoney")
		GetZoneName_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetZoneName")
		GetCityName_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetCityName")
		GetVehicleHealth_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetVehicleHealth")
		GetFrameRate_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetFrameRate")
		GetVehicleSpeed_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetVehicleSpeed")
		GetVehicleModelId_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetVehicleModelId")
		GetVehicleModelName_func := DllCall("GetProcAddress", UInt, hModule, AStr, "GetVehicleModelName")
		IsVehicleLocked_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsVehicleLocked")
		IsVehicleEngineEnabled_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsVehicleEngineEnabled")
		IsVehicleLightEnabled_func := DllCall("GetProcAddress", UInt, hModule, AStr, "IsVehicleLightEnabled")
	}
	if(InStr(text, "[HP]"))
		StringReplace, text, text, [HP], % DllCall(GetPlayerHealth_func), All
	if(InStr(text, "[Armor]"))
		StringReplace, text, text, [Armor], % DllCall(GetPlayerArmor_func), All
	/*
	if(InStr(text, "[ID]")){
		if((id := DllCall(GetPlayerId_func)) = 65535){
			if(old_id != "")
				id := old_id
			else
				id := "[Fehler]"
		}
		else
			old_id := id
		StringReplace, text, text, [ID], %id%, All
	}
	*/
	if(InStr(text, "[Money]"))
		StringReplace, text, text, [Money], % number_format(DllCall(GetPlayerMoney_func)), All
	if(InStr(text, "[Zone]")) {
		VarSetCapacity(Zone, 64, 0)
		res :=DllCall(GetZoneName_func, "StrP", Zone, "Int", 32)
		Zone := StrGet(&Zone, "cp0")
		StringReplace, text, text, [Zone], % res ? Zone : "[Fehler]", All
	}
	if(InStr(text, "[City]")) {
		VarSetCapacity(City, 64, 0)
		res := DllCall(GetCityName_func, "StrP", City, "Int", 32)
		City := StrGet(&City, "cp0")
		StringReplace, text, text, [City], % res ? City : "[Fehler]", All
	}
	if(InStr(text, "[CarHeal]"))
		StringReplace, text, text, [CarHeal], % ((dl := DllCall(GetVehicleHealth_func, "Cdecl Float")) > 0) ? number_format(Round(dl)) : "[Fehler]", All
	if(InStr(text, "[CarName]")) {
		VarSetCapacity(name, 64, 0)
		res := DllCall(GetVehicleModelName_func, StrP, name, Int, 32)
		name := StrGet(&name, "cp0")
		StringReplace, text, text, [CarName], % res ? name : "[Fehler]", All
	}
	if(InStr(text, "[CarModel]"))
		StringReplace, text, text, [CarModel], % (model := DllCall(GetVehicleModelId_func)) ? model : "[Fehler]", All
	if(InStr(text, "[CarLock]"))
		StringReplace, text, text, [CarLock], % ["[Fehler]", "aufgeschlossen", "abgeschlossen"][DllCall(IsVehicleLocked_func)-!InVehicle+2], All
	if(InStr(text, "[CarMotor]"))
		StringReplace, text, text, [CarMotor], % ["[Fehler]", "aus", "an"][DllCall(IsVehicleEngineEnabled_func)-!InVehicle+2], All
	if(InStr(text, "[CarLight]"))
		StringReplace, text, text, [CarLight], % ["[Fehler]", "aus", "an"][DllCall(IsVehicleLightEnabled_func)-!InVehicle+2], All
	if(InStr(text, "[CarSpeed]"))
		StringReplace, text, text, [CarSpeed], % (InVehicle AND (speed := DllCall(GetVehicleSpeed_func, Float, 1.62)) > -1) ? speed : "[Fehler]", All
	if(InStr(text, "[FPS]"))
		StringReplace, text, text, [FPS], % DllCall(GetFrameRate_func), All
	if(InStr(text, "[Time]"))
		StringReplace, text, text, [Time], % A_Hour ":" A_Min ":" A_Sec, All
	if(InStr(text, "[Date]"))
		StringReplace, text, text, [Date], % A_DD "." A_MM "." A_YYYY, All
	if(InStr(text, "[NL")){
		NL := NextNovaLocation()
		StringReplace, text, text, [NL], % NL["Name"], All
		StringReplace, text, text, [NLDistance], % NL["Distance"] = "-" ? "-" : Round(NL["Distance"]) "m", All
	}
	if(InStr(text, "[Name]"))
		StringReplace, text, text, [Name], % Nickname ? Nickname : SAMPName, All
	if(InStr(text, "[LsdTimer]")){
		replaceText := "-"
		if (LastUseLsd > 0){
			diff := Round((A_TickCount - LastUseLSD) / 1000)
			if(diff < 90)
				replaceText := "Nachwirkungen " (90 - diff) "s/Use " (120 - diff) "s"
			else if(diff < 120)
				replaceText := "Use möglich in " (120 - diff) "s"
			else if (diff < 180)
				replaceText := "(Use möglich)"
		}
		StringReplace, text, text, [LsdTimer], %replaceText%, All
	}
	if(InStr(text, "[GreenTimer]") OR InStr(text, "[DonutTimer]") OR InStr(text, "[GoldTImer]")){
		replaceText := "-"
		if (NextUseGreenDonutGold > 0){
			diff := Round((NextUseGreenDonutGold - A_TickCount) / 1000)
			if(diff > 0)
				replaceText := "Use möglich in " diff "s"
			else if (diff > -60)
				replaceText := "(Use möglich)"
		}
		StringReplace, text, text, [GreenTimer], %replaceText%, All
		StringReplace, text, text, [DonutTimer], %replaceText%, All
		StringReplace, text, text, [GoldTimer], %replaceText%, All
	}
	charMap := {"Ä": "Ae", "ä": "ae", "Ö": "oe", "ö": "oe", "Ü": "Ue", "ü": "ue", "ß": "ss"}
	for char in charMap
		text := RegExReplace(text, "i)" char, charMap[char])
	return text
}
ping(host, packagesize=32, timeout=5000){ ;http://www.autohotkey.com/de/forum/viewtopic.php?t=8710 //Bentschi
	static packagecontent := "AHK PING TEST -+- "
	if(packagesize < 12)
		packagesize := 12
	if((s := DllCall("ws2_32\socket", "int", 2, "int", 3, "int", 1, "ptr")) = -1){
		if(DllCall("ws2_32\WSAGetLastError", "int")=10093){
			hws2_32 := DllCall("LoadLibrary", "str", "ws2_32", "ptr")
			VarSetCapacity(wsaData, 394+A_PtrSize, 0)
			wsstarted := ((DllCall("ws2_32\WSAStartup", "ushort", (0<<8)|2, "ptr", &wsaData)=0) ? 1 : 0)
		}
		s := DllCall("ws2_32\socket", "int", 2, "int", 3, "int", 1, "ptr")
	}
	if (s = -1){
		if(wsstarted){
			DllCall("ws2_32\WSACleanup")
			DllCall("FreeLibrary", "ptr", hws2_32)
		}
		return -1
	}
	VarSetCapacity(optval, 4, 0)
	NumPut(timeout, optval, 0, "int")
	DllCall("ws2_32\setsockopt", "ptr", s, "int", 0xFFFF, "int", 0x1006, "ptr", &optval, "int", 4)
	pid := DllCall("GetCurrentProcessId", "uint") & 0xFFFF
	VarSetCapacity(bhints, 16+4*A_PtrSize, 0)
	NumPut(2, bhints, 4, "int")
	NumPut(3, bhints, 8, "int")
	NumPut(1, bhints, 12, "int")
	DllCall("ws2_32\getaddrinfo", "astr", host, "astr", port, "ptr", &bhints, "ptr*", next)
	if(!next){
		DllCall("ws2_32\closesocket", "ptr", s)
		if(wsstarted){
			DllCall("ws2_32\WSACleanup")
			DllCall("FreeLibrary", "ptr", hws2_32)
		}
		return -2
	}
	addr := NumGet(next+0, 16+2*A_PtrSize, "ptr")
	addrlength := NumGet(next+0, 16, "ptr")
	VarSetCapacity(recvbuf, 65200)
	VarSetCapacity(package, packagesize, 0)
	while(strlen(packagecontent) < (packagesize-12))
		packagecontent .= packagecontent
	StrPut(packagecontent, &package+12, packagesize-12, "UTF-8")
	NumPut(8, package, 0, "uchar") ;ICMP echo
	NumPut(pid, package, 4, "ushort")
	NumPut(start := A_TickCount, package, 8, "uint")
	packageaddr := &package
	packagelen := packagesize
	cksum := 0
	while(packagelen > 1){
		cksum += NumGet(packageaddr+0, 0, "ushort")
		packageaddr += 2
		packagelen -= 2
	}
	if(len)
		cksum += NumGet(packageaddr+0, 0, "uchar")<<8
	while(cksum>>16)
		cksum := (cksum&0xFFFF)+(cksum>>16)
	NumPut(cksum^0xFFFF, package, 2, "ushort")
	if((r := DllCall("ws2_32\sendto", "ptr", s, "ptr", &package, "int", packagesize, "int", 0, "ptr", addr, "int", addrlength)) < packagesize){
		DllCall("ws2_32\closesocket", "ptr", s)
		if(wsstarted){
			DllCall("ws2_32\WSACleanup")
			DllCall("FreeLibrary", "ptr", hws2_32)
		}
		return -3
	}
	while(1){
		recvlen := DllCall("ws2_32\recv", "ptr", s, "ptr", &recvbuf, "int", 65200, "int", 0)
		stop := A_TickCount
		if(recvlen = -1){
			DllCall("ws2_32\closesocket", "ptr", s)
			if(wsstarted){
				DllCall("ws2_32\WSACleanup")
				DllCall("FreeLibrary", "ptr", hws2_32)
			}
			return (DllCall("ws2_32\WSAGetLastError", "int")=10060) ? -4 : -5
		}
		icmpoffset := (NumGet(recvbuf, 0, "int")&0xF)*4
		recvicmphdr := &recvbuf+icmpoffset
		if(NumGet(recvicmphdr+0, 4, "ushort")!=pid)
			continue
		if(NumGet(recvicmphdr+0, 0, "uchar")=3){
			result := NumGet(recvicmphdr+0, 1, "uchar")
			if((result=0) || (result=1)){
				DllCall("ws2_32\closesocket", "ptr", s)
				if(wsstarted){
					DllCall("ws2_32\WSACleanup")
					DllCall("FreeLibrary", "ptr", hws2_32)
				}
				return (result=0) ? -6 : -7
			}
		}
		if(NumGet(recvicmphdr+0, 0, "uchar")=0){
			DllCall("ws2_32\closesocket", "ptr", s)
			if(wsstarted){
				DllCall("ws2_32\WSACleanup")
				DllCall("FreeLibrary", "ptr", hws2_32)
			}
			return stop-start
		}
	}
}
PlayerInput(text, trim=1){
	s := A_IsSuspended
	Suspend On
	KeyWait Enter
	SendInput t^a{backspace}%text%
	str := ""
	loop{
		Input, var, v, {enter}{LControl}{RControl}
		str .= var
		if(InStr(ErrorLevel, "Control")){
			var := 0
			while(GetKeyState("Ctrl", "P") AND !GetKeyState("Alt", "P")){
				if(GetKeyState("V", "P"))
					var := 1
				Sleep, 10
			}
			if(var)
				str .= RegExReplace(Clipboard, "`a)`n|`t")
		}
		else
			break
	}
	var := str
	SendInput ^a{backspace}{enter}
	if(!s)
		Suspend Off
	if(trim)
		return Trim(var)
	else
		return var
}
print_r(input){
	output := ""
	if(!IsObject(input))
		return input
	this := input
	tabs := ""
	ThisArray:
	if(IsObject(this)){
		output .= "Array`n" tabs "(`n"
		tabs .= "`t"
		for i, k in this
		{
			if(IsObject(k)){
				this := k
				output .= tabs "[" i "] => "
				gosub ThisArray
			}
			else
				output .= tabs "[" i "] => " k "`n"
		}
		tabs := SubStr(tabs, 1, -1)
		output .= tabs ")`n"
	}
	return Trim(output, "`n")
}
Pythagoras(n*){
	r := 0
	for i, k in n
		r += k**2
	return sqrt(r)
}
RegExFileRead(string, key, default=-1){
	if(RegExMatch(string, "Um`a)^\Q" key "\E=(.*)$", out))
		return out1
	return default
}
RoundEx(num, n=0){
	if((out := Round(num, n)) != num)
		out := "~" out
	return out
}
SB_SetTextEx(text){
	SB_SetText(text)
	Gui, +LastFound
	SendMessage, 0x410, 0, % """" text """", msctls_statusbar321
}
SendHKey(Hkey=""){
	SendInput, % RegExReplace(RegExReplace((HKey ? HKey : A_ThisHotkey), "i)[^\^\+!#]{2,}", "{$L0}"), "\w", "$L0")
}
SendWPs(crime, wps){
	pi := PlayerInput("ID für " crime " (" (wps > 0 ? wps : "?") " WPs): ")
	if(pi = "")
		return
	ia := ""
	RegExMatch(pi, "Ui)^(.*)(\s+i\.A\.\s+(.*))?$", id)
	RegExMatch(id1, "^((d|r)\s+)?(.*)\s*$", data)
	if data3 is not integer
	{
		SendChat("/id " data3)
		chat := WaitForChatLine(0, "ID:")
		RegExMatch(chat, "U)ID: \((\d*)\) ", chat)
		if(chat1)
			data3 := chat1
	}
	if(id3)
		ia := " i.A. " id3
	if(data2)
		SendChat("./" data2 " ID " data3 " | " wps " WPs | " crime " | bitte best." ia)
	else
		SendChat("/su " data3 " " wps " " crime ia)
}
SetTimerNow(Label, time){
	SetTimer, %Label%, %time%
	gosub %Label%
}
SetWB(wb, html, useheader=1, bgColor="FFFFFF"){
	wb.Navigate("about:blank")
	while(wb.ReadyState != 4){
		if(A_Index > 30){
			ToolTip("Ein Fehler ist aufgetreten", 1000)
			return -1
		}
		Sleep 10
	}
	wb.Document.open()
	if(useheader){
		global UseDesign, AppliedDPI	
		zoomlevel := (AppliedDPI / 96) ** 2 * 100
		wb.ExecWB(OLECMDID_OPTICAL_ZOOM:=63, OLECMDEXECOPT_DODEFAULT:=0, Round(zoomlevel))
		html := RegExReplace(html, "`a)`n", "<br>")
		if(UseDesign = 3){
			html =
			(
<!DOCTYPE html>
<html>
    <head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
        <style type="text/css">
            body{
                margin: 0 0;
                background-color: #%bgColor%;
                overflow: auto;
                font-size: 12px;
                font-family: Arial;
				color: #ddd;
            }
            ul{
                margin: 0;
				padding: 0 15px;
            }
            table{
                border-collapse: collapse;
                width: 100`%;
				color: #000;
                font-size: 11px;
            }
            table th{
                background: #eee;
                text-align: left;
                font-weight: normal;
            }
			table td{
				background: #ccc;
			}
            table td, table th{
                padding: 3px;
                text-align: left;
                width: auto;
            }
			table tr:hover td{
                background: #9bccfc;
            }
            a{
                color: #ddd;
            }
            a:visited{
                color: #888;
            }
            a:hover{
                color: #fff;
            }
			table a{
				color: #000;
			}
			table a:visited{
				color: #555;
			}
            .new{
                font-size: 9px;
                color: red;
            }
			.hint{
				font-size: 11px;
				color: #888;
			}
            .small{
                font-size: 11px;
            }
			.dyk{
				font-size: 13px;
				color: #ddd;
				text-align: left;
				border: 1px solid #3f3f3f;
			}
			.dyk-header{
				color: #000;
				background-color: #ddd;
				font-weight: bold;
				line-height: 20px;
			}
        </style>
    </head>
    <body>
        %html%
    </body>
</html>
			)
		} else {
			html =
			(
<!DOCTYPE html>
<html>
    <head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
        <style type="text/css">
            body{
                margin: 0 0;
                background-color: #%bgColor%;
                overflow: auto;
                font-size: 12px;
                font-family: Arial;
            }
            ul{
                margin: 0;
				padding: 0 15px;
            }
            table{
                border-collapse: collapse;
                width: 100`%;
                font-size: 11px;
            }
            table th{
                background: #282828;
                color: #fff;
                text-align: left;
                font-weight: normal;
            }
            table td, table th{
                padding: 3px;
                text-align: left;
                width: auto;
            }
			table tr:hover{
                background: #EAECEE;
                color: #111;
            }
            a{
                color: #000;
            }
            a:visited{
                color: #444;
            }
            a:hover{
                color: #888;
            }
            .new{
                font-size: 9px;
                color: red;
            }
			.hint{
				font-size: 11px;
				color: #363636;
			}
            .small{
                font-size: 11px;
            }
			.dyk{
				font-size: 13px;
				color: #222222;
				text-align: left;
				border: 1px solid #ddd;
			}
			.dyk-header{
				color: #FFFFFF;
				background-color: #282828;
				font-weight: bold;
				line-height: 20px;
			}
        </style>
    </head>
    <body>
        %html%
    </body>
</html>
			)
		}
	}
	wb.Document.write(html)
	wb.Document.Close()
}
StrCalc(str){ ;http://www.php.de/php-tipps-2010/66855-mathematische-berechnung-vom-stringinhalt.html#post507927
	stack := Object()
	v := Object()
	m := Object()
	v[0] := v[1] := op := ""
	pos := 0
	str := RegExReplace(RegExReplace(str, "\s"), "[\d.]+[*/][\d.]+", "($0)")
	while(pos := RegExMatch(str, "([()+*/^-]|(\-?[\d.]+))", regex, pos + (StrLen(regex1) ? StrLen(regex1) : 1)))
		m.Insert(regex1)
	for i, tk in m
	{
		if(tk = "+" OR tk = "-" OR tk = "*" OR tk = "/" OR tk = "^"){
			op := tk
			continue
		}
		else if(tk = "("){
			stack.Insert([v[0], v[1], op])
			v[0] := v[1] := op := ""
			continue
		}
		else if(tk = ")"){
			kResult := v[0]
			v[0] := stack[stack._maxIndex(), 1]
			v[1] := stack[stack._maxIndex(), 2]
			op := stack[stack._maxIndex(), 3]
			stack.Remove()
			v[(v[0] = "") ? 0 : 1] := kResult
			bracketMode := 1
		}
		if(!bracketMode)
			v[((op = "") && (v[0] = "")) ? 0 : 1] := tk
		if(v[1] != ""){
			if(op = "+")
				v[0] := v[0] + v[1]
			else if(op = "-")
				v[0] := v[0] - v[1]
			else if(op = "*")
				v[0] := v[0] * v[1]
			else if(op = "/")
				v[0] := v[0] / v[1]
			else if(op = "^")
				v[0] := v[0] ** v[1]
			op := v[1] := ""
		}
		bracketMode := 0
	}
	return v[0]
}
toMoney(str){
	StringReplace, str, str, .,, All
	StringReplace, str, str, $,, All
	StringReplace, str, str, €,, All
	StringReplace, str, str, % ",", ., All
	if(RegExMatch(Trim(str), "Ui)^([\d.]+?)\s*([^\d]+)$", regex)){
		if(regex2 = "m")
			str := regex1 * 1000000
		else if(regex2 = "k")
			str := regex1 * 1000
		else
			str := regex1
	}
	return Round(Trim(str))
}
ToolTip(text="", time=0, x="", y="", num=""){
	ToolTip, %text%, %x%, %y%, %num%
	if(time)
		SetTimer, HideTT, % "-" Abs(time)
	return
	HideTT:
	ToolTip
	return
}
TrimNum(num){
	if(num = 0)
		return 0
	oldnum := num
	while((num2 := SubStr(num, 1, -A_Index)) = num)
		oldnum := num2
	return oldnum
}
URLEncode(raw){
	out := ""
	oldformat := A_FormatInteger
	SetFormat, Integer, Hex
	loop, % StrLen(raw){
		asc := Asc(char := SubStr(raw, A_Index, 1))
		if(asc = 0x20)
			out .= "+"
		else if(between(asc, 48, 57) OR between(asc, 65, 90) OR between(asc, 97, 122))
			out .= char
		else if(asc < 128)
			out .= "%" SubStr(asc, 3)
		else if(asc < 192)
			out .= "%C2%" SubStr(asc, 3)
		else
			out .= "%C3%" SubStr(asc - 64, 3)
	}
	SetFormat, Integer, %oldformat%
	return out
}
WaitFor(){
	global WaitFor
	ping("server.nes-newlife.de", 32, 400)
	Sleep, % WaitFor
}
wb_BeforeNavigate2(wb, url, flags, frame, postdata, headers, cancel){ ;AHK-Installer //Lexikos
	global _mainGui
	if(SubStr(url, 1, 6) = "about:")
		return
	static m1, m2
	NumPut(-1, ComObjValue(cancel), "short")
    if(RegExMatch(url, "i)^sBinder://(.*?)/(.*)$", m)){
		StringReplace m2, m2, `%20, %A_Space%, All
		SetTimer wb_bn2_call, -15
	}
	else if(SubStr(url, 1, 8) != "file:///"){
		Run, %url%,, UseErrorLevel
		if(ErrorLevel)
			ToolTip("Fehler beim Starten des " (IsURL(url) ? "Browsers" : "Programms") "!", 5000)
	}
    return
	wb_bn2_call:
	if(m1 = "go" OR m1 = "g"){
		loop, Parse, m2, `;
		{
			if(IsLabel(A_LoopField) AND (wb != _mainGui OR RegExMatch(A_LoopField, ".*GUI$|^Help\d*$|^Forum(Thread)?$|Connect$|^SimpleSAM$|.*Online$")))
				gosub %A_LoopField%
		}
	}
	else if(m1 = "MsgBox")
		MsgBox, %m2%
	else if(m1 = "Settings"){
		gosub SettingsGUI
		if(m2)
			GuiControl, SettingsGUI:Choose, SettingsListBox, |%m2%
	}
    return
}
wb_NavigateError(wb, url, frame, status, cancel){ ;AHK-Installer //Lexikos
    wb_BeforeNavigate2(wb, url, 0, frame, "", "", cancel)
}
WM_HANDLER(wParam, lParam, msg, hwnd){
	static CursorMove
	global GUIs
	if(msg = 0x47){ ;WM_WINDOWPOSCHANGED
		if(A_Gui = 1){
			global TrayMinimize
			if(!TrayMinimize)
				return
			WinGet, min, MinMax, % "ahk_id " GUIs["mainGUI"]
			if(min = -1){
				Gui, 1:Cancel
				TrayTip, sBinder, Der sBinder wurde in die Trayleiste minimiert, 1, 1
			}
		}
	}
	else if(msg = 0x200){ ;WM_MOUSEMOVE
		if((A_Gui = "AFKBox" AND A_GuiControl = "") OR A_Gui = "InfoProgress"){
			if(!CursorMove)
				CursorMove := DllCall("LoadCursor", "UInt", "", "Int", 32646, "UInt") ;IDC_SIZEALL
			DllCall("SetCursor", "UInt", CursorMove)
		}
	}
	else if(msg = 0x201){ ;WM_LBUTTONDOWN
		if(A_Gui = "AFKBox" AND A_GuiControl = "")
			PostMessage, 0xA1, 2, 0,, % "ahk_id " GUIs["AFKBox"]
		if(A_Gui = "InfoProgress")
			PostMessage, 0xA1, 2, 0,, % "ahk_id " GUIs["InfoProgress"]
	}
	else if(msg = 0x204){ ;WM_RBUTTONDOWN
		if(A_GuiControl = "Nickname" AND A_Gui = 1)
			Menu, NicknameAction, Show
		else if(A_GuiControl = "TruckLV" AND A_Gui = "TruckerGUI")
			Menu, TruckLVAction, Show
	}
	else if(msg = 0x216){ ;WM_MOVING
		if(A_Gui = "AFKBox")
			SetTimer, SaveAFKBoxPos, -1000
	}
}

;#Include C:\Users\Marcel\Autohotkey\PHPFunctions.ahk

#if frakbinds && WinActive("ahk_group GTASA")
#IfWinActive, ahk_group GTASA
#SingleInstance, force
#UseHook
#HotString EndChars `n
#HotString ?


gosub Open
GroupAdd, GTASA, ahk_class Grand theft auto San Andreas ahk_exe %GTAProcessName%
if (UseAPI) {
	SetParam("process", GTAProcessName)
	DllCall(Init_func)
	DllCall(DestroyAllVisual_func)
}
GUIs := Object()
GUIs.Insert(0, "AboutGUI", "SettingsGUI", "CreditsGUI", "CustomBindsGUI", "CarCalcGUI", "TruckerGUI", "FrakGUI", "JobGUI", "NotesGUI")
gosub mainGUI
GUIs["mainGUI"] := mainGUI
gosub BuildGUIs
OnMessage(0x47, "WM_HANDLER") ;WM_WINDOWPOSCHANGED (für TrayMinimize)
OnMessage(0x200, "WM_HANDLER") ;WM_MOUSEHOVER (für AFKBox und InfoProgress)
OnMessage(0x201, "WM_HANDLER") ;WM_LBUTTONDOWN (für AFKBox und InfoProgress)
OnMessage(0x204, "WM_HANDLER") ;WM_RBUTTONDOWN (fürs Kontextmenü von Edits usw.)
if(AFKBox)
	SetTimerNow("AFKBox_CheckDesk", 500)
if(InStr(FullArgs, "--just-updated")){
	Gui, TempGUI2:Destroy
	Gui, TempGUI2:Color, FFFFFF, 282828
	Gui, TempGUI2:Add, Text,, Das Update wurde erfolgreich abgeschlossen.`nDu kannst den sBinder jetzt in der Version %Version%-%Build% nutzen.
	Gui, TempGUI2:Add, Button, gChangelogOnline y50 x10 w120, Changelog anzeigen
	Gui, TempGUI2:Add, Button, gTempGUI2GuiClose y50 x220 w80, Schließen
	Gui, TempGUI2:Show, % (WinActive("ahk_group GTASA") ? "NA" : ""), Update abgeschlossen
}

; Enable FrakGui from the start since frak passwords are no longer required
gosub FrakGuiBuild
if(UseHTMLGUI){
	_mainGUI.Document.getElementById("FrakGUI").className := "button"
	_mainGUI.Document.getElementById("FrakGUI").href := "sBinder://g/FrakGUI"
}
else
	GuiControl, 1:Enable, FrakGUI
gosub FrakChangeGuiBuild

gosub HotkeysDefine
gosub Downloads
if(OverlayActive AND UseAPI)
	SetTimerNow("Overlay", 500)
Sleep, 20
if(Startup_Fraps)
	SetTimer, RunFraps, % Abs(Startup_Fraps_Delay) * -1000
if(Startup_TS)
	SetTimer, TSConnect, % Abs(Startup_TS_Delay) * -1000
if(Startup_SAMP)
	SetTimer, Connect, % Abs(Startup_SAMP_Delay) * -1000
if(Startup_Other)
	SetTimer, RunOtherProgram, % Abs(Startup_Other_Delay) * -1000
if(AutoHitsound)
	SetTimer, AutoHitsound, 1000
return

Accept:
FileAppend,, %INIFile%
gosub Open
RegRead, Nickname, HKCU, Software\SAMP, playername
if(!Nickname)
	Nickname := "Name"
savemsg := 0
gosub Save
if(LastUsedBuild != Build)
	IniWrite, %Build%, %INIFile%, Settings, LastUsedBuild
Reload
return
LicenseGUIGuiClose:
ExitApp
return
Open:
RegRead, SAMPName, HKCU, Software\SAMP, playername
RegRead, AppliedDPI, HKCU, Control Panel\Desktop\WindowMetrics, AppliedDPI
if ErrorLevel
	AppliedDPI := 96 ; default DPI
IniRead, samppath, %INIFile%, Settings, SAMPPath, 0
IniRead, reloaded, %INIFile%, Settings, Reload, 0
IniRead, Nickname, %INIFile%, Settings, Name, Name
IniRead, Frak, %INIFile%, Settings, Fraktion, 1
IniRead, hmv, %INIFile%, Settings, AutoMv, 0
IniRead, TruckLevelLimit, %INIFile%, Settings, TruckLevelLimit, 1
IniRead, Design, %INIFile%, Settings, Design, 1
UseDesign := Design
if(InStr(FullArgs, "--design=") AND RegExMatch(FullArgs, "--design=\s*(\d+)", regex) AND Designs[regex1])
	UseDesign := regex1
IniRead, meTexte, %INIFile%, Settings, me, 1
loop, %FrakOptions%
	IniRead, Frakoption%A_Index%, %INIFile%, Settings, Frakoption%A_Index%, %A_Space%
IniRead, JobOption1, %INIFile%, Settings, JobOption1, 0
IniRead, TrayMinimize, %INIFile%, Settings, MinimizeToTray, 0
IniRead, TruckPics, %INIFile%, Settings, TruckPics, 1
IniRead, Job, %INIFile%, Settings, Job, 1
IniRead, TruckingSort, %INIFile%, Settings, TruckSort, 1
IniRead, TruckingSortOrder, %INIFile%, Settings, TruckSortOrder, 1
IniRead, AutoHitsound, %INIFile%, Settings, AutoHitsound, 0
IniRead, HitsoundText, %INIFile%, Settings, HitsoundText, %A_Space%
IniRead, chatlogpath, %INIFile%, Settings, ChatlogPath, %A_MyDocuments%\GTA San Andreas User Files\SAMP\chatlog.txt
if(!FileExist(chatlogpath))
	chatlogpath := A_MyDocuments "\GTA San Andreas User Files\SAMP\chatlog.txt"
if(LastUsedBuild = 0)
	gosub ChatlogSearch
IniRead, ServerIP, %INIFile%, IPs, Server, server.nes-newlife.de
if(!IsIP(ServerIP))
	ServerIP := "server.nes-newlife.de"
IniRead, TSIP, %INIFile%, IPs, TS, ts.nes-newlife.de
if(!IsIP(TSIP))
	TSIP := "ts.nes-newlife.de"
IniRead, WaitFor, %INIFile%, Settings, WaitFor, 90
IniRead, GTAProcessName, %IniFile%, Settings, GTAProcessName, gta_sa.exe
IniRead, UseTimerActive, %IniFile%, Settings, UseTimerActive, 1
IniRead, xBind1, %INIFile%, Binds, xBind1, %A_Space%
IniRead, xBind2, %INIFile%, Binds, xBind2, %A_Space%
IniRead, wBind1, %INIFile%, Binds, wBind1, %A_Space%
IniRead, wBind2, %INIFile%, Binds, wBind2, %A_Space%
IniRead, DownloadMode, %INIFile%, Settings, DownloadMode, 1
IniRead, SkipPing, %INIFile%, Settings, SkipPing, 0
IniRead, AFKBox, %INIFile%, Settings, AFKBox, 0
IniRead, Tel, %INIFile%, Telefon, Active, 0
IniRead, pText, %INIFile%, Telefon, p, Guten Tag, mein Name ist [Name].~Was kann ich für Sie tun?
IniRead, hText, %INIFile%, Telefon, h, Wiederhören.
IniRead, abText, %INIFile%, Telefon, ab, Sie sprechen mit dem Anrufbeantworter von [Name].~Leider ist [Name] zur Zeit nicht erreichbar.~Versuchen Sie es bitte später erneut!
if(!WaitFor)
	WaitFor := 70
IniRead, AFKBoxX, %INIFile%, WindowPos, AFKBox_X, % A_ScreenWidth - 200
IniRead, AFKBoxY, %INIFile%, WindowPos, AFKBox_Y, % A_ScreenHeight - 160
IniRead, Startup_SAMP, %INIFile%, Startup, SAMP, 0
IniRead, Startup_TS, %INIFile%, Startup, TS, 0
IniRead, Startup_Fraps, %INIFile%, Startup, Fraps, 0
IniRead, Startup_Other, %INIFile%, Startup, Other, 0
IniRead, Startup_SAMP_Delay, %INIFile%, Startup, SAMP_Delay, 20
IniRead, Startup_TS_Delay, %INIFile%, Startup, TS_Delay, 0
IniRead, Startup_Fraps_Delay, %INIFile%, Startup, Fraps_Delay, 0
IniRead, Startup_Other_Delay, %INIFile%, Startup, Other_Delay, 0
IniRead, Startup_Fraps_Path, %INIFile%, Startup, Fraps_Path, ERROR
IniRead, Startup_Other_Path, %INIFile%, Startup, Other_Path, %A_Space%
if(Startup_Fraps_Path == "ERROR" OR !FileExist(Startup_Fraps_Path)){
	RegRead, Startup_Fraps_Path, HKCU, Software\Fraps3, Directory
	if(ErrorLevel)
		RegRead, Startup_Fraps_Path, HKCU, Software\Fraps2, Directory
	if(Startup_Fraps_Path)
		Startup_Fraps_Path := Trim(Startup_Fraps_Path) "\Fraps.exe"
}
loop, %Binds%
{
	IniRead, Key%A_Index%, %INIFile%, Keys, Key%A_Index%, %A_Space%
	IniRead, Bind%A_Index%, %INIFile%, Binds, Bind%A_Index%, %A_Space%
}
loop, %Hotstrings%
{
	IniRead, Hotstring%A_Index%, %INIFile%, Keys, Hotstring%A_Index%, %A_Space%
	IniRead, hBind%A_Index%, %INIFile%, Binds, hBind%A_Index%, %A_Space%
}
loop, % fBinds_max
	IniRead, fBind%A_Index%, %INIFile%, Keys, fBind%A_Index%, %A_Space%
Loop, %jBinds_max%
	IniRead, jBind%A_Index%, %INIFile%, Keys, jBind%A_Index%, %A_Space%
loop, %Notes%
	IniRead, Note%A_Index%, %INIFile%, Notes, Note%A_Index%, %A_Space%
if(OverlayActive){
	loop, %MaxOverlays%
	{
		IniRead, OvColor%A_Index%, %INIFile%, Overlay, OvColor%A_Index%, 0xFFFFFF
		IniRead, OvFont%A_Index%, %INIFile%, Overlay, OvFont%A_Index%, Arial
		IniRead, OvFontStyle%A_Index%, %INIFile%, Overlay, OvFontStyle%A_Index%, %A_Space%
		IniRead, OvShadow%A_Index%, %INIFile%, Overlay, OvShadow%A_Index%, 1
		IniRead, OvText%A_Index%, %INIFile%, Overlay, OvText%A_Index%, %A_Space%
		StringReplace, OvText%A_Index%, OvText%A_Index%, ¶, `n, All
		IniRead, OvPosX%A_Index%, %INIFile%, Overlay, OvPosX%A_Index%, 600
		IniRead, OvPosY%A_Index%, %INIFile%, Overlay, OvPosY%A_Index%, 300
		IniRead, OvOnlyInVeh%A_Index%, %INIFile%, Overlay, OvCarOnly%A_Index%, 0
	}
}
return
Save:
if(savemsg)
	ToolTip, Wird gespeichert...
if(!savewithoutsubmit){
	for i, k in GUIs
	{
		if(k)
			Gui, %k%:Submit, NoHide
		else if(!A_IsCompiled)
			MsgBox, % "Submit called for unnamed GUI " i "`n`n" print_r(GUIs)
	}
}
if(UseHTMLGUI)
	Nickname := _mainGUI.document.getElementById("Name").value
; Global
IniWrite, %RunAsAdmin%, %A_AppData%\sBinder\global.ini, RunAsAdmin, %A_ScriptFullPath%

; Local
IniWrite, %Nickname%, %INIFile%, Settings, Name
IniWrite, %hmv%, %INIFile%, Settings, AutoMv
IniWrite, %TruckLevelLimit%, %INIFile%, Settings, TruckLevelLimit
IniWrite, %Design%, %INIFile%, Settings, Design
IniWrite, %meTexte%, %INIFile%, Settings, me
loop, %FrakOptions%
	IniWrite, % Frakoption%A_Index%, %INIFile%, Settings, Frakoption%A_Index%
IniWrite, %JobOption1%, %INIFile%, Settings, JobOption1
IniWrite, %TrayMinimize%, %INIFile%, Settings, MinimizeToTray
IniWrite, %TruckPics%, %INIFile%, Settings, TruckPics
IniWrite, %WaitFor%, %INIFile%, Settings, WaitFor
IniWrite, %GTAProcessName%, %IniFile%, Settings, GTAProcessName
IniWrite, %UseTimerActive%, %IniFile%, Settings, UseTimerActive
IniWrite, %AutoHitsound%, %INIFile%, Settings, AutoHitsound
IniWrite, %HitsoundText%, %INIFile%, Settings, HitsoundText
IniWrite, %AFKBox%, %INIFile%, Settings, AFKBox
IniWrite, %UseAPI%, %INIFile%, Settings, UseAPI
IniWrite, %TruckingSort%, %INIFile%, Settings, TruckSort
IniWrite, %TruckingSortOrder%, %INIFile%, Settings, TruckSortOrder
IniWrite, %Tel%, %INIFile%, Telefon, Active
IniWrite, %pText%, %INIFile%, Telefon, p
IniWrite, %hText%, %INIFile%, Telefon, h
IniWrite, %abText%, %INIFile%, Telefon, ab
if(AutoHitsound)
	SetTimer, AutoHitsound, 1000
else
	SetTimer, AutoHitsound, Off
loop, %Binds%
{
	IniWrite, % Key%A_Index%, %INIFile%, Keys, Key%A_Index%
	IniWrite, % Bind%A_Index%, %INIFile%, Binds, Bind%A_Index%
}
loop, %Hotstrings%
{
	IniWrite, % Hotstring%A_Index%, %INIFile%, Keys, Hotstring%A_Index%
	IniWrite, % hBind%A_Index%, %INIFile%, Binds, hBind%A_Index%
}
Loop, %jBinds_max%
	IniWrite, % jBind%A_Index%, %INIFile%, Keys, jBind%A_Index%
IniWrite, %xBind1%, %INIFile%, Binds, xBind1
IniWrite, %xBind2%, %INIFile%, Binds, xBind2
IniWrite, %wBind1%, %INIFile%, Binds, wBind1
IniWrite, %wBind2%, %INIFile%, Binds, wBind2
IniWrite, %Startup_SAMP%, %INIFile%, Startup, SAMP
IniWrite, %Startup_TS%, %INIFile%, Startup, TS
IniWrite, %Startup_Fraps%, %INIFile%, Startup, Fraps
IniWrite, %Startup_Other%, %INIFile%, Startup, Other
IniWrite, %Startup_SAMP_Delay%, %INIFile%, Startup, SAMP_Delay
IniWrite, %Startup_TS_Delay%, %INIFile%, Startup, TS_Delay
IniWrite, %Startup_Fraps_Delay%, %INIFile%, Startup, Fraps_Delay
IniWrite, %Startup_Other_Delay%, %INIFile%, Startup, Other_Delay
IniWrite, %Startup_Fraps_Path%, %INIFile%, Startup, Fraps_Path
IniWrite, %Startup_Other_Path%, %INIFile%, Startup, Other_Path
SaveExit:
loop, % fBinds
	IniWrite,% fBind%A_Index%, %INIFile%, Keys, fBind%A_Index%
loop, %Notes%
	IniWrite,% Note%A_Index%, %INIFile%, Notes, Note%A_Index%
if(OverlayActive)
	gosub OvSave
if(savemsg)
	ToolTip("Deine Daten wurden gespeichert.`nSpeicherort: " INIFile, 3000)
gosub HotkeysDefine
return
OvSave:
Gui, Overlay:Submit, Nohide
loop, %MaxOverlays%
{
	IniWrite, % OvColor%A_Index%, %INIFile%, Overlay, OvColor%A_Index%
	IniWrite, % OvFont%A_Index%, %INIFile%, Overlay, OvFont%A_Index%
	IniWrite, % OvFontStyle%A_Index%, %INIFile%, Overlay, OvFontStyle%A_Index%
	IniWrite, % OvShadow%A_Index%, %INIFile%, Overlay, OvShadow%A_Index%
	IniWrite, % RegExReplace(OvText%A_Index%, "`a)`n", "¶"), %INIFile%, Overlay, OvText%A_Index%
	IniWrite, % OvPosX%A_Index%, %INIFile%, Overlay, OvPosX%A_Index%
	IniWrite, % OvPosY%A_Index%, %INIFile%, Overlay, OvPosY%A_Index%
	IniWrite, % OvOnlyInVeh%A_Index%, %INIFile%, Overlay, OvCarOnly%A_Index%
	OvNeedsUpdate%A_Index% := 1
}
return
Downloads:
inetconn := UpdateAvailable := 0
errortext := ""
if(UseAPI AND !FileExist(A_WinDir "\System32\D3DX9_43.dll"))
	errortext .= "<li>Die d3dx9_43.dll konnte auf dem Computer nicht gefunden werden. Sie gehört zu DirectX und wird von der API benötigt. <a href='http://www.microsoft.com/de-de/download/details.aspx?id=35'>DirectX-Installer herunterladen</a></li>"
if(!(temp := FileExist(chatlogpath)) OR InStr(temp, "D"))
	errortext .= "<li>Die chatlog.txt konnte nicht gefunden werden. <a href='sBinder://go/ChatlogSearch'>Automatisch beheben</a> oder <a href='sBinder://go/SelectCL'>manuell auswählen</a></li>"
else{
	FileGetTime, temp2, %chatlogpath%, M
	temp := A_Now
	temp -= temp2, Seconds
	if(temp > 432000) ;5 Tage
		errortext .= "<li>Die chatlog.txt wurde vor langer Zeit geändert (zuletzt " FormatTime(temp2, "dd.MM.yyyy HH:mm") "). <a href='sBinder://go/ChatlogSearch'>Automatisch beheben</a> oder <a href='sBinder://go/SelectCL'>manuell auswählen</a>"
}
if(!SkipPing){
	while(ping < 0 AND A_Index <= 3){
		SB_SetTextEx("Internetverbindung wird geprüft... (Versuch " A_Index "/3" (A_Index > 1 ? ", Vorheriger Versuch: " clearping(ping) : "") ")")
		ping := ping("saplayer.lima-city.de",, 450)
		if(ping < 0)
			Sleep, 500
	}
	pingsuccessful := ping >= 0
} else {
	pingsuccessful := 1
}
if(pingsuccessful || FileExist(datacachefile)){
	SB_SetTextEx("Daten werden heruntergeladen...")
	
	if(pingsuccessful)
		data := LTrim(HTTPData("http://saplayer.lima-city.de/sBinder/logon.php?nl&u=" URLEncode(Nickname) "&v=" URLEncode(Version "-" Build (InStr(A_ScriptName, ".ahk") ? "-dev" : (A_ScriptName = "sBinder_Beta.exe" ? "-beta" : ""))), "Die Daten konnten nicht heruntergeladen werden", "UTF-8"), " ?")
	else
		data := ""
	if(vBuild := RegExFileRead(data, "B", 0)){
		inetconn := 1
	}
	vVersion := RegExFileRead(data, "V")
	vSize := RegExFileRead(data, "S", 100) * 1000
	Info_ := RegExFileRead(data, "I2", "Die Informationen konnten nicht abgerufen werden :(`n`nFehler: " data)
	StringReplace, Info_, Info_, ``n, `n, All
	StringReplace, Info_, Info_, ``t, `t, All
	Info := Object()
	;;;
	DYK_ := RegExFileRead(data, "DYK", " ")
	StringReplace, DYK_, DYK_, ``n, `n, All
	StringReplace, DYK_, DYK_, ``t, `t, All
	DYK := Object()
	;;;
	if(errortext)
		Info_ := "<span style='color:#F10'>Es sind Fehler aufgetreten!</span><br><ul>" errortext "</ul><br><b>Hinweis:</b> <div class='hint'>Diese Seite aktualisiert sich nicht automatisch. <a href='sBinder://g/Downloads'>Jetzt aktualisieren</a></div>§" Info_
	;;;
	loop, Parse, DYK_, §
	{
		data := A_LoopField
		if(InStr(data, "Build ") AND RegExMatch(data, "U)^\[\[(Min|Max|Only)Build ([\d.]+)\]\]", chat)){ ;Erkennung von [[MinBuild X]], [[MaxBuild X]] und [[OnlyBuild X]]
			if((chat1 = "Min" AND Build < chat2) OR (chat1 = "Max" AND Build > chat2) OR (chat1 = "Only" AND Build != chat2))
				continue
			data := RegExReplace(data, "U)^\[\[(Min|Max|Only)Build (\d+)\]\]")
		}
		DYK.Insert(data)
	}
	if(DYK._maxIndex()){
		Random, DYK_, 1, % DYK._maxIndex()
		DYK := DYK[DYK_]
		if(DYK)
			DYK := "<div class=""dyk""><div class=""dyk-header"">Schon gewusst, ...</div>" DYK "</div>"
	}
	DYK_ := ""
	;;;
	loop, Parse, Info_, §
	{
		data := A_LoopField
		if(InStr(data, "Build ") AND RegExMatch(data, "U)^\[\[(Min|Max|Only)Build (\d+)\]\]", chat)){ ;Erkennung von [[MinBuild X]], [[MaxBuild X]] und [[OnlyBuild X]]
			if((chat1 = "Min" AND Build < chat2) OR (chat1 = "Max" AND Build > chat2) OR (chat1 = "Only" AND Build != chat2))
				continue
			data := RegExReplace(data, "U)^\[\[(Min|Max|Only)Build (\d+)\]\]")
		}
		if(data = "[[DYK]]")
			data := DYK
		Info.Insert(data)
	}
	Info_ := ""
	;StringSplit, Info, Info, §
	;GuiControl, 1:, Info, %Info1%
	SetWB(Inf, Info[1],, InfoColor)
	if(Info._maxIndex() > 1)
		GuiControl, 1:Enable, NextInfo
	GuiControl, 1:Disable, LastInfo
	cInfo := 1
	if(Build < vBuild){
		UpdateAvailable := 1
		SB_SetTextEx("Version " vVersion "-" vBuild " verfügbar. Ein Update kannst du über Datei->Update ausführen.")
		if(!reloaded AND !WinActive("ahk_group GTASA"))
			gosub UpdateGUI
	}
	else
		SB_SetTextEx("Keine neue Version gefunden")
	data := ""
}
if(!inetconn){
	errortext := "<li>Die Informationen konnten nicht heruntergeladen werden :(<br><a href='sBinder://g/Downloads'>Versuche es in ein paar Minuten erneut</a><br>Fehler: <b><span style='color:#F10'>" clearping(ping) "</span></b></li>" errortext
	SetWB(Inf, "<span style='color:#F10'>Es sind Fehler aufgetreten!</span><br><ul>" errortext "</ul><br><b>Hinweis:</b> <div class='hint'>Diese Seite aktualisiert sich nicht automatisch. <a href='sBinder://g/Downloads'>Jetzt aktualisieren</a></div>",, InfoColor)
	GuiControl, 1:Disable, LastInfo
	GuiControl, 1:Disable, NextInfo
	SB_SetTextEx("Überprüfung auf neue Version fehlgeschlagen. Es werden gecachte Daten genutzt.")
}
if(!vBuild){
	SB_SetTextEx("Überprüfung auf neue Version fehlgeschlagen, Fraktionsbinds können nicht verwendet werden! Grund: " clearping(ping))
}
return
VT:
Run, "http://saplayer.lima-city.de/l/virustotal-sBinder"
return
UpdateGUI:
Gui, TempGUI:Destroy
Gui, TempGUI:Color, FFFFFF, 282828
Gui, TempGUI:Add, Text, w290, % (UpdateAvailable ? "Die neue Version " vVersion "-" vBuild " ist zum Download verfügbar.`nWillst du jetzt ein Update ausführen?" : "Es ist kein Update verfügbar, die aktuellste Version ist " vVersion "-" vBuild ". Du kannst trotzdem ein manuelles Update ausführen.")
Gui, TempGUI:Add, Button, x160 y40 w120 gVT, Virustotal-Link öffnen
Gui, TempGUI:Add, Button, x200 y65 w80 gChangelogOnline, Changelog
Gui, TempGUI:Add, CheckBox, % "x10 y90 vDoUpdate" + (UpdateAvailable ? " Checked" : ""), % "Update durchführen" + (UpdateAvailable ? " (empfohlen)" : "")
Gui, TempGUI:Add, Button, x220 w60 y90 gUpdate Default, Weiter »»
Gui, TempGUI:Add, Text, vStatus x10 y110 w200
Gui, TempGUI:Show, w290, sBinder: Update
return
TempGUIGuiClose:
Update:
if(A_ThisLabel = "TempGuiGUIClose")
	DoUpdate := 0
else
	GuiControlGet, DoUpdate, TempGUI:
if(!DoUpdate){
	Gui, TempGUI:Destroy
	ToolTip("Das Update wird nicht durchgeführt!", 4000)
	return
}
Gui, 1:Default
savemsg := 0
gosub Save
savemsg := 1
GuiControlGet, SB_old, 1:, SB
SB_SetTextEx("Das Update wird vorbereitet...")
GuiControl, TempGUI:, Status, Das Update wird vorbereitet...
URLDownloadToFile, http://saplayer.lima-city.de/l/sBinder-update, sBinder_new.exe
SB_SetTextEx("Update wird durchgeführt...")
GuiControl, TempGUI:, Status, Update wird durchgeführt...
FileGetSize, size_curr, sBinder_new.exe
if(size_curr >= vSize){
	FileDelete, sUpdate.bat
	FileAppend, % "@echo off`nping 1.1.1.1 -n 1 -w 800`ndel """ A_ScriptDir "\sBinder.exe""`nmove """ A_ScriptDir "\sBinder_new.exe"" """ A_ScriptDir "\sBinder.exe""`nping 1.1.1.1 -n 1 -w 800`nstart """" """ A_ScriptDir "\sBinder.exe"" ""--just-updated""`ndel """ A_ScriptDir "\sUpdate.bat""", sUpdate.bat
	Run, %RunPrivileges%sUpdate.bat,, Hide
	ExitApp
}
else{
	FileDelete, sBinder_new.exe
	MsgBox, 21, Updatefehler, % "Update auf Version " vVersion "-" vBuild " war nicht erfolgreich!`n" number_format(size_curr) "/" number_format(vSize)
	IfMsgBox, Cancel
	{
		SB_SetTextEx(SB_Old)
		GuiControl, TempGUI:, Status
	}
	IfMsgBox, Retry
		goto Update
	return
}
return
TempGUI2GuiClose:
Gui, TempGUI2:Destroy
return
Variables:
Version := "3.0.0"
Build := 84
active := 1
;INIFile := A_ScriptDir "\keybinder.ini"
IniRead, INIFile, %A_AppData%\sBinder\global.ini, Path, %A_ScriptFullPath%, %A_ScriptDir%\keybinder.ini
Binds := 52
fBinds_max := 13
jBinds_max := 9
MaxOverlays := 3
OverlayActive := 1
Hotstrings := 26
hotstringsactive := []
Notes := 8
FrakOptions := 6
frakbinds := 1
savemsg := 1
GuiButtons := 6
DownloadMode := 0
pi := 4 * ATan(1)
EnvGet, ProcessorCount, NUMBER_OF_PROCESSORS
EnvGet, UserProfile, UserProfile
IniRead, UseAPI, %INIFile%, Settings, UseAPI, 0
IniRead, LastUsedBuild, %INIFile%, Settings, LastUsedBuild, 0
 ; Use in Run commands to run another program if and only if the sBinder itself has admin privileges (don't show a UAC dialog!)
RunPrivileges := A_IsAdmin ? "*RunAs " : ""

ShowDialogWorking := 0
return
GetArgs:
Args := Object(), FullArgs := FullArgsQuoted := ""
loop, %0%
{
	Args.Insert(%A_Index%)
	FullArgs .= (A_Index = 1 ? "" : " ") %A_Index%
	FullArgsQuoted .= (A_Index = 1 ? "" : " ") """" %A_Index% """"
}
return
Arrays:
loop, %MaxOverlay%
	Ov[A_Index] := -1
Fraknames := ["Keine Fraktion", "Los Santos Polizei", "San Andreas Rettungsdienst", "Triaden", "La Cosa Nostra", "Yakuza", "Grove Street", "San Andreas Media AG", "Ballas Family", "Los Vagos", "FBI", "Scarfo Family"]
Fraks := Fraknames._maxIndex() - 1
Jobnames := ["Kein Beruf", "Anwalt", "Busfahrer", "Detektiv", "Dieb", "Erzarbeiter & Erzlieferant", "Farmer & Getreidelieferant", "Lieferant", "Mechaniker", "Reinigungsdienst", "Tankstellenlieferant", "Wartungsservice", "Taxifahrer", "Hochseefischer", "Gärtner", "Holzfäller", "Jäger", "Müllmann", "Pizzabote", "Drogendealer & Drogenschieber", "Waffenhändler", "Fastfood AG"]
FrakRegEx := ["Police|Polizei|\bPD\b|Bullen|Cops", "F\.B\.I|FBI|Federal|Bureau|Investigation|Geheimdienst", "Army|Bundeswehr|Corps", "SARD|Krankenhaus|Arzt|Ärzte|Rettung|Medic", "Ndrangheta|Cosa|Nostra|LCN", "Yakuza", "Regierung|Gov|White House|Weißes Haus",, "SAM|\bAG\b|Media|\bTV\b|Reporter|News",, "Scarfo|Auto|Rennen|Race",, "Ballas", "Grove|\bGS\b",,, "Shanghai|Syndikat|\bSS\b", "Jerkov|\bJF\b", "Los|Vagos|\bLV\b"]
FrakNums := [0, 1, 4, 18, 5, 6, 14, 9, 13, 19, 2, 11]
Designs := [{name: "Standard", file: "", url: "", version: ""}, {name: "Epic White", file: "ewhite.html", url: "http://saplayer.lima-city.de/sBinder/design/ewhite/1_3.html", version: "1.3"}, {name: "Graphite", file: "graphite.html", url: "http://saplayer.lima-city.de/sBinder/design/graphite/1_2.html", version: "1.2"}, {name: "Custom", file: "custom.html", url: "", version: ""}]

CarModels := {400:"Landstalker",402:"Buffalo",403:"Linerunner",404:"Perenniel",405:"Sentinel",406:"Dumper",407:"Feuerwehr",408:"Müllwagen",409:"Stretch",411:"Infernus",412:"Voodoo",413:"Pony",415:"Cheetah",416:"Rettungswagen",417:"Leviathan",418:"Moonbeam",419:"Esperanto",420:"Taxi",421:"Washington",422:"Bobcat",424:"BF Injection",425:"Hunter",426:"Premier",427:"Enforcer",428:"Bankwagen",429:"Banshee",430:"Polizeischiff",431:"Bus",432:"Panzer",433:"Barracks",434:"Hotknife",437:"Coach",440:"Rumpo",445:"Admiral",451:"Turismo",454:"Tropic",456:"Yankee",457:"Golf-Caddy",459:"Drogenvan",461:"PCJ-600",462:"Faggio",463:"Freeway",467:"Oceanic",468:"Sanchez",470:"Patriot",471:"Quad",472:"Coastguard",473:"Dinghy",474:"Hermes",475:"Sabre",476:"Rustler",477:"ZR-350",478:"Walton",480:"Comet",482:"Burrito",483:"Camper",484:"Marquis",487:"Maverick",489:"Rancher",490:"FBI Rancher",493:"Jetmax",494:"Hotring Racer",495:"Sandking",496:"Blista Compact",497:"Polizei Maverick",498:"Boxville",499:"Benson",500:"Mesa",502:"Hotring Racer",503:"Hotring Racer",504:"Bloodring Banger",505:"Rancher",506:"Super GT",507:"Elegant",508:"Journey",514:"Tanker",515:"Roadtrain",517:"Majestic",519:"Shamal",520:"Hydra",521:"FCR-900",522:"NRG-500",523:"Polizei Bike",524:"Betonmischer",525:"Towtruck",528:"FBI Truck",532:"Mähdrescher",533:"Feltzer",534:"Remington",535:"Slamvan",536:"Blade",541:"Bullet",542:"Clover",544:"Feuerwehr mit Leiter",545:"Hustler",548:"Cargobob",550:"Sunrise",554:"Yosemite",555:"Windsor",558:"Uranus",559:"Jester",560:"Sultan",561:"Stratum",562:"Elegy",563:"Raindance",565:"Flash",566:"Tahoma",567:"Savanna",568:"Bandito",573:"Dune",574:"Sweeper",575:"Broadway",579:"Huntley",580:"Stafford",581:"BF-400",585:"Emperor",586:"Wayfarer",587:"Euros",589:"Club",593:"Dodo",596:"Polizei (LS)",597:"Polizei (SF)",598:"Army Car",599:"Noteinsatzfahrzeug",601:"Wasserwerfer",602:"Alpha",603:"Phoenix"}
return
mainGUI:
;DocumentWidth := 424
DocumentHeight := 300
if(UseDesign = 1){
	UseHTMLGUI := 0
	MainGuiColor := "F0F0F0"
	InfoColor := "F0F0F0"
	MenuColor := "F0F0F0"
	Gui, Color, %MainGuiColor%
	;width: 424
	;height: 478
	Gui, Add, Picture, x104 y0, %A_AppData%\sBinder\bg.png
	Gui, Add, Button, x10 y30 w120 h20 gTSConnect, TS³ Connect
	Gui, Add, Button, x140 y30 w120 h20 gConnect, SAMP starten
	Gui, Add, Button, x270 y30 w120 h20 gForum, Nova Forum
	Gui, Add, Button, x395 y30 h20 w12 gHelp1, ?
	Gui, Add, Button, x140 y80 w120 h20 gCustomBindsGUI, Eigene Binds
	Gui, Add, Button, x265 y80 h20 w12 gHelp2, ?
	Gui, Add, Button, x140 y110 w120 h20 gJobGUI, Jobs
	Gui, Add, Button, x265 y110 h20 w12 gHelp3, ?
	if(Frak = 8)
		Gui, Add, Button, x10 y140 w120 h20 gSimpleSAM, SimpleSAM starten
	Gui, Add, Button, x140 y140 w120 h20 gFrakGUI vFrakGUI Disabled, Fraktionsbinds
	Gui, Add, Button, x265 y140 h20 w12 gHelp4, ?
	Gui, Add, Button, x140 y170 w120 h20 gNotesGUI, Notizen
	Gui, Add, Button, x265 y170 h20 w12 gHelp5, ?
	Gui, Add, Button, x140 y200 w120 h20 gCarCalcGUI, Fahrzeugrechner
	Gui, Add, Button, x265 y200 h20 w12 gHelp6, ?
	Gui, Add, Button, x140 y230 w120 h20 gTruckerGUI, Trucking
	Gui, Add, Button, x265 y230 h20 w12 gHelp9, ?
	Gui, Add, Text, % "x212 y" 92+30*GuiButtons " h20", Dein Name:
	Gui, Add, Edit, % "x270 y" 90+30*GuiButtons " w120 h20 vNickname", %Nickname%
	Gui, Add, Button, % "x395 y" 90+30*GuiButtons " h20 w12 gHelp7", ?
}
else{
	UseHTMLGUI := 1
	MainGuiDesign := Designs[UseDesign]
	if(!FileExist(A_AppData "\sBinder\Design\" MainGuiDesign["file"])){
		if(!MainGuiDesign["url"]){
			MsgBox, 16, % "Design " MainGuiDesign["name"] " konnte nicht gefunden werden", % "Das von dir gewählte Design " MainGuiDesign["name"] " konnte leider nicht gefunden werden.`nEs sollte unter " A_AppData "\sBinder\Design\" MainGuiDesign["file"] " gespeichert sein.`n`nAus diesem Grund wird jetzt vorübergehend das Standard-Design genutzt.`n`nTipp: Sollte dir diese Meldung des Öfteren angezeigt werden, empfehlen wir, das Standard-Design auch in den Einstellungen zu wählen."
			UseDesign := 1
			goto mainGUI
		}
		else{
			;Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., % "Design " MainGuiDesign["name"] " wird heruntergeladen", % "sBinder: Design " MainGuiDesign["name"]
			InfoProgress("Bitte habe etwas Geduld...", "Design " MainGuiDesign["name"] " wird heruntergeladen", "sBinder: Design " MainGuiDesign["name"])
			URLDownloadToFile, % MainGuiDesign["url"], % A_AppData "\sBinder\Design\" MainGuiDesign["file"]
			EL := ErrorLevel
			;Progress, Off
			InfoProgress()
			if(EL OR !FileExist(A_AppData "\sBinder\Design\" MainGuiDesign["file"])){
				MsgBox, 16, % "Design " MainGuiDesign["name"] " konnte nicht heruntergeladen werden", % "Das von dir gewählte Design " MainGuiDesign["name"] " konnte leider nicht heruntergeladen werden.`n`nAus diesem Grund wird jetzt vorübergehend das Standard-Design genutzt.`n`nTipp: Sollte dir diese Meldung des Öfteren angezeigt werden, empfehlen wir, das Standard-Design auch in den Einstellungen zu wählen."
				UseDesign := 1
				goto mainGUI
			}
		}
	}
	FileRead, mainGUIHTML, % A_AppData "\sBinder\Design\" MainGuiDesign["file"]
	RegExMatch(mainGUIHTML, "Usi)<sBinder>(.*)</sBinder>", match)
	RegExMatch(match1, "i)Version:\s*([\d\.]+)\s*;?", regex)
	MainGuiVersion := regex1 != "" ? regex1 : "1.0"
	RegExMatch(match1, "i)MainGuiColor:\s*#?([0-9a-f]{6})\s*;?", regex)
	MainGuiColor := regex1 != "" ? regex1 : "FFFFFF"
	RegExMatch(match1, "i)InfoColor:\s*#?([0-9a-f]{6})\s*;?", regex)
	InfoColor := regex1 != "" ? regex1 : "FFFFFF"
	RegExMatch(match1, "i)MenuColor:\s*#?([0-9a-f]{6})\s*;?", regex)
	MenuColor := regex1 != "" ? regex1 : "FFFFFF"
	;RegExMatch(match1, "i)DocumentWidth:\s*(\d+)\s?(px)?\s*;?", regex)
	;DocumentWidth := regex1 != "" ? regex1 : "424"
	RegExMatch(match1, "i)DocumentHeight:\s*(\d+)\s?(px)?\s*;?", regex)
	DocumentHeight := regex1 != "" ? regex1 : "300"
	
	if(MainGuiVersion != MainGuiDesign["version"] && MainGuiDesign["url"]){
		;Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., % "Design " MainGuiDesign["name"] " wird aktualisiert", % "sBinder: Design " MainGuiDesign["name"]
		InfoProgress("Bitte habe etwas Geduld...", "Design " MainGuiDesign["name"] " wird aktualisiert", "sBinder: Design " MainGuiDesign["name"])
		URLDownloadToFile, % MainGuiDesign["url"], % A_AppData "\sBinder\Design\" MainGuiDesign["file"]
		EL := ErrorLevel
		;Progress, Off
		InfoProgress()
		if(EL OR !FileExist(A_AppData "\sBinder\Design\" MainGuiDesign["file"])){
			MsgBox, 16, % "Design " MainGuiDesign["name"] " konnte nicht aktualisiert werden", % "Das von dir gewählte Design " MainGuiDesign["name"] " konnte leider nicht aktualisiert werden.`n`nAus diesem Grund wird jetzt vorübergehend das alte Design genutzt.`n`nTipp: Sollte dir diese Meldung des Öfteren angezeigt werden, empfehlen wir, das Standard-Design in den Einstellungen zu wählen."
		}
		goto mainGUI
	}
	
	mainGUIHTML := RegExReplace(RegExReplace(mainGUIHTML, "Usi)<sBinder>.*</sBinder>"), "%AppData%", RegExReplace(A_AppData, "\\", "/"))
	FileDelete, %A_Temp%\sBinder\design_t.html
	FileAppend, %mainGUIHTML%, %A_Temp%\sBinder\design_t.html
	;MainGuiColor := "FFFFFF"
	;InfoColor := "FFFFFF"
	;MenuColor := "FFFFFF"
	Gui, Color, %MainGuiColor%
	Gui, Margin, 0
	Gui, Add, ActiveX, x0 y0 w424 h%DocumentHeight% v_mainGUI, WebBrowser
	;SetWB(_mainGUI, mainGUIHTML, 0)
	_mainGUI.Silent := 1
	_mainGUI.Navigate(A_Temp "\sBinder\design_t.html")
	while(_mainGUI.readyState != 4 && A_Index < 40)
		Sleep, 20
	zoomlevel := (AppliedDPI / 96) ** 2 * 100
	_mainGUI.ExecWB(OLECMDID_OPTICAL_ZOOM:=63, OLECMDEXECOPT_DODEFAULT:=0, Round(zoomlevel))
	if(!InStr(_mainGUI.document.getElementById("FrakGUI").className, "disabled"))
		_mainGUI.document.getElementById("FrakGUI").className .= " disabled"
	_mainGUI.document.getElementById("FrakGUI").href := "#"
	_mainGUI.document.getElementById("Name").value := Nickname
	if(Frak = 8 AND _mainGUI.document.DocumentMode >= 8)
		_mainGUI.document.querySelectorAll(".content")[0].innerHTML  .= "<a class=""button"" style=""left: 10px; top: 140px; font-size: 0.9em"" href=""sBinder://g/SimpleSAM"">SimpleSAM starten</a>"
	;MsgBox, % _mainGUI.document.DocumentMode
	ComObjConnect(_mainGUI, "wb_")
	MainGUIHTML := ""
}

HeightCorrection := DocumentHeight - 300
Gui, Add, Button, % "Disabled vLastInfo gInfo x18 y" 125+30*GuiButtons + HeightCorrection " h80 w30", <-
Gui, Add, ActiveX, % "x53 y" 125+30*GuiButtons + HeightCorrection " w310 h80 vInf", Shell.Explorer
Inf.Silent := 1
ComObjConnect(Inf, "wb_")
SetWB(Inf, "Informationen werden geladen...",, InfoColor)
Gui, Add, Button, % "Disabled vNextInfo gInfo x368 y" 125+30*GuiButtons + HeightCorrection " h80 w30", ->
Menu, NicknameAction, Add, Diesen Namen in SAMP verwenden, NameToSamp
Menu, NicknameAction, Add, SAMP-Namen auslesen und hier einsetzen, NameFromSamp
Menu, TruckLVAction, Add, Missionen kopieren, TruckCopy
Menu, TruckLVAction, Add, Aktualisieren, TruckReload

Menu, DateiMenu, Add, %INIFile%, Nothing
Menu, DateiMenu, Disable, %INIFile%
Menu, DateiMenu, Add, &Öffnen, SelectINI
Menu, DateiMenu, Add, &Speichern, Save
Menu, DateiMenu, Add, Speichern &unter..., SaveAs
Menu, DateiMenu, Add, &Update, UpdateGUI
Menu, DateiMenu, Add
Menu, DateiMenu, Add, E&instellungen, SettingsGUI
Menu, DateiMenu, Add
Menu, DateiMenu, Add, B&eenden, Exit
Menu, DateiMenu, Add, Neu sta&rten, Restart
Menu, SonstigesMenu, Add, &Textbinds, TextbindsOnline
Menu, SonstigesMenu, Add, &Changelog, ChangelogOnline
Menu, SonstigesMenu, Add, Thread im &Forum, ForumThread
Menu, SonstigesMenu, Add
Menu, SonstigesMenu, Add, C&redits, CreditsGUI
Menu, SonstigesMenu, Add, &Über, AboutGUI
Menu, SonstigesMenu, Add
Menu, SonstigesMenu, Add, Nach &Updates suchen, Downloads
Menu, SonstigesMenu, Add
Menu, SonstigesMenu, Add, &Debug-Informationen anzeigen, DebugGUI
Menu, SonstigesMenu, Add, Keybinder &testen (Debug), TestGUI
Menu, ConnectMenu, Add, SAMP sta&rten, Connect
Menu, ConnectMenu, Add, &TeamSpeak³, TSConnect
Menu, ConnectMenu, Add, Nova &Forum, Forum
Menu, MenuBar, Add, &Datei, :DateiMenu
Menu, MenuBar, Add, &Speichern, Save
Menu, MenuBar, Add, S&onstiges, :SonstigesMenu
Menu, MenuBar, Add, &Connect, :ConnectMenu
Menu, MenuBar, Color, %MenuColor%
Gui, Menu, MenuBar
Gui, Add, StatusBar, vSB
if(reloaded){
	IniDelete, %INIFile%, Settings, Reload
	AddChatMessage("Der sBinder wurde {88AA62}neu gestartet{FFFFFF}!")
	AddChatMessage("Um das Fenster zu öffnen, kannst du in der Trayleiste auf das Symbol klicken.")
}
else if(InStr(FullArgs, "--start-minimized")){
	if(WinActive("ahk_group GTASA")){
		AddChatMessage("Der sBinder wurde {88AA62}minimiert gestartet{FFFFFF}!")
		AddChatMessage("Um das Fenster zu öffnen, kannst du in der Trayleiste auf das Symbol klicken.")
	}
}
else
	gosub GuiShow
;WinGetPos,,, posw, posh, A
;MsgBox, Breite: %posw%`nHöhe: %posh%
if(A_IsCompiled)
	Menu, Tray, NoStandard
Menu, Tray, Color, FFFFFF
Menu, Tray, Tip, sBinder %Version%-%Build% by IcedWave
Menu, Tray, Add, &Öffnen, GuiShow
Menu, Tray, Add, B&eenden, 1GuiClose
Menu, Tray, Default, &Öffnen
Menu, DateiMenu, Icon, %INIFile%, shell32.dll, 70
Menu, DateiMenu, Icon, &Öffnen, shell32.dll, 5
Menu, DateiMenu, Icon, &Speichern, shell32.dll, 259 ;7
Menu, DateiMenu, Icon, Speichern &unter..., shell32.dll, 259 ;7
Menu, DateiMenu, Icon, &Update, shell32.dll, 123
Menu, DateiMenu, Icon, E&instellungen, shell32.dll, 72
Menu, DateiMenu, Icon, B&eenden, shell32.dll, 132
Menu, DateiMenu, Icon, Neu sta&rten, shell32.dll, 239
Menu, SonstigesMenu, Icon, &Textbinds, shell32.dll, 75
Menu, SonstigesMenu, Icon, &Changelog, shell32.dll, 56
Menu, SonstigesMenu, Icon, Thread im &Forum, shell32.dll, 14
Menu, SonstigesMenu, Icon, Nach &Updates suchen, shell32.dll, 145
Menu, SonstigesMenu, Icon, C&redits, shell32.dll, 225
Menu, SonstigesMenu, Icon, &Über, shell32.dll, 225
Menu, SonstigesMenu, Icon, &Debug-Informationen anzeigen, shell32.dll, 222
Menu, SonstigesMenu, Icon, Keybinder &testen (Debug), shell32.dll, 217
try
	Menu, ConnectMenu, Icon, SAMP sta&rten, %samppath%
try{
	RegRead, ts3_temp, HKCR, ts3server\shell\open\command
	RegExMatch(ts3_temp, "UO)^""(.+)""", ts3_temp)
	if(!ErrorLevel)
		Menu, ConnectMenu, Icon, &TeamSpeak³, % ts3_temp.Value(1)
}
try{
	RegRead, default_browser, HKCR, http\shell\open\command
	RegExMatch(default_browser, "UO)^""(.+)""", default_browser)
	default_browser := default_browser.Value(1)
	if(!ErrorLevel)
		Menu, ConnectMenu, Icon, Nova &Forum, %default_browser%
}
Menu, Tray, Icon, B&eenden, shell32.dll, 132
Menu, Tray, Icon, &Öffnen, % (A_IsCompiled ? A_ScriptFullPath : A_IconFile)
Gui, +HwndmainGUI
return
BuildGUIs:
;AboutGUI
Gui, AboutGUI:Add, Picture, x0 y5, %A_AppData%\sBinder\bg.png
Gui, AboutGUI:Add, Link, x10, % "Version: " Version " (Build " Build ")`n`nEntwickler: IcedWave`nCopyright © 2012-2015 IcedWave`n`nProgrammiert mit <a href=""http://autohotkey.com"">Autohotkey</a> Version " A_AhkVersion
Gui, AboutGUI:Menu, MenuBar
;SettingsGUI
Gui, SettingsGUI:Add, Tab2, -Background +Theme -Wrap x5 y5 w525 h340 vSettingsTab, Seite 1|Seite 2|Erweiterte Optionen
Gui, SettingsGUI:Tab, 1
;Tab 1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
y := 50
Gui, SettingsGUI:Add, GroupBox, % "x10 y" y-15 " h90 w510 vGenericSettings c000000", Allgemeine Einstellungen
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vTrayMinimize Checked%TrayMinimize%, Ins Tray minimieren
Gui, SettingsGUI:Add, Text, x180 y%y%, Name des GTA-Prozesses:
Gui, SettingsGUI:Add, Edit, x310 y%y% w135 vGTAProcessName, %GTAProcessName%
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp10, ?
y += 25
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vTruckPics Checked%TruckPics%, Bilder im Trucking-Fenster anzeigen
Gui, SettingsGUI:Add, Checkbox, x215 y%y% h20 vAFKBox gAFKBox_Changed Checked%AFKBox%, Box anzeigen, wenn du auf dem Desktop bist
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp11, ?
y += 25
Gui, SettingsGUI:Add, Text, x15 y%y%, Design:
ddl := ""
for i, k in Designs
	ddl .= (A_Index = 1 ? "" : A_Index = 2 ? "||" : "|") k["name"]
Gui, SettingsGUI:Add, DDL, x60 y%y% w110 vDesign Choose%Design% AltSubmit gDesignChange, %ddl%
Gui, SettingsGUI:Add, Text, x180 y%y%, Aktuelles Design:
Gui, SettingsGUI:Add, Edit, x270 y%y% w225 ReadOnly, % Designs[UseDesign, "name"] (MainGuiVersion ? " Version " MainGuiVersion : "") (UseHTMLGUI ? " im IE " Round(_mainGUI.document.DocumentMode, 1) : "")
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp29, ?
y += 45
Gui, SettingsGUI:Add, GroupBox, % "x10 y" y-15 " h205 w510 vIngameSettings c000000", Ingame-Einstellungen
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vhmv Checked%hmv%, Doppelhupe = /mv
Gui, SettingsGUI:Add, Checkbox, x140 y%y% h20 vmeTexte Checked%meTexte%, /me-Texte bei Animationen
Gui, SettingsGUI:Add, Checkbox, x300 y%y% h20 vUseTimerActive Checked%UseTimerActive%, Timer für /use [lsd/green/donut/gold]
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp12, ?
y += 25
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vAutoHitsound Checked%AutoHitsound% gHitsoundChanged, Beim Login automatisch eingeben:
Gui, SettingsGUI:Add, Edit, x205 y%y% w290 h20 vHitsoundText, %HitsoundText%
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp21, ?
gosub HitsoundChanged
y += 35
Gui, SettingsGUI:Add, GroupBox, % "x20 y" y-15 " h115 w475 vTelSettings c000000", Telefontexte
Gui, SettingsGUI:Add, Checkbox, x30 y%y% gTelChanged vTel Checked%Tel%, Telefontexte aktivieren
Gui, SettingsGUI:Add, Button, % "x505 y" y-10 " h110 w12 gHelp19", ?
y += 20
Gui, SettingsGUI:Add, Text, x30 y%y%, /p:
Gui, SettingsGUI:Add, Edit, x150 y%y% w330 h20 vpText, %pText%
y += 25
Gui, SettingsGUI:Add, Text, x30 y%y%, /h:
Gui, SettingsGUI:Add, Edit, x150 y%y% w330 h20 vhText, %hText%
y += 25
Gui, SettingsGUI:Add, Text, x30 y%y%, /ab (Anrufbeantworter):
Gui, SettingsGUI:Add, Edit, x150 y%y% w330 h20 vabText, %abText%
gosub TelChanged
y += 35
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vUseAPI gAPIUseChange Checked%UseAPI%, API nutzen
if(OverlayActive)
	Gui, SettingsGUI:Add, Button, % "x100 y" y " h20 vOvSettings gOverlayGUI", Overlay-Einstellungen
GuiControl, SettingsGUI:Enable%UseAPI%, OvSettings
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp18, ?
Gui, SettingsGUI:Tab, 2
;Tab 2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
y := 50
Gui, SettingsGUI:Add, GroupBox, % "x10 y" y-15 " h65 w510 vPathSettings c000000", Pfade
Gui, SettingsGUI:Add, Button, x15 y%y% h20 gSelectCL, Chatlog-Pfad auswählen
Gui, SettingsGUI:Add, Button, x+15 y%y% h20 w150 gChatlogSearch, Chatlog automatisch suchen
Gui, SettingsGUI:Add, Button, x+15 y%y% h20 w120 gSelectSAMP vSAMPSelect, SAMP-Pfad ändern
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp15, ?
y += 25
Gui, SettingsGUI:Add, Button, x15 y%y% h20 gOpenINI, INI-Datei öffnen
Gui, SettingsGUI:Add, Button, x+15 y%y% h20 gOpenDir, sBinder-Ordner öffnen
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp22, ?
y += 45
Gui, SettingsGUI:Add, GroupBox, % "x10 y" y-15 " h65 w510 vTruckingSettings c000000", /trucking
Gui, SettingsGUI:Add, Text, x15 y%y% h20, Nur Aufträge für Level anzeigen (s. ?-Button):
Gui, SettingsGUI:Add, Edit, y%y% x235 w45
Gui, SettingsGUI:Add, UpDown, vTruckLevelLimit Range-1-10, %TruckLevelLimit%
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp14, ?
y += 25
Gui, SettingsGUI:Add, Text, x15 y%y% h20, Aufträge sortieren nach
Gui, SettingsGUI:Add, DDL, x130 y%y% w180 Choose%TruckingSort% vTruckingSort gTruckingSortChange AltSubmit, Trucklevel||Erfahrung|Einkaufspreis|Verkaufspreis|Gewinn|Gewicht|Entfernung zum Kaufort (Luftlinie)
Gui, SettingsGUI:Add, DDL, x320 y%y% w80 Choose%TruckingSortOrder% vTruckingSortOrder AltSubmit, aufsteigend||absteigend
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp28, ?
y += 45
Gui, SettingsGUI:Add, GroupBox, % "x10 y" y-15 " h140 w510 vStartupProgramSettings c000000", Programme mitstarten
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vStartup_SAMP Checked%Startup_SAMP% gStartupSettingsChange, SAMP mitstarten
Gui, SettingsGUI:Add, Text, x190 y%y% vStartup_SAMP_Disable1, Verzögerung:
Gui, SettingsGUI:Add, Edit, x260 y%y% w45 h20 vStartup_SAMP_Disable2
Gui, SettingsGUI:Add, UpDown, vStartup_SAMP_Delay Range0-60, %Startup_SAMP_Delay%
Gui, SettingsGUI:Add, Text, x310 y%y% vStartup_SAMP_Disable3, Sekunden
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp23, ?
y += 25
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vStartup_TS Checked%Startup_TS% gStartupSettingsChange, TS³ mitstarten
Gui, SettingsGUI:Add, Text, x190 y%y% vStartup_TS_Disable1, Verzögerung:
Gui, SettingsGUI:Add, Edit, x260 y%y% w45 h20 vStartup_TS_Disable2
Gui, SettingsGUI:Add, UpDown, vStartup_TS_Delay Range0-60, %Startup_TS_Delay%
Gui, SettingsGUI:Add, Text, x310 y%y% vStartup_TS_Disable3, Sekunden
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp24, ?
y += 25
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vStartup_Fraps Checked%Startup_Fraps% gStartupSettingsChange, Fraps mitstarten
Gui, SettingsGUI:Add, Text, x190 y%y% vStartup_Fraps_Disable1, Verzögerung:
Gui, SettingsGUI:Add, Edit, x260 y%y% w45 h20 vStartup_Fraps_Disable2
Gui, SettingsGUI:Add, UpDown, vStartup_Fraps_Delay Range0-60, %Startup_Fraps_Delay%
Gui, SettingsGUI:Add, Text, x310 y%y% vStartup_Fraps_Disable3, Sekunden
Gui, SettingsGUI:Add, Button, x410 y%y% h20 vStartup_Fraps_Disable4 gStartup_Select_Fraps, Durchsuchen
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp25, ?
y += 25
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vStartup_Other Checked%Startup_Other% gStartupSettingsChange, Anderes Programm mitstarten
Gui, SettingsGUI:Add, Text, x190 y%y% vStartup_Other_Disable1, Verzögerung:
Gui, SettingsGUI:Add, Edit, x260 y%y% w45 h20 vStartup_Other_Disable2
Gui, SettingsGUI:Add, UpDown, vStartup_Other_Delay Range0-60, %Startup_Other_Delay%
Gui, SettingsGUI:Add, Text, x310 y%y% vStartup_Other_Disable3, Sekunden
y += 25
Gui, SettingsGUI:Add, Text, x160 y%y% vStartup_Other_Disable4, Pfad:
Gui, SettingsGUI:Add, Edit, x190 y%y% w210 h20 vStartup_Other_Path, %Startup_Other_Path%
Gui, SettingsGUI:Add, Button, x410 y%y% h20 vStartup_Other_Disable5 gStartup_Select_Other, Durchsuchen
Gui, SettingsGUI:Add, Button, % "x505 y" y - 25 " h45 w12 gHelp26", ?
gosub StartupSettingsChange
Gui, SettingsGUI:Tab, 3
;Tab 3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
y := 50
Gui, SettingsGUI:Add, GroupBox, % "x10 y" y-15 " h115 w510 vOtherSettings c000000", Erweiterte Optionen
Gui, SettingsGUI:Add, Text, x15 y%y% h20, Zeit zum Warten auf Chatlog (ms) (s. ?-Button):
Gui, SettingsGUI:Add, Edit, y%y% x245 w45
Gui, SettingsGUI:Add, UpDown, vWaitFor Range20-300, %WaitFor%
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp16, ?
y += 25
Gui, SettingsGUI:Add, Checkbox, x15 y%y% h20 vRunAsAdmin Checked%RunAsAdmin%, Mit Administratorrechten starten
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp8, ?
y += 25
Gui, SettingsGUI:Add, Button, x15 y%y% h20 gDeleteData, sBinder-Dateien löschen
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp17, ?
y += 25
Gui, SettingsGUI:Add, Button, x15 y%y% h20 gUpdateDesign, Aktuelles Design manuell aktualisieren
Gui, SettingsGUI:Add, Button, x505 y%y% h20 w12 gHelp30, ?
y += 30
Gui, SettingsGUI:Tab
Gui, SettingsGUI:Add, Text, x5, sBinder %Version%-%Build% by IcedWave
Gui, SettingsGUI:Add, ListBox, x535 y25 w150 h320 gSettingsChangeTab vSettingsListBox AltSubmit Choose1 0x100, Allgemeine Einstellungen|Ingame-Einstellungen|   Telefontexte|Pfade|/trucking|Programme mitstarten|Erweiterte Optionen
Gui, SettingsGUI:Menu, MenuBar
;CreditsGUI
Gui, CreditsGUI:Font, S15 bold
Gui, CreditsGUI:Add, Link, cRed, Entwickler: <a href="https://forum.nes-newlife.de/user/810-icedwave/">IcedWave</a>`nDanke an folgende Personen:
Gui, CreditsGUI:Font
Gui, CreditsGUI:Font, S10
Gui, CreditsGUI:Add, Link,, <a href="https://forum.nes-newlife.de/user/1602-muffle/">Muffle</a> (Alter Schriftzug)`nChackN0rris (Viele tolle Ideen)`n<a href="https://forum.nes-newlife.de/user/412-l-ucius/">[L]ucius</a> (Icon, Schriftzug)`n`nAus dem AHK-Forum: <a href="http://www.autohotkey.com/board/user/7194-bentschi/">Bentschi</a>, <a href="http://www.autohotkey.com/board/user/19424-jnizm/">jNizM</a>, <a href="http://www.autohotkey.com/board/user/932-shimanov/">shimanov</a>, <a href="http://www.autohotkey.com/board/user/331-toralf/">toralf</a>, Brainside, <a href="http://www.autohotkey.com/board/user/1-polyethene/">polyethene</a>
Gui, CreditsGUI:Menu, MenuBar
;CustomBindsGUI
Gui, CustomBindsGUI:Add, Tab2, % "x5 y5 h" (Binds/4)*25+55 " w565 +Theme -Background -Wrap", Hotkeys - Seite 1|Hotkeys - Seite 2|Maustasten|Textbinds
loop, 2
{
	Gui, CustomBindsGUI:Tab, %A_Index%
	Gui, CustomBindsGUI:Add, GroupBox, % "x285 y50 h" (Binds/4)*25 " w1"
	Gui, CustomBindsGUI:Font, underline
	Gui, CustomBindsGUI:Add, Text, x10 y30 h20, Taste
	Gui, CustomBindsGUI:Add, Text, x140 y30 h20, Aktion
	Gui, CustomBindsGUI:Add, Text, x300 y30 h20, Taste
	Gui, CustomBindsGUI:Add, Text, x430 y30 h20, Aktion
	Gui, CustomBindsGUI:Font
	ddl := Round((Binds / 2) * (A_Index - 1))
	loop, % Binds / 2
	{
		num := Round((num2 := A_Index > Binds / 4) ? A_Index - Binds / 4 : A_Index)
		num3 := A_Index + ddl
		Gui, CustomBindsGUI:Add, Hotkey, % "x" (num2 ? 300 : 10) " y" num * 25 + 25 " w120 h20 vKey" num3, % Key%num3%
		Gui, CustomBindsGUI:Add, Edit, % "x" (num2 ? 430 : 140) " y" num * 25 + 25 " w130 h20 vBind" num3, % Bind%num3%
	}
}
Gui, CustomBindsGUI:Tab, 3
Gui, CustomBindsGUI:Font, underline
Gui, CustomBindsGUI:Add, Text, x10 y30 h20, Taste
Gui, CustomBindsGUI:Add, Text, x140 y30 h20, Aktion
Gui, CustomBindsGUI:Add, Text, x300 y30 h20, Taste
Gui, CustomBindsGUI:Add, Text, x430 y30 h20, Aktion
Gui, CustomBindsGUI:Font
Gui, CustomBindsGUI:Add, Text, x10 y50, Maustaste 4
Gui, CustomBindsGUI:Add, Edit, x140 y50 w130 h20 vxBind1, % xBind1
Gui, CustomBindsGUI:Add, Text, x300 y50, Maustaste 5
Gui, CustomBindsGUI:Add, Edit, x430 y50 w130 h20 vxBind2, % xBind2
Gui, CustomBindsGUI:Add, Text, x10 y75, Mausrad links kippen
Gui, CustomBindsGUI:Add, Edit, x140 y75 w130 h20 vwBind1, % wBind1
Gui, CustomBindsGUI:Add, Text, x300 y75, Mausrad rechts kippen
Gui, CustomBindsGUI:Add, Edit, x430 y75 w130 h20 vwBind2, % wBind2
Gui, CustomBindsGUI:Tab, 4
Gui, CustomBindsGUI:Add, GroupBox, % "x285 y50 h" (Hotstrings/2)*25 " w1"
Gui, CustomBindsGUI:Font, underline
Gui, CustomBindsGUI:Add, Text, x10 y30 h20, Textbind
Gui, CustomBindsGUI:Add, Text, x140 y30 h20, Aktion
Gui, CustomBindsGUI:Add, Text, x300 y30 h20, Textbind
Gui, CustomBindsGUI:Add, Text, x430 y30 h20, Aktion
Gui, CustomBindsGUI:Font
loop, % Hotstrings
{
	num := Round((num2 := A_Index > Hotstrings / 2) ? A_Index - Hotstrings / 2 : A_Index)
	Gui, CustomBindsGUI:Add, Edit, % "x" (num2 ? 300 : 10) " y" num * 25 + 25 " w120 h20 vHotstring" A_Index, % Hotstring%A_Index%
	Gui, CustomBindsGUI:Add, Edit, % "x" (num2 ? 430 : 140) " y" num * 25 + 25 " w130 h20 vhBind" A_Index, % hBind%A_Index%
}
Gui, CustomBindsGUI:Menu, MenuBar
;CarCalcGUI:
car_name := ["Admiral", "Alpha", "Andromada", "Baggage", "Banshee", "Benson", "BF Injection", "BF-400", "Bike", "Blade", "Blista Compact", "BMX", "Bobcat", "Boxville", "Broadway", "Buccaneer", "Buffalo", "Bullet", "Burrito [Premium]", "Cabbie", "Camper", "Cheetah [Premium]", "Clover", "Club [Premium]", "Comet [Premium]", "DFT-30", "Dinghy", "Dodo", "Elegant", "Elegy", "Esperanto", "Euros", "FCR-900", "Feltzer", "Flash", "Flatbed", "Freeway", "Glendale", "Greenwood", "Hermes", "Hotknife [Premium]", "Hotring Racer Typ A", "Huntley", "Hustler", "Infernus", "Jester", "Jetmax", "Journey", "Landstalker", "Leviathan", "Linerunner", "Majestic", "Marquis", "Maverick", "Mesa", "Moonbeam", "Mountain Bike", "Mule", "Nevada", "NRG-500", "Oceanic", "PCJ-600", "Perenniel", "Phoenix", "Picador", "Pony", "Premier [Premium]", "Quad", "Regina", "Remington", "Roadtrain", "Sabre", "Sanchez", "Savanna", "Sentinel", "Shamal", "Slamvan", "Sparrow", "Stafford", "Stallion", "Stratum", "Stretch", "Stunt", "Sultan", "Sunrise", "Super GT", "Tahoma", "Tanker", "Taxi", "Tornado", "Tractor", "Tropic", "Tug", "Turismo", "Uranus", "Utility", "Virgo", "Voodoo", "Vortex", "Walton", "Washington", "Wayfarer", "Windsor", "Yankee", "Yosemite", "ZR-350"]
Gui, CarCalcGUI:Add, Text, x10 y10, Fahrzeug:
Gui, CarCalcGUI:Add, Text, x130 y10, Panzerung:
Gui, CarCalcGUI:Font, s15 cRed
Gui, CarCalcGUI:Add, Text, vprice Border x280 y10 w180 Center, $0
Gui, CarCalcGUI:Font
ddl := ""
for i, v in car_name
{
	ddl .= "|" v
	if(A_Index = 1)
		ddl .= "|"
}
Gui, CarCalcGUI:Add, DDL, AltSubmit vcar gCalc x10 y30 w110, % SubStr(ddl, 2)
ddl := ""
Gui, CarCalcGUI:Add, DDL, AltSubmit vcarheal gCalc x130 y30 w140, Standard: 1.000||Stufe 1: 1.250|Stufe 2: 1.500|Stufe 3: 1.750|Stufe 4: 2.000
Gui, CarCalcGUI:Add, Checkbox, vTogAll gTogAll x280 y40, Alle auswählen
Gui, CarCalcGUI:Add, Checkbox, vOnlyAddons gCalc x375 y40, Nur Addonpreise
Gui, CarCalcGUI:Add, Checkbox, x10 y70 vpeilsender gCalc, Peilsender
Gui, CarCalcGUI:Add, Checkbox, x170 y70 vfunkfernbedienung gCalc, Funkfernbedienung
Gui, CarCalcGUI:Add, Checkbox, x330 y70 valarmanlage gCalc, Alarmanlage
Gui, CarCalcGUI:Add, Checkbox, x10 y90 vkennzeichenfarbe gCalc, Kennzeichenfarbe
Gui, CarCalcGUI:Add, Checkbox, x170 y90 vkraum gCalc, Kofferraum
Gui, CarCalcGUI:Add, Checkbox, x330 y90 vwaffenlager gCalc, Waffenlager
Gui, CarCalcGUI:Add, Checkbox, x10 y110 vversicherung gCalc, Versicherung
Gui, CarCalcGUI:Add, Checkbox, x170 y110 vunlimited_respawn gCalc, Unlimited Respawn
Gui, CarCalcGUI:Add, Checkbox, x330 y110 vakku gCalc, Handyakku
Gui, CarCalcGUI:Add, Checkbox, x10 y130 vneon gCalc, Neon
Gui, CarCalcGUI:Add, Checkbox, x330 y130 vvalue gCalc, Wert (/car sell)
Gui, CarCalcGUI:Add, Checkbox, x10 y150 vDiesel gCalc, Umbau auf Diesel
Gui, CarCalcGUI:Add, Checkbox, x330 y150 vLPG gCalc, Umbau auf LPG
Gui, CarCalcGUI:Add, GroupBox, x10 y170 w480 h50
Gui, CarCalcGUI:Add, Text, vInfo x15 y180 w470 h30 Center
Gui, CarCalcGUI:Add, Text, x10 y225 w480 Center cred, Alle Angaben ohne Gewähr!
gosub TogAll
;TruckerGUI:
Gui, TruckerGUI:Add, ListView, w800 h350 Grid Sort gLVClicked AltSubmit vTruckLV, Trucklevel|Kaufort|Verkaufsort|Produkt|Erfahrung|Einkaufspreis|Verkaufspreis|Gewinn|Gewicht|Erfahrung_|Einkaufspreis_|Verkaufspreis_|Gewinn_|Gewicht_|Kaufort_|Verkaufsort_
Gui, TruckerGUI:Default
LV_ModifyCol(1, "Integer Center")
loop, 7
{
	LV_ModifyCol(4 + A_Index, "NoSort")
	LV_ModifyCol(9 + A_Index, "0 Integer")
}
Gui, 1:Default
Gui, TruckerGUI:Add, Button, x10 w120 h20 y365 gTruckReload, Aktualisieren
Gui, TruckerGUI:Add, Text, x150 w250 y365 vTruckReloaded, Letzte Aktualisierung: Nie
Gui, TruckerGUI:Add, Text, x420 w80 y365 vTruckMissions, Missionen: -
Gui, TruckerGUI:Add, Text, x550 w80 y365 vTruckSelected gTruckCopy, Markiert: 0
Gui, TruckerGUI:Add, Button, x690 w120 y365 gTruckMap, Karte anzeigen
Gui, TruckerGUI:Add, Picture, x20 y400 w300 h169 vTruckPic1
Gui, TruckerGUI:Add, Picture, x450 y400 w300 h169 vTruckPic2
Gui, TruckerGUI:Font, s15 bold, Verdana
Gui, TruckerGUI:Add, Text, x320 y470 w130 Center, ->
Gui, TruckerGUI:Font
;TestGUI:
Gui, TestGUI:Add, Text,, HINWEIS: Gib am Anfang eines Befehls t ein, um Probleme zu vermeiden!`nAußerdem werden manche Text- und Fraktionsbinds im Spiel nicht so reagieren wie in diesem Fenster.`nAuch der Timestamp wird nur in diesem Fenster angezeigt.
Gui, TestGUI:Add, Edit, r30 w700
;DeleteGui:
Gui, DeleteGui:Add, Checkbox, vDel1, Temporäre Dateien löschen
Gui, DeleteGui:Add, Checkbox, vDel2 y+10, Registry-Daten löschen
Gui, DeleteGUI:Add, Checkbox, vDel9 y+10, Designs löschen
Gui, DeleteGUI:Add, Checkbox, vDel8 y+10, AppData-Ordner löschen
Gui, DeleteGui:Add, Checkbox, vDel3 y+10, Chatlog-Backups löschen
Gui, DeleteGui:Add, Checkbox, vDel7 y+10, Open-SAMP-API.dll löschen
Gui, DeleteGui:Add, Checkbox, vDel4 y+10, Einstellungsdatei löschen
Gui, DeleteGui:Add, Checkbox, vDel6 y+10, sBinder.exe löschen
Gui, DeleteGui:Add, Button, gDelete y+10 x120, Weiter »»
;DebugGUI:
Gui, DebugGUI:Add, Text, w500, Diese Informationen solltest du bei Problemen mit dem sBinder angeben. Dafür kannst du den Kopieren-Button nutzen.
Gui, DebugGUI:Add, Edit, ReadOnly h210 w500 vDebug, Wenn du diesen Text siehst, ist etwas schief gelaufen!
Gui, DebugGUI:Font
Gui, DebugGUI:Add, Button, h20 gCopyDebug, Kopieren
Gui, DebugGUI:Add, Button, x430 y+-20 h20 gReloadDebugGUI Default, Aktualisieren
gosub JobGUIBuild
;ChangelogGUI:
Gui, Changelog:Color, FFFFFF
Gui, Changelog:Add, ActiveX, x0 y0 w640 h480 vChangelog, Shell.Explorer
Gui, Changelog:Add, Button, gChangelogBrowser, Im Browser anzeigen
Gui, Changelog:Margin, 0
;TextbindsGUI:
Gui, Textbinds:Color, FFFFFF
Gui, Textbinds:Add, ActiveX, x0 y0 w640 h480 vTextbinds, Shell.Explorer
Gui, Textbinds:Add, Button, gTextbindsBrowser, Im Browser anzeigen
Gui, Textbinds:Margin, 0
;Overlay:
if(OverlayActive){
	Gui, Overlay:Color, DDDDDD
	Gui, Overlay:Add, Button, x520 y5 h20 w12 gHelp27, ?
	y := -95
	loop, %MaxOverlays%
	{
		y += 110
		Gui, Overlay:Add, GroupBox, % "x5 y" y-15 " h130 w510", Overlay %A_Index%
		Gui, Overlay:Add, Checkbox, % "x10 y" y " vOvOnlyInVeh" A_Index " Checked" OvOnlyInVeh%A_Index%, Nur in einem Fahrzeug anzeigen
		Gui, Overlay:Font, % "c" OvColor%A_Index% " " OvFontStyle%A_Index%, % OvFont%A_Index%
		Gui, Overlay:Add, Text, x390 y%y% w110 h24 vOvExample%A_Index%, Vorschau
		Gui, Overlay:Font
		y += 20
		Gui, Overlay:Add, Text, x10 y%y%, Schrift:
		Gui, Overlay:Add, Button, x50 y%y% w100 vOvFont%A_Index% gOvFontChange, Schriftart wählen
		Gui, Overlay:Add, Button, x160 y%y% w110 vOvColor%A_Index% gOvColorChange, Schriftfarbe wählen
		Gui, Overlay:Add, Button, x280 y%y% w100 vOvPos%A_Index% gOvPosChange, Position wählen
		Gui, Overlay:Add, Checkbox, % "x390 y" y " vOvShadow" A_Index " Checked" OvShadow%A_Index%, Schatten
		Gui, Overlay:Add, Text, % "x10 y" y+25, Text:
		Gui, Overlay:Add, Edit, % "x40 y" y+25 " w465 h60 vOvText" A_Index, % OvText%A_Index%
	}
	Gui, Overlay:Menu, MenuBar
	;OverlayPos:
	Gui, OverlayPos:Margin, 0
	Gui, OverlayPos:Add, Picture, x0 y0 w400 h300 gOvPicClick vOvPic 0x4000000
	Gui, OverlayPos:Add, GroupBox, w20 h20 x10 y10 vOvBorder
	Gui, OverlayPos:Add, Text, x5 y310, Wähle im Bild die ungefähre Position aus, die kannst du dann unten genauer`neinstellen. Die Koordinaten entsprechen der oberen linken Ecke des Textes`nund orientieren sich immer an einer Auflösung von 800x600.
	Gui, OverlayPos:Add, Text, x10 y360, x-Position:
	Gui, OverlayPos:Add, Edit, x70 y360 gOvPicClick
	Gui, OverlayPos:Add, UpDown, vOvX Range0-780 gOvPicClick, 10
	Gui, OverlayPos:Add, Text, x10 y390, y-Position:
	Gui, OverlayPos:Add, Edit, x70 y390 gOvPicClick
	Gui, OverlayPos:Add, UpDown, vOvY Range0-580 gOvPicClick, 10
	Gui, OverlayPos:Add, Button, x10 y420 gOverlayPosGuiClose Default, Speichern
	Gui, OverlayPos:Add, Button, x90 y420 gOverlayPosGuiCancel, Abbrechen
}
;AFKBox:
Gui, AFKBox:-Caption +AlwaysOnTop +ToolWindow +Hwndtemp2
GUIs["AFKBox"] := temp2
Gui, AFKBox:Margin, 5, 5
Gui, AFKBox:Add, Button, x5 y5 w140 h20 gDisableAFKBox, Dauerhaft deaktivieren
Gui, AFKBox:Add, Button, x150 y5 w15 h20 gDisableAFKBoxTemp, X
Gui, AFKBox:Add, Button, vAFKBox_Button x5 y30 w160 h60 Default gGTAActivate, Du bist seit 0 Sekunden auf dem Desktop
return
StartupSettingsChange:
for i, k in ["SAMP", "TS", "Fraps", "Other"]
{
	GuiControlGet, temp, SettingsGUI:, Startup_%k%
	GuiControl, SettingsGUI:Enable%temp%, Startup_%k%_Delay
	GuiControl, SettingsGUI:Enable%temp%, Startup_%k%_Path
	loop, 5
		GuiControl, SettingsGUI:Enable%temp%, Startup_%k%_Disable%A_Index%
}
return
GTAActivate:
WinActivate, ahk_group GTASA
return
SettingsChangeTab:
pages := [1, 1, 1, 2, 2, 2, 3]
GroupBoxVars := ["GenericSettings", "IngameSettings", "TelSettings", "PathSettings", "TruckingSettings", "StartupProgramSettings", "OtherSettings"]
Gui, SettingsGUI:Font, c000000
for i, k in GroupBoxVars
	GuiControl, SettingsGUI:Font, %k%
if(A_GuiControl){
	GuiControlGet, temp, SettingsGUI:, %A_GuiControl%
	GuiControl, SettingsGUI:Choose, SettingsTab, % pages[temp]
	Gui, SettingsGUI:Font, cFF0000 underline
	GuiControl, SettingsGUI:Font, % GroupBoxVars[temp]
	Gui, SettingsGUI:Font
}
pages := GroupBoxVars := ""
return
OvPosChange:
OvPosNum := SubStr(A_GuiControl, 0)
if(!FileExist(A_Temp "\sBinder\OvScreen.png")){
	ToolTip, Bild wird geladen...
	URLDownloadToFile, http://saplayer.lima-city.de/l/sBinder-ovscreen, %A_Temp%\sBinder\OvScreen.png
	ToolTip
}
GuiControl, OverlayPos:, OvPic, %A_Temp%\sBinder\OvScreen.png
GuiControl, OverlayPos:, OvX, % OvPosX%OvPosNum%
GuiControl, OverlayPos:, OvY, % OvPosY%OvPosNum%
gosub OvPicClick
Gui, OverlayPos:Show,, sBinder: Overlay-Position wählen
return
OvPicClick:
if(A_GuiControl = "OvPic"){
	;CoordMode, Mouse, Client
	mouse_ctrl := "Button"
	while((InStr(mouse_ctrl, "Button") OR InStr(mouse_ctrl, "Static")) AND GetKeyState("LButton", "P")){
		MouseGetPos, mouse_x, mouse_y,, mouse_ctrl
		GuiControl, OverlayPos:MoveDraw, OvBorder, x%mouse_x% y%mouse_y%
		GuiControl, OverlayPos:, OvX, % mouse_x*2
		GuiControl, OverlayPos:, OvY, % mouse_y*2
	}
}
else if(InStr(A_GuiControl, "OvPos") OR StrLen(A_GuiControl) = 3 OR is(A_GuiControl, "number")){
	GuiControlGet, x, OverlayPos:, OvX
	GuiControlGet, y, OverlayPos:, OvY
	GuiControl, OverlayPos:MoveDraw, OvBorder, % "x" x/2 " y" y/2
}
return
OvFontChange:
OvColorChange:
Thread, NoTimers
ToolTip
OvNum := SubStr(A_GuiControl, 0)
if(A_ThisLabel = "OvFontChange"){
	if(Font := Dlg_Font(OvFont%OvNum%, OvFontStyle%OvNum%, OvColor%OvNum%)){
		OvFont%OvNum% := Font["Name"]
		OvColor%OvNum% := Font["Color"]
		OvFontStyle%OvNum% := Font["Style"]
		ToolTip, % "Die Schriftart von Overlay " OvNum " wurde erfolgreich geändert.`nNeue Schriftart: " OvFont%OvNum%
	}
	else
		ToolTip, Die Schriftart konnte nicht geändert werden!
}
else if(A_ThisLabel = "OvColorChange"){
	if(Font := Dlg_Color(OvColor%OvNum%)){
		OvColor%OvNum% := Font[1], 2
		ToolTip, Die Schriftfarbe von Overlay %OvNum% wurde erfolgreich geändert.
	}
	else
		ToolTip, Die Schriftfarbe konnte nicht geändert werden!
}
if(Font){
	Gui, Overlay:Font, % "c" OvColor%OvNum% " " OvFontStyle%OvNum%, % OvFont%OvNum%
	GuiControl, Overlay:Font, OvExample%OvNum%
	gosub OvSave
}
SetTimer, HideToolTip, 5000
Gui, Overlay:Font
Font := ""
Thread, NoTimers, false
return
TogAll:
GuiControlGet, TogAll, CarCalcGUI:
GuiControl, CarCalcGUI:, peilsender, %TogAll%
GuiControl, CarCalcGUI:, funkfernbedienung, %TogAll%
GuiControl, CarCalcGUI:, alarmanlage, %TogAll%
GuiControl, CarCalcGUI:, kennzeichenfarbe, %TogAll%
GuiControl, CarCalcGUI:, kraum, %TogAll%
GuiControl, CarCalcGUI:, waffenlager, %TogAll%
GuiControl, CarCalcGUI:, versicherung, %TogAll%
GuiControl, CarCalcGUI:, unlimited_respawn, %TogAll%
GuiControl, CarCalcGUI:, akku, %TogAll%
GuiControl, CarCalcGUI:, neon, %TogAll%
Calc:
Gui, CarCalcGUI:Submit, Nohide
car_shop := [12, 12, 10, 16, 5, 13, 6, 7, 7, 3, 0, 7, 12, 13, 3, 15, 5, 5, 11, 13, 1, 11, 0, 11, 11, 13, 9, 10, 2, 2, 3, 2, 7, 0, 4, 13, 7, 15, 15, 3, 11, 16, 4, 3, 5, 4, 9, 8, 0, 16, 13, 4, 9, 10, 6, 12, 7, 13, 10, 7, 3, 7, 12, 4, 15, 13, 11, 7, 0, 1, 13, 4, 7, 0, 15, 10, 1, 16, 5, 15, 2, 5, 16, 2, 1, 4, 15, 13, 13, 15, 8, 9, 16, 5, 0, 13, 15, 1, 16, 13, 12, 7, 3, 13, 4, 12]
car_price := [31500, 34000, 2000000, 32500, 125000, 12000, 19900, 13900, 3000, 12500, 7500, 5000, 27500, 14000, 22700, 14800, 89000, 175000, 56000, 22000, 34000, 274000, 3999, 44000, 220000, 22000, 12500, 299000, 23500, 27900, 14500, 42500, 15000, 19500, 24500, 28500, 21000, 3400, 14500, 28500, 78000, 350000, 32000, 23000, 275000, 38900, 240000, 28000, 12900, 950000, 49000, 14500, 220000, 700000, 24999, 18000, 9000, 19500, 945000, 44900, 10500, 18000, 6800, 125000, 4300, 8500, 35000, 9000, 10700, 37500, 69000, 28000, 12900, 8400, 22000, 1400000, 16500, 320000, 48000, 19500, 23500, 112000, 450000, 39999, 23999, 98000, 14000, 59000, 29000, 9999, 14500, 79999, 32500, 144000, 16500, 24780, 18500, 9800, 300000, 4250, 32500, 36000, 27200, 17000, 27500, 59000]
car_info := [0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 5, 0, 0]
shop_name := ["GS Autohaus an der Ostküste", "Truckstop Autohaus zwischen LS und SF", "Oldtimer Autohaus in BlueBerry", "NewComer Autohaus in Las Venturas", "Otto's Autohaus in San Fierro", "Strandautohaus Nähe Los Santos Pier", "Bikeladen in San Fierro", "Wohnmobilekaufhaus nahe Los Santos", "Bootsanlegesteg in San Fierro", "Airshop San Fierro Airport", "Premium Autohaus San Fierro Schiff", "Caligula's Autohaus in LV", "Gewerbliches Autohaus East Los Santos", "Autohaus Los Santos am Hotel", "El Corrona Autohaus (nähe LS Airport)", "Prestige Autohaus in San Fierro (nahe Nova Tel AG)"]
;carhealprices := [0, 258500, 487000, 687000, 887000, 1287000, 1687000, 1987000, 2487000]
;carhealprices := [0, 258500, 745500, 1432500, 2319500, 3606500, 5293500, 7280500, 9767500]
carhealprices := [0, 10000, 25000, 45000, 70000] ; cumulative! Second is first + second
GuiControl, % "CarCalcGUI:" (Diesel ? "Disable" : "Enable"), LPG
GuiControl, % "CarCalcGUI:" (LPG ? "Disable" : "Enable"), Diesel
/*if(value){
	GuiControl, CarCalcGUI:Show, km
	if km is not number
		km := 0
	price := "Wert: " Floor(car_price[car]*(0.25-(km/100000)))
}
*/
if(value)
	price := "Wert: $" number_format(Floor(car_price[car]*0.25))
else{
	;GuiControl, CarCalcGUI:Hide, km
	price := "$" number_format(car_price[car]*!OnlyAddons+carhealprices[carheal]+peilsender*2000+funkfernbedienung*899+alarmanlage*500+kennzeichenfarbe*60+kraum*2500+waffenlager*2700+versicherung*800+unlimited_respawn*12000+akku*750+neon*2500+Diesel*2250+LPG*4500)
}
GuiControl, CarCalcGUI:, price, %price%
shop := car_shop[car]
GuiControl, CarCalcGUI:, Info, % "Du kannst das Fahrzeug " car_name[car] " bei" (shop = 5 ? " " : "m ") shop_name[shop] (shop = 13 && car_info[car] > 0 ? " ab Truckerlevel " car_info[car] : "") " kaufen."
car_shop := car_price := car_info := shop_name := shop_level := carhealprices := shop := price := ""
return
TruckReload:
GuiControlGet, temp, TruckerGUI:, TruckReloaded
GuiControl, TruckerGUI:, TruckReloaded, % SubStr(temp, 1, 31) " (Wird aktualisiert...)"
TruckDDOS := 0
if(RegExMatch(truck := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=trucking-v2",,, 1), "^\[\[(\d+)\]\]$", var)){
	TruckDDOS := 1
	if(WinActive("ahk_group GTASA"))
		AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	else
		ToolTip("Du musst noch " var1 " Sekunden warten`, bis du die Daten wieder abrufen kannst.`nGrund dafür ist`, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.", var1 * 1000)
	GuiControl, TruckerGUI:, TruckReloaded, Letzte Aktualisierung: %A_Hour%:%A_Min%:%A_Sec% (DDOS-Sperre)
	return
}
pos := 0
Gui, TruckerGUI:Default
LV_Delete()
while(pos := RegExMatch(truck, "Um`a)^(.+);(.+);(.+);(\d+);(\d+);(\d+);(\d+);(\d+)\|(\d+);(\d+)$", var, pos + 1))
	LV_Add("", var4, var1, var2, var3, number_format(var5), "$" number_format(var6), "$" number_format(var7), "$" number_format(var7 - var6), number_format(var8) "kg", var5, var6, var7, var7 - var6, var8, var9, var10)
truck := var := ""
loop, 9
	LV_ModifyCol(A_Index, "AutoHDR")
loop, 7
	LV_ModifyCol(9 + A_Index, "0 Integer")
LV_ModifyCol(1, "Sort")
GuiControl, TruckerGUI:, TruckReloaded, Letzte Aktualisierung: %A_Hour%:%A_Min%:%A_Sec%
GuiControl, TruckerGUI:, TruckMissions, % "Missionen: " LV_GetCount()
Gui, 1:Default
return
TruckMap:
Run, "http://saplayer.lima-city.de/dl/trucker/map.jpg"
return
LVClicked:
EL := ErrorLevel
if(A_GuiEvent = "ColClick" AND A_EventInfo > 4)
	LV_ModifyCol(A_EventInfo + 5, "Sort")
else if(A_GuiEvent = "I" AND InStr(EL, "s")){
	GuiControl, TruckerGUI:, TruckSelected, % "Markiert: " LV_GetCount("S")
	if(TruckPics){
		row := LV_GetNext()
		LV_GetText(row1, row, 15)
		LV_GetText(row2, row, 16)
		if(row1 AND row AND LV_GetCount("S") = 1){
			if(!FileExist(A_Temp "\sBinder\Trucking\" row2 ".png"))
				GuiControl, TruckerGUI:, TruckPic2
			if(!FileExist(A_Temp "\sBinder\Trucking\" row1 ".png")){
				GuiControl, TruckerGUI:, TruckPic1
				URLDownloadToFile, % "http://saplayer.lima-city.de/dl/trucker/" row1 ".png", % A_Temp "\sBinder\Trucking\" row1 ".png"
			}
			if(!FileExist(A_Temp "\sBinder\Trucking\" row2 ".png"))
				URLDownloadToFile, % "http://saplayer.lima-city.de/dl/trucker/" row2 ".png", % A_Temp "\sBinder\Trucking\" row2 ".png"
			GuiControl, TruckerGUI:, TruckPic1, % A_Temp "\sBinder\Trucking\" row1 ".png"
			GuiControl, TruckerGUI:, TruckPic2, % A_Temp "\sBinder\Trucking\" row2 ".png"
			Gui, TruckerGUI:+hwndTruckHWND
			if(WinExist("ahk_id " TruckHWND))
				Gui, TruckerGUI:Show, AutoSize NA, Trucking
		}
		else
			Gui, TruckerGUI:Show, h400 NA, Trucking
	}
}
return
TruckCopy:
Gui, TruckerGUI:Default
if(!LV_GetCount("S")){
	MsgBox, 48, Keine Daten zum Kopieren, Es sind keine Daten zum Kopieren ausgewählt!
	return
}
str := "Ort (Produkt) | Trucklevel | Erfahrung | Einkaufspreis -> Verkaufspreis (Gewinn) | Gewicht"
num := 0
while(num := LV_GetNext(num)){
	LV_Truck := Object()
	loop, % LV_GetCount("Col"){
		LV_GetText(LV_T, num, A_Index)
		LV_Truck[A_Index] := LV_T
	}
	str .= "`r`n" LV_Truck[2] " -> " LV_Truck[3] " (" LV_Truck[4] ") | " LV_Truck[1] " | " LV_Truck[5] " | " LV_Truck[6] " -> " LV_Truck[7] " (" LV_Truck[8] ") | " LV_Truck[9]
}
Gui, 1:Default
LV_Truck := ""
Clipboard := str
ToolTip("Die Daten der ausgewählten Missionen wurden erfolgreich in die Zwischenablage kopiert.", 4000)
return
FrakChangeGuiBuild:
Gui, FrakChangeGUI:Destroy
RealFrak := 1
loop, %Fraks%
{
	if(IsFrak(A_Index + 1)){
		RealFrak := A_Index + 1
		break
	}
}
ddl := ""
for i, k in Fraknames
	ddl .= "|" k
Gui, FrakChangeGUI:Add, DDL, Choose%RealFrak% vNewFrak AltSubmit, % SubStr(ddl, 2)
ddl := ""
Gui, FrakChangeGUI:Add, Button, y40 x10 gFrakChangeGUISave Default, Speichern
Gui, FrakChangeGUI:Add, Button, y40 x80 gFrakChangeGuiCancel, Abbrechen
Gui, FrakChangeGUI:+OwnerFrakGui
return
FrakGUIBuild:
Gui, FrakGui:Destroy
Gui, FrakGUI:Add, Text, x10 y5 h20, Aktuelle Fraktion:
Gui, FrakGUI:Font, underline
if(IsFrak(Frak) AND Frak > 1)
	Gui, FrakGUI:Add, Text, x+5 y5 h20 c009900, % Fraknames[Frak]
else
	Gui, FrakGUI:Add, Text, x+5 y5 h20 cAA0000, % Fraknames[1]
Gui, FrakGUI:Font
Gui, FrakGUI:Add, Button, y5 h20 w120 gFrakChangeGUI, Fraktion ändern
if(IsFrak(2))
	TextArray := ["Onduty/Offduty gehen", "Donut benutzen", "/checkwanted", "/m: Traffic Stop", "/m: Straße räumen", "/m: Felony Stop", "/s: Sie sind verhaftet", "/swapgun", "/mv + /oldmv + /towopen", "/me: Zur Zentrale funken", "/wanted: Alle anzeigen", "/wanted: Alle anzeigen außer 1-10", "/accept cop"]
else if(IsFrak(3))
	TextArray := ["Onduty/Offduty gehen -- Status 1/6", "/accept medic -- Status 3", "Einsatzort erreicht -- Status 4", "/revive + /ame", "/m: Dienstfahrzeug", "/m: Rettungshelikopter", "/m: Castor-Transport", "Willkommen zurück im Leben", "Nicht einsatzbereit -- Status 6", "/cancel revive + /ame", "Funkrufnummer umschalten", "Brandeinsatz angenommen -- Status 3"]
else if(IsFrak(4))
	TextArray := ["/getbizflag & /dropbizflag & /gangflag", "/mv & /oldmv", "/use green", "/use gold", "/use lsd", "/kcheck"]
else if(IsFrak(5))
	TextArray := ["/use lsd", "/use gold", "/use green", "/equip", "/s: Überfall", "/gangflag", "/me: Pizza anbieten"]
else if(IsFrak(6))
	TextArray := ["Spielst du mit uns, spielst du mit dem Tod!", "Wir sehen, wir kommen, wir töten, wir gehen", "/s: Überfall", "Munition anbieten", "/materials buildgun", "/materials buildammo", "/materials getgun", "/materials getammo", "/sellgun"]
else if(IsFrak(7))
	TextArray := ["/equip", "/use gold", "/use lsd", "/gangflag", "/swapgun", "/s: Überfall", "1. Spruch", "2. Spruch", "3. Spruch"]
else if(IsFrak(8))
	TextArray := ["Onduty/Offduty gehen", "/aufzug", "/lottoinfo", "/use donut", "/breaklive"]
else if(IsFrak(9))
	TextArray := ["/use gold", "/use green", "/equip", "/use lsd", "/gangfight", "/gangflag", "/gangwar", "/s: Don't fuck with the Ballas Family", "/s: Wir kommen wir sehen wir töten wir gehen", "/s Are you kidding me?"]
else if(IsFrak(10))
	TextArray := ["/dropbizflag, /getbizflag, /getflagpos", "/s: Überfall", "/ad: Werbung", "/gangflag", "/use lsd", "/use gold", "/fpkeep wasser", "/fpkeep dueng", "/swapgun", "/bl"]
else if(IsFrak(11))
	TextArray := ["/m: Straße räumen", "/m: Rechts ranfahren", "/m: Drogenkontrolle", "/s: Stehen bleiben"]
else if(IsFrak(12))
	TextArray := ["/dropbizflag, /getbizflag, /getflagpos", "/s: Überfall", "/gangflag", "/use lsd", "/use gold", "/fpkeep wasser", "/fpkeep dueng", "/swapgun", "/bl"]
fBinds := TextArray._maxIndex()
if(TextArray AND IsFrak(Frak)){
	Gui, FrakGUI:Font, underline
	Gui, FrakGUI:Add, Text, x10 y30, Taste
	Gui, FrakGUI:Add, Text, x150 y30, Aktion
	Gui, FrakGUI:Font
	for i, k in TextArray
	{
		Gui, FrakGUI:Add, Hotkey, % "x10 y" A_Index * 25 + 25 " w120 h20 vfBind" A_Index, % fBind%A_Index%
		Gui, FrakGUI:Add, Text, % "x150 y" A_Index * 25 + 25 " h20", % k
	}
}
if(IsFrak(3)){
	FrakOption6 := between(FrakOption6, 1, 5) AND is(FrakOption6, "integer") ? FrakOption6 : 1
	Gui, FrakGui:Add, Radio, % "x10 y" fBinds*25+60 " vFrakOption6 gFRNChange Checked" !!(FrakOption6 = 1), Funkrufnummer 1 (mit / und -):
	Gui, FrakGui:Add, Radio, % "x10 y" fBinds*25+85 " gFRNChange Checked" !!(FrakOption6 = 2), Funkrufnummer 2 (mit / und -):
	Gui, FrakGui:Add, Radio, % "x10 y" fBinds*25+110 " gFRNChange Checked" !!(FrakOption6 = 3), Funkrufnummer 3 (mit / und -):
	Gui, FrakGui:Add, Radio, % "x10 y" fBinds*25+135 " gFRNChange Checked" !!(FrakOption6 = 4), Funkrufnummer 4 (mit / und -):
	Gui, FrakGui:Add, Radio, % "x10 y" fBinds*25+160 " gFRNChange Checked" !!(FrakOption6 = 5), Funkrufnummer 5 (mit / und -):
	Gui, FrakGui:Add, Edit, % "vFrakoption1 x175 y" fBinds*25+60 " w100 h20", %Frakoption1%
	Gui, FrakGui:Add, Edit, % "vFrakoption2 x175 y" fBinds*25+85 " w100 h20", %Frakoption2%
	Gui, FrakGui:Add, Edit, % "vFrakoption3 x175 y" fBinds*25+110 " w100 h20", %Frakoption3%
	Gui, FrakGui:Add, Edit, % "vFrakoption4 x175 y" fBinds*25+135 " w100 h20", %Frakoption4%
	Gui, FrakGui:Add, Edit, % "vFrakoption5 x175 y" fBinds*25+160 " w100 h20", %Frakoption5%
}
TextArray := ""
Gui, FrakGUI:Menu, MenuBar
return
JobGUIBuild:
Gui, JobGUI:Destroy
Gui, JobGUI:Add, Text, x10 y5 h20, Beruf:
num := ""
for i, k in Jobnames
{
	if(A_Index != 1)
		num .= "|"
	num .= k
}
Gui, JobGUI:Add, DDL, y5 x+10 w175 AltSubmit Choose%Job% gJobChange vNewJob, %num%
if(Job = 2)
	TextArray := ["/knastmember", "/free", "/checkjailtime"]
else if(Job = 3)
	TextArray := ["/bus", "/route", "/buslock", "/delbus"]
else if(Job = 4)
	TextArray := ["/find", "/findcar"]
else if(Job = 5)
	TextArray := ["/rob haus", "/rob person", "/rob vehicle", "/printkey"]
else if(Job = 6)
	TextArray := ["/stone", "/takestone", "/deliverstone", "/stopstone", "/startgeterz", "/stopgeterz", "/erzload", "/releaseerz", "/einfo"]
else if(Job = 7)
	TextArray := ["/startfarm", "/cornload", "/releasecorn", "/pinfo"]
else if(Job = 8)
	TextArray := ["/buyprods", "/sellprods", "/load", "/prodinfo"]
else if(Job = 9)
	TextArray := ["/repair car", "/get kanister", "/get werkzeug", "/refill", "/tirechange", "/mduty", "/respray", "/respraycolor", "/showcolors"]
else if(Job = 10)
	TextArray := ["/startclean", "/clean", "/stopclean"]
else if(Job = 11)
	TextArray := ["/filljob", "/fillstation"]
else if(Job = 12)
	TextArray := ["/repair", "/tzinfo", "/atminfo", "/marktz", "/markatm", "/get ersatzteil"]
else if(Job = 13)
	TextArray := ["/fare", "/startfare", "/fare (Offduty gehen)", "/accept taxi", "/cancel taxi"]
else if(Job = 14)
    TextArray := ["/startfish", "/trackfish", "/catchfish", "/unloadfish", "/stopfish"]
else if(Job = 15)
    TextArray := ["/lawns", "/getgras", "/unloadgras", "/stopgras"]
else if(Job = 16)
    TextArray := ["/wood", "/takewood", "/deliverwood", "/stopwood"]
else if(Job = 17)
    TextArray := ["/hunt", "/trackhunt", "/takehunt", "/deliverhunt", "/stophunt"]
else if(Job = 18)
    TextArray := ["/starttrash", "/empty", "/unloadtrash", "/stoptrash", "/gettrash"]
else if(Job = 19)
    TextArray := ["/startpizza", "/getpizza", "/delivery", "/unloadpizza", "/stoppizza"]
else if(Job = 20)
    TextArray := ["/get drogen", "/sellhanf", "/crackload", "/releasecrack"]
else if(Job = 21)
    TextArray := ["/materials buy", "/materials deliver", "/sellgun"]
else if(Job = 22)
    TextArray := ["/foodload", "/releasefood"]
jBinds := TextArray._maxIndex()
if(TextArray){
	Gui, JobGUI:Font, underline
	Gui, JobGUI:Add, Text, x10 y30, Taste
	Gui, JobGUI:Add, Text, x150 y30, Aktion
	Gui, JobGUI:Font
	for i, k in TextArray
	{
		Gui, JobGUI:Add, Hotkey, % "x10 y" A_Index * 25 + 25 " w120 h20 vjBind" A_Index, % jBind%A_Index%
		Gui, JobGUI:Add, Text, % "x150 y" A_Index * 25 + 25 " h20", % k
	}
	/*if(Job = 10)
		Gui, JobGUI:Add, Checkbox, % "x10 y" TextArray._maxIndex() * 25 + 50 " h20 vJobOption1 Checked" JobOption1, Dialog bei /moneyload automatisch schließen
	*/
}
TextArray := ""
Gui, JobGUI:Menu, MenuBar
return
JobChange:
GuiControlGet, NewJob, JobGUI:
Gui, JobGUI:+HwndJobGUI
WinGetPos, job_x, job_y,,, ahk_id %JobGUI%
if(NewJob != Job){
	Job := NewJob
	IniWrite, %Job%, %INIFile%, Settings, Job
	gosub JobGUIBuild
	Gui, JobGUI:Show, x%job_x% y%job_y% w300, sBinder: Jobs
}
gosub HotkeysDefine
return
FrakChangeGuiCancel:
Gui, FrakChangeGUI:Cancel
return
Info:
if(InfoChangesActive)
	return
Inf.Silent := 1
InfoChangesActive := 1
GuiControl, 1:Disable, LastInfo
GuiControl, 1:Disable, NextInfo
if(A_GuiControl = "NextInfo")
	cInfo ++
else if(A_GuiControl = "LastInfo")
	cInfo --
;GuiControl, 1:, Info, % Info%cInfo%
SetWB(Inf, Info[cInfo],, InfoColor)
if(cInfo = 1)
	GuiControl, 1:Disable, LastInfo
else
	GuiControl, 1:Enable, LastInfo
if(cInfo = Info._maxIndex())
	GuiControl, 1:Disable, NextInfo
else
	GuiControl, 1:Enable, NextInfo
GuiControl, 1:Focus, %A_GuiControl%
InfoChangesActive := 0
return
UpdateDesign:
MainGuiDesign := Designs[UseDesign]
if(MainGuiDesign["url"]){
	;Progress, A B1 M T CB000000 CWFFFFFF, Bitte habe etwas Geduld..., % "Design " MainGuiDesign["name"] " wird aktualisiert", % "sBinder: Design " MainGuiDesign["name"]
	InfoProgress("Bitte habe etwas Geduld...", "Design " MainGuiDesign["name"] " wird aktualisiert", "sBinder: Design " MainGuiDesign["name"])
	URLDownloadToFile, % MainGuiDesign["url"], % A_AppData "\sBinder\Design\" MainGuiDesign["file"]
	EL := ErrorLevel
	;Progress, Off
	InfoProgress()
	if(EL OR !FileExist(A_AppData "\sBinder\Design\" MainGuiDesign["file"]))
		MsgBox, 16, % "Design " MainGuiDesign["name"] " konnte nicht manuell aktualisiert werden", % "Das von dir gewählte Design " MainGuiDesign["name"] " konnte leider nicht manuell aktualisiert werden.`n`nAus diesem Grund wird jetzt weiterhin das alte Design genutzt."
	else{
		ToolTip, % "Das von dir gewählte Design " MainGuiDesign["name"] " wurde erfolgreich manuell aktualisiert.`nEtwaige Änderungen werden jedoch erst nach einem Neustart des sBinder aktiv."
		SetTimer, HideToolTip, 10000
	}
}
else{
	ToolTip, % "Das von dir gewählte Design " MainGuiDesign["name"] " kann nicht aktualisiert werden!"
	SetTimer, HideToolTip, 5000
}
return
APIUseChange:
GuiControlGet, UseAPI, SettingsGUI:
GuiControl, SettingsGUI:Enabled%UseAPI%, OvSettings
IniWrite, %UseAPI%, %INIFile%, Settings, UseAPI
if(UseAPI){
	MsgBox, 36, API nutzen: sBinder neustarten?, Um die API nutzen zu können, muss der sBinder jetzt neu gestartet werden. Willst du davor deine Änderungen speichern?
	IfMsgBox, Yes
	{
		gosub Save
		Sleep, 1000
	}
	Reload
}
else{
	DllCall("FreeLibrary", "Ptr", hModule)
	ToolTip("Die API wird nun nicht mehr genutzt (kein Neustart erforderlich).", 6000)
}
return
TruckingSortChange:
GuiControlGet, TruckingSort_temp, SettingsGUI:, TruckingSort
if(TruckingSort_temp = 7 AND !UseAPI){
	GuiControl, SettingsGUI:Choose, TruckingSort, %TruckingSort%
	ToolTip, Das Sortieren der Einträge nach Entfernung ist nur möglich`, wenn die API aktiviert ist!
	SetTimer, HideToolTip, 5000
}
TruckingSort_temp := ""
return
AFKBox_Changed:
GuiControlGet, AFKBox, SettingsGUI:
IniWrite, %AFKBox%, %INIFile%, Settings, AFKBox
SetTimerNow("AFKBox_CheckDesk", AFKBox ? 500 : "Off")
return
TelChanged:
GuiControlGet, Tel, SettingsGUI:
GuiControl, % "SettingsGUI:Disable" !Tel, pText
GuiControl, % "SettingsGUI:Disable" !Tel, hText
GuiControl, % "SettingsGUI:Disable" !Tel, abText
return
FRNChange:
Gui, FrakGUI:Submit, Nohide
return
DesignChange:
ToolTip, Die Änderung wird erst nach einem Neustart des sBinders gültig!`nAußerdem muss vorher gespeichert werden!
SetTimer, HideToolTip, 5000
return
HitsoundChanged:
GuiControlGet, temp, SettingsGUI:, AutoHitsound
GuiControl, % "SettingsGUI:Disable" !temp, HitsoundText
return
NameToSamp:
GuiControlGet, Nickname, 1:
RegWrite, REG_SZ, HKCU, Software\SAMP, playername, %Nickname%
if(!ErrorLevel)
	ToolTip, Dein SAMP-Name wurde erfolgreich in %Nickname% geändert.
else
	ToolTip, Ein Fehler ist aufgetreten!
SetTimer, HideToolTip, 5000
return
NameFromSamp:
RegRead, temp, HKCU, Software\SAMP, playername
if(!ErrorLevel){
	Nickname := temp
	GuiControl, 1:, Nickname, %Nickname%
	IniWrite, %Nickname%, %INIFile%, Settings, Name
	ToolTip, Dein SAMP-Name wurde erfolgreich ausgelesen und wird jetzt genutzt.
}
else
	ToolTip, Ein Fehler ist aufgetreten!
SetTimer, HideToolTip, 5000
return


TSConnect:
SetTimer, TSConnect, Off
Process, Exist, ts3client_win32.exe
ts3 := ErrorLevel
Process, Exist, ts3client_win64.exe
if(!(ts3 + ErrorLevel)){
	Run, ts3server://%TSIP%,, UseErrorLevel
	if(ErrorLevel)
		ToolTip("Fehler beim Starten von TS³`n`nTS³ konnte nicht gestartet werden.`nEventuell ist es auf diesem Computer nicht oder nicht richtig installiert.", 5000)
}
else
	ToolTip("TS³ ist bereits aktiv`nBeende es erst`, bevor du es neu startest!", 4000)
return
Forum:
Run, http://forum.nes-newlife.de
return
RunOtherProgram:
SetTimer, RunOtherProgram, Off
SplitPath, Startup_Other_Path, temp
Process, Exist, %temp%
if(temp AND ErrorLevel)
	ToolTip("Das ausgewählte Programm zum Mitstarten ist bereits aktiv`nBeende es erst`, bevor du es neu startest!", 5000)
else{
	if(FileExist(Startup_Other_Path))
		Run, %RunPrivileges%%Startup_Other_Path%,, UseErrorLevel
	else
		ErrorLevel := 1
	if(ErrorLevel){
		Run, %Startup_Other_Path%,, UseErrorLevel
		if(ErrorLevel)
			ToolTip("Fehler beim Starten des anderen ausgewählten Programms.`nEventuell stimmt der Pfad nicht, prüfe diesen bitte.`n`n(" FileExist(Startup_Other_Path) ")", 5000)
	}
}
return
RunFraps:
SetTimer, RunFraps, Off
SplitPath, Startup_Fraps_Path, temp
Process, Exist, %temp%
if(ErrorLevel)
	ToolTip("Fraps ist bereits aktiv`nBeende es erst`, bevor du es neu startest!", 5000)
else{
	Run, %RunPrivileges%%Startup_Fraps_Path%,, UseErrorLevel
	if(ErrorLevel)
		ToolTip("Fehler beim Starten von Fraps`n`nFraps konnte nicht gestartet werden.`nEventuell ist es auf diesem nicht oder nicht richtig installiert.", 5000)
}
return
SimpleSAM:
Run, simplesam://,, UseErrorLevel
if(ErrorLevel)
	MsgBox, 48, SimpleSAM nicht gefunden, SimpleSAM konnte nicht gestartet werden.`nIst es installiert?
return
CarCalcGUI:
Gui, CarCalcGUI:Show,, sBinder: Fahrzeugrechner
gosub Calc
return
CustomBindsGUI:
Gui, CustomBindsGUI:Show,, sBinder: Eigene Binds
return
NotesGUI:
Gui, NotesGUI:Font, underline
Gui, NotesGUI:Add, Text, x10 y10, Notiznummer
Gui, NotesGUI:Add, Text, x80 y10, Inhalt
Gui, NotesGUI:Font
loop, %Notes%
{
	Gui, NotesGUI:Add, Text, % "x10 y" A_Index * 25 + 5, Notiz %A_Index%:
	Gui, NotesGUI:Add, Edit, % "vNote" A_Index " x80 w600 r1 y" A_Index * 25 +5, % Note%A_Index%
}
Gui, NotesGUI:Menu, MenuBar
Gui, NotesGUI:Show,, sBinder: Notizen
return
FrakGUI:
Gui, FrakGUI:Show, AutoSize, sBinder: Fraktionsbinds
return
FrakChangeGUI:
Gui, FrakChangeGUI:Show,, sBinder: Fraktion ändern
return
TestGUI:
Gui, TestGUI:Show,, Keybinder testen (Debug)
return
OverlayGUI:
Gui, Overlay:Show,, sBinder: Overlay-Einstellungen
return
TextbindsOnline:
Textbinds.Silent := 1
Textbinds.Navigate("http://saplayer.lima-city.de/l/sBinder-textbinds")
Gui, Textbinds:Show,, sBinder: Textbinds
return
TextbindsBrowser:
Run, http://saplayer.lima-city.de/l/sBinder-textbinds
return
ChangelogOnline:
Changelog.Silent := 1
Changelog.Navigate("http://saplayer.lima-city.de/l/sBinder-changelog&a=nobugs")
Gui, Changelog:Show,, sBinder: Changelog
return
ChangelogBrowser:
Run, http://saplayer.lima-city.de/l/sBinder-changelog&a=nobugs
return
ForumThread:
Run, https://forum.nes-newlife.de/thread/1544-sbinder-by-icedwave/
return
CreditsGUI:
Gui, CreditsGUI:Show,, sBinder: Credits
return
TruckerGUI:
Gui, TruckerGUI:Show, h400, sBinder: Trucking
return
AboutGUI:
Gui, AboutGUI:Show,, sBinder: Über
return
Nothing:
return
Exit:
ExitApp
return
SettingsGUI:
Gui, SettingsGUI:Show,, sBinder: Einstellungen
GuiControl, SettingsGUI:Focus, SettingsListBox
return
JobGUI:
Gui, JobGUI:Show, Center w300, sBinder: Jobs
return
DebugGUI:
gosub ReloadDebugGUI
Gui, DebugGUI:Show,, sBinder: Debug-Informationen
return
Restart:
Reload
return
HotkeysDefine:
currhotkeyif := 0
if(IsObject(OldHotkeys)){
	for i, k in OldHotkeys
	{
		if(k != ""){
			if(InStr(OldHotkeyLabels[i], "fBind")){
				if(!currhotkeyif)
					Hotkey, If, frakbinds && WinActive("ahk_group GTASA")
				currhotkeyif := 1
			}
			else if(currhotkeyif){
				Hotkey, IfWinActive, ahk_group GTASA
				currhotkeyif := 0
			}
			Hotkey, %k%, Off, UseErrorLevel
			if(ErrorLevel AND !A_IsCompiled)
				MsgBox, 16, Fehler bei HotkeysDefine, % "HotkeysDefine-Fehler!`n`nHotkey: " k "`nErrorLevel: " ErrorLevel
		}
	}
}
OldHotkeys := Object()
OldHotkeyLabels := Object()
loop, %Binds%
{
	if(Key%A_Index% != "")
		NewHotkey(Key%A_Index%, "Bind" A_Index)
}
loop, 2
{
	if(xBind%A_Index%)
		NewHotkey("XButton" A_Index, "xBind" A_Index)
}
if(wBind1)
	NewHotkey("WheelLeft", "wBind1")
if(wBind2)
	NewHotkey("WheelRight", "wBind2")
fBinds_used := 0
Hotkey, If, frakbinds && WinActive("ahk_group GTASA")
loop, % fBinds_max
{
	if(fBind%A_Index% != "" AND fBinds >= A_Index){
		NewHotkey(fBind%A_Index%, "fBind" A_Index)
		fBinds_used ++
	}
}
Hotkey, IfWinActive, ahk_group GTASA
for i, oldhotstring in hotstringsactive
{
	Hotstring(":X:" oldhotstring, "hBind" i, "Off")
}
hotstringsactive := []
loop, % Hotstrings
{
	if(Hotstring%A_Index% != "" AND hBind%A_Index% != ""){
		Hotstring(":X:" Hotstring%A_Index%, "hBind" A_Index, "On")
		hotstringsactive[A_Index] := Hotstring%A_Index%
	}
}
loop, %jBinds_max%
{
	if(jBind%A_Index% != "" AND jBinds >= A_Index)
		NewHotkey(jBind%A_Index%, "jBind" A_Index)
}
return
Help1:
Help2:
Help3:
Help4:
Help5:
Help6:
Help7:
Help8:
Help9:
Help10:
Help11:
Help12:
Help13:
Help14:
Help15:
Help16:
Help17:
Help18:
Help19:
Help20:
Help21:
Help22:
Help23:
Help24:
Help25:
Help26:
Help27:
Help28:
Help29:
Help30:
helptexts := ["Die Connect-Funktionen ermöglichen dir, dass du mit dem sBinder alles, was Nova-eSports NewLife bietet (TeamSpeak, SAMP-Server und Forum), mit nur einem Klick erreichen kannst.`nProbier es aus!"
, "In den Eigenen Binds kannst du Texte oder Befehle festlegen, die beim Drücken einer festgelegten Taste an GTA:SA:MP gesendet werden. Du kannst mehrere Befehle/Texte durch das Zeichen ""~"" (ohne Anführungszeichen) trennen.`nBeispiel: /sell fisch 1~/sell fisch 2~/sell fisch 3~/sell fisch 4~/sell fisch 5~`n`nAußerdem kannst du eine Pause zwischen den einzelnen Befehlen einfügen, indem du dort ein ""[Wait XXX]"" (ohne Anführungszeichen) einfügst.`nBeispiel: /fish~[Wait 5000]/fish~[Wait 5000]/fish~[Wait 5000]/fish~[Wait 5000]/fish~`nDieses Beispiel gibt ""/fish"" ein, wartet 5 Sekunden (5000 Millisekunden) und gibt dann wieder ""/fish"" ein (insgesamt 5 mal).`n`nDu kannst auch das Wort [Name] nutzen, dieses wird durch den unter ""Dein Name"" angegebenen Namen ersetzt.`n`nAußerdem kannst du auch ID-Binds nutzen, Beispiel dazu: ""/d ID [ID 1] | [ID 2] WPs | [ID 3] | bitte best.~/su [ID 1] [ID 2] [ID 3]"" Bei diesem Beispiel wirst du 3mal nach der ID gefragt, wenn du dann zum Beispiel die Daten 99, 15 und schwere StVO eingibst, wird Folgendes gesendet:`n/d ID 99 | 15 WPs | schwere StVO | bitte best.~/su 99 15 schwere StVO`n`nDu kannst am Anfang der eigenen Binds auch [InputMode] schreiben, dann wird der Text ""normal"" gesendet (somit muss am Anfang t stehen und ~ wird zu einem Enter, außerdem kannst du Tasten wie z.B. {F6} nutzen).`nBitte beachte: Manche Eingaben, wie z.B. Dialoge, kannst du NUR per [InputMode] nutzen!`n`nACHTUNG: Vergiss nicht, die Eigenen Binds zu speichern!`n`nHINWEIS: Die Maustasten 4/5 sowie das Kippen des Mausrads werden nicht bei jeder Maus korrekt erkannt. Es kann auch sein, dass das Kippen des Mausrads als Taste 4/5 erkannt wird, oder auch gar nicht."
, "Hier findest du die Binds für die Befehle aller Berufe auf dem Server. Du kannst sie dir selbst definieren."
, "In den Fraktionsbinds kannst du Tasten für vordefinierte, einheitliche Aktionen setzen.`nDafür musst du erst deine Fraktion auswählen.`n`nWenn deine Fraktion noch nicht vertreten ist, kannst du, oder z.B. einer eurer Leader, mich kontaktieren, dass auch deine Fraktion integriert wird."
, "In den Notizen kannst du persönliche Aufgaben für dich speichern, die du auch im Spiel anzeigen, bearbeiten und löschen kannst."
, "Der Fahrzeugrechner kann euch die Preise der Fahrzeuge auf Nova anzeigen. Er wurde von mir entworfen."
, "Du kannst hier deinen Nova-Nickname eingeben. In den eigenen Binds wird dann [Name] mit diesem Namen ersetzt."
, "Mit Administratorrechten starten:`nIst diese Option aktiviert, so wird bei jedem Start nach Administratorrechten gefragt. Dies stellt sicher, dass der sBinder auch tatsächlich auf den SAMP-Prozess zugreifen und im entsprechenden Fenster Eingaben tätigen kann."
, "Hier findest du die Aufträge für Trucker.`n`nDu kannst sie auch ingame mit /trucking abrufen. Außerdem kannst du die Bilder der Orte in den Einstellungen deaktivieren."
, "Ins Tray minimieren:`nWenn du diese Option aktivierst, wird der sBinder beim Minimieren in die Trayleiste verschoben - er erscheint also nicht mehr in der Taskleiste.`nDu kannst ihn in der Trayleiste wieder öffnen.`n`n`nName des GTA-Prozesses:`nDer Name des GTA San Andreas-Prozesses. Dieser wird benötigt, damit der sBinder richtig funktioniert.`nGib hier keinen Pfad an, nur den Namen der .exe-Datei. Standardmäßig heißt diese gta_sa.exe`n(Erfordert einen Neustart)"
, "Bilder im Trucking-Fenster anzeigen:`nMit dieser Option kannst du kontrollieren, ob im Fenster der Trucking-Aufträge die Bilder der jeweiligen Orte angezeigt werden sollen.`n`n`nBox anzeigen, wenn du auf dem Desktop bist:`nWenn diese Option aktiviert ist, wird dir immer, wenn du gerade auf dem Desktop bist, eine (verschiebbare) Box angezeigt, die dir die Zeit, wie lange du auf dem Desktop bist, anzeigt."
, "Doppelhupe = /mv:`nWenn diese Funktion aktiviert ist, bewirkt ein schnelles, doppeltes Betätigen der Hupe (Taste H), dass /mv (Tor öffnen/schließen) gesendet wird.`n`n`n/me-Texte bei Animationen:`nDie /me-Texte werden bei Animationen wie z.B. /gro gesendet.`nBeispiel: /gro -> /me setzt sich auf den Boden.`n`n`nTimer für /use [lsd/green/donut/gold]`nZeigt dir im Spiel an, wann du LSD/Green/Gold/Donuts wieder einnehmen kannst bzw. warnt dich im Fall von LSD zusätzlich, kurz bevor die Nebenwirkungen eintreten."
, ""
, "Du kannst ingame /trucking nutzen, um dir die aktuell verfügbaren Aufträge anzeigen zu lassen.`n`n`nNur Aufträge für Level anzeigen:`nDamit kannst du einstellen, bis zu welcher Grenze des Truckerlevels du die Aufträge angezeigt bekommst. Es gibt im Grunde diese Werte:`n-1: Zeigt ALLE Werte an, auch, wenn du das Level für diese Aufträge noch gar nicht erreicht hast.`n0: Zeigt nur die Aufträge deines aktuellen Levels an.`n1-10: Zeigt auch Aufträge von n niedrigeren Leveln an. Wenn du es also auf 2 stellst und du aktuell Truckerlevel 5 bist, zeigt es dir Aufträge von Level 3, 4 und 5 an. Der Wert 1 ist bei dieser Einstellung empfehlenswert (Standardwert)."
, "Chatlog-Pfad auswählen:`nWenn du Probleme beim Auslesen des Chats hast, dann kannst du hier den Pfad des Chatlogs ändern.`n`n`nSAMP-Pfad ändern:`nDu kannst den Pfad zu SAMP angeben, um direkt im sBinder auf den Server zu verbinden (mit dem Button ""SAMP starten"")."
, "Diesen Wert solltest du nur ändern, wenn es wirklich nötig ist!`n`nDiese Zeit bestimmt, wie lange (in Millisekunden) zusätzlich zum aktuellen Ping zum Server auf eine neue Zeile im Chatlog gewartet werden soll.`nStandardwert ist 90, falls der Chatlog nicht ausgelesen werden kann (z.B. bei /paydaytime), solltest du diese Zeit erhöhen.`nEs sind Werte zwischen 20 und 200 möglich."
, "Hier findest du einige Möglichkeiten zum Löschen der Daten/Dateien, die der sBinder erzeugt.`nEs ist also ähnlich wie eine Deinstallation."
, "API nutzen:`nDie Open-SAMP-API.dll wird benutzt, um Daten, die für dich bestimmt sind, auch nur dir anzuzeigen. Außerdem wird der Spielablauf weniger blockiert und die Eingabe in Dialoge nicht gestört.`nAllerdings funktioniert die API nicht bei jedem richtig, deshalb ist ihre Nutzung optional. Du kannst sie jederzeit aktivieren und deaktivieren.`nHINWEIS: Nach einer Änderung dieser Option wird der sBinder evtl. neu gestartet!`n`n`nOverlay-Einstellungen:`nDu kannst im sBinder ein komplett konfigurierbares Overlay nutzen, das dir im Spiel wichtige Daten anzeigt.`nDabei kannst du den Text mit einigen Variablen gestalten, außerdem sind dir bei der Wahl der Farbe, Schriftart, Schriftgröße und Position keine Grenzen gesetzt.`nMehr Informationen dazu findest du beim Klick auf den ?-Button in den Overlay-Einstellungen."
, "Die Telefontexte werden geschrieben, wenn du einen Anruf annimmst, auflegst oder auf den Anrufbeantworter (/ab) umleitest.`nDu kannst sie nutzen wie die eigenen Binds.`nSie werden durch /p (Annehmen), /h (Auflegen) und /ab (Anrufbeantworter) ausgelöst, sofern sie aktiviert sind."
, ""
, "Beim Login automatisch eingeben:`nWenn du diese Funktion aktivierst, wird nach dem Login automatisch der in dem nebenstehenden Textfeld angegebene Befehl eingegeben.`nDu kannst zum Beispiel /togphone oder /hitsound nutzen (oder eine Kombination aus beiden).`nHINWEIS: Damit die Funktion korrekt arbeitet, muss der Keybinder VOR dem Start von SAMP gestartet werden!"
, "INI-Datei öffnen:`nIn der INI-Datei werden alle deine Einstellungen gespeichert. Du kannst sie dir mit diesem Button ansehen.`nHINWEIS: Falls du Daten in der INI-Datei geändert hast, musst du den sBinder neu starten, damit sie ausgelesen werden. Wenn du davor im Keybinder speicherst gehen deine Änderungen verloren.`n`n`nsBinder-Ordner öffnen:`nMit diesem Button kannst du den Ordner öffnen, in dem der sBinder gespeichert ist."
, "Hier kannst du bestimmen, ob beim Starten des sBinders automatisch nach der angegebenen Zeit auf den Server connectet werden soll."
, "Hier kannst du bestimmen, ob beim Starten des sBinders automatisch nach der angegebenen Zeit auf den TS-Server connectet werden soll."
, "Hier kannst du bestimmen, ob beim Starten des sBinders automatisch nach der angegebenen Zeit Fraps gestartet werden soll.`nEventuell musst du dazu den Pfad von Fraps angeben."
, "Hier kannst du bestimmen, ob beim Starten des sBinders automatisch nach der angegebenen Zeit ein weiteres Programm gestartet werden soll.`nDu musst den Pfad dieses Programms angeben."
, "Hier kannst du deine Overlays (maximal " MaxOverlays ") kofigurieren. Du kannst die Schriftfarbe wählen, die Schriftgröße und -art einstellen und natürlich einen individuellen Text wählen, der durch einige Variablen (siehe unten) ergänzt werden kann. Außerdem kannst du festlegen, dass ein Overlay nur in einem Fahrzeug angezeigt werden soll.`n`nHier findest du alle Variablen, die du nutzen kannst:`n[Armor]: Deine aktuelle Rüstung (0 falls nicht vorhanden)`n[CarHeal]: Dein aktuelles Carheal (wie bei /dl)`n[CarLight]: ""an"" oder ""aus"", je nachdem, ob das Licht an ist`n[CarLock]: Zeigt dir ""aufgeschlossen"" oder ""abgeschlossen"" an (bei Fraktionsfahrzeugen immer ""aufgeschlossen"")`n[CarModel]: Die Model-ID des aktuellen Fahrzeugs (nicht die Car-ID!)`n[CarMotor]: ""an"" oder ""aus"", je nachdem, ob der Motor an ist`n[CarName]: Der Name des aktuellen Fahrzeugs`n[CarSpeed]: Anzeige der Geschwindigkeit des Fahrzeugs in km/h (schneller als der Server-Tacho)`n[City]: Die Stadt, in der du dich aktuell aufhältst`n[Date]: Datum im Format dd.mm.yyyy`n[FPS]: Aktuelle FPS-Anzahl`n[HP]: Dein aktuelles Heal`n[Money]: Dein aktuelles Geld (auf der Hand)`n[Name]: Der unter ""Dein Name"" angegebene Name`n[NL]: Nähester Ort auf Nova, zum Beispiel ""Stadthalle SF""`n[NLDistance]: Entfernung zum nächsten Ort auf Nova`n[Time]: Uhrzeit im Format hh:mm:ss`n[Zone]: Die Zone, in der du dich aktuell aufhältst`n[LsdTimer]: Zeit, bis nach /use lsd die Nachwirkungen eintreten bzw. bis du das nächste Mal LSD usen kannst`n[GreenTimer] / [DonutTimer] / [GoldTimer]: Zeit, bis du das nächste Mal Green/Donuts/Gold zu dir nehmen kannst"
, "Hier kannst du bestimmen, nach welchem Kriterium die Aufträge sortiert werden (standardmäßig nach Trucklevel). Wenn du zum Beispiel ""Erfahrung"" wählst, wird dir der Auftrag mit der höchsten Erfahrung oben (absteigend) bzw. unten (aufsteigend) angezeigt."
, "Hier kannst du das Aussehen deines sBinders anpassen. Das betrifft nur das Hauptfenster des sBinders, alle anderen Fenster (z.B. Eigene Binds, Einstellungen) erscheinen im gewohnten Anblick.`n`nDu kannst aus einigen vorgefertigten Designs wählen oder dir sogar ein eigenes erstellen (sofern du HTML kannst). Wähle dazu die entsprechende Option aus, speichere und starte den sBinder neu."
, "Hier kannst du das aktuell genutzte Design aktualisieren, falls es irgendwelche kleineren Änderungen gab. Normalerweise musst du diese Funktion nicht nutzen, sofern du nicht darauf hingewiesen wurdest."]
helptitles := ["Connect-Funktionen", "Eigene Binds", "Wichtige Binds", "Fraktionsbinds", "Notizen", "Fahrzeugrechner", "Nickname", "Mit Adminrechten starten", "Trucking", "Ins Tray minimieren + Effekt beim Schließen", "Bilder der Trucking-Orte + Box anzeigen", "Doppelhupe + /me-Texte", "", "/trucking", "Chatlog-Pfad + SAMP-Pfad", "Chatlog-Wartezeit", "Löschen der Daten und Dateien", "API nutzen + Overlay-Einstellungen", "Telefontexte", "", "Beim Login automatisch eingeben", "INI-Datei öffnen + sBinder-Ordner öffnen", "Programm mitstarten: SAMP", "Programm mitstarten: TS³", "Programm mitstarten: Fraps", "Programm mitstarten: Anderes Programm" , "Overlays", "/trucking: Sortierung der Aufträge", "Designs", "Design manuell aktualisieren"] ;30
help := helptexts[SubStr(A_ThisLabel, 5)]
MsgBox, 64, % "sBinder-Hilfe: " helptitles[SubStr(A_ThisLabel, 5)], %help%
helptexts := helptitles := help := error := ""
return
SelectSAMP:
Thread, NoTimers
FileSelectFile, temp, 1, % (FileExist(samppath) ? samppath : A_Desktop), Wähle die samp.exe aus, *.exe
if(!ErrorLevel){
	samppath := temp
	IniWrite, %samppath%, %INIFile%, Settings, SAMPPath
	ToolTip("Der SAMP-Pfad wurde erfolgreich geändert.`nAusgewählte Datei: " samppath, 5000)
}
Thread, NoTimers, false
return
SelectCL:
Thread, NoTimers
FileSelectFile, temp, 1, % (FileExist(chatlogpath) ? chatlogpath : A_MyDocuments), Wähle den Pfad des Chatlogs, *.txt
if(!ErrorLevel){
	chatlogpath := temp
	IniWrite, %chatlogpath%, %INIFile%, Settings, ChatlogPath
	ToolTip("Der Chatlog-Pfad wurde erfolgreich geändert.`nAusgewählte Datei: " chatlogpath, 5000)
}
Thread, NoTimers, false
return
SelectINI:
Thread, NoTimers
FileSelectFile, temp, 8, %A_ScriptDir%\keybinder.ini, Wähle die neue ini-Datei aus, *.ini
if(INIFile = temp)
	ToolTip("Du nutzt diese ini-Datei bereits!", 4000)
else if(!ErrorLevel){
	SplitPath, temp,,, ext
	if(ext = "ini"){
		OldIni := INIFile
		INIFile := temp
		IniWrite, %INIFile%, %A_AppData%\sBinder\global.ini, Path, %A_ScriptFullPath%
		FileGetSize, temp, %INIFile%
		if(!temp){
			Gui, TempGUI2:Destroy
			Gui, TempGUI2:Add, Text, w200, Willst du die aktuellen Einstellungen (Einstellungen, Hotkeys, ...) in die neue ini übernehmen oder die Standardeinstellungen nutzen?
			Gui, TempGUI2:Add, Button, gCopyIni, Einstellungen übernehmen
			Gui, TempGUI2:Add, Button, gNewIni, Standardeinstellungen nutzen
			Gui, TempGUI2:Show,, sBinder: Neue ini
		}
		else
			Reload
	}
	else
		ToolTip("Die ausgewählte Datei ist keine ini-Datei!", 5000)
}
Thread, NoTimers, false
return
Startup_Select_Fraps:
Thread, NoTimers
FileSelectFile, temp, 1, % (FileExist(Startup_Fraps_Path) ? Startup_Fraps_Path : A_ProgramFiles), Wähle den Pfad von Fraps aus, *.exe
if(!ErrorLevel){
	Startup_Fraps_Path := temp
	IniWrite, %Startup_Fraps_Path%, %INIFile%, Startup, Fraps_Path
	ToolTip("Der Fraps-Pfad wurde erfolgreich geändert.`nAusgewählte Datei: " Startup_Fraps_Path, 5000)
}
Thread, NoTimers, false
return
Startup_Select_Other:
Thread, NoTimers
FileSelectFile, temp, 1, % (FileExist(Startup_Other_Path) ? Startup_Other_Path : A_ProgramFiles), Wähle den Pfad des anderen Programmes aus`, das du mitstarten willst
if(!ErrorLevel){
	Startup_Other_Path := temp
	GuiControl, SettingsGUI:, Startup_Other_Path, %Startup_Other_Path%
	IniWrite, %Startup_Other_Path%, %INIFile%, Startup, Other_Path
	ToolTip("Der Pfad wurde erfolgreich geändert.`nAusgewählte Datei: " Startup_Other_Path, 5000)
}
Thread, NoTimers, false
return
SaveAs:
Thread, NoTimers
FileSelectFile, temp, 8, %A_ScriptDir%\keybinder.ini, Wähle die neue ini-Datei aus, *.ini
if(!ErrorLevel){
	SplitPath, temp,,, ext
	if(ext = "ini"){
		OldIni := INIFile
		INIFile := temp
		savemsg := 0
		gosub Save
		IniWrite, %Frak%, %INIFile%, Settings, Fraktion
		IniWrite, %chatlogpath%, %INIFile%, Settings, ChatlogPath
		IniWrite, %Job%, %INIFile%, Settings, Job
		IniWrite, %samppath%, %INIFile%, Settings, SAMPPath
		savemsg := 1
		ToolTip("Deine Daten wurden gespeichert.`nSpeicherort: " INIFile "`n`nHINWEIS:`nBeim nächsten Start wird wieder folgende ini-Datei verwendet:`n" OldIni "`nDu kannst die andere ini-Datei aber per Datei->Öffnen auswählen.", 12000)
		INIFile := OldIni
	}
	else
		ToolTip("Die ausgewählte Datei ist keine ini-Datei!", 5000)
}
Thread, NoTimers, false
return
NewIni:
FileAppend,, %INIFile%
gosub Open
Gui, TempGUI2:Destroy
savemsg := 0
savewithoutsubmit := 1
gosub Save
Reload
return
CopyIni:
Gui, TempGUI2:Destroy
if(temp := FileExist(OldIni))
	FileCopy, %OldIni%, %IniFile%, 1
if(!temp OR ErrorLevel)
	MsgBox, 16, Fehler!, Ein Fehler beim Kopieren ist aufgetreten!
Reload
return
OpenINI:
Run, %INIFile%
return
OpenDir:
Run, %A_ScriptDir%\
return
DeleteData:
loop, 9
	GuiControl, DeleteGUI:, Del%A_Index%, 0
GuiControl, % "DeleteGUI:" (FileExist(A_Temp "\sBinder") ? "Enable" : "Disable"), Del1
ErrorLevel := 1
loop, HKCU, Software, 2
{
	if(A_LoopRegName = "sBinder"){
		ErrorLevel := 0
		break
	}
}
GuiControl, % "DeleteGUI:" (ErrorLevel ? "Disable" : "Enable"), Del2
GuiControl, % "DeleteGUI:" (FileExist("ChatlogBackups") ? "Enable" : "Disable"), Del3
GuiControl, % "DeleteGUI:" (FileExist(INIFile) ? "Enable" : "Disable"), Del4
GuiControl, % "DeleteGUI:" (FileExist(A_AppData "\sBinder\Open-SAMP-API.dll") ? "Enable" : "Disable"), Del7
GuiControl, % "DeleteGUI:" (FileExist(A_AppData "\sBinder") ? "Enable" : "Disable"), Del8
GuiControl, % "DeleteGUI:" (FileExist(A_AppData "\sBinder\Design") ? "Enable" : "Disable"), Del9
Gui, DeleteGui:Show,, sBinder-Daten und -Dateien löschen
return
Delete:
Gui, DeleteGui:Submit
if(Del1){
	MsgBox, 35, Temporäre Dateien wirklich löschen?, Willst du die temporären Dateien wirklich löschen?`n`nDabei wird der Ordner %A_Temp%\sBinder gelöscht.`nIn dem Ordner werden kurzzeitig benötigte Dateien wie Truckingbilder gespeichert.
	IfMsgBox, Yes
		FileRemoveDir, %A_Temp%\sBinder, 1
	IfMsgBox, No
		Del1 := 0
	IfMsgBox, Cancel
		return
}
if(Del2){
	MsgBox, 35, Registry-Daten wirklich löschen?, Willst du die Registry-Daten wirklich löschen?`n`nDabei wird der Registry-Schlüssel HKEY_CURRENT_USER\Software\sBinder gelöscht.
	IfMsgBox, Yes
		RegDelete, HKCU, Software\sBinder
	IfMsgBox, No
		Del2 := 0
	IfMsgBox, Cancel
		return
}
if(Del3){
	MsgBox, 35, Chatlog-Backups wirklich löschen?, Willst du den Ordner für die Chatlog-Backups wirklich löschen?`n`nIn ihm werden die vom Textbind "/chatlogbackup" kopierten Chatlogs gespeichert.
	IfMsgBox, Yes
		FileRemoveDir, ChatlogBackups, 1
	IfMsgBox, No
		Del3 := 0
	IfMsgBox, Cancel
		return
}
if(Del4){
	MsgBox, 35, Einstellungsdatei wirklich löschen?, Willst du die Einstellungsdatei (ini-Datei) wirklich löschen? Dabei wird die Datei %INIFile% gelöscht, in ihr werden ALLE deine Einstellungen, z.B. alle eigenen Binds und alle Notizen usw. gespeichert.`nSie kann nicht wiederhergestellt werden!
	IfMsgBox, Yes
		FileDelete, %INIFile%
	IfMsgBox, No
		Del4 := 0
	IfMsgBox, Cancel
		return
}
if(Del6){
	MsgBox, 35, sBinder.exe wirklich löschen?, Willst du den sBinder (sBinder.exe) wirklich löschen?`n`nDu kannst ihn jederzeit wieder aus dem Internet herunterladen.
	IfMsgBox, Yes
	{
		FileDelete, delete.bat
		FileAppend, @echo off`nping 1.1.1.1 -n 1 -w 800`ndel "%A_ScriptDir%\sBinder.exe"`ndel "%A_ScriptDir%\delete.bat", delete.bat
		Run, %RunPrivileges%delete.bat
		ExitApp
	}
	IfMsgBox, No
		Del6 := 0
	IfMsgBox, Cancel
		return
}
if(Del7){
	MsgBox, 35, Open-SAMP-API.dll wirklich löschen?, Willst du die Open-SAMP-API.dll wirklich löschen?`n`nDu kannst sie jederzeit wieder nutzen lassen, indem du die Option "API nutzen" in den Einstellungen wieder aktivierst.
	IfMsgBox, Yes
	{
		if hModule not between 1 and 0
			DllCall("FreeLibrary", "Ptr", hModule)
		FileDelete, %A_AppData%\sBinder\Open-SAMP-API.dll
		UseAPI := 0
		IniWrite, 0, %INIFile%, Settings, UseAPI
		GuiControl, SettingsGUI:, UseAPI, %UseAPI%
	}
	IfMsgBox, No
		Del7 := 0
	IfMsgBox, Cancel
		return
}
if(Del8){
	MsgBox, 35, AppData-Ordner wirklich löschen?, Willst du den AppData-Ordner wirklich löschen?`n`nDabei wird der Ordner %A_AppData%\sBinder gelöscht.`nIn ihm werden z.B. die Open-SAMP-API.dll und der Schriftzug sowie die Designs (inklusive dem Custom-Design) gespeichert.
	IfMsgBox, Yes
	{
		if(FileExist(A_AppData "\sBinder\Design\custom.html")){
			MsgBox, 51, ACHTUNG! Custom-Design wird gelöscht!, Im AppData-Ordner befindet sich ein Custom-Design! Soll der Ordner wirklich gelöscht werden?
			IfMsgBox, No
				Del8 := 0
			IfMsgBox, Cancel
				return
		}
		if(Del8){
			if hModule not between 1 and 0
				DllCall("FreeLibrary", "Ptr", hModule)
			FileRemoveDir, %A_AppData%\sBinder, 1
			UseAPI := 0
			IniWrite, 0, %INIFile%, Settings, UseAPI
			GuiControl, SettingsGUI:, UseAPI, %UseAPI%
		}
	}
	IfMsgBox, No
		Del8 := 0
	IfMsgBox, Cancel
		return
}
if(Del9){
	MsgBox, 35, Designs wirklich löschen?, Willst du den Ordner mit den Designs wirklich löschen?`n`nDabei wird der Ordner %A_AppData%\sBinder\Design gelöscht.`nIn ihm werden alle heruntergeladenen Designs gespeichert. Falls du dir ein Custom-Design erstellt hast, wird das auch gelöscht!
	IfMsgBox, Yes
	{
		if(FileExist(A_AppData "\sBinder\Design\custom.html")){
			MsgBox, 51, ACHTUNG! Custom-Design wird gelöscht!, Im Design-Ordner befindet sich ein Custom-Design! Soll der Ordner wirklich gelöscht werden?
			IfMsgBox, No
				Del9 := 0
			IfMsgBox, Cancel
				return
		}
		if(Del9)
			FileRemoveDir, %A_AppData%\sBinder\Design, 1
	}
	IfMsgBox, No
		Del8 := 0
	IfMsgBox, Cancel
		return
}
if(Del1 OR Del2 OR Del3 OR Del4 OR Del5 OR Del6 OR Del7 OR Del8 OR Del9)
	MsgBox, 64, Gelöscht, Die gewünschten Daten wurden erfolgreich gelöscht.
gosub DeleteData
return
HideToolTip:
SetTimer, HideToolTip, Off
ToolTip
return
ReloadDebugGUI:
hotstringscount := 0
for i in hotstringsactive
	hotstringscount ++
GuiControl, DebugGUI:, Debug, % "[sBinder Debug-Informationen]`n`nNutzer: " Nickname " -- " Fraknames[Frak] " (" Frak ") <- " (IsFrak(Frak) ? "Bestätigt" : "Nicht bestätigt") "`nOS: " A_OSVersion " " (A_Is64BitOS ? "64bit" : "32bit") "`nAHK: " A_AhkVersion " " (A_IsUnicode ? "Unicode" : "ANSI") " " (A_PtrSize = 4 ? "32bit" : "64bit") ", "  (A_IsAdmin ? "A" : "Nicht a") "ls Administrator gestartet`nsBinder: Version " Version "-" Build " | Neueste gefundene Version: " vVersion "-" vBuild "`nDatum: " A_DD "." A_MM "." A_YYYY " " A_Hour ":" A_Min ":" A_Sec "`n" (A_IsCompiled ? "Kompiliert" : "Nicht kompiliert") "; " (A_IsPaused ? "Pausiert" : "Nicht pausiert") "; " (A_IsSuspended ? "Deaktiviert" : "Aktiviert") "; WaitFor: " WaitFor "ms; API " (UseAPI ? "wird genutzt" : "wird nicht genutzt") "; " (hotstringscount ? hotstringscount : 0) " Textbind" (hotstringscount = 1 ? "" : "s") " aktiviert`nAFK-Box " (AFKBox ? "" : "de") "aktiviert, DownloadMode: " DownloadMode (OverlayActive ? ", Overlay " (OvText1 OR OvText2 OR OvText3 ? "wird genutzt" : "wird nicht genutzt") : "") "`nDesign: " Designs[UseDesign, "name"] (MainGuiVersion ? " Version " MainGuiVersion : "") (UseHTMLGUI ? " im IE " Round(_mainGUI.document.DocumentMode, 1) : "") "`nStartparameter: " FullArgs
return
ChatlogSearch:
SplitPath, A_MyDocuments,,,,, clDrive
clTime1 := 20000101
if(FileExist(chatlogpath))
	FileGetTime, clTime1, %chatlogpath%
temp := A_Now
temp -= clTime1, days
if(temp >= 7){
	clPath2 := clDrive "\Users\Public\Documents\GTA San Andreas User Files\SAMP\chatlog.txt"
	if(FileExist(clPath2))
		FileGetTime, clTime2, %clPath2%
	clPath3 := UserProfile "\Documents\GTA San Andreas User Files\SAMP\chatlog.txt"
	if(FileExist(clPath3))
		FileGetTime, clTime3, %clPath3%
	
	temparr := Object()
	temparr[clTime1] := chatlogPath
	temparr[clTime2] := clPath2
	temparr[clTime3] := clPath3
	
	temp := clTime1 "," clTime2 "," clTime3
	Sort, temp, R D,
	RegExMatch(temp, "U)^(\d+),", data)
	if(temparr[data1] != chatlogpath && FileExist(temparr[data1])){
		chatlogpath := temparr[data1]
		IniWrite, %chatlogpath%, %INIFile%, Settings, ChatlogPath
	}
}
return
CopyDebug:
GuiControlGet, Debug, DebugGUI:
Clipboard := Debug
ToolTip("Die Debug-Informationen wurden in die Zwischenablage kopiert.`nDu kannst sie mit Strg+V einfügen.", 5000)
return
DisableAFKBox:
AFKBox := 0
GuiControl, SettingsGUI:, AFKBox, %AFKBox%
IniWrite, %AFKBox%, %INIFile%, Settings, AFKBox
gosub AFKBox_CheckDesk
ToolTip("Die Box wurde deaktiviert. Du kannst sie in den Einstellungen jederzeit wieder aktivieren.", 5000)
return
DisableAFKBoxTemp:
Gui, AFKBox:Hide
return
AFKBox_CheckDesk:
if(!AFKBox OR !WinExist("ahk_group GTASA") OR WinActive("ahk_group GTASA")){
	if(AFKBox_shown){
		Gui, AFKBox:Hide
		AFKBox_shown := 0
		AFKBox_desksince := 0
	}
	if(!AFKBox)
		SetTimer, AFKBox_CheckDesk, Off
	return
}
if(!AFKBox_desksince)
	AFKBox_desksince := A_TickCount
if(!AFKBox_shown){
	OnMessage(0x216, "WM_HANDLER") ;WM_MOVING
	Gui, AFKBox:Show, x%AFKBoxX% y%AFKBoxY%, sBinder: Desktop
	AFKBox_shown := 1
}
GuiControl, AFKBox:, AFKBox_Button, % "Du bist seit " date(Round((A_TickCount - AFKBox_desksince) / 1000), 2) " auf dem Desktop"
return
SaveAFKBoxPos:
WinGetPos, AFKBoxX, AFKBoxY,,, % "ahk_id " GUIs["AFKBox"]
IniWrite, %AFKBoxX%, %INIFile%, WindowPos, AFKBox_X
IniWrite, %AFKBoxY%, %INIFile%, WindowPos, AFKBox_Y
return
AutoHitsound:
WinWaitClose, ahk_group GTASA
WinWaitActive, ahk_group GTASA
; Wait for game window to be renamed: GTA: San Andreas -> GTA:SA:MP or random name (SAMPCAC)
while(WinActive("GTA: San Andreas"))
	Sleep, 100
if(!AutoHitsound)
	return
Loop, 50
{
	FileRead, chat_hitsound, %chatlogpath%
	if(InStr(chat_hitsound, "] {CC210A}SERVER:{FFFFFF} Willkommen ") AND WinActive("ahk_group GTASA")){
		chat_hitsound := ""
		Sleep, 1000
		if(!WinActive("ahk_class AutoHotkeyGUI")){
			SendInput, {enter}
			if(!GetKeyState("w", "P"))
				SendInput, w
		}
		BindReplace(HitsoundText)
		break
	}
	chat_hitsound := ""
	Sleep, 2000
}
return
Overlay:
if(!UseAPI){
	SetTimer, Overlay, Off
	return
}
if(!WinActive("ahk_group GTASA") OR WinActive("ahk_class AutoHotkeyGUI")){
	if(!WinExist("ahk_group GTASA"))
		Ov := [-1, -1, -1]
	return
}
InVehicle := IsPlayerInAnyVehicle()
OverlayShown := !(IsMenuOpen() OR IsDialogOpen()) AND active
loop, %MaxOverlays%
{
	if(OvText%A_Index% = ""){
		if(Ov[A_Index] > -1){
			TextDestroy(Ov[A_Index])
			Ov[A_Index] := -1
		}
		continue
	}
	if(Ov[A_Index] < 0){
		if(!OvOnlyInVeh%A_Index% OR InVehicle){
			RegExMatch(OvFontStyle%A_Index%, "O)s(\d+)\b", OvRegEx)
			Ov[A_Index] := TextCreate(OvFont%A_Index%, (OvRegEx.Value(1) ? OvRegEx.Value(1) : 11), !!InStr(OvFontStyle%A_Index%, "bold"), !!InStr(OvFontStyle%A_Index%, "italic"), OvPosX%A_Index%, OvPosY%A_Index%, OvColor%A_Index% + 0xFF000000, "", OvShadow%A_Index%, 1)
			if(!A_IsCompiled AND Ov[A_Index] != "")
				AddChatMessage("Overlay " A_Index " wurde geladen. (" Ov[A_Index] ")")
		}
	}
	else if(OvOnlyInVeh%A_Index% AND !InVehicle){
		TextDestroy(Ov[A_Index])
		Ov[A_Index] := -1
	}
	if(Ov[A_Index] != "" AND Ov[A_Index] > -1){
		TextSetString(Ov[A_Index], OverlayReplace(OvText%A_Index%, InVehicle))
		TextSetShown(Ov[A_Index], OverlayShown)
		
		if(OvNeedsUpdate%A_Index%){
			OvNeedsUpdate%A_Index% := 0
			TextSetPos(Ov[A_Index], OvPosX%A_Index%, OvPosY%A_Index%)
			TextSetColor(Ov[A_Index], OvColor%A_Index% + 0xFF000000)
			TextSetShadow(Ov[A_Index], OvShadow%A_Index%)
			RegExMatch(OvFontStyle%A_Index%, "O)s(\d+)\b", OvRegEx)
			TextUpdate(Ov[A_Index], OvFont%A_Index%, (OvRegEx.Value(1) ? OvRegEx.Value(1) : 11), !!InStr(OvFontStyle%A_Index%, "bold"), !!InStr(OvFontStyle%A_Index%, "italic"))
		}
	}
}
return

::/kstop::
Del::
Suspend
if(UseAPI)
	AddChatMessage("Der sBinder wurde " (A_IsSuspended ? "{FF1100}de" : "{00AA00}") "aktiviert{FFFFFF}.")
active := !A_IsSuspended
loop, % (A_IsSuspended ? 2 : 1)
{
	SoundPlay, *-1, 1
	Sleep, 200
}
return

~Escape::
Suspend Off
Hotkey, ~NumpadEnter, Off
Hotkey, ~Enter, Off
Hotkey, ~Escape, Off
return
~t::
~+t::
Suspend On
Hotkey, ~NumpadEnter, On
Hotkey, ~Enter, On
Hotkey, ~Escape, On
return
~NumpadEnter::
~Enter::
Suspend Off
Hotkey, ~NumpadEnter, Off
Hotkey, ~Enter, Off
Hotkey, ~Escape, Off
return
#If hmv && WinActive("ahk_group GTASA")
~h::
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen())
	return
KeyWait, h
KeyWait, h, D T0.2
if(!ErrorLevel){
	BindReplace("/mv~/oldmv")
	if(IsFrak(2))
		SendChat("/towopen")
}
return
#IfWinActive ahk_group GTASA

NotesGUIGuiClose:
Gui, NotesGUI:Submit
Gui, NotesGUI:Destroy
return
SettingsGUIGuiClose:
Gui, SettingsGUI:Hide
gosub SettingsChangeTab
return
OverlayPosGuiClose:
GuiControlGet, OvPosX%OvPosNum%, OverlayPos:, OvX
GuiControlGet, OvPosY%OvPosNum%, OverlayPos:, OvY
Gui, OverlayPos:Hide
gosub OvSave
ToolTip("Die neue Position des " OvPosNum ". Overlays wurde gespeichert.", 4000)
return
OverlayPosGuiCancel:
Gui, OverlayPos:Hide
return
FrakChangeGUISave:
Gui, FrakChangeGUI:Submit, Nohide
Frak := NewFrak
MsgBox, 64, Fraktion geändert, Die Fraktion wurde erfolgreich geändert, 1
IniWrite, %Frak%, %INIFile%, Settings, Fraktion
Gui, FrakChangeGUI:Destroy
Gui, FrakGUI:Destroy
gosub FrakGUIBuild
gosub FrakChangeGuiBuild
gosub FrakGUI
gosub HotkeysDefine
return
BeforeExit:
if(OverlayActive){
	SetTimer, Overlay, Off
	Sleep, 50
	if(UseAPI AND WinExist("ahk_group GTASA"))
		DllCall(DestroyAllVisual_func)
}
ExitApp
return
GuiClose:
1GuiClose:
savemsg := 0
if(FileExist(INIFile))
	gosub SaveExit
ExitApp
return
GuiShow:
Gui, 1:Show,, sBinder %Version%-%Build% by IcedWave
return

::/reconnect::
Suspend Permit
Critical
reconnected := 1
WinClose, ahk_group GTASA,, 3
gosub Connect
return

Connect:
SetTimer, %A_ThisLabel%, Off
if(WinExist("ahk_group GTASA"))
	WinActivate, ahk_group GTASA
else{
	if(!samppath){
		RegRead, samppath, HKLM, SOFTWARE\Classes\samp\shell\open\command
		RegExMatch(samppath, "UO)^""(.+)""", samppath)
		samppath := samppath.Value(1)
		IniWrite, %samppath%, %INIFile%, Settings, SAMPPath
	}
	Run, %RunPrivileges%"%samppath%" "%ServerIP%",, UseErrorLevel
	if(ErrorLevel){
		gosub SelectSAMP
		if (!ErrorLevel)
			goto %A_ThisLabel%
	}
}
return
::/krestart::
Suspend Permit
Sleep, 100
AddChatMessage("Willst du den sBinder jetzt wirklich neu starten?")
AddChatMessage("Dabei werden alle ungespeicherten Daten und alle Variablen gelöscht!")
AddChatMessage("Wenn du den sBinder neu starten willst, drücke innerhalb der nächsten 5 Sekunden {88AA62}R{FFFFFF}.")
s := A_IsSuspended
Suspend On
KeyWait, R, T5 D
if(!s)
	Suspend Off
if(!ErrorLevel){
	IniWrite, 1, %INIFile%, Settings, Reload
	Reload
}
else
	AddChatMessage("Der sBinder wurde nicht neu gestartet, da du nicht innerhalb von 5 Sekunden {88AA62}R{FFFFFF} gedrückt hast.")
return
::/kpd::
::/kpayday::
Suspend Permit
SendChat("/payday " PlayerInput("Erste Zahl: ") + PlayerInput("Zweite Zahl: "))
return
::/znotiz::
::/zeige notiz::
Suspend Permit
Gui, NotesGUI:Submit, Nohide
notenum := Trim(PlayerInput("Gib die Nummer der gewünschten Notiz ein: "))
if((notenum < 1 OR notenum > 8) AND notenum != "all")
	AddChatMessage("Es sind nur Zahlen zwischen {88AA62}1 und 8{FFFFFF} oder {88AA62}all{FFFFFF} möglich.")
else if(InStr(notenum, "all")){
	notenum := ""
	loop, %Notes%
	{
		if(!UseAPI OR !ShowDialogWorking){
			notenum := "Notiz " A_Index ": "
			if(Note%A_Index%)
				notenum .= SubStr(Note%A_Index%, 1, 90) (StrLen(Note%A_Index%) > 90 ? " ..." : "")
			else
				notenum .= "Leer"
			AddChatMessage(notenum)
		}
		else{
			notenum .= "`n{00AA00}Notiz " A_Index ": "
			if(Note%A_Index%)
				notenum .= "{FFFFFF}" SubStr(Note%A_Index%, 1, 90) (StrLen(Note%A_Index%) > 90 ? " ..." : "")
			else
				notenum .= "{AA0000}Leer"
		}
	}
	if(UseAPI AND ShowDialogWorking)
		ShowDialog(0, "sBinder: {00AA00}Notizen", SubStr(notenum, 2))
	notenum := ""
}
else{
	if(Note%notenum% = "")
		AddChatMessage("Notiz " notenum " ist leer. Du kannst Sie mit {88AA62}/bearbeite notiz " notenum "{FFFFFF} füllen.")
	else
		AddChatMessage("Notiz " notenum ":{FFFFFF} " Note%notenum%)
}
return
::/bnotiz::
::/bearbeite notiz::
Suspend Permit
Gui, NotesGUI:Submit, Nohide
ClipboardBackup := ClipboardAll
notenum := PlayerInput("Gib die Nummer der gewünschten Notiz ein: ")
if(notenum < 1 OR notenum > 8){
	AddChatMessage("Es sind nur Zahlen zwischen {88AA62}1 und 8{FFFFFF} möglich.")
	return
}
KeyWait, Enter
SendInput, t{backspace 100}
SendInput, % "{Raw}" Note%notenum%
Clipboard := ""
KeyWait, Enter, D
SendInput ^a^x
ClipWait, 1
Note%notenum% := Clipboard
IniWrite,% Note%notenum%, %INIFile%, Notes, Note%notenum%
SendInput ^a{backspace}{enter}
Clipboard := ClipboardBackup
AddChatMessage("Notiz " notenum " wurde {88AA62}erfolgreich gespeichert{FFFFFF}.")
ClipboardBackup := ""
return
::/lnotiz::
::/lösche notiz::
Suspend Permit
notenum := PlayerInput("Gib die Nummer der zu löschenden Notiz ein: ")
if((notenum < 1 OR notenum > 8) AND notenum != "all")
	AddChatMessage("Es sind nur Zahlen zwischen {88AA62}1 und 8{FFFFFF} oder {88AA62}all{FFFFFF} möglich.")
else if(notenum = "all"){
	loop, %Notes%
	{
		Note%A_Index% := ""
		IniWrite, % "", %INIFile%, Notes, Note%A_Index%
	}
	AddChatMessage("Alle Notizen wurden {88AA62}erfolgreich gelöscht{FFFFFF}!")
}
else{
	if(!Note%notenum%)
		AddChatMessage("Notiz " notenum " ist bereits leer!")
	else{
		Note%notenum% := ""
		IniWrite, % "", %INIFile%, Notes, Note%notenum%
		AddChatMessage("Notiz " notenum " wurde {88AA62}erfolgreich gelöscht{FFFFFF}!")
	}
}
return
::/inettest::
Suspend Permit
AddChatMessage("Ein Test der Internetverbindung wird durchgeführt...")
AddChatMessage("Ping nes-newlife Gameserver: {88AA62}" clearping("server.nes-newlife.de", 400))
AddChatMessage("Ping nes-newlife Homepage: {88AA62}" clearping("nes-newlife.de", 400))
AddChatMessage("Ping nes-newlife Forum: {88AA62}" clearping("forum.nes-newlife.de", 400))
AddChatMessage("Ping google.com (Referenz): {88AA62}" clearping("google.com", 400))
return
::/kdonut::
Suspend Permit
SendChat("/oldstats")
chat := WaitForChatLine(3, "Donuts: [")
RegExMatch(chat, "Donuts: \[(.*)\]", chat)
if(chat1 < 20)
	SendChat("/get donut " 20 - chat1)
else if(chat1 = 20)
	AddChatMessage("Du hast bereits 20 Donuts!")
return
::/kame::
Suspend Permit
if(ame := PlayerInput("Gib den /ame-Text ein: ")){
	SetTimer, ame, 15000
	AddChatMessage("Der Text {88AA62}" ame "{FFFFFF} wird jetzt über dir angezeigt.")
	AddChatMessage("Du kannst diese Funktion mit {88AA62}/kcancel{FFFFFF} stoppen.")
	gosub ame
}
else
	SetTimer, ame, Off
multiame_current := ""
return
::/kame multi::
Suspend Permit
ame := Object()
while(ame[A_Index] := PlayerInput("Gib den " A_Index ". /ame-Text ein (gib nichts ein, um fertigzustellen): "))
	Sleep, 1
ame.Remove()
if(!ame[1])
	SetTimer, ame, Off
else{
	SetTimer, ame, 3000
	AddChatMessage("Es werden nun insgesamt " ame._maxIndex() " Texte über deinem Kopf angezeigt:")
	for i, k in ame
		AddChatMessage("Text " i ": {88AA62}" k)
	AddChatMessage("Sie werden alle 3 Sekunden gewechselt. Du kannst diese Funktion mit {88AA62}/kcancel{FFFFFF} stoppen.")
	multiame_current := 0
	gosub ame
}	
return
ame:
if((!A_IsSuspended OR UseAPI) AND WinActive("ahk_group GTASA")){
	if(IsObject(ame)){
		multiame_current ++
		if(multiame_current > ame._maxIndex())
			multiame_current := 1
		SendChat("/ame " ame[multiame_current])
	}
	else
		SendChat("/ame " ame)
}
return
::/togfrakbinds::
Suspend Permit
frakbinds := !frakbinds
AddChatMessage("Die Fraktionsbinds wurden {88AA62}" (frakbinds ? "" : "de") "aktiviert{FFFFFF}.")
return
::/kcancel::
Suspend Permit
ame := ""
SetTimer, ame, Off
AddChatMessage("Alle Funktionen wurden {88AA62}deaktiviert{FFFFFF}.")
return
::/pdt::
::/paydaytime::
Suspend Permit
SendChat("/oldstats")
chat := WaitForChatLine(1, "Spielzeit seit Payday: [")
RegExMatch(chat, "Spielzeit seit Payday: \[(.*) Minuten\]", chat)
chat1 := 60 - chat1
AddChatMessage("Du musst noch {88AA62}" chat1 " Minute" (chat1 = 1 ? "" : "n") "{FFFFFF} bis zum Payday warten.")
return
::/respekt::
Suspend Permit
SendChat("/oldstats")
chat := WaitForChatLine(3, "Respekt:[")
num := ChatLine(6, "Level:[")
stat := ChatLine(5, "Status:[")
RegExMatch(chat, "Respekt:\[(\d+)/(\d+)\]", chat)
RegExMatch(num, "Level:\[(\d+)\] Geschlecht:\[", num)
chat3 := chat2 - chat1
;if(chat1 < chat2)
AddChatMessage("Du benötigst noch {88AA62}" chat3 " Respektpunkt" (chat3 = 1 ? "" : "e") "{FFFFFF}" (InStr(stat, "Status:[Premium") ? " (ca. " (stat := Round(chat3 / 1.2)) " Payday" (stat = 1 ? "" : "s") " mit Premium)" : "") " bis {88AA62}Level " num1 + 1 "{FFFFFF}. {A6A6A6}[" chat1 "/" chat2 "]")
;else
;	AddChatMessage("Du kannst dir {88AA62}Level " num1 + 1 "{FFFFFF} für {88AA62}$" number_format(chat1) "{FFFFFF} kaufen. {A6A6A6}[" chat2 "/" chat3 "]")
return
::/kcall::
Suspend Permit
chat := ""
if(!num1 := PlayerInput("Gib die Nummer, den Namen oder die ID der Person ein: "))
	return
if(!is(num1, "integer") OR (StrLen(num1) < 4 AND is(num1, "integer"))){
	SendChat("/nummer " num1)
	chat := WaitForChatLine(0, ", Ph: ")
}
if(InStr(chat, "Spieler nicht gefunden"))
	return
if(chat)
	RegExMatch(chat, "Ph: (\d+),?", num)
if(is(num1, "integer") AND StrLen(num1) >= 5)
	SendChat("/call " num1)
return
::/ksms::
::/ktzelle::
Suspend Permit
thishkey := A_ThisLabel
chat := ""
if(!num1 := PlayerInput("Gib die Nummer, den Namen oder die ID der Person ein: "))
	return
if(!is(num1, "integer") OR (StrLen(num1) < 4 AND is(num1, "integer"))){
	SendChat("/nummer " num1)
	chat := WaitForChatLine(0, ", Ph: ")
}
if(InStr(chat, "Spieler nicht gefunden"))
	return
if(chat)
	RegExMatch(chat, "Ph: (\d+),?", num)
if(is(num1, "integer") AND StrLen(num1) >= 5){
	if(thishkey = "::/ksms")
		SendChat("/sms")
	else
		SendChat("/tzelle")
	WaitFor()
	SendInput, %num1%
	WaitFor()
	SendInput, {enter}
}
return
::/kgeld::
Suspend Permit
SendChat("/oldstats")
chat := WaitForChatLine(6, "Bank:[$")
StringReplace, chat, chat, .,, All
RegExMatch(chat, "Bargeld:\[\$(.*?)\] Bank:\[\$(.*?)\] Handynummer:", chat)
AddChatMessage("Geldbörse: {88AA62}$" number_format(chat1))
AddChatMessage("Bankguthaben: {88AA62}$" number_format(chat2))
AddChatMessage("Gesamt: {88AA62}$" number_format(chat1 + chat2))
return

#if UseTimerActive AND WinActive("ahk_group GTASA")
:b0:/use lsd::
Suspend Permit
if (!UseTimerActive)
	return
DrugContext := "lsd"
SetTimer, DrugHandlerAsync, -1
return
:b0:/use green::
:b0:/use donut::
:b0:/use gold::
Suspend Permit
if (!UseTimerActive)
	return
if (InStr(A_ThisHotkey, "gold"))
	DrugContext := "gold"
else if (InStr(A_ThisHotkey, "green"))
	DrugContext := "green"
else if (InStr(A_ThisHotkey, "donut"))
	DrugContext := "donut"
SetTimer, DrugHandlerAsync, -1
return
DrugHandlerAsync:
SetTimer, DrugHandlerAsync, Off
waitForText := ""
if (DrugContext == "lsd")
	waitForText := "Du hast LSD Pillen eingenommen"
else if (IDrugContext == "gold")
	waitForText := "Acapulco Gold benutzt!"
else if (DrugContext == "green")
	waitForText := "Hawaiian Green benutzt!"
else if DrugContext == "donut")
	waitForText := "Du hast" ; Don't actually know the text; hope this works?
if (!WaitForChatLine(0, waitForText))
	return
	
if (DrugContext == "lsd") {	
	LastUseLsd := A_TickCount
	SetTimer, LsdEffects, Off
	SetTimer, LsdEffects, -84500
	SetTimer, CanUseLsd, Off
	SetTimer, CanUseLsd, -120500
} else {
	if (DrugContext == "gold"){
		time := 60500
		NextUseGreenDonutGold := A_TickCount + 60000
	}
	else {
		time := 45500
		NextUseGreenDonutGold := A_TickCount + 45000
	}
	SetTimer, CanUseGreenDonutGold, Off
	SetTimer, CanUseGreenDonutGold, % - time
}
return
LsdEffects:
if (WinActive("ahk_group GTASA"))
	AddChatMessage("Achtung! In 5 Sekunden treten die LSD-Nebenwirkungen ein!")
return
CanUseLsd:
if (WinActive("ahk_group GTASA"))
	AddChatMessage("Du kannst jetzt wieder LSD zu dir nehmen.")
return
CanUseGreenDonutGold:
if (WinActive("ahk_group GTASA"))
	AddChatMessage("Du kannst jetzt wieder Green/Gold/Donuts zu dir nehmen.")
return

; Frakbinds
#If IsFrak(5) AND WinActive("ahk_group GTASA")
::/slsd::
Suspend Permit
if((id1 := PlayerInput("Gib den Namen oder die ID des Spielers ein: ")) != ""){
	loop, % (id2 := PlayerInput("Gib die Anzahl der Pizzen ein: ")) ? id2 : 1
		SendChat("/sellpizza speziale " id1)
}
else
	AddChatMessage("Du hast keinen Namen eingegeben")
return
::/slsdme::
Suspend Permit
SendChat("/oldstats")
chat := WaitForChatLine(2, " LSD:[")
RegExMatch(chat, "U)\] LSD:\[(\d+)\] Eisen:", chat)
loop, % 6 - chat1
	SendChat("/sellpizza speziale " Nickname)
return
::/ssp::
Suspend Permit
if((id1 := PlayerInput("Gib den Namen oder die ID des Spielers ein: ")) != ""){
	AddChatMessage("Gib den Anfangsbuchstaben der Pizza ein: {88AA62}C{FFFFFF}alzone, {88AA62}T{FFFFFF}onno, {88AA62}M{FFFFFF}argarita, {88AA62}S{FFFFFF}peziale")
	pizza := Object()
	pizza["beginning"] := A_TickCount
	s := A_IsSuspended
	Suspend On
	while((pizza["beginning"] > A_TickCount - 3000) AND !(pizza["key_c"] := GetKeyState("C", "P")) AND !(pizza["key_t"] := GetKeyState("T", "P")) AND !(pizza["key_m"] := GetKeyState("M", "P")) AND !(pizza["key_s"] := GetKeyState("S", "P")))
		Sleep, 50
	if(!s)
		Suspend Off
	pizza := pizza["key_c"] ? "calzone" : (pizza["key_t"] ? "tonno" : (pizza["key_m"] ? "margarita" : (pizza["key_s"] ? "speziale" : "")))
	if(pizza){
		loop, % (id2 := PlayerInput("Gib die Anzahl der Pizzen ein: ")) ? id2 : 1
			SendChat("/sellpizza " pizza " " id1)
	}
	else
		AddChatMessage("Die Aktion wurde abgebrochen, da du keine Taste gedrückt hast!")
}
else
	AddChatMessage("Du hast keinen Namen eingegeben")
pizza := ""
;BindReplace("/me ______________________________________~/me flüstert zu dir: Pizza Calzone | 25$~/me flüstert zu dir: Pizza Tonno | 29$~/me flüstert zu dir: Pizza Margarita | 21$~/me flüstert zu dir: Speziale Pizza | Zivi --> 750$~/me flüstert zu dir: Speziale Pizza | Fraktion --> 1000$~/me ______________________________________")
return
#if IsFrak(8) AND WinActive("ahk_group GTASA")
::/mixWord::
Suspend Permit
if((word := PlayerInput("Gib ein Wort zum Verdrehen ein: ")) = ""){
	AddChatMessage("Du hast nichts eingegeben!")
	return
}
loop{
	AddChatMessage(word ": {88AA62}" (mixedWord := mixWord(word)))
	AddChatMessage("Drücke innerhalb der nächsten 3 Sekunden {88AA62}C{FFFFFF}, um das Wort zu kopieren, oder {88AA62}R{FFFFFF}, um es neu zu mischen.")
	Input, temp, T3, CR
	if(ErrorLevel = "EndKey:C"){
		Clipboard := mixedWord
		AddChatMessage("Das Wort wurde kopiert. Du kannst es mit {88AA62}Strg+V{FFFFFF} einfügen.")
	}
	if(ErrorLevel != "EndKey:R")
		break
}
return

#if IsFrak(3) AND WinActive("ahk_group GTASA") AND active
:b0:/mpdrop::
Suspend Permit
chat := WaitForChatLine(0, "Du hast das Lager mit")
if(RegExMatch(chat, "Du hast das Lager mit ([0-9.]+) von ([0-9.]+) Medikamenten befüllt\.", regex)){
	regex1 := StrReplace(regex1, ".")
	regex2 := StrReplace(regex2, ".")
	SendChat("/r Das Lager wurde mit " number_format(regex1) "/" number_format(regex2) " Medikamenten befüllt.")
}
return
:b0:/mpdelete::
Suspend Permit
chat := WaitForChatLine(1, "verfallene Medikamente an der Vernichtungsanlage abgeladen")
if(RegExMatch(chat, "Du hast ([0-9.]+) verfallene Medikamente an der Vernichtungsanlage abgeladen\.", regex)){
	regex1 := StrReplace(regex1, ".")
	SendChat("/r Es wurden " number_format(regex1) " Medikamente zur Vernichtungsanlage gebracht.")
}
return
:b0:/drop medikamente::
Suspend Permit
chat := WaitForChatLine(0, "Du hast das Lager erfolgreich")
if(chat)
    SendChat("/r Es wurden 10 Medikamente in den Healpunkt gefüllt.")
return
#if (IsFrak(2) OR IsFrak(3) OR IsFrak(11)) AND WinActive("ahk_group GTASA")
::/vs::
Suspend Permit
if(UseAPI){
	location := NextNovaLocation() ;Name, distance
	AddChatMessage("Automatisch ermittelter Standort: {88AA62}" location["Name"] "{FFFFFF} (Distanz: " Round(location["distance"]) "m)")
	AddChatMessage("Wenn du diesen Vorschlag übernehmen willst, drücke innerhalb der nächsten 3 Sekunden {88AA62}J{FFFFFF}. Nutze {88AA62}N{FFFFFF}, um einen eigenen Ort anzugeben, oder {88AA62}C{FFFFFF}, um abzubrechen.")
	location["beginning"] := A_TickCount
	s := A_IsSuspended
	Suspend On
	while((location["beginning"] > A_TickCount - 3000) AND !(location["key_j"] := GetKeyState("J", "P")) AND !(location["key_n"] := GetKeyState("N", "P")) AND !(location["key_c"] := GetKeyState("C", "P")))
		Sleep, 50
	if(!s)
		Suspend Off
	if(location["key_j"]){
		SendChat("/d VS " location["Name"] " (Distanz: " Round(location["distance"]) "m)")
		return
	}
	else if(location["key_c"]){
		AddChatMessage("Der /vs-Modus wird verlassen, da du {88AA62}C{FFFFFF} gedrückt hast.")
		return
	}
	else if(!location["key_n"]){
		AddChatMessage("Der /vs-Modus wird verlassen, da du nichts gedrückt hast.")
		return
	}
}
else
	AddChatMessage("Da du die API nicht nutzt, funktioniert die automatische Standorterkennung leider nicht.")
if((location := PlayerInput("Gib den Ort ein, an dem du Verstärkung brauchst: ")) != "")
	SendChat("/d Brauche Verstärkung: " location)
else
	AddChatMessage("Der /vs-Modus wird verlassen, da du nichts eingegeben hast.")
return
#if (IsFrak(2) OR IsFrak(11)) AND WinActive("ahk_group GTASA")
::/showstaat::
Suspend Permit
chat1 := GetPlayerId()
BindReplace("/oos /showperso " chat1 "~/oos /showlicenses " chat1 "~/oos /showvisum " chat1)
return
#if (IsFrak(2) OR IsFrak(11)) AND WinActive("ahk_group GTASA")
::/takedrogenall::
Suspend Permit
SendChat("/knastmember")
WaitForChatLine(0, "Ort: ")
chat_Arr := Object()
while(A_Index < 30){
	GetChatLine(A_Index-1, chat)
	if(InStr(chat, " Ort: ") AND RegExMatch(chat, "U)^\s*(.+) Ort: .+ \(Nr\.: \d+\)", chat))
		chat_Arr.Insert(chat1)
	else if(InStr(chat, "Liste der Spieler im Gefängnis:"))
		break
}
for i, k in chat_Arr
{
	SendChat("/take drogen " k)
	Sleep, 5000
}
chat_Arr := ""
return
#IfWinActive, ahk_group GTASA
::/housewithdraw all::
Suspend Permit
SendChat("/housewithdraw")
chat := WaitForChatLine(1, " in deiner Hauskasse.")
StringReplace, chat, chat, .,, All
RegExMatch(chat, "Du hast aktuell \$(\d*) in deiner Hauskasse", chat)
if(chat1)
	SendChat("/housewithdraw " chat1)
return
::/kexit::
Suspend Permit
AddChatMessage("Willst du den sBinder jetzt wirklich beenden?")
AddChatMessage("Dabei werden alle ungespeicherten Daten und alle Variablen gelöscht!")
AddChatMessage("Wenn du den sBinder beenden willst, drücke innerhalb der nächsten 5 Sekunden {88AA62}E{FFFFFF}.")
s := A_IsSuspended
Suspend On
KeyWait, E, T5 D
if(!s)
	Suspend Off
if(!ErrorLevel){
	AddChatMessage("Der sBinder wird nun {88AA62}beendet{FFFFFF}.")
	ExitApp
}
else
	AddChatMessage("Der sBinder wurde nicht beendet, da du nicht innerhalb von 5 Sekunden {88AA62}E{FFFFFF} gedrückt hast.")
return
::/textbinds::
::/textbinds 1::
::/textbinds 2::
::/textbinds 3::
::/textbinds 4::
::/textbinds 5::
Suspend Permit
cmd := ArraySort(["/reconnect", "/kpayday (/kpd)", "/zeige notiz (/znotiz)", "/bearbeite notiz (/bnotiz)", "/lösche notiz (/lnotiz)", "/inettest", "/kdonut", "/kame (multi)", "/togfrakbinds", "/kcancel", "/paydaytime (/pdt)", "/respekt", "/kcall", "/ksms", "/kgeld", "/housewithdraw all", "/kcmd", "/cpu", "/timer", "/timermin", "/countdown", "/stoppuhr", "/uhr", "/clearchat", "/trucking", "/setmoney", "/showpolice", "/wetter", "/kme", "/membersonline (id) (/checkfrak (id))", "/myfrak", "/chatlogbackup", "/leaders (id)", "/playerinfo", "/setjob", "/ktzelle", "/calc", "/kbl", "/frakall", "/membersall", "/carvalue", "/car lock [1-20]"])
if(A_ThisLabel = "::/textbinds"){
	if(UseAPI){
		loop, % Ceil(cmd._maxIndex()/10){
			index := A_Index
			tempvar := Object()
			for i, k in cmd
			{
				if A_Index between % index*10-9 and % index*10
					tempvar.Insert(k)
			}
			AddChatMessage("Seite " A_Index ":{FFFFFF} Hilfe mit {88AA62}/textbinds " A_Index, 0x00FF00)
			List(tempvar)
		}
	}
	else
		List(cmd)
}
if(IsFrak(2))
	FrakCmd := ["/showstaat", "/takedrogenall", "/wpbinds", "/vs"]
else if(IsFrak(3))
	FrakCmd := ["/vs"]
else if(IsFrak(5))
	FrakCmd := ["/slsd", "/slsdme", "/ssp"]
else if(IsFrak(8))
	FrakCmd := ["/mixWord"]
else if(IsFrak(11))
	FrakCmd := ["/showstaat", "/takedrogenall", "/wpbinds", "/vs"]
if(FrakCmd AND A_ThisLabel = "::/textbinds")
	List(FrakCmd, Fraknames[Frak] ": ", 1)
if(A_ThisLabel = "::/textbinds")
	AddChatMessage("Die speziellen Textbinds siehst du mit {88AA62}/kcmd{FFFFFF}!")
else{
	RegExMatch(A_ThisLabel, "::/textbinds (\d)", chat)
	if(UseAPI AND ShowDialogWorking){
		helptexts := ["Zuerst werdet ihr nach der Nummer (1-8) der zu bearbeitenden Notiz gefragt.`nNach der Eingabe dieser wird euch der aktuelle Inhalt der Notiz in der Chatleiste angezeigt, ihr könnt ihn durch ganz normales Schreiben ändern."
	, "Mit diesem Befehl könnt ihr eine einfach Rechnung rechnen lassen. Unterstützt werden die Operatoren {999999}+ - * / ^{FFFFFF}.`nAuch Punkt-vor-Strich und Klammern werden beachtet. Allerdings ist das System noch in der Beta-Phase, es kann also zu Fehlern beim Ergebnis kommen."
	, "Dieser Befehl ermöglicht es dir, dein n-tes Fahrzeug auf- bzw. abzuschließen. So schließt /car lock 2 z.B. das Fahrzeug auf oder ab, das als zweites im /car lock-Dialog aufgeführt wird."
	, "Mit diesem Befehl kannst du prüfen, wie viel dein Fahrzeug wert ist (Neupreis ohne Addons, Neupreis mit Addons, Wert bei /car sell)."
	, "Damit könnt ihr den aktuellen Chatlog (chatlog.txt) in den Ordner ChatlogBackups im Keybinder-Ordner kopieren, er wird mit dem Datum versehen (im Namen)."
	, "Sendet einige leere Zeilen in den Chat, sodass dieser leer erscheint."
	, "Bei der Eingabe dieses Befehls werdet ihr gefragt, in welchen Chat der Countdown gestartet werden soll (z.B. /s, /r, /d, /news, /f, ...).`nDann wird ein Countdown in diesen Chat gestartet. Ihr könnt den Countdown mit Entf abbrechen."
	, "Gibt die ungefähre aktuelle Prozessorauslastung aus. Außerdem wird euch die RAM-Auslastung angezeigt."
	, "Dieser Textbind zeigt dir die Mitgliederzahlen - online und gesamt - aller Fraktionen auf Nova an."
	, "Mit diesem Textbind wird deine gesamte Hauskasse entleert."
	, "Es wird ein Ping-Test durchgeführt, um zu erkennen, ob Internetprobleme serverseitig oder von eurem PC ausgehen."
	, "Nach der Eingabe dieses Befehls werdet ihr nach einem Text gefragt, dieser wird dann als /ame-Text über eurem Kopf angezeigt und`nalle 15 Sekunden aktualisiert. Der Befehl ist mit /kcancel abbrechbar.`nDu kannst auch {999999}/kame multi{FFFFFF} nutzen, um mehrere /ame-Texte als Lauftext (wird alle 3 Sekunden gewechselt) anzuzeigen."
	, "Mit diesem Befehl wird der /id-Befehl für alle BLer (/bl) angezeigt. Somit siehst du, wer von ihnen auf dem Friedhof oder im AFK-Modus ist."
	, "Nach der Eingabe dieses Textbinds wirst du nach der Nummer, dem Namen oder der ID einer Person gefragt.`nDann wird diese Person angerufen (ihr braucht also nicht /nummer einzugeben)."
	, "Mit diesem Textbind werden einige laufende Funktionen (aktuell nur /kame) des sBinders gestoppt."
	, "Gibt alle Textbinds, die den sBinder direkt steuern, sortiert im Chat aus."
	, "Dieser Textbind ermittelt per /oldstats die Anzahl eurer aktuellen Donuts und kauft dann so viele Donuts, wie sie euch bis 20 Donuts fehlen.`nIhr habt also nach der Eingabe dieses Befehls wieder 20 Donuts."
	, "Nach der Eingabe dieses Textbinds wird per /oldstats dein Vermögen ausgelesen und (zusammengerechnet) ausgegeben."
	, "Schaltet die /me-Texte zu den Animationen an bzw. aus."
	, "Nach der Eingabe dieses Textbinds wirst du nach der Nummer, dem Namen oder der ID einer Person gefragt.`nDann wird dieser Person eine SMS geschickt (ihr braucht also nicht /nummer einzugeben)."
	, "Nach der Eingabe dieses Textbinds wirst du nach der Nummer, dem Namen oder der ID einer Person gefragt.`nDann wird diese Person über eine Telefonzelle, also anonym, angerufen (ihr braucht also nicht /nummer einzugeben)."
	, "Dieser Textbind zeigt die Leader der eingegebenen Fraktion (sowohl online als auch offline).`nDer Fraktionsname kann jeder bekannte Name der Fraktion sein (Z.B. SARD: ""SARD"", ""SA:RD"", ""Medics"", ""Ärzte"", ""Krankenhaus"", ""Rettungsdienst"").`nMit {999999}/leaders id{FFFFFF} kannst du außerdem den /id-Befehl für jeden Leader ausgeben lassen,`nso siehst du z.B., wer von ihnen auf dem Friedhof oder im Gefängnis ist."
	, "Nachdem ihr die Nummer (1-8) der Notiz eingegeben habt wird der Inhalt der Notiz zurückgesetzt.`nIhr könnt auch 'all' eingeben, dann werden alle Notizen zurückgesetzt."
	, "Zeigt alle Mitglieder der angegebenen Fraktion an.`nDer Fraktionsname kann jeder bekannte Name der Fraktion sein (Z.B. SARD: ""SARD"", ""SA:RD"", ""Medics"", ""Ärzte"", ""Krankenhaus"", ""Rettungsdienst"")."
	, "Zeigt die Mitglieder der angegebenen Fraktion an, die aktuell online sind.`nDer Fraktionsname kann jeder bekannte Name der Fraktion sein (Z.B. SARD: ""SARD"", ""SA:RD"", ""Medics"", ""Ärzte"", ""Krankenhaus"", ""Rettungsdienst"").`nMit {999999}/membersonline id{FFFFFF} bzw. {999999}/checkfrak id{FFFFFF} kannst du außerdem den /id-Befehl für jedes Fraktionsmitglied ausgeben lassen,`nso siehst du z.B., wer von ihnen auf dem Friedhof oder im Gefängnis ist."
	, "Zeigt alle Mitglieder deiner Fraktion an, die aktuell online sind."
	, "Der Textbind liest die /oldstats aus und rechnet aus diesen aus, wann der nächste Payday ist."
	, "Dieser Textbind ermittelt einige Informationen über einen beliebigen Spieler. Dabei ist es vollkommen egal, ob dieser Spieler Zivilist ist oder einen Platz in einer Fraktion hat.`nAllerdings kann es sein, dass neue Spieler oder Spieler mit einem Namechange noch nicht gefunden werden."
	, "Beendet die Sitzung auf Nova und verbindet neu."
	, "Der Textbind liest die /oldstats aus und rechnet aus diesen aus, wie viele Respektpunkte du noch bis zum nächsten Level benötigst."
	, "Mit diesem Textbind kannst du im Spiel deinen Beruf ändern. Gib auf die Frage nach deinem neuen Beruf einfach den Beruf ein und drücke danach J."
	, "Bei diesem Textbind wirst du nach der Summe gefragt, die du auf der Hand haben willst. Dann wird dein Geld auf diesen Wert gesetzt.`nDu musst dafür an der Bank oder an einem Bankautomaten sein."
	, "Zeigt der Polizei bei einer Kontrolle deinen Personalausweis, den Führerschein und dein Visum. Entspricht ""/showperso [ID 1]~/showlicenses [ID 1]~/showvisum [ID 1]""."
	, "Startet eine Stoppuhr. Diese kann mit /stoppuhr wieder gestoppt werden. Die Zeit wird dann im Format Stunden:Minuten:Sekunden:Millisekunden ausgegeben."
	, "Stellt einen Timer in Sekunden. Nach Ablauf des Timers werdet ihr benachrichtigt."
	, "Stellt einen Timer in Minuten. Nach Ablauf des Timers werdet ihr benachrichtigt."
	, "Mit diesem Textbind werden Fraktionsbinds aktiviert oder deaktiviert."
	, "Gibt euch ingame alle aktuell verfügbaren Truckermissionen bis zu eurem Truckerlevel aus. Dabei werden die Aufträge auch im Trucking-Fenster aktualisiert.`nDie Daten werden direkt von der Homepage heruntergeladen.`nFormat: {999999}Ort (Produkt) | Trucklevel | Erfahrung | Einkaufspreis -> Verkaufspreis (Gewinn) | Gewicht | (Anhänger){FFFFFF}`nEventuell funktioniert dieser Textbind bei Änderungen an der Homepage kurzzeitig nicht."
	, "Zeigt dir die aktuelle Uhrzeit und das Datum."
	, "Zeigt dir das Wetter in LS, SF, LV und der Umgebung."
	, "Nach der Eingabe dieses Textbinds werdet ihr nach der Nummer (1-8) der Notiz gefragt. Nach der Eingabe der Nummer wird die Notiz ausgegeben.`nIhr könnt auch 'all' eingeben, dann werden alle Notizen im Chat ausgegeben."]
		for i, k in cmd
		{
			if A_Index between % chat1*10-9 and % chat1*10
				notenum .= "`n`n{00FF00}" k ":{FFFFFF}`n" helptexts[A_Index]
		}
		ShowDialog(0, "sBinder: {00FF00}Textbind-Hilfe - Seite " chat1, SubStr(notenum, 3))
	}
	else{
		tempvar := Object()
		for i, k in cmd
		{
			if A_Index between % chat1*10-9 and % chat1*10
				tempvar.Insert(k)
		}
		List(tempvar)
	}
}
cmd := FrakCmd := helptexts := tempvar := notenum := ""
return
::/kcmd::
Suspend Permit
List(["/krestart", "/kexit", "/textbinds", "/kstop", "/kautosetup", "/kstate"], "", 1)
AddChatMessage("Die normalen Textbinds siehst du mit {88AA62}/textbinds{FFFFFF}!")
return
::/cpu::
Suspend Permit
GetCPULoad_Short()
Sleep, 200
AddChatMessage("Aktuelle Prozessorauslastung: etwa {88AA62}" Round(GetCPULoad_Short()) "%")
;http://www.autohotkey.com/board/topic/91322-mini-tool-info-zum-arbeitsspeicher-ram/ //jNizM
try{
	if(!(objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")) OR !(colItems := objWMIService.ExecQuery("Select * from Win32_OperatingSystem")._NewEnum))
		throw
	else{
		while(colItems[objItem]){
			TVMemory := % Round((objItem.TotalVisibleMemorySize / 1048576), 1)
			UPMemory := % Round(TVMemory - (objItem.FreePhysicalMemory / 1048576), 1)
		}
		try
			AddChatMessage("Aktuelle RAM-Belegung: etwa " UPMemory "/" TVMemory " GB (" Round((UPMemory/TVMemory)*100) "%)")
	}
}
catch
	AddChatMessage("Fehler beim Auslesen der RAM-Belegung!")
VarSetCapacity(powerStatus, 12)
if(DllCall("GetSystemPowerStatus", "UInt", &powerstatus)){
	Battery := Object()
	if((Battery["Status"] := NumGet(powerstatus, 0, "UChar")) != 255){
		Battery["Status"] := Battery["Status"] ? "Netzbetrieb" : "Akkubetrieb"
		if((Battery["Percent"] := NumGet(powerstatus, 2, "UChar") "%") = "100%" AND Battery["Status"] = "Netzbetrieb")
			Battery["Percent"] := "voll geladen"
		if((Battery["left"] := NumGet(powerstatus, 4, "UInt")) != 0xFFFFFFFF)
			Battery["left"] := date(Battery["left"],, 0)
		else
			Battery["left"] := 0
		AddChatMessage("Akku: {88AA62}" Battery["Status"] "{FFFFFF} (" Battery["Percent"] ")" (Battery["left"] ? " (" Battery["left"] " verbleiben)" : ""))
	}
	Battery := ""
}
return
::/timer::
Suspend Permit
if(timer_s := PlayerInput("Gib die Zeit in Sekunden ein: ")){
	SetTimer, Timer, % timer_s * 1000
	AddChatMessage("Du hast den Timer auf {88AA62}" RoundEx(timer_s) " Sekunde" (Round(timer_s) = 1 ? "" : "n") "{FFFFFF} gestellt.")
	timer_time := A_Now
	timer_time += timer_s, Seconds
	AddChatMessage("Er wird um " FormatTime(timer_time, "HH:mm:ss") " ablaufen.")
}
return
::/timermin::
Suspend Permit
if(timer_s := PlayerInput("Gib die Zeit in Minuten ein: ") * 60){
	SetTimer, Timer, % timer_s * 1000
	AddChatMessage("Du hast den Timer auf {88AA62}" RoundEx(timer_s/60, 2) " Minuten{FFFFFF} gestellt.")
	timer_time := A_Now
	timer_time += timer_s, Seconds
	AddChatMessage("Er wird um " FormatTime(timer_time, "HH:mm:ss") " ablaufen.")
}
return
Timer:
SetTimer, Timer, Off
SetTimer, TimerTone, -1
string := "Der Timer ist nach {88AA62}" date(timer_s) "{FFFFFF} abgelaufen!"
timer_time := 0
if(WinActive("ahk_group GTASA"))
	AddChatMessage(string)
else
	MsgBox, 64, sBinder: Timer abgelaufen, % RegExReplace(string, "Ui)\{[a-f0-9]{6}\}")
return
TimerTone:
loop, 5
{
	SoundPlay, *48, 1
	Sleep, 200
}
return
::/countdown::
Suspend Permit
if(A_IsSuspended){
	AddChatMessage("Der sBinder ist aktuell deaktiviert. Aktiviere ihn erst!")
	return
}
pre := PlayerInput("In welchen Chat willst du den Countdown schreiben? (z.B. /s, /d, /r, /f...): ")
loop, % count := PlayerInput("Gib die erste Zahl des Countdowns ein: "){
	if(A_IsSuspended)
		break
	if(!WinActive("ahk_group GTASA"))
		return
	SendChat((pre ? pre " " : "") (count-A_Index)+1)
	Sleep, 1000
}
if(!A_IsSuspended)
	SendChat((pre ? pre " " : "") "GO!")
else
	AddChatMessage("Countdown abgebrochen")
pre := ""
return
::/stoppuhr::
Suspend Permit
if(stoppuhr){
	stoppuhr := A_TickCount - stoppuhr
	AddChatMessage("Die Stoppuhr wurde beendet. Zeit: {88AA62}" Floor(stoppuhr/3600000) ":" LeadingZero(Mod(Floor(stoppuhr/60000), 60)) ":" LeadingZero(Mod(Floor(stoppuhr/1000), 60)) ":" LeadingZero(SubStr(stoppuhr, -2), 3) "{FFFFFF} (h:min:sek:ms)")
	stoppuhr := 0
}
else{
	AddChatMessage("Die Stoppuhr wurde gestartet. Du kannst sie mit {88AA62}/stoppuhr{FFFFFF} anhalten.")
	stoppuhr := A_TickCount
}
return
::/uhr::
Suspend Permit
AddChatMessage("Es ist {88AA62}" A_Hour ":" A_Min ":" A_Sec " Uhr{FFFFFF} am " A_DDDD ", dem {88AA62}" A_DD "." A_MM "." A_YYYY "{FFFFFF}.")
return
::/clearchat::
Suspend Permit
SplitPath, chatlogpath,, userfiles
FileRead, data, %userfiles%\sa-mp.cfg
loop, % RegExFileRead(data, "pagesize", 10)
{
	AddChatMessage(" ")
	/*
	if(!UseAPI)
		SendChat("//")
	*/
}
data := ""
return
::/trucking::
::/trucking input::
Suspend Permit
GuiControlGet, TruckLevelLimit, SettingsGUI:
if(TruckLevelLimit != -1 AND A_ThisLabel != "::/trucking input")
	SendChat("/truckinfo")
else if(A_ThisLabel = "::/trucking input")
	TruckLevelLimit := 0
AddChatMessage("Daten werden geladen...")
gosub TruckReload
if(TruckDDOS)
	return
Gui, TruckerGUI:Default
if(TruckLevelLimit != -1){
	Sleep, 15
	chat := ChatLine(0, "Trucklevel")
	chat2 := ""
	RegExMatch(chat, "^\s*Trucklevel: (\d+?) \(Erfahrungspunkte: (\d+)( / \d+ bis Level \d+)?\)", chat)
	if(LV_GetCount() AND (A_ThisLabel = "::/trucking input" OR !chat1) AND !(chat1 := Trim(PlayerInput("Gib " (A_ThisLabel = "::/trucking input" ? "das" : "dein aktuelles") " Trucklevel ein: ")))){
		TruckLevelLimit := -1
		chat1 := 100
	}
}
else
	chat1 := 100
if(LV_GetCount()){
	Truck_LV := Object()
	i := 0
	loop, % LV_GetCount(){
		LV_Truck := Object()
		x := A_Index
		loop, % LV_GetCount("Col"){
			LV_GetText(LV_T, x, A_Index)
			LV_Truck[A_Index] := LV_T
		}
		if(TruckLevelLimit != -1 AND ((TruckLevelLimit = 0 AND LV_Truck[1] > chat1) OR !between(LV_Truck[1], chat1 - TruckLevelLimit, chat1)))
			continue
		i++
		if(i = 1)
			AddChatMessage("Ort (Produkt) | Trucklevel | Erfahrung | Einkaufspreis -> Verkaufspreis (Gewinn) | Gewicht" (TruckingSort = 7 AND UseAPI ? " | Entfernung" : "") (chat1 >= 8 OR TruckLevelLimit = -1? " | (Anhänger)" : ""))
		Truck_LV[i] := LV_Truck
	}
	if(i){
		if(TruckingSort = 1 OR TruckingSort = 7)
			Truck_LV := ArrayMultiSort(Truck_LV, 10, TruckingSort = 7)
		LV_Truck := [1, 10, 11, 12, 13, 14, 17]
		if(TruckingSort = 7){
			trucking_places := ["Zombotech", "Raffinerie", "Kraftwerk SF", "Radio SF", "Sägewerk", "Truckstop", "LV Productions", "Lagerverkauf", "LS Train Station", "LS Docks", "Fleischberg"]
			if(UseAPI){
				trucking_places := [{x: -1954, y: 617, z: 35}, {x: 264, y: 1415, z: 12}, {x: -1019, y: -662, z: 32}, {x: -2520, y: -618, z: 133}, {x: -2003, y: -2414, z: 31}, {x: -53, y: -1141, z: 1}, {x: -224, y: 2601, z: 64}, {x: 1449, y: 2350, z: 12}, {x: 2186, y: -2277, z: 13}, {x: 2760, y: -2451, z: 13}, {x: -119, y: -353, z: 1}]
				GetPlayerPosition(pos_x, pos_y, pos_z)
				for index, k in trucking_places
					trucking_places[index] := Pythagoras(k["x"] - pos_x, k["y"] - pos_y, k["z"] - pos_z)
				for index, k in Truck_LV
					Truck_LV[index, 17] := trucking_places[k[15]]
				Truck_LV := ArrayMultiSort(Truck_LV, 17, TruckingSortOrder - 1)
			}
			else
				AddChatMessage("Das Sortieren nach Entfernung wird nicht unterstützt, wenn die API nicht aktiviert ist!")
		}
		else
			Truck_LV := ArrayMultiSort(Truck_LV, LV_Truck[TruckingSort], TruckingSortOrder - 1)
		/*
		Truck_Output := Object()
		for index, k in Truck_LV
		{
			for index2, k2 in k
			{
				if(index2 = 17)
					Truck_Output[index, index2] := number_format(Round(k2, -1)) 
				Truck_Output[index, index2] := (index2 = LV_Truck[TruckingSort] ? "{D65B0F}" : "") k[index2]
			}
		}
		*/
		for index, k in Truck_LV
			AddChatMessage(k[2] " -> " k[3] " (" k[4] ") | " k[1] " | " k[5] " | " k[6] " -> " k[7] " (" k[8] ") | " k[9] (k[17] ? " | " number_format(Round(k[17], -1)) "m" : "") (k[1] >= 8 AND SubStr(k[9], 1, -2) = 0 ? " | " (InStr(k[4], "Lebens") OR InStr(k[4], "Neue Warenlieferung") ? "Lebensmittelanhänger" : "Kastenanhänger") : ""),, 1)
		if(UseAPI)
			AddChatMessage(i " Mission" (i = 1 ? "" : "en, sortiert nach " (["Trucklevel", "Erfahrung", "Einkaufspreis", "Verkaufspreis", "Gewinn", "Gewicht", "Entfernung zum Kaufort (Luftlinie)"][TruckingSort]) " - höchste" (["s Trucklevel", " Erfahrung", "r Einkaufspreis", "r Verkaufspreis", "r Gewinn", "s Gewicht", " Entfernung (Luftlinie)"][TruckingSort]) " " (TruckingSortOrder = 2 ? "oben" : "unten")))
	}
	else
		AddChatMessage("Aktuell sind keine Trucker-Missionen für dein Level verfügbar")
}
else
	AddChatMessage("Fehler beim Herunterladen der Trucker-Missionen!")
LV_Truck := Truck_LV := ""
Gui, 1:Default
return
::/setmoney::
Suspend Permit
num1 := toMoney(PlayerInput("Gib das Geld ein, das du auf der Hand haben willst: "))
if(num1 < 0 OR num1 = ""){
	AddChatMessage("Du musst eine positive Zahl eingeben!")
	return
}
SendChat("/oldstats")
chat := WaitForChatLine(6, "Bank:[$")
StringReplace, chat, chat, .,, All
RegExMatch(chat, "Bargeld:\[\$(.*?)\] Bank:\[\$(.*?)\] Handynummer:", chat)
num1 -= chat1
if(num1 > 0 AND chat2 < num1){
	AddChatMessage("Du hast nicht genug Geld auf dem Konto")
	return
}
;WinGetPos,,, money_w, money_h, ahk_group GTASA
if(!num1){
	AddChatMessage("Du hast bereits so viel Geld auf der Hand!")
	return
}
SendChat("/bankmenu")
WaitFor()
GetChatLine(0, chat)
if(InStr(chat, "Du bist nicht an einem Bankterminal"))
	return
/*
if(num1 > 0)
	MouseClick, Left, money_w/2+58, money_h/2+60
else if(num1 < 0)
	MouseClick, Left, money_w/2-66, money_h/2+60
*/
if(num1 > 0)
	SendInput, {Escape}
else if(num1 < 0)
	SendInput, {Enter}
WaitFor()
SendInput, % Abs(num1) "{enter}"
return
::/showpolice::
Suspend Permit
BindReplace("/showperso [ID 1]~/showlicenses [ID 1]~/showvisum [ID 1]")
return
::/wetter::
Suspend Permit
AddChatMessage("Wetterdaten werden geladen...")
if(RegExMatch(data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=weather",,, 1), "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
i := 0
loop, Parse, data, `n, `r
{
	if(!A_LoopField)
		break
	AddChatMessage(A_LoopField)
	i++
}
if(!i)
	AddChatMessage("Die Wetterdaten konnten nicht heruntergeladen werden!")
data := ""
return
::/kme::
Suspend Permit
meTexte := !meTexte
AddChatMessage("Die /me-Texte wurden " (meTexte ? "" : "de") "aktiviert.")
IniWrite, %meTexte%, %INIFile%, Settings, me
GuiControl, SettingsGUI:, meTexte, %meTexte%
return
::/checkfrak::
::/checkfrak id::
::/checkfrak wp::
::/membersonline::
::/membersonline id::
::/membersonline wp::
Suspend Permit
num2 := leaderonline := leader := members := online := 0
if(!num1 := PlayerInput("Gib den Namen der Fraktion ein: ")){
	AddChatMessage("Du hast keine Fraktion eingegeben!")
	return
}
if(!num2 := ArrayMatch(num1, FrakRegEx)){
	AddChatMessage("Kein gültiger Fraktionsname!")
	return
}
AddChatMessage("Daten werden geladen...")
if(RegExMatch(data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=members-v2&p=" num2,,, 1), "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
FrakWebsite := Object()
pos := 0
while(pos := RegExMatch(data, "Um`a)^(.+);(\d+);(\d+);(\d*);(\d*);$", chat, pos+1)){
	FrakWebsite[A_Index] := [chat1, chat2, chat3, chat4, chat5] ;Name, Level, Rang, online/offline, Leader
	if(chat4)
		online ++
	if(chat5){
		if(chat4)
			leaderonline ++
		leader ++
	}
	members ++
}
FrakWebsite := ArrayReverse(ArrayMultiSort(ArrayMultiSort(ArrayMultiSort(FrakWebsite, 2), 3), 5))
if(!RegExMatch(data, "U)^\[(.+)\]", data))
	AddChatMessage("Fehler beim Download")
else if(!members)
	AddChatMessage("Die Fraktion {88AA62}" data1 "{FFFFFF} hat keine Mitglieder")
else if(!online)
	AddChatMessage("0/" members " der Fraktion {88AA62}" data1 "{FFFFFF} online.")
else{
	AddChatMessage(online "/" members " der Fraktion {88AA62}" data1 "{FFFFFF} online (" RoundEx(online/members*100) " Prozent), davon " leaderonline "/" leader " Leader:")
	for i, k in FrakWebsite
	{
		if(k[4]){
			if(SubStr(A_ThisLabel, -2) = " id")
				SendChat("/id " k[1])
			else if(SubStr(A_ThisLabel, -2) = " wp")
				SendChat("/checkwanted " k[1])
			else
				AddChatMessage((k[5] ? "{00AA00}Leader:{FFFFFF} " : "") k[1] " [Rang " k[3] "; Level " k[2] "]")
		}
	}
}
FrakWebsite := ""
return
::/myfrak::
Suspend Permit
num2 := leaderonline := leader := members := online := 0
if(!num2 := FrakNums[Frak])
	return
AddChatMessage("Daten werden geladen...")
if(RegExMatch(data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=members-v2&p=" num2,,, 1), "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
FrakWebsite := Object()
pos := 0
while(pos := RegExMatch(data, "Um`a)^(.+);(\d+);(\d+);(\d*);(\d*);$", chat, pos+1)){
	FrakWebsite[A_Index] := [chat1, chat2, chat3, chat4, chat5] ;Name, Level, Rang, online/offline, Leader
	if(chat4)
		online ++
	if(chat5){
		if(chat4)
			leaderonline ++
		leader ++
	}
	members ++
}
FrakWebsite := ArrayReverse(ArrayMultiSort(ArrayMultiSort(ArrayMultiSort(FrakWebsite, 2), 3), 5))
if(!RegExMatch(data, "U)^\[(.+)\]", data))
	AddChatMessage("Fehler beim Download")
else{
	for i, k in FrakWebsite
	{
		if(k[4])
			SendChat("/id " k[1])
	}
	WaitFor()
	Sleep, 50
	active := online
	leaderactive := leaderonline
	i2 := 0
	for i, k in FrakWebsite
	{
		if(k[4])
		{
			chat := ChatLine(online - i2 - 1, ") " k[1] " Level: ")
			if (InStr(chat, "| AFK-Modus.") || InStr(chat, "| User ist tot.") || InStr(chat, "| User ist im Gefängnis."))
			{
				active--
				if(k[5])
					leaderactive--
			}
			i2++
		}
	}
	AddChatMessage("Members online: " online "/" members " (" leaderonline "/" leader " Leader)")
	AddChatMessage("Davon ingame anwesend: " active "/" online " (" leaderactive "/" leaderonline " Leader)")
}
FrakWebsite := ""
return
::/chatlogbackup::
Suspend Permit
FileCreateDir, ChatlogBackups
clpath := "ChatlogBackups\chatlog" A_DD "_" A_MM "_" A_YYYY "-" A_Hour "_" A_Min "_" A_Sec ".txt"
FileCopy, %chatlogpath%, %clpath%
AddChatMessage("Der aktuelle Chatlog wurde hierhin kopiert:")
AddChatMessage(clpath)
return
::/leaders::
::/leaders id::
Suspend Permit
num2 := leaderonline := leader := members := 0
if(!num1 := PlayerInput("Gib den Namen der Fraktion ein: ")){
	AddChatMessage("Du hast keine Fraktion eingegeben!")
	return
}
if(!num2 := ArrayMatch(num1, FrakRegEx)){
	AddChatMessage("Kein gültiger Fraktionsname!")
	return
}
AddChatMessage("Daten werden geladen...")
if(RegExMatch(data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=members-v2&p=" num2,,, 1), "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
FrakWebsite := Object()
pos := 0
while(pos := RegExMatch(data, "Um`a)^(.+);(\d+);(\d+);(\d*);(\d*);$", chat, pos+1)){
	if(!chat5)
		continue
	FrakWebsite[A_Index] := [chat1, chat2, chat3, chat4, chat5] ;Name, Level, Rang, online/offline, Leader
	leader++
	if(chat4)
		leaderonline++
}
if(!RegExMatch(data, "U)^\[(.+)\]", data))
	AddChatMessage("Fehler beim Download")
else if(!leader)
	AddChatMessage("Die Fraktion {88AA62}" data1 "{FFFFFF} hat keine Leader.")
else{
	AddChatMessage("Die Fraktion {88AA62}" data1 "{FFFFFF} hat " leader " Leader, davon " leaderonline " online:")
	FrakWebsite := ArrayReverse(ArrayMultiSort(ArrayMultiSort(FrakWebsite, 2), 3))
	for i, k in FrakWebsite
	{
		if(k[5] = 1){
			if(k[4])
				temp := "{00AA00}Online:"
			else
				temp := "{FF1100}Offline:"
			AddChatMessage(temp "{FFFFFF} " k[1] " [Rang " k[3] "; Level " k[2] "]")
		}
		else if(k[5] = -1)
			AddChatMessage("{FF0000}Fehler: {FFFFFF}" k[1])
	}
	if(SubStr(A_ThisLabel, -2) = " id"){
		for i, k in FrakWebsite
		{
			if(k[4] AND k[5] != 0)
				SendChat("/id " k[1])
		}
	}
}
FrakWebsite := ""
return
::/playerinfo::
Suspend Permit
if((id := PlayerInput("Gib Name, ID oder Nummer des Spielers ein: ")) = ""){
	AddChatMessage("Du hast nichts eingegeben...")
	return
}
chat := chat1 := 0
if(is(id, "integer") AND (between(StrLen(id), 1, 3))){
	if(is(id := GetPlayerNameById(id), "integer")){
		AddChatMessage("Kein Spieler mit der ID " id " gefunden!")
		return
	}
}
if(SubStr(id, -5, 6) = "_[AFK]")
	id := SubStr(id, 1, -6)
AddChatMessage("Spielerdaten werden geladen...")
if((data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=player-v2.3&p=" URLEncode(id), "")) = -1){
	AddChatMessage("Kein Spieler mit " (is(id, "integer") ? "der Nummer" : "dem Namen") " {88AA62}" id "{FFFFFF} gefunden")
	return
}
if(RegExMatch(data, "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
if(RegExMatch(data, "U)^(.+);(\d);(\d+);(\d+);(\d{5,6});(.+);(\d{1,2});(\d+)(;.+)?(\|.+)?(#.+)?$", data)){ ;Name, online/offline, Level, Alter, Tel.nummer, Frak + Rang + Leader, Achievements, Achievements insg., Ehepartner (mit ;), Adminrang (mit |), Frühere Namen (mit #)
	if(!RegExMatch(data6, "^(.+)\[(.+);(\d)\]$", num))
		num1 := data6
	if(data4 = 0)
		data4 := "Unbekannt"
	AddChatMessage("--- [sBinder] Spieler-Informationen ---")
	AddChatMessage("Name: {88AA62}" data1 "{FFFFFF} -- Status: " (data2 ? "{00AA00}on" : "{FF1100}off") "line{FFFFFF} -- Level: " data3)
	AddChatMessage("Alter: " data4 " -- Fraktion: " num1 (InStr(data6, "[") ? " (Rang " num2 (num3 ? ", Leader" : "") ")" : ""))
	AddChatMessage("Handynummer: " data5 " -- Achievements: " data7 "/" data8 " (" RoundEx(data7/data8*100) " Prozent)")
	if(data9)
		AddChatMessage("Verheiratet mit {E809B4}" SubStr(data9, 2))
	if(data10)
		AddChatMessage("Adminrang: {DDDD00}" SubStr(data10, 2))
	if(data11)
		AddChatMessage((InStr(data11, ",") ? "Frühere Namen: " : "Früherer Name: ") SubStr(data11, 2))
	if(data2)
		SendChat("/id " data1)
}
else{
	AddChatMessage("Fehler beim Download" (StrLen(id) > 3 AND is(id, "number") ? ". Eventuell hast du eine falsche Nummer eingegeben." : ""))
	if(StrLen(id) > 3 AND is(id, "number"))
		AddChatMessage("Überprüfe die Nummer {88AA62}" id)
}
data := ""
return
::/setjob::
Suspend Permit
if(!num1 := PlayerInput("Gib den Namen des Berufs ein: ")){
	AddChatMessage("Du hast nichts eingegeben!")
	return
}
SetJob_Names := ["Kein|Arbeitslos|Hartz", "Anwalt", "Bus", "Dete", "Dieb|Ganove", "Erz", "Farm|Getreide", "Liefer", "Mech|Kfz", "Reinigung", "Tank", "Wartung", "Taxi|Cab", "Fisch|Angel", "Gärtner|Garten|Gras", "Holz", "Jäger|Jagen", "Müll", "Pizza", "Drogen|Schieber", "Waffen", "Fastfood"]
if(!num2 := ArrayMatch(num1, SetJob_Names)){
	AddChatMessage("Deine Eingabe ist kein gültiger Beruf")
	return
}
SetJob_Names := ""
if(num2 = Job){
	AddChatMessage("Der Beruf {88AA62}" Jobnames[Job] "{FFFFFF} ist bereits im sBinder ausgewählt!")
	return
}
AddChatMessage("Willst du deinen Beruf {88AA62}" Jobnames[Job] "{FFFFFF} wirklich zu {88AA62}" Jobnames[num2] "{FFFFFF} ändern? Drücke dazu innerhalb der nächsten 5 Sekunden {88AA62}J{FFFFFF}.")
s := A_IsSuspended
Suspend On
KeyWait, J, D T5
if(!s)
	Suspend Off
if(ErrorLevel)
	AddChatMessage("Dein Beruf bleibt {88AA62}" Jobnames[Job] "{FFFFFF}, da du nicht innerhalb der letzten 5 Sekunden {88AA62}J{FFFFFF} gedrückt hast!")
else{
	Job := num2
	IniWrite, %Job%, %INIFile%, Settings, Job
	gosub JobGUIBuild
	gosub HotkeysDefine
	AddChatMessage("Dein Beruf wurde erfolgreich in {88AA62}" Jobnames[Job] "{FFFFFF} geändert!")
}
return
::/kautosetup::
Suspend Permit
AddChatMessage("Automatisches Setup des sBinders wird durchgeführt, bitte warten...")
if(FileExist(chatlogpath)){
	Sleep, 100
	SendChat("/echo [[sBinder]]")
	start := A_TickCount
	while(A_TickCount - start < 300 AND !(chat := ChatLine(0, "[[sBinder]]", 2)))
	{
	}
	temp2 := A_TickCount - start + 30
	temp2 -= ping("nes-newlife.de")
	if(chat AND between(temp2, 20, 300)){
		WaitFor := temp2
		AddChatMessage("Die Zeit zum Warten auf den Chatlog wurde auf {88AA62}" WaitFor " ms{FFFFFF} gesetzt.")
		IniWrite, %WaitFor%, %INIFile%, Settings, WaitFor
		GuiControl, SettingsGUI:, WaitFor, %WaitFor%
	}
	else
		AddChatMessage("Ein Fehler ist aufgetreten! (" temp2 ")")
}
else
	AddChatMessage("Die chatlog.txt konnte nicht gefunden werden. Bitte wähle in den Einstellungen (Datei->Einstellungen) den Pfad zur chatlog.txt aus.")
return
::/kbl::
Suspend Permit
SendChat("/bl")
WaitFor()
fullchat := ""
loop
{
	GetChatLine(A_Index-1, chat)
	if(InStr(chat, "Blacklist Spieler Online:"))
		break
	else if(A_Index >= 15){
		AddChatMessage("Du bist nicht berechtigt!")
		return
	}
	fullchat := chat "`n" fullchat
}
pos := 0
while(pos := RegExMatch(" " fullchat, "Um`a)\s(.+)(,\s|\.\s*$)", chat, pos + 1))
	SendChat("/id " Trim(chat1))
fullchat := ""
return
::/calc::
Suspend Permit
AddChatMessage("HINWEIS: Der Rechner ist noch in der Beta-Phase, es können evtl. fehlerhafte Ergebnisse ausgegeben werden.")
if((id := PlayerInput("Gib eine Rechnung ein: ")) = "")
	AddChatMessage("Du hast nichts eingegeben...")
else
	AddChatMessage(id " = {88AA62}" (((id := StrCalc(id)) != "") ? TrimNum(id) : "Fehler"))
return
::/kstate::
Suspend Permit
AddChatMessage("Status des sBinders " (UpdateAvailable ? "{FF1100}" : "{00AA00}") "(Version " Version "-" Build "):")
AddChatMessage("Der sBinder ist aktuell " (A_IsSuspended ? "{FF1100}de" : "{00AA00}") "aktiviert.")
temp := timer_time
temp -= A_Now, Seconds
AddChatMessage("/timer: " (timer_time ? "{00AA00}aktiv. {FFFFFF}Er läuft in " date(temp) " (um " FormatTime(timer_time, "HH:mm:ss") ") ab." : "{FF1100}nicht aktiv."))
temp := A_TickCount - stoppuhr
AddChatMessage("/stoppuhr: " (stoppuhr ? "{00AA00}aktiv{FFFFFF}. Sie steht aktuell bei {88AA62}" Floor(temp/3600000) ":" LeadingZero(Mod(Floor(temp/60000), 60)) ":" LeadingZero(Mod(Floor(temp/1000), 60)) ":" LeadingZero(SubStr(temp, -2), 3) "{FFFFFF} (h:min:sek:ms)." : "{FF1100}nicht aktiv."))
if(IsObject(ame)){
	AddChatMessage("/kame multi: Es werden " ame._maxIndex() " Texte über deinem Kopf angezeigt:")
	for i, k in ame
		AddChatMessage("     Text " i ": {88AA62}" k)
}
else if(ame)
	AddChatMessage("/kame: {88AA62}" ame)
else
	AddChatMessage("/kame: {FF1100}nicht aktiv.")7
AddChatMessage("Fraktionsbinds für {88AA62}" (IsFrak(Frak) ? Fraknames[Frak] : "Fehler") ": " (Frak = 1 ? "{FF1100}nicht vorhanden" : frakbinds ? "{00AA00}aktiv{FFFFFF} (" fBinds_used "/" fBinds " belegt)" : "{FF1100}nicht aktiv"))
AddChatMessage("Job: " (Job = 1 ? "{FF1100}" : "{88AA62}") Jobnames[Job])
return
::/frakall::
Suspend Permit
members := online := fraks := 0
AddChatMessage("Daten werden geladen...")
if(RegExMatch(data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=fraks",,, 1), "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
FrakWebsite := Object()
pos := 0
while(pos := RegExMatch(data, "Um`a)^(.+):(\d+)/(\d+)$", chat, pos+1)){
	FrakWebsite[A_Index] := [chat1, chat2, chat3]
	online += chat2
	members += chat3
	fraks ++
}
FrakWebsite := ArrayMultiSort(ArrayMultiSort(FrakWebsite, 3), 2)
if(!FrakWebsite._maxIndex())
	AddChatMessage("Fehler beim Download")
else{
	AddChatMessage(online "/" members " Mitglieder von " fraks " Fraktionen online:")
	for i, k in FrakWebsite
	{
		AddChatMessage(k[1] ": {88AA62}" k[2] "/" k[3] "{FFFFFF} (" RoundEx(k[2]/k[3] * 100) " Prozent)")
	}
}
FrakWebsite := ""
return
::/membersall::
Suspend Permit
num2 := leaderonline := leader := members := online := 0
if(!num1 := PlayerInput("Gib den Namen der Fraktion ein: ")){
	AddChatMessage("Du hast keine Fraktion eingegeben!")
	return
}
if(!num2 := ArrayMatch(num1, FrakRegEx)){
	AddChatMessage("Kein gültiger Fraktionsname!")
	return
}
AddChatMessage("Daten werden geladen...")
if(RegExMatch(data := HTTPData("http://saplayer.lima-city.de/sBinder_get.php?nl&a=members-v2&p=" num2,,, 1), "^\[\[(\d+)\]\]$", var)){
	AddChatMessage("Du musst noch {88AA62}" var1 " Sekunden{FFFFFF} warten, bis du die Daten wieder abrufen kannst. Grund dafür ist, dass die Anfrage anderfalls aufgrund von DDOS-Verdacht gesperrt werden würde.")
	return
}
FrakWebsite := Object()
pos := 0
while(pos := RegExMatch(data, "Um`a)^(.+);(\d+);(\d+);(\d*);(\d*);$", chat, pos+1)){
	FrakWebsite[A_Index] := [chat1, chat2, chat3, chat4, chat5] ;Name, Level, Rang, online/offline, Leader
	if(chat4)
		online ++
	if(chat5){
		if(chat4)
			leaderonline ++
		leader ++
	}
	members ++
}
FrakWebsite := ArrayReverse(ArrayMultiSort(ArrayMultiSort(ArrayMultiSort(FrakWebsite, 2), 3), 5))
if(!RegExMatch(data, "U)^\[(.+)\]", data))
	AddChatMessage("Fehler beim Download")
else if(!members)
	AddChatMessage("Die Fraktion {88AA62}" data1 "{FFFFFF} hat keine Mitglieder")
else{
	for i, k in FrakWebsite
		AddChatMessage(k[1] "{FFFFFF} [Rang " k[3] "; Level " k[2] (k[5] ? "; Leader" : "") "]" (k[4] ? ": online" : ""), k[4] ? 0x00AA00 : 0xFF1100)
	AddChatMessage(online "/" members " der Fraktion {88AA62}" data1 "{FFFFFF} online (" RoundEx(online/members*100) " Prozent), davon " leaderonline "/" leader " Leader.")
}
FrakWebsite := ""
return
::/carvalue::
Suspend Permit
SendChat("/vehinfo")
SendChat("/addoninfo")
WaitForChatLine(0, "Kofferraumerweiterung:")
chat := GetChatLines(17)
if(RegExMatch(chat, "FahrzeugID: \d+\s+ModelID: (\d+)", data) AND RegExMatch(chat, "Ui)Dieses Fahrzeug hat folgende Extras eingebaut:\s+-> Kennzeichen: .+\s+-> Navigationsgerät \(/car search\): (.+)\s+-> Funkfernbedienung \(/car lock\): (.+)\s+-> Alarmanlage: (.+)\s+-> Unterbodenbeleuchtung: (.+)\s+-> Waffenkiste: (.+)\s+-> Fahrzeugstatus: .+\s+-> Versicherung: (.+)\s+-> Unlimitedrespawn \(Premium\): (.+)\s+-> Fahrzeugpanzerung: (.+)\s+-> Handyladestation: (.+)\s+-> Kofferraumerweiterung: (.+)", var)){ ;1: Peilsender, 2: Funkfernbedienung, 3: Alarmanlage, 4: Neon, 5: Waffenlager, 6: Versicherung (mit Text), 7: Unlimited Respawn, 8: Carheal (mit Text), 9: Handyakku, 10: Kofferraum
	carvalue := Object()
	;{
	carvalues := ArrayParse("445:31500|602:34000|592:2000000|485:32500|429:125000|499:12000|424:19900|581:13900|509:3000|536:12500|496:7500|481:5000|422:27500|498:14000|575:22700|518:14800|402:89000|541:175000|482:56000|438:22000|483:34000|415:274000|542:3999|589:44000|480:220000|578:22000|473:12500|593:299000|507:23500|562:27900|419:14500|587:42500|521:15000|533:19500|565:24500|455:28500|463:21000|466:3400|492:14500|474:28500|434:78000|502:350000|579:32000|545:23000|411:275000|559:38900|493:240000|508:28000|400:12900|417:950000|403:49000|517:14500|484:220000|487:700000|500:24999|418:18000|510:9000|414:19500|553:945000|522:44900|467:10500|461:18000|404:6800|603:125000|600:4300|413:8500|426:35000|471:9000|479:10700|534:37500|515:69000|475:28000|468:12900|567:8400|405:22000|519:1400000|535:16500|469:320000|580:48000|439:19500|561:23500|409:112000|513:450000|560:39999|550:23999|506:98000|566:14000|514:59000|420:29000|576:9999|531:14500|454:79999|583:32500|451:144000|558:16500|552:24780|491:18500|412:9800|539:300000|478:4250|421:32500|586:36000|555:27200|456:17000|554:27500|477:59000|")
	;}
	carvalue["price"] := carvalue["carprice"] := carvalues[data1]
	AddChatMessage("Neupreis (ohne Addons): {88AA62}$" number_format(carvalue["carprice"]))
	carvalue["price"] += var1 = "Vorhanden" ? 2000 : 0
	carvalue["price"] += var2 = "Vorhanden" ? 899 : 0
	carvalue["price"] += var3 = "Vorhanden" ? 500 : 0
	carvalue["price"] += var4 = "Vorhanden" ? 2500 : 0
	carvalue["price"] += var5 = "Vorhanden" ? 2700 : 0
	carvalue["price"] += RegExMatch(var6, "-> (\d+)", data) ? data1 * 80 : 0
	carvalue["price"] += var7 = "Vorhanden" ? 12000 : 0
	carvalue["price"] += RegExMatch(var8, "Stufe -> (\d+)", data) ? [10000][data1] : 0
	carvalue["price"] += var9 = "Vorhanden" ? 750 : 0
	carvalue["price"] += var10 = "Vorhanden" ? 2500 : 0
	AddChatMessage("Neupreis (mit Addons): {88AA62}$" number_format(carvalue["price"]))
	AddChatMessage("Fahrzeugwert (/car sell): {88AA62}$" number_format(Round(carvalue["carprice"] * 0.25)))
	AddChatMessage("Hinweis: Kennzeichenfarbe sowie Umrüstungen auf Diesel/LPG werden nicht berücksichtigt.", 0xFF1100)
	AddChatMessage("Alle Angaben ohne Gewähr!", 0xFF1100)
	carvalue := carvalues := ""
}
else
	AddChatMessage("Das Fahrzeug konnte nicht gefunden werden. Bist du in einem Fahrzeug? Ist es ein Fraktionsfahrzeug?")
return
::/car lock 1::
::/car lock 2::
::/car lock 3::
::/car lock 4::
::/car lock 5::
::/car lock 6::
::/car lock 7::
::/car lock 8::
::/car lock 9::
::/car lock 10::
::/car lock 11::
::/car lock 12::
::/car lock 13::
::/car lock 14::
::/car lock 15::
::/car lock 16::
::/car lock 17::
::/car lock 18::
::/car lock 19::
::/car lock 20::
Suspend Permit
SendChat("/car lock")
if(UseAPI){
	while(!IsDialogOpen() AND A_Index < 60)
		Sleep, 10
	if(!IsDialogOpen())
		return
}
else{
	WaitFor()
	Sleep, 5
}
SendInput, % "{down " SubStr(A_ThisLabel, -1) - 1 "}{enter}"
return


;/me-Texte
#If meTexte && active && WinActive("ahk_group GTASA")
:?b0:/handsup::
Suspend Permit
SendChat("/me hebt die Hände hoch.")
return
:?b0:/drunk::
Suspend Permit
SendChat("/me torkelt betrunken durch die Gegend.")
return
:?b0:/bomb::
Suspend Permit
SendChat("/me montiert etwas.")
return
:?b0:/getarrested::
Suspend Permit
SendChat("/me wird festgenommen.")
return
:?b0:/lachen::
Suspend Permit
SendChat("/me lacht.")
return
:?b0:/lookout::
Suspend Permit
SendChat("/me schaut sich um.")
return
:?b0:/raub::
Suspend Permit
SendChat("/me überfällt eine Person.")
return
:?b0:/schreien::
Suspend Permit
SendChat("/me schreit.")
return
:?b0:/denken::
Suspend Permit
SendChat("/me denkt nach.")
return
:?b0:/crossarms::
Suspend Permit
SendChat("/me verschränkt die Arme.")
return
:?b0:/lay::
:?b0:/lay2::
:?b0:/lay3::
Suspend Permit
SendChat("/me legt sich hin.")
return
:?b0:/hide::
:?b0:/hi::
Suspend Permit
SendChat("/me duckt sich.")
return
:?b0:/kotzen::
Suspend Permit
SendChat("/me erbricht.")
return
:?b0:/eat::
Suspend Permit
SendChat("/me isst etwas.")
return
:?b0:/winken::
Suspend Permit
SendChat("/me winkt.")
return
:?b0:/taichi::
Suspend Permit
SendChat("/me meditiert.")
return
:?b0:/anfeuern::
Suspend Permit
SendChat("/me feuert dich an.")
return
:?b0:/sprung::
Suspend Permit
SendChat("/me springt zur Seite.")
return
:?b0:/handstand::
Suspend Permit
SendChat("/me macht einen Handstand.")
return
:?b0:/deal::
Suspend Permit
SendChat("/me bietet etwas an.")
return
:?b0:/crack::
Suspend Permit
SendChat("/me krümmt sich.")
return
:?b0:/smoke::
Suspend Permit
SendChat("/me raucht.")
return
:?b0:/groundsit::
:?b0:/gro::
:?b0:/sit::
Suspend Permit
SendChat("/me setzt sich.")
return
:?b0:/chat::
Suspend Permit
SendChat("/me erklärt etwas.")
return
:?b0:/dance 1::
:?b0:/dance 2::
:?b0:/dance 3::
:?b0:/dance 4::
Suspend Permit
SendChat("/me tanzt.")
return
:?b0:/medic::
Suspend Permit
SendChat("/me tut alles, um die Person wiederzubeleben.")
return
:?b0:/verletzt::
Suspend Permit
SendChat("/me ist verletzt.")
return
:?b0:/prefight::
Suspend Permit
SendChat("/me bereitet sich auf den Kampf vor.")
return
:?b0:/afun::
Suspend Permit
BindReplace("/afun~/me krault seine Eier.")
return
:?b0:/piss::
Suspend Permit
SendChat("/me pinkelt.")
return
:?b0:/dinfo::
Suspend Permit
SendChat("/me schaut nach, wer gestorben ist.")
return
:?b0:/wank::
Suspend Permit
BindReplace("/wank~/me holt sich einen runter.")
return
;WPs
#if (IsFrak(2) OR IsFrak(3) OR IsFrak(11)) AND WinActive("ahk_group GTASA")
::/wpbinds::
Suspend Permit
if(!UseAPI OR !ShowDialogWorking)
	List(["/anmaßung", "/anschlag", "/itätigkeit", "/braub", "/bflucht (/bhzf)", "/bsgen", "/sperrgebiet (/sg)", "/beleidigung", "/beamtenverweigerung (/bv)", "/bvl (/blösch)", "/bpassv", "/craub", "/diebstahl", "/c4dieb", "/drohung", "/drogen (/drogen1)", "/drogen2", "/drogen3", "/drogentransport (/dtrans)", "/seinbruch", "/peinbruch", "/erpressg", "/erschleichen", "/irpg", "/flucht", "/itüv", "/geiselnahme", "/ggs", "/bhack", "/ihandel", "/hetze", "/whetze", "/waffen", "/isf (/ibs)", "/kv", "/mord", "/ntl", "/pstörung", "/psv", "/raubwp", "/sachb", "/gefährdung (/staatsgefährdung)", "/schießen", "/lstvo", "/sstvo", "/smord", "/ticketv", "/vmord", "/vertuschung", "/vertuschungd", "/werkstoffe (/materialien)", "/iwerben", "/dicewp", "/wtransport"],, 1)
else
	ShowDialog(0, "sBinder: {0022FF}WP-Textbinds", "{0022FF}/anmaßung{FFFFFF}: Amtsanmaßung (15 WPs)`n{0022FF}/anschlag{FFFFFF}: Anschlag auf ein Staatsoberhaupt (61 WPs)`n{0022FF}/itätigkeit{FFFFFF}: Ausübung von besonderen Tätigkeiten ohne staatliche Genehmigung (20 WPs)`n{0022FF}/braub{FFFFFF}: Bankraub (40 WPs)`n{0022FF}/bflucht (/bhzf){FFFFFF}: Beihilfe zur Flucht (15 WPs)`n{0022FF}/bsgen{FFFFFF}: Beschädigung von Stromgeneratoren (20 WPs)`n{0022FF}/sperrgebiet (/sg){FFFFFF}: Betreten eines Sperrgebietes (40 WPs)`n{0022FF}/beleidigung{FFFFFF}: Beleidigung (10 WPs)`n{0022FF}/beamtenverweigerung (/bv){FFFFFF}: Beamtenverweigerung (5 WPs)`n{0022FF}/bvl (/blösch){FFFFFF}: Behinderung von Löscharbeiten (20 WPs)`n{0022FF}/bpassv{FFFFFF}: Beschuss während des Passverkaufes (40 WPs)`n{0022FF}/craub{FFFFFF}: Casinoraub (40 WPs)`n{0022FF}/diebstahl{FFFFFF}: Diebstahl (15 WPs)`n{0022FF}/c4dieb{FFFFFF}: Diebstahl von C4 (61 WPs)`n{0022FF}/drohung{FFFFFF}: Drohung (10 WPs)`n{0022FF}/drogen (/drogen1){FFFFFF}: Drogenbesitz (Green >= 51g, Gold >= 21g, LSD >= 1) (10 WPs)`n{0022FF}/drogen2{FFFFFF}: Drogenbesitz (Green >= 251g, Gold >= 50g, LSD >= 3) (15 WPs)`n{0022FF}/drogen3{FFFFFF}: Drogenbesitz (Green >= 501g, Gold >= 100g, LSD >= 5) (20 WPs)`n{0022FF}/drogentransport (/dtrans){FFFFFF}: Drogentransport (20 WPs)`n{0022FF}/seinbruch{FFFFFF}: Einbruch in institutionen des Staates (20 WPs)`n{0022FF}/peinbruch{FFFFFF}: Einbruch ins Alcatraz (61 WPs)`n{0022FF}/erpressg{FFFFFF}: Erpressung eines Geschäftes (10 WPs)`n{0022FF}/erschleichen{FFFFFF}: Erschleichen von Sozialleistungen (15 WPs)`n{0022FF}/irpg{FFFFFF}: Führen von illegalen Waffen (Raketenwerfer (61 WPs)`n{0022FF}/flucht{FFFFFF}: Flucht oder Fluchtversuch (15 WPs)`n{0022FF}/itüv{FFFFFF}: Führen eines Kfz mit abgelaufener/fehlender TÜV-Plakette (15 WPs)`n{0022FF}/geiselnahme{FFFFFF}: Geiselnahme (30 WPs)`n{0022FF}/ggs{FFFFFF}: Gruppierungen gegen den Staat (40 WPs)`n{0022FF}/bhack{FFFFFF}: Hacken des Banksystems (40 WPs)`n{0022FF}/ihandel{FFFFFF}: Handel mit illegalen Substanzen / Waffen (15 WPs)`n{0022FF}/hetze{FFFFFF}: Hetze gegen den Staat (20 WPs)`n{0022FF}/whetze{FFFFFF}: Hetze gegen den Staat (in Verbindung mit Waffengewalt) (40 WPs)`n{0022FF}/waffen{FFFFFF}: Illegaler Waffenbesitz (10 WPs)`n{0022FF}/isf (/ibs){FFFFFF}: Illegaler Aufenthalt (San Fierro oder Bayside) (15 WPs)`n{0022FF}/kv{FFFFFF}: Körperverletzung (15 WPs)`n{0022FF}/mord{FFFFFF}: Mord (35 WPs)`n{0022FF}/ntl{FFFFFF}: Null-Toleranz-Liste (Beschuss auf Staatsbeamte) (69 WPs)`n{0022FF}/pstörung{FFFFFF}: Prüfungsstörung (20 WPs)`n{0022FF}/psv{FFFFFF}: Parken innerhalb eines permanenten Sperrgebietes (40 WPs)`n{0022FF}/raubwp{FFFFFF}: Raub (20 WPs)`n{0022FF}/sachb{FFFFFF}: Sachbeschädigung (10 WPs)`n{0022FF}/gefährdung (/staatsgefährdung){FFFFFF}: Staatsgefährdung (61 WPs)`n{0022FF}/schießen{FFFFFF}: Schießen in der Öffentlichkeit (10 WPs)`n{0022FF}/lstvo{FFFFFF}: Leichtes StVO-Vergehen (9 WPs)`n{0022FF}/sstvo{FFFFFF}: Schweres StVO-Vergehen (10 WPs)`n{0022FF}/smord{FFFFFF}: Serienmord (40 WPs)`n{0022FF}/ticketv{FFFFFF}: Ticketverweigerung (10 WPs)`n{0022FF}/vmord{FFFFFF}: Versuchter Mord (25 WPs)`n{0022FF}/vertuschung{FFFFFF}: Vertuschung (Werkstoffe oder Mord) (15 WPs)`n{0022FF}/vertuschungd{FFFFFF}: Vertuschung (Drogen) (20 WPs)`n{0022FF}/werkstoffe (/materialien){FFFFFF}: Werkstoffe (ab 100g, Eisen) (15 WPs)`n{0022FF}/iwerben{FFFFFF}: Werben für illegale Aktivitäten (20 WPs)`n{0022FF}/dicewp{FFFFFF}: Würfeln außerhalb des Casinos (10 WPs)`n{0022FF}/wtransport{FFFFFF}: Illegaler Waffentransport (20 WPs)")
return
::/anmaßung::
Suspend Permit
SendWPs("Amtsanmaßung", 15)
return
::/anschlag::
Suspend Permit
SendWPs("Anschlag auf ein Staatsoberhaupt", 61)
return
::/itätigkeit::
Suspend Permit
SendWPs("Ausübung von besonderen Tätigkeiten ohne staatliche Genehmigung", 20)
return
::/braub::
Suspend Permit
SendWPs("Bankraub", 40)
return
::/bflucht::
::/bhzf::
Suspend Permit
SendWPs("Beihilfe zur Flucht", 15)
return
::/bsgen::
Suspend Permit
SendWPs("Beschädigung von Stromgeneratoren", 20)
return
::/sperrgebiet::
::/sg::
Suspend Permit
SendWPs("Betreten eines Sperrgebietes", 40)
return
::/beleidigung::
Suspend Permit
SendWPs("Beleidigung", 10)
return
::/beamtenverweigerung::
::/bv::
Suspend Permit
SendWPs("Beamtenverweigerung", 5)
return
::/bvl::
::/blösch::
Suspend Permit
SendWPs("Behinderung von Löscharbeiten", 20)
return
::/bpassv::
Suspend Permit
SendWPs("Beschuss während des Passverkaufes", 40)
return
::/craub::
Suspend Permit
SendWPs("Casinoraub", 40)
return
::/diebstahl::
Suspend Permit
SendWPs("Diebstahl", 15)
return
::/c4dieb::
Suspend Permit
SendWPs("Diebstahl von C4", 61)
return
::/drohung::
Suspend Permit
SendWPs("Drohung", 10)
return
::/drogen::
::/drogen1::
Suspend Permit
SendWPs("Drogenbesitz (Green >= 51g, Gold >= 21g, LSD >= 1)", 10)
return
::/drogen2::
Suspend Permit
SendWPs("Drogenbesitz (Green >= 251g, Gold >= 50g, LSD >= 3)", 15)
return
::/drogen3::
Suspend Permit
SendWPs("Drogenbesitz (Green >= 501g, Gold >= 100g, LSD >= 5)", 20)
return
::/drogentransport::
::/dtrans::
Suspend Permit
SendWPs("Drogentransport", 20)
return
::/seinbruch::
Suspend Permit
SendWPs("Einbruch in institutionen des Staates", 20)
return
::/peinbruch::
Suspend Permit
SendWPs("Einbruch ins Alcatraz", 61)
return
::/erpressg::
Suspend Permit
SendWPs("Erpressung eines Geschäftes", 10)
return
::/erschleichen::
Suspend Permit
SendWPs("Erschleichen von Sozialleistungen", 15)
return
::/irpg::
Suspend Permit
SendWPs("Führen von illegalen Waffen (Raketenwerfer", 61)
return
::/flucht::
Suspend Permit
SendWPs("Flucht oder Fluchtversuch", 15)
return
::/itüv::
Suspend Permit
SendWPs("Führen eines Kfz mit abgelaufener/fehlender TÜV-Plakette", 15)
return
::/geiselnahme::
Suspend Permit
SendWPs("Geiselnahme", 30)
return
::/ggs::
Suspend Permit
SendWPs("Gruppierungen gegen den Staat", 40)
return
::/bhack::
Suspend Permit
SendWPs("Hacken des Banksystems", 40)
return
::/ihandel::
Suspend Permit
SendWPs("Handel mit illegalen Substanzen / Waffen", 15)
return
::/hetze::
Suspend Permit
SendWPs("Hetze gegen den Staat", 20)
return
::/whetze::
Suspend Permit
SendWPs("Hetze gegen den Staat (in Verbindung mit Waffengewalt)", 40)
return
::/waffen::
Suspend Permit
SendWPs("Illegaler Waffenbesitz", 10)
return
::/isf::
::/ibs::
Suspend Permit
SendWPs("Illegaler Aufenthalt (San Fierro oder Bayside)", 15)
return
::/kv::
Suspend Permit
SendWPs("Körperverletzung", 15)
return
::/mord::
Suspend Permit
SendWPs("Mord", 35)
return
::/ntl::
Suspend Permit
SendWPs("Null-Toleranz-Liste (Beschuss auf Staatsbeamte)", 69)
return
::/pstörung::
Suspend Permit
SendWPs("Prüfungsstörung", 20)
return
::/psv::
Suspend Permit
SendWPs("Parken innerhalb eines permanenten Sperrgebietes", 40)
return
::/raubwp::
Suspend Permit
SendWPs("Raub", 20)
return
::/sachb::
Suspend Permit
SendWPs("Sachbeschädigung", 10)
return
::/gefährdung::
::/staatsgefährdung::
Suspend Permit
SendWPs("Staatsgefährdung", 61)
return
::/schießen::
Suspend Permit
SendWPs("Schießen in der Öffentlichkeit", 10)
return
::/lstvo::
Suspend Permit
SendWPs("Leichtes StVO-Vergehen", 9)
return
::/sstvo::
Suspend Permit
SendWPs("Schweres StVO-Vergehen", 10)
return
::/smord::
Suspend Permit
SendWPs("Serienmord", 40)
return
::/ticketv::
Suspend Permit
SendWPs("Ticketverweigerung", 10)
return
::/vmord::
Suspend Permit
SendWPs("Versuchter Mord", 25)
return
::/vertuschung::
Suspend Permit
SendWPs("Vertuschung (Werkstoffe oder Mord)", 15)
return
::/vertuschungd::
Suspend Permit
SendWPs("Vertuschung (Drogen)", 20)
return
::/werkstoffe::
::/materialien::
Suspend Permit
SendWPs("Werkstoffe (ab 100g, Eisen)", 15)
return
::/iwerben::
Suspend Permit
SendWPs("Werben für illegale Aktivitäten", 20)
return
::/dicewp::
Suspend Permit
SendWPs("Würfeln außerhalb des Casinos", 10)
return
::/wtransport::
Suspend Permit
SendWPs("Illegaler Waffentransport", 20)
return

;Ende der WPs
#If Tel AND pText AND active AND WinActive("ahk_group GTASA")
:?b0:/p::
Suspend Permit
WaitFor()
BindReplace(pText)
return
#If Tel AND hText AND active AND WinActive("ahk_group GTASA")
::/h::
Suspend Permit
BindReplace(hText)
WaitFor()
SendChat("/h")
return
#If Tel AND abText AND active AND WinActive("ahk_group GTASA")
::/ab::
Suspend Permit
SendChat("/p")
WaitFor()
BindReplace(abText)
WaitFor()
SendChat("/h")
return
#IfWinActive ahk_group GTASA

;Binds:
;Eigene Binds:
xBind1:
xBind2:
wBind1:
wBind2:
Bind1:
Bind2:
Bind3:
Bind4:
Bind5:
Bind6:
Bind7:
Bind8:
Bind9:
Bind10:
Bind11:
Bind12:
Bind13:
Bind14:
Bind15:
Bind16:
Bind17:
Bind18:
Bind19:
Bind20:
Bind21:
Bind22:
Bind23:
Bind24:
Bind25:
Bind26:
Bind27:
Bind28:
Bind29:
Bind30:
Bind31:
Bind32:
Bind33:
Bind34:
Bind35:
Bind36:
Bind37:
Bind38:
Bind39:
Bind40:
Bind41:
Bind42:
Bind43:
Bind44:
Bind45:
Bind46:
Bind47:
Bind48:
Bind49:
Bind50:
Bind51:
Bind52:
if(UseAPI AND (IsChatOpen() OR IsDialogOpen() OR IsMenuOpen())){
	SendHKey()
	return
}
BindReplace(%A_ThisLabel%)
return

hBind1:
hBind2:
hBind3:
hBind4:
hBind5:
hBind6:
hBind7:
hBind8:
hBind9:
hBind10:
hBind11:
hBind12:
hBind13:
hBind14:
hBind15:
hBind16:
hBind17:
hBind18:
hBind19:
hBind20:
hBind21:
hBind22:
hBind23:
hBind24:
hBind25:
hBind26:
Suspend Permit
BindReplace(%A_ThisLabel%)
return

;jBinds
jBind1:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 2)
	SendChat("/knastmember")
else if(Job = 3)
	SendChat("/bus")
else if(Job = 4)
	SendChat("/find")
else if(Job = 5)
	SendChat("/rob haus")
else if(Job = 6)
	SendChat("/stone")
else if(Job = 7)
	SendChat("/startfarm")
else if(Job = 8){
	if(jobvar := PlayerInput("Gib die Menge an Produkten ein, die du laden willst [1-2500]: "))
		SendChat("/buyprods " jobvar)
}
else if(Job = 9){
	if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "" AND (jobvar1 := PlayerInput("Gib den Preis fürs Reparieren ein: ")))
		SendChat("/repair car " jobvar " " jobvar1)
}
else if(Job = 10)
	SendChat("/startclean")
else if(Job = 11)
	SendChat("/filljob")
else if(Job = 12){
	if(jobvar := Trim(PlayerInput("Gib ein, was du reparieren willst (tzelle/haustuer): "))){
		jobvar1 := RegExMatch(jobvar, "tuer|tür|haus") ? "haustuer" : "tzelle"
		SendChat("/repair " jobvar1)
	}
}
else if(Job = 13){
	if(jobvar := PlayerInput("Gib den Fahrpreis ein: "))
		SendChat("/fare " jobvar)
}
else if(Job = 14)
    SendChat("/startfish")
else if(Job = 15)
    SendChat("/lawns")
else if(Job = 16)
    SendChat("/wood")
else if(Job = 17)
    SendChat("/hunt")
else if(Job = 18)
    SendChat("/starttrash")
else if(Job = 19)
    SendChat("/startpizza")
else if(Job = 20){
	if(jobvar := PlayerInput("Gib den Drogenbetrag ein: "))
		SendChat("/get drogen " jobvar)
}
else if(Job = 21)
    SendChat("/materials buy")
else if(Job = 22)
    SendChat("/foodload")
return
jBind2:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 2){
	if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "")
		SendChat("/free " jobvar)
}
else if(Job = 3)
	SendChat("/route")
else if(Job = 4){
	if(jobvar := PlayerInput("Gib die ID des Fahrzeuges ein, das du suchen willst (/vehicles): "))
		SendChat("/findcar " jobvar)
}
else if(Job = 5)
	SendChat("/rob person")
else if(Job = 6)
	SendChat("/takestone")
else if(Job = 7){
	if(jobvar := PlayerInput("Gib die Menge an Getreide an, die du einladen willst (25/50/75/100): "))
		SendChat("/cornload " jobvar)
}
else if(Job = 8)
	SendChat("/sellprods")
else if(Job = 9)
	SendChat("/get kanister")
else if(Job = 10)
	SendChat("/clean")
else if(Job = 11)
	SendChat("/fillstation")
else if(Job = 12)
    SendChat("/tzelle")
else if(Job = 13){
	if(jobvar := PlayerInput("Gib die ID des Fahrgastes ein: "))
		SendChat("/startfare " jobvar)
}
else if(Job = 14)
    SendChat("/trackfish")
else if(Job = 15)
    SendChat("/getgras")
else if(Job = 16)
    SendChat("/takewood")
else if(Job = 17)
    SendChat("/trackhunt")
else if(Job = 18)
    SendChat("/empty")
else if(Job = 19)
    SendChat("/getpizza")
else if(Job = 20){
	if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "" AND (jobvar1 := PlayerInput("Gib die Menge an Drogen ein: ")) AND (jobvar2 := PlayerInput("Gib den Preis für die Drogen ein: ")))
		SendChat("/sellhand " jobvar " " jobvar1 " " jobvar2)
}
else if(Job = 21)
    SendChat("/materials deliver")
else if(Job = 22)
    SendChat("/releasefood")
return
jBind3:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 2){
	if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "")
		SendChat("/checkjailtime " jobvar)
}
else if(Job = 3)
    SendChat("/buslock")
else if(Job = 5)
	SendChat("/rob vehicle")
else if(Job = 6)
    SendChat("/deliverstone")
else if(Job = 7)
	SendChat("/releasecorn")
else if(Job = 8)
	SendChat("/load")
else if(Job = 9)
    SendChat("/get werkzeug")
else if(Job = 10)
	SendChat("/stopclean")
else if(Job = 12)
	SendChat("/atminfo")
else if(Job = 13)
    SendChat("/fare")
else if(Job = 14)
    SendChat("/catchfish")
else if(Job = 15)
    SendChat("/unloadgras")
else if(Job = 16)
    SendChat("/deliverwood")
else if(Job = 17)
    SendChat("/takehunt")
else if(Job = 18)
    SendChat("/unloadtrash")
else if(Job = 19)
    SendChat("/delivery")
else if(Job = 20)
    SendChat("/crackload")
else if(Job = 21){
	if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "")
		SendChat("/sellgun " jobvar)
}
return
jBind4:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 3)
    SendChat("/delbus")
else if(Job = 5)
	SendChat("/printkey")
else if(Job = 6)
    SendChat("/stopstone")
else if(Job = 7)
	SendChat("/pinfo")
else if(Job = 8)
    SendChat("/prodinfo")
else if(Job = 9){
	if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "" AND (jobvar1 := PlayerInput("Gib den Preis fürs Auffüllen ein: ")))
		SendChat("/refill " jobvar " " jobvar1)
}
else if(Job = 12){
    if(Trim(jobvar := PlayerInput("Gib die ID der Telefonzelle ein: ")))
        SendChat("/marktz " jobvar)
}
else if(Job = 13)
    SendChat("/accept taxi")
else if(Job = 14)
    SendChat("/unloadfish")
else if(Job = 15)
    SendChat("stopgras")
else if(Job = 16)
    SendChat("/stopwood")
else if(Job = 17)
    SendChat("/deliverhunt")
else if(Job = 18)
    SendChat("/stoptrash")
else if(Job = 19)
    SendChat("/unloadpizza")
else if(Job = 20)
    SendChat("/releasecrack")
return
jBind5:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 6)
    SendChat("/startgeterz")
else if(Job = 9){
    if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "" AND (jobvar1 := PlayerInput("Gib den Preis für den Reifenwechsel ein: ")))
		SendChat("/tirechange " jobvar " " jobvar1)
}
else if(Job = 12){
    if(Trim(jobvar := PlayerInput("Gib die ID des ATM ein: ")))
        SendChat("/markatm " jobvar)
}
else if(Job = 13)
    SendChat("/cancel taxi")
else if(Job = 14)
    SendChat("/stopfish")
else if(Job = 17)
    SendChat("/stophunt")
else if(Job = 18)
    SendChat("/gettrash")
else if(Job = 19)
    SendChat("/stoppizza")
return
jBind6:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 6)
    SendChat("/stopgeterz")
else if(Job = 9)
    SendChat("/mduty")
else if(Job = 12)
    SendChat("/get ersatzteil")
return
jBind7:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 6){
	if(jobvar := PlayerInput("Gib die Menge an Erz an, die du einladen willst (50/100/150/200): "))
		SendChat("/erzload " jobvar)
}
else if(Job = 9){
    if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")) != "" AND (jobvar1 := PlayerInput("Gib den Preis für die Lackierung ein: ")))
		SendChat("/respray " jobvar " " jobvar1)
}
return
jBind8:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 6)
    SendChat("/releaseerz")
else if(Job = 9)
    SendChat("/respraycolor")
return
jBind9:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(Job = 6)
    SendChat("/einfo")
else if(Job = 9){
    if(Trim(jobvar := PlayerInput("Gib die ID des Spielers ein: ")))
		SendChat("/showcolors " jobvar)
}
return

;fBinds
fBind1:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1)){
	SendChat("/duty")
	chat := WaitForChatLine(0, " nimmt seine Marke aus dem Spint.")
	if(chat){
		BindReplace("/takku~/equip")
		WaitFor()
		SendInput, {enter}
	}
}
else if(IsFrak(3, 1)){
	SendChat("/duty")
	chat := WaitForChatLine(0, "Du befindest dich nun|Du bist nicht am Dutypunkt in", 1,, 1)
	if(InStr(chat, "Du befindest dich nun im Dienst."))
		BindReplace("/equip~/takku~/r " FrakOption%FrakOption6% " «« Status 1 »» Einsatzbereit über Funk ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 1")
	else if(InStr(chat, "Du bist nicht am Dutypunkt in Los Santos oder San Fierro."))
		BindReplace("/r " FrakOption%FrakOption6% " «« Status 1 »» Einsatzbereit über Funk ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 1")
	else if(InStr(chat, "Du befindest dich nun nicht mehr im Dienst."))
		BindReplace("/r " FrakOption%FrakOption6% " «« Status 6 »» Nicht Einsatzbereit ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 6")
}
else if(IsFrak(4, 1))
	BindReplace("/getbizflag~/dropbizflag~/gangflag")
else if(IsFrak(5, 1))
	SendChat("/use lsd")
else if(IsFrak(6, 1))
	SendChat("/oos Yakuza | Spielst du mit uns, spielst du mit dem Tod!")
else if(IsFrak(7, 1))
	SendChat("/equip")
else if(IsFrak(8, 1))
	BindReplace("/duty~/equip")
else if(IsFrak(9, 1))
	SendChat("/use gold")
else if(IsFrak(10, 1))
	BindReplace("/dropbizflag~/getbizflag~/getflagpos")
else if(IsFrak(11, 1))
	BindReplace("/m [»»» Federal Bureau of Investigation im Einsatz «««~/m [»»» Machen Sie unverzüglich den Weg frei! «««")
else if(IsFrak(12, 1))
	BindReplace("/dropbizflag~/getbizflag~/getflagpos")
return
fBind2:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	SendChat("/use donut")
else if(IsFrak(3, 1)){
	SendChat("/accept medic")
	WaitFor()
	GetChatLine(0, chat)
	if(!InStr(chat, "Niemand benötigt einen Krankenwagen.")){
		chat := WaitForChatLine(0, " angenommen, du hast 5min um zum Marker zufahren.",, 45)
		if (!chat)
			return
		RegExMatch(chat, "U)Du hast den Notruf von (.*) angenommen, du hast 5min um zum Marker zufahren.", chat)
		BindReplace("/r " FrakOption%FrakOption6% " «« Status 3 »» Einsatz" (chat1 ? " von " chat1 : "") " angenommen ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 3")
	}
}
else if(IsFrak(4, 1))
	BindReplace("/mv~/oldmv")
else if(IsFrak(5, 1))
	SendChat("/use gold")
else if(IsFrak(6, 1))
	SendChat("Yakuza | Wir sehen, wir kommen, wir töten, wir gehen! | Yakuza")
else if(IsFrak(7, 1))
	SendChat("/use gold")
else if(IsFrak(8, 1))
	SendChat("/aufzug")
else if(IsFrak(9, 1))
	SendChat("/use green")
else if(IsFrak(10, 1))
	BindReplace("/s LV²² | Überfall! Bleib sofort stehen!~/s LV²² | Geld her dann passiert dir nichts!")
else if(IsFrak(11, 1))
	BindReplace("/m [»»» Federal Bureau of Investigation «««~/m [» Fahren Sie an den Straßenrand und folgen den Anweisungen «")
else if(IsFrak(12, 1))
	BindReplace("/s Scarfo Family >|< Überfall >|< Halt sofort an, Puta Madre")
return
fBind3:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	SendChat("/checkwanted " PlayerInput("Gib die ID des Spielers ein: "))
else if(IsFrak(3, 1))
	BindReplace("/r " FrakOption%FrakOption6% " «« Status 4 »» Am Einsatzort angekommen ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 4")
else if(IsFrak(4, 1))
	SendChat("/use green")
else if(IsFrak(5, 1))
	SendChat("/use green")
else if(IsFrak(6, 1))
	BindReplace("/s Yakuza | »» Überfall «« /handsup & Kohle her! | Yakuza~/oos /pay " GetPlayerId() " [Betrag]~/s Gib mir sofort deine ganze Kohle~/s Sonst rollt dein Kopf die Straße entlang")
else if(IsFrak(7, 1))
	SendChat("/use lsd")
else if(IsFrak(8, 1))
	SendChat("/lottoinfo")
else if(IsFrak(9, 1))
	SendChat("/equip")
else if(IsFrak(10, 1))
	SendChat("/ad LV²² | Mobiler Tequilaverkäufer on Tour | LV²² Call/SMS")
else if(IsFrak(11, 1))
	BindReplace("/m [»»» Drug Enforcement Administration «««~/m [» Person- und Güterkontrolle im Bezug auf Drogenkriminalität «~/m [» Fahren Sie an den Straßenrand und folgen den Anweisungen «")
else if(IsFrak(12, 1))
	SendChat("/gangflag")
return
fBind4:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	BindReplace("/m [SA:PD] Fahren Sie rechts ran und stellen Sie den Motor ab.~/m Warten Sie auf weitere Anweisungen der Beamten! [SA:PD]")
else if(IsFrak(3, 1)){
	SendChat("/revive")
	WaitFor()
	GetChatLine(0, chat1)
	GetChatLine(2, chat2)
	if(!InStr(chat1, "Du bist bei keiner Leiche") && !InStr(chat1, "Begib dich zur Verwaltung und gib /get medizin ein") && !InStr(chat1, "Du bist schon dabei einen toten Spieler zu reanimieren!"))
	    if(InStr(chat2, "Die Person wird nicht hier spawnen, da sie AFK ist oder eine CP-Strafe hat"))
	        SendChat("/ame »» Spieler AFK oder Checkpointstrafe ««")
	    else
	        SendChat("/ame »» im Revive ««")
    if(RegExMatch(chat1, "INFO: Nach der Reanimation hast du noch ([0-9.]+) Medikamente\.", regex)){
        if(StrReplace(regex1, ".") <= 10)
            AddChatMessage("Du solltest demnächst das Krankenhaus aufsuchen und deine Medikamente aufstocken.")
    }
}
else if(IsFrak(4, 1))
    SendChat("/use gold")
else if(IsFrak(5, 1))
	SendChat("/equip")
else if(IsFrak(6, 1)){
	SendChat("/nummer " Nickname)
	chat := WaitForChatLine(0, ", Ph: ")
	if(!RegExMatch(chat, "U)Name: .*, Ph: (\d+)$", chat) OR !chat1)
		chat1 := "me"
	BindReplace("Yakuza - feinste Ware aus dem fernen Osten~Du brauchst was? /call " chat1 " | Yakuza~Nur bei mir, einfach aufsteigen~Munition der Klasse 1 & Klasse 2.~Waffen der Klasse 1 & Klasse 2.")
}
else if(IsFrak(7, 1))
	SendChat("/gangflag")
else if(IsFrak(8, 1))
	SendChat("/use donut")
else if(IsFrak(9, 1))
	SendChat("/use lsd")
else if(IsFrak(10, 1))
	SendChat("/gangflag")
else if(IsFrak(11, 1))
	BindReplace("/s » Federal Bureau of Investigation «~/s Stehen bleiben und Hände hoch~/oos Befehl: /handsup")
else if(IsFrak(12, 1))
	SendChat("/use lsd")
return
fBind5:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	BindReplace("/m »»»» Polizeieinsatz ««««~/m Bitte machen Sie den Weg frei und ermöglichen die Durchfahrt!")
else if(IsFrak(3, 1))
	BindReplace("/m SARD | ACHTUNG: Dienstfahrzeug im Einsatz!!~/m SARD | Bitte räumen Sie die Straße frei!!")
else if(IsFrak(4, 1))
    SendChat("/use lsd")
else if(IsFrak(5, 1))
	BindReplace("/s | LCN | Sofort stehen bleiben!~/s »» Dann passiert dir auch nichts! ««")
else if(IsFrak(6, 1))
	SendChat("/materials buildgun")
else if(IsFrak(7, 1))
	SendChat("/swapgun")
else if(IsFrak(8, 1))
	SendChat("/breaklive")
else if(IsFrak(9, 1))
	SendChat("/gangfight")
else if(IsFrak(10, 1))
	SendChat("/use lsd")
else if(IsFrak(12, 1))
	SendChat("/use gold")
return
fBind6:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	BindReplace("/m [SA:PD] Fahren Sie sofort rechts ran und stellen Sie den Motor ab.~/m Steigen Sie aus und legen sich auf den Boden!~/m Sollten Sie Widerstand leisten, wird dies Folgen haben! [SA:PD]~/oos /verletzt")
else if(IsFrak(3, 1))
	BindReplace("/m SARD | ACHTUNG: Rettungshelikopter startet / landet!!~/m SARD | Bitte räumen Sie die Landefläche frei!!")
else if(IsFrak(4, 1)){
	SendChat("/kcheck")
	WaitFor()
	Sleep, 50
	SendInput, {enter}{down 2}{enter}
	WaitFor()
	Sleep, 50
	SendInput, {down}{enter}
	WaitFor()
	Sleep, 50
	SendInput, 6{enter}
}
else if(IsFrak(5, 1))
	SendChat("/gangflag")
else if(IsFrak(6, 1))
	SendChat("/materials buildammo")
else if(IsFrak(7, 1))
	BindReplace("/s » Grove Street » ÜBERFALL « Grove Street «~/s Sofort aussteigen!~/s Sonst gibt es Stress!~/s » Grove Street » ÜBERFALL « Grove Street «")
else if(IsFrak(9, 1))
	SendChat("/gangflag")
else if(IsFrak(10, 1))
	SendChat("/use gold")
else if(IsFrak(12, 1))
	SendChat("/fpkeep wasser")
return
fBind7:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	BindReplace("/s Stehenbleiben, Sie sind verhaftet!~/s Legen Sie sich auf den Boden (/verletzt)!")
else if(IsFrak(3, 1))
	BindReplace("/m SARD | ACHTUNG: Castor-Transport!!~/m SARD | Bitte halten Sie die Straße frei!!~/m SARD | Bei Entfernung unterhalb von 100m erfolgt Schussfreigabe!!")
else if(IsFrak(5, 1))
	BindReplace("/me ______________________________________~/me flüstert zu dir: Pizza Calzone | 25$~/me flüstert zu dir: Pizza Tonno | 29$~/me flüstert zu dir: Pizza Margarita | 21$~/me flüstert zu dir: Speziale Pizza | Zivi --> 750$~/me flüstert zu dir: Speziale Pizza | Fraktion --> 1000$~/me ______________________________________")
else if(IsFrak(6, 1))
	SendChat("/materials getgun")
else if(IsFrak(7, 1))
	SendChat("† We come we kill we go no one has seen it so it does a Nigga from GroveStreet †")
else if(IsFrak(9, 1))
	SendChat("/gangwar")
else if(IsFrak(10, 1))
	SendChat("/fpkeep wasser")
else if(IsFrak(12, 1))
	SendChat("/fpkeep dueng")
return
fBind8:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	SendChat("/swapgun")
else if(IsFrak(3, 1))
	BindReplace("SARD | Willkommen zurück im Leben~SARD | Bitte passen Sie das nächste mal besser auf~SARD | Der SARD wünscht Ihnen noch einen schönen Tag :)")
else if(IsFrak(6, 1))
	SendChat("/materials getammo")
else if(IsFrak(7, 1))
	BindReplace("† When we come, stand at attention. When we stand before you, go on your knees.~When we speak, be quiet. This is the Grove Street mother fucker †")
else if(IsFrak(9, 1))
	SendChat("/s † Don't fuck with the Ballas Family or we'll fuck your life †")
else if(IsFrak(10, 1))
	SendChat("/fpkeep dueng")
else if(IsFrak(12, 1))
	SendChat("/swapgun")
return
fBind9:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	BindReplace("/mv~/oldmv~/towopen")
else if(IsFrak(3, 1))
	BindReplace("/r " FrakOption%FrakOption6% " «« Status 6 »» Nicht Einsatzbereit ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 6")
else if(IsFrak(6, 1))
	SendChat("/sellgun " PlayerInput("Gib den Namen oder die ID des Spielers ein: "))
else if(IsFrak(7, 1))
	SendChat("† Grove Street | If you fuck with one of us, you fuck with all of us | Grove Street †")
else if(IsFrak(9, 1))
	SendChat("/s Wir kommen wir sehen wir töten wir gehen | Saint Jefferson Ballas Family")
else if(IsFrak(10, 1))
	SendChat("/swapgun")
else if(IsFrak(12, 1))
	SendChat("/bl")
return
fBind10:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1))
	SendChat("/me funkt zur Zentrale")
else if(IsFrak(3, 1))
	BindReplace("/cancel revive~/ame »» Revive abgebrochen ««")
else if(IsFrak(9, 1))
	SendChat("/s Are you kidding me? I'm kidding your life motherfucka!")
else if(IsFrak(10, 1))
	SendChat("/bl")
return
fBind11:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1)){
	SendChat("/wanted")
	if(UseAPI){
		while(!IsDialogOpen() AND A_Index < 60)
			Sleep, 10
		if(!IsDialogOpen())
			return
	}
	else{
		WaitFor()
		Sleep, 20
	}
	SendInput, {down 9}{enter}
}
else if(IsFrak(3, 1)){
	FrakOption6 := Mod(FrakOption6, 5) + 1
	;FrakOption4 := FrakOption3 >= 2 ? 1 : FrakOption3 + 1
	IniWrite, %FrakOption6%, %INIFile%, Settings, FrakOption6
	GuiControl, FrakGUI:, Funkrufnummer %FrakOption6%, 1
	AddChatMessage("Von nun an wird {88AA62}Funkrufnummer " FrakOption6 "{FFFFFF} ({00AA00}" FrakOption%FrakOption6% "{FFFFFF}) genutzt.")
}
return
fBind12:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1)){
	SendChat("/wanted")
	if(UseAPI){
		while(!IsDialogOpen() AND A_Index < 60)
			Sleep, 10
		if(!IsDialogOpen())
			return
	}
	else{
		WaitFor()
		Sleep, 20
	}
	SendInput, {down 8}{enter}
}
else if(IsFrak(3, 1))
	BindReplace("/r " FrakOption%FrakOption6% " «« Status 3 »» Brandeinsatz angenommen ««~/frn " RegExReplace(FrakOption%FrakOption6%, "[/\-]") " 3")
return
fBind13:
if(UseAPI AND IsChatOpen() OR IsDialogOpen() OR IsMenuOpen()){
	SendHKey()
	return
}
if(IsFrak(2, 1)){
    SendChat("/accept cop")
	WaitFor()
	GetChatLine(0, chat)
	if(!InStr(chat, "Niemand benötigt einen Streifenwagen.")){
		chat := WaitForChatLine(0, "Du hast den Einsatz von ",, 45)
		if (!chat)
			return
		RegExMatch(chat, "U)Du hast den Einsatz von (.*) angenommen \(Ort: (.*)\)\.", chat)
		BindReplace("/r » Code 5 - Notruf " (chat1 ? " von " chat1 : "") " angenommen (Ort: " chat2 ") «")
	}
}
return
/*
ö::
AddChatMessage(IsChatOpen())
return

/*
*::
arr := NextNovaLocation()
AddChatMessage(arr["Name"] " -> " arr["Distance"] "m")
return

.::
GetPlayerPosition(x, y, z)
FileAppend, % (n := PlayerInput("Gib den Namen des Ortes ein: ")) "|" Round(x) "|" Round(y) "|" Round(z) "|1,", Locations.txt
AddChatMessage(n " wurde erfolgreich gespeichert")
AddChatMessage(Round(x) ", " Round(y) ", " Round(z))
return