#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=resources\icon.ico
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include "autoit_libraries/UWPOCR.au3"
#include "autoit_libraries/common.au3"
#include "autoit_libraries/GUI.au3"
#include "autoit_libraries/mp.au3"
#include <Constants.au3>


; Enables GUI events
Opt("GUIOnEventMode", 1)
; Disable Caps for better background
Opt("SendCapslockMode", 0)
; Set window Mode for PixelSearch
Opt("PixelCoordMode", 0)
; Set window Mode for MouseClick
Opt("MouseCoordMode", 0)

_MP_Init()
Global $oData = _MP_SharedData()
Global $aCoordinatesRange[0]
Global $aCoordinatesAngle[0]
Global $hWnd = WinGetHandle("SquadGame")

_GDIPlus_Startup()
setCoordinates()

If _MP_IsMain() Then
	main()
Else
	angleMortar()
EndIf

Func main()
	HotKeySet(".", "switchWindow")
	createGUI()
	Run("scripts/squadMortarServerSilent.exe")
	If WinExists("SquadGame") == 1 Then
		DirRemove("frontend/public/merged", 1)
		DirCreate("frontend/public/merged")
		DirRemove("runtime", 1)
		DirCreate("runtime")
		runSquadMortar()
	Else
		While 1
			Sleep(1000)
		WEnd
	EndIf
EndFunc   ;==>main

Func runSquadMortar()
	While True
		Sleep(1000)
		syncCoordinates()
		If isMortarNotActive() Then
			Sleep(1000)
			ContinueLoop
		EndIf
		For $i = 0 To UBound($aCoordinatesRange) - 1
			;ConsoleWrite('Range from sync  ' & $aCoordinatesRange[$i] & @CRLF)
			;ConsoleWrite('Angle from sync ' & $aCoordinatesAngle[$i] & @CRLF)
			If syncExitLoop(False) Then ExitLoop
			$oData.fAngle = $aCoordinatesAngle[$i]
			_MP_Fork()
			Local $bSuccess = rangeMortar($i)
			_MP_WaitAll()
			If syncExitLoop() Then ExitLoop
			If $bSuccess Then
				cSend(20, 1770, "o")
				cSend(20, 1770, "o")
				cSend(20, 10, "o")
				cSend(0, 3100, "r")
				cSend(0, 0, "p")
			Else
				ExitLoop
			EndIf
		Next
	WEnd
EndFunc   ;==>runSquadMortar

Func angleMortar()
	$fAngle = $oData.fAngle
	Local $hTime = TimerInit()
	Do
		If isMortarNotActive() Then
			Return
		EndIf
		$fAngleOcr = Number(getOCRAngle(), 3)
		If Not @error And $fAngleOcr > 0 And $fAngleOcr < 360 Then
			If $fAngleOcr == $fAngle Then
				ExitLoop
			EndIf
			Local $fTimes
			Local $fDiff = $fAngle - $fAngleOcr
			If $fDiff < -180 Then $fDiff += 360
			If $fDiff > 180 Then $fDiff -= 360
			If $fDiff > 0 Then
				$fTimes = $fDiff
				$sKey = "d"
			Else
				$fTimes = -$fDiff
				$sKey = "a"
			EndIf
			cSend($fTimes * 19.78, 200, $sKey)

			$fAngleOcr = Number(getOCRAngle(), 3)
			;ConsoleWrite($fAngleOcr & " OCR Coordinates" & @CRLF)
			;ConsoleWrite($fAngle & " Actual Coordinates" & @CRLF)
			Local $fDiff = $fAngle - $fAngleOcr
			Local $bCorrection = False
			If $fDiff < -180 Then $fDiff += 360
			If $fDiff > 180 Then $fDiff -= 360
			If $fDiff > 0 Then
				If $fDiff > 0.49 Then
					$bCorrection = True
					If $fDiff > 0.85 Then
						$fTimes = 3
					Else
						$fTimes = 0
					EndIf
					$sKey = "d"
				EndIf
			Else
				If - $fDiff > 0.49 Then
					$bCorrection = True
					If - $fDiff > 0.85 Then
						$fTimes = 3
					Else
						$fTimes = 0
					EndIf
					$sKey = "a"
				EndIf
			EndIf
			If $bCorrection Then
				cSend($fTimes, 0, $sKey)
			EndIf
			ExitLoop
		EndIf
		cSend(0, 0, "d")
	Until 5000 < TimerDiff($hTime)
EndFunc   ;==>angleMortar

Func rangeMortar($i)
	Local $hTime = TimerInit()
	Do
		If isMortarNotActive() Then
			Return False
		EndIf
		$iRangeOcr = Number(getOCRRange())
		If Not @error And $iRangeOcr > 809 And $iRangeOcr < 1581 Then
			If $iRangeOcr == $aCoordinatesRange[$i] Then
				Return True
			EndIf
			Local $fTimes
			If $iRangeOcr < $aCoordinatesRange[$i] Then
				$fTimes = ($aCoordinatesRange[$i] - $iRangeOcr) / 10
				$sKey = "w"
			EndIf
			If $iRangeOcr > $aCoordinatesRange[$i] Then
				$fTimes = ($iRangeOcr - $aCoordinatesRange[$i]) / 10
				$sKey = "s"
			EndIf
			cSend($fTimes * 62.5, 0, $sKey)
			Return True
		EndIf
		cSend(0, 0, "w")
	Until 5000 < TimerDiff($hTime)
	Return False
EndFunc   ;==>rangeMortar

Func isMortarNotActive()
	PixelSearch(100, 100, 100, 100, "0x000000", 0, 1, $hWnd)
	If @error Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>isMortarNotActive

Func syncExitLoop($bWithPixelSearch = True)
	If $bWithPixelSearch Then
		If isMortarNotActive() Then
			Return True
		EndIf
	EndIf
	$aCoordinatesAngleCopy = $aCoordinatesAngle
	$aCoordinatesRangeCopy = $aCoordinatesRange
	syncCoordinates()
	If Not arrayCompare($aCoordinatesAngleCopy, $aCoordinatesAngle) Or Not arrayCompare($aCoordinatesRangeCopy, $aCoordinatesRange) Then
		Return True
	EndIf
	Return False
EndFunc   ;==>syncExitLoop

Func getOCRRange()
	Local $hHBitmap = _ScreenCapture_CaptureWnd("", "SquadGame", $aCoordinates[$iResolution][$iMortarRangeOcr][0], $aCoordinates[$iResolution][$iMortarRangeOcr][1], $aCoordinates[$iResolution][$iMortarRangeOcr][2], $aCoordinates[$iResolution][$iMortarRangeOcr][3], False)
	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
	Local $aDim = _GDIPlus_ImageGetDimension($hBitmap)
	If @error Then
		Return 0
	EndIf
	$hBitmap = _GDIPlus_ImageResize($hBitmap, $aDim[0] * 2, $aDim[1] * 2)
	Local $hEffect = _GDIPlus_EffectCreateColorBalance(65, 65, 65)
	_GDIPlus_BitmapApplyEffect($hBitmap, $hEffect)
	Local $hEffect = _GDIPlus_EffectCreateSharpen(255, 50)
	_GDIPlus_BitmapApplyEffect($hBitmap, $hEffect)
	Local $iWidth = _GDIPlus_ImageGetWidth($hBitmap)
	Local $iHeight = _GDIPlus_ImageGetHeight($hBitmap)
	Local $iIncrease = $iWidth * 2
	Local $hBitmapBuffered = _GDIPlus_BitmapCreateFromScan0($iWidth + $iIncrease, $iHeight + $iIncrease)
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmapBuffered)
	_GDIPlus_GraphicsClear($hGraphics, 0xFFFFFFFF)
	_GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, $iIncrease / 2, $iIncrease / 2, $iWidth, $iHeight)
	Local $sOCRTextResult = _UWPOCR_GetText($hBitmapBuffered, Default, True)

	;ConsoleWrite("OCR RANGE: " & $sOCRTextResult & @CRLF)
	;_GDIPlus_ImageSaveToFile($hBitmapBuffered, "range.bmp")
	;Exit

	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_BitmapDispose($hBitmapBuffered)

	If $sOCRTextResult <> "" Then
		Return StringRegExpReplace($sOCRTextResult, "[^0-9]", "")
	EndIf
	Return $sOCRTextResult
EndFunc   ;==>getOCRRange

Func getOCRAngle()
	Local $hHBitmap = _ScreenCapture_CaptureWnd("", "SquadGame", $aCoordinates[$iResolution][$iMortarAngleOcr][0], $aCoordinates[$iResolution][$iMortarAngleOcr][1], $aCoordinates[$iResolution][$iMortarAngleOcr][2], $aCoordinates[$iResolution][$iMortarAngleOcr][3], False)
	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
	Local $aDim = _GDIPlus_ImageGetDimension($hBitmap)
	If @error Then
		Return 0
	EndIf
	$hBitmap = _GDIPlus_ImageResize($hBitmap, $aDim[0] * 2, $aDim[1] * 2)
	$hEffect = _GDIPlus_EffectCreateBrightnessContrast(0, 60)
	_GDIPlus_BitmapApplyEffect($hBitmap, $hEffect)
	Local $iWidth = _GDIPlus_ImageGetWidth($hBitmap)
	Local $iHeight = _GDIPlus_ImageGetHeight($hBitmap)
	Local $iIncrease = $iWidth * 2
	Local $hBitmapBuffered = _GDIPlus_BitmapCreateFromScan0($iWidth + $iIncrease, $iHeight + $iIncrease)
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmapBuffered)
	_GDIPlus_GraphicsClear($hGraphics, 0xFFFFFF)
	_GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, $iIncrease / 2, $iIncrease / 2, $iWidth, $iHeight)
	Local $sOCRTextResult = _UWPOCR_GetText($hBitmapBuffered, Default, True)

	;ConsoleWrite("OCR ANGLE: " & $sOCRTextResult & @CRLF)
	;_GDIPlus_ImageSaveToFile($hBitmapBuffered, "angle.bmp")
	;Exit

	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_BitmapDispose($hBitmapBuffered)
	_GDIPlus_Shutdown()
	If $sOCRTextResult <> "" Then
		Return StringRegExpReplace($sOCRTextResult, "[^0-9.]", "")
	EndIf
	Return $sOCRTextResult
EndFunc   ;==>getOCRAngle

Func syncCoordinates()
	ReDim $aCoordinatesRange[0]
	ReDim $aCoordinatesAngle[0]
	Local $sFileContent = FileRead("runtime/coordinates.txt")
	If @error Then
		Return
	EndIf
	If $sFileContent == "" Then
		Return
	EndIf
	Local $aReadCoordinates = StringSplit($sFileContent, ";", 2)
	Local $iArraySize = UBound($aReadCoordinates)
	ReDim $aCoordinatesRange[$iArraySize]
	ReDim $aCoordinatesAngle[$iArraySize]
	For $i = 0 To $iArraySize - 1
		Local $aCoordinate = StringSplit($aReadCoordinates[$i], ",", 2)
		If UBound($aCoordinate) = 2 Then
			$aCoordinatesRange[$i] = $aCoordinate[0]
			$aCoordinatesAngle[$i] = $aCoordinate[1]
		EndIf
	Next
EndFunc   ;==>syncCoordinates

Func switchWindow()
	$iState = WinGetState("SquadGame")
	If BitAND($iState, $WIN_STATE_ACTIVE) Then
		If $hBrowser == "" Then
			eventButtonOpenHTMLFileClick()
		EndIf
		WinActivate($hBrowser)
	Else
		WinActivate("SquadGame")
	EndIf
EndFunc   ;==>switchWindow
