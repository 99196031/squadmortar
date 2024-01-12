#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GDIPlus.au3>

Global $hBrowser = ""

Func createGUI()
	Local $hGUIWidth = 560
	Local $hGUIHeight = 300
	Local $sVersion = FileRead(@ScriptDir & "\VERSION.txt")
	$hGUI = GUICreate("Auto SquadMortar " & $sVersion, $hGUIWidth, $hGUIHeight, -1, -1, $WS_SYSMENU + $WS_MINIMIZEBOX)
	GUISetOnEvent($GUI_EVENT_CLOSE, "exitScript")
	GUISetBkColor(0x202225)
	$iLog = GUICtrlCreateEdit("", 10, 10, $hGUIWidth - 25, $hGUIHeight - 115, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL, $ES_READONLY))
	GUICtrlSetBkColor($iLog, 0x000000)
	GUICtrlSetFont($iLog, 9, 400, 0, "Arial")
	GUICtrlSetColor($iLog, 0xF7FF01)
	loadDataLog($iLog)

	Local $buttonWidth = ($hGUIWidth - 45) / 3
	Local $buttonHeight = 30

	GUICtrlCreateButton("Open SquadMortar Site", 10, $hGUIHeight - 100, $hGUIWidth - 25, $buttonHeight)
	GUICtrlSetOnEvent(-1, "eventButtonOpenHTMLFileClick")

	GUICtrlCreateButton("Discord", 10, $hGUIHeight - 65, $buttonWidth, $buttonHeight)
	GUICtrlSetOnEvent(-1, "eventButtonDiscordClick")

	GUICtrlCreateButton("Github", 20 + $buttonWidth, $hGUIHeight - 65, $buttonWidth, $buttonHeight)
	GUICtrlSetOnEvent(-1, "eventButtonGithubClick")

	GUICtrlCreateButton("Check Update", 30 + $buttonWidth * 2, $hGUIHeight - 65, $buttonWidth, $buttonHeight)
	GUICtrlSetOnEvent(-1, "eventButtonUpdateClick")

	GUISetState(@SW_SHOW)
EndFunc   ;==>createGUI


Func exitScript()
	ControlSend("Squad", "", "", "{a Up}")
	ControlSend("Squad", "", "", "{d Up}")
	ControlSend("Squad", "", "", "{w Up}")
	ControlSend("Squad", "", "", "{s Up}")
	ControlSend("Squad", "", "", "{i Up}")
	ControlSend("Squad", "", "", "{r Up}")
	ControlSend("Squad", "", "", "{o Up}")
	If ProcessExists("squadMortarServerSilent.exe") Then
		ProcessClose("squadMortarServerSilent.exe")
	EndIf
	_GDIPlus_Shutdown()
	Exit
EndFunc   ;==>exitScript

Func customConsole($iComponent, $sText, $bAppend = False)
	If $bAppend Then
		$sText = $sText & "	"
	Else
		$sText = $sText & @CRLF
	EndIf
	GUICtrlSetData($iComponent, $sText, 1)
EndFunc   ;==>customConsole


Func loadDataLog($iLogData)
	Sleep(100)
	GUICtrlSetData($iLogData, "")

	If WinExists("SquadGame") == 1 Then
		Local $aWinPos = WinGetClientSize("SquadGame")
		Eval("i" & $aWinPos[0] & "x" & $aWinPos[1])
		If Not @error Then
			customConsole($iLogData, "Size of game is correct :" & $aWinPos[0] & "x" & $aWinPos[1] & ".")
		Else
			customConsole($iLogData, "Size of game is incorrect correct: 1024x768, 1920x1080, 2560x1440, 3840x1600")
			customConsole($iLogData, "Your size is: " & $aWinPos[0] & "x" & $aWinPos[1] & ".")
			customConsole($iLogData, "Restart Auto SquadMortar once the issue is resolved.")
			customConsole($iLogData, "Usual Causes: Setting -> Display -> Scale & Layout put on 100% to fix ")
		EndIf
	Else
		customConsole($iLogData, "Squad not Active")
		customConsole($iLogData, "Restart Auto SquadMortar once the issue is resolved.")
	EndIf
	customConsole($iLogData, "")
	customConsole($iLogData, "Set in Squad following options:")
	customConsole($iLogData, "  • CONTROLS -> INFANTRY -> FIRE/USE -> ALTERNATIVE = O")
	customConsole($iLogData, "  • CONTROLS -> INFANTRY -> AIM DOWN SIGHTS -> ALTERNATIVE = P")
	customConsole($iLogData, "")
	customConsole($iLogData, "If you intend to use sync targets and sync map:") ;
	customConsole($iLogData, "  • If you have only one monitor, play at 1024x768 in windowed mode.")
	customConsole($iLogData, "  • If you have two or more monitors, play at all other resolutions in fullscreen or")
	customConsole($iLogData, "    borderless mode.")
	customConsole($iLogData, "")
	customConsole($iLogData, "If you wish to use only sync map:")
	customConsole($iLogData, "  • Play all supported resolutions, with 1024x768 in windowed mode and all other resolutions")
	customConsole($iLogData, "    in fullscreen or borderless mode.")
	customConsole($iLogData, "  • If you have only one monitor, use the sync map active squad.")
	customConsole($iLogData, "")
	customConsole($iLogData, "Notes:")
	customConsole($iLogData, "  • Squad MUST be visible (It can't be covered).")
	customConsole($iLogData, "  • Sync Targets only works with Standard Mortar.")
	customConsole($iLogData, "  • To activate the Sync Target Feature you need to be in a mortar and be in aiming mode.")
	customConsole($iLogData, "  • Hotkey '.' as DOT to switch fast between Squad and the Website")
	customConsole($iLogData, "")
	customConsole($iLogData, "Optional Improvements:")
	customConsole($iLogData, "  • Tab -> Right site of screen -> Map Icon Scale 0.3")
	customConsole($iLogData, "  • Tab -> Right site of screen -> Grid Opacity 0", True)
EndFunc   ;==>loadDataLog

Func eventButtonUpdateClick()
	Local $sVersion = FileRead(@ScriptDir & "\VERSION.txt")
	Local $dData = InetRead("https://raw.githubusercontent.com/Devil4ngle/squadmortar/release/VERSION.txt")
	$sRemoteVersion = BinaryToString($dData)
	If $sVersion == $sRemoteVersion Then
		MsgBox($MB_OK, "Up to date", "Your script is up to date.")
	Else
		ShellExecute("scripts\update.bat")
		exitScript()
	EndIf
EndFunc   ;==>eventButtonUpdateClick

Func eventButtonGithubClick()
	ShellExecute("https://github.com/Devil4ngle/squadmortar")
EndFunc   ;==>eventButtonGithubClick

Func eventButtonDiscordClick()
	ShellExecute("https://discord.gg/ghrksNETNA")
EndFunc   ;==>eventButtonDiscordClick

Func eventButtonOpenHTMLFileClick()
	ShellExecute("http://localhost:3000/", "", @ScriptDir, "open")
	Sleep(200)
	$hBrowser = WinGetHandle("[active]")
EndFunc   ;==>eventButtonOpenHTMLFileClick
