#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ScreenCapture.au3>
#include "../autoit_libraries/common.au3"

; Enables GUI events
Opt("GUIOnEventMode", 1)
; Disable Caps for better background
Opt("SendCapslockMode", 0)
; Set window Mode for PixelSearch
Opt("PixelCoordMode", 0)
; Set window Mode for MouseClick
Opt("MouseCoordMode", 0)

Global $hWnd = WinGetHandle("SquadGame")
setCoordinates()
Local $sImageName0 = $CmdLine[1]
Local $sImageName1 = $CmdLine[2]
Local $bActiveSquadOnMapSync = $CmdLine[3]


If $bActiveSquadOnMapSync == 1 Then
	WinActivate("SquadGame")
	Sleep(500)
EndIf

PixelSearch($aCoordinates[$iResolution][$iIsMapActive][0], $aCoordinates[$iResolution][$iIsMapActive][1], $aCoordinates[$iResolution][$iIsMapActive][2], $aCoordinates[$iResolution][$iIsMapActive][3], "0xFFFFFF", 0, 1, $hWnd)
If @error Then
	ControlSend("SquadGame", "", "", "{m}")
	Sleep(300)
EndIf
_MouseWheelPlus("SquadGame", "down", 30)
Sleep(600)
Local $hHBitmap = _ScreenCapture_CaptureWnd("", "SquadGame", $aCoordinates[$iResolution][$iMapCoordinates][0], $aCoordinates[$iResolution][$iMapCoordinates][1], $aCoordinates[$iResolution][$iMapCoordinates][2], $aCoordinates[$iResolution][$iMapCoordinates][3], False)
_ScreenCapture_SaveImage("runtime/screenshot.jpg", $hHBitmap)
RunWait("./scripts/imageLayeringSilent runtime/screenshot.jpg frontend/public/" & $sImageName0 & " frontend/public/merged/" & $sImageName1)

Exit(0)
