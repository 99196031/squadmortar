
#include "../autoit_libraries/common.au3"
#include <GDIPlus.au3>
#include <ScreenCapture.au3>
#include "../autoit_libraries/UWPOCR.au3"

Global $aCoordinatesRange[0]
Global $aCoordinatesAngle[0]
Global $hWnd = WinGetHandle("Squad")
Global $aCoordinates[3][5][4]
Const $i1024x768 = 0
Const $i1920x1080 = 1
Const $i2560x1440 = 2
Const $iMortarAngleOcr = 0
Local $aWinPos = WinGetClientSize("Squad")
Global $iResolution = Eval("i" & $aWinPos[0] & "x" & $aWinPos[1])
setCoordinates()
_GDIPlus_Startup()
$fMagicNumber = 19.92
$iDistance = 10
While True
	$fAngleOcr = Number(getOCRAngle(), 3)
	If Not @error And $fAngleOcr > 0 And $fAngleOcr < 360 Then
		$fAngle = $fAngleOcr + $iDistance
		If $fAngle > 360 Then
			$fAngle -= 360
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
		cSend($fTimes * $fMagicNumber, 200, $sKey)
		Sleep(1000)
		$fAngleOcr = Number(getOCRAngle(), 3)

		$fDiffAfterAdjustment = $fAngle - $fAngleOcr
		If $fDiffAfterAdjustment > 0 Then
			$fMagicNumber += 0.01
		Else
			$fMagicNumber -= 0.01
		EndIf
		If $fDiffAfterAdjustment == 0 Then
			ConsoleWrite("Distance: " & $iDistance & " Wished Angle: " & $fAngle & " Got Angle: " & $fAngleOcr & " Magic Number: " & $fMagicNumber & @CRLF)
			$iDistance += 10
			If $iDistance = 190 Then
				Exit
			Else
			EndIf
		EndIf
		; check here if it overshot decrease value if to less then increase and console write it
	EndIf
	cSend(0, 0, "d")
	Sleep(300)
WEnd


Func setCoordinates()
	;=================================================== 1920x1080
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][0] = 938
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][1] = 1052
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][2] = 980
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][3] = 1063
EndFunc   ;==>setCoordinates


Func getOCRAngle()
	Local $hHBitmap = _ScreenCapture_CaptureWnd("", "Squad", $aCoordinates[$iResolution][$iMortarAngleOcr][0], $aCoordinates[$iResolution][$iMortarAngleOcr][1], $aCoordinates[$iResolution][$iMortarAngleOcr][2], $aCoordinates[$iResolution][$iMortarAngleOcr][3], False)
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
	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_BitmapDispose($hBitmapBuffered)
	If $sOCRTextResult <> "" Then
		Return StringRegExpReplace($sOCRTextResult, "[^0-9.]", "")
	EndIf
	Return $sOCRTextResult
EndFunc   ;==>getOCRAngle
