
Const $i1024x768 = 0
Const $i1920x1080 = 1
Const $i2560x1440 = 2
Const $i3840x1600 = 3
Const $iMortarAngleOcr = 0
Const $iMortarRangeOcr = 1
Const $iIsMapActive = 2
Const $iMapCoordinates = 3
Global $aCoordinates[4][4][4]


Func arrayCompare(Const ByRef $aArray1, Const ByRef $aArray2)
	; Check Subscripts
	$aArray1NumDimensions = UBound($aArray1, 0)
	$aArray2NumDimensions = UBound($aArray2, 0)

	; Static Variables
	Static $bArrayMatch
	Static $sEvaluationString = ""
	Static $iDimension = 0

	If $iDimension = 0 Then
		If $aArray1NumDimensions <> $aArray2NumDimensions Then
			Return SetError(1, 0, False)
		EndIf

		If $aArray1NumDimensions = 0 Then
			Return SetError(2, 0, False)
		EndIf
	EndIf

	Switch $iDimension
		Case 0
			; Start the iterations
			$bArrayMatch = True
			$iDimension = 1
			arrayCompare($aArray1, $aArray2)
			$iDimension = 0
		Case Else
			; Save string to revert back
			$sOldString = $sEvaluationString

			For $i = 0 To (UBound($aArray1, $iDimension) - 1)
				; Add dimension to the string
				$sEvaluationString &= "[" & $i & "]"

				If $iDimension = $aArray1NumDimensions Then
					; Evaluate the string
					$bArrayMatch = Execute("$aArray1" & $sEvaluationString & " = $aArray2" & $sEvaluationString)

				Else
					; Call the function for the next dimension
					$iDimension += 1
					arrayCompare($aArray1, $aArray2)
					$iDimension -= 1
				EndIf

				; Revert to old string
				$sEvaluationString = $sOldString

				; Dump out after the first mismatch
				If $bArrayMatch = False Then
					ExitLoop
				EndIf
			Next
	EndSwitch
	Return $bArrayMatch
EndFunc   ;==>arrayCompare



Func _MouseWheelPlus($Window, $direction, $clicks)
	Local $WM_MOUSEWHEEL = 0x020A
	$MouseCoord = MouseGetPos()
	$X = $MouseCoord[0]
	$Y = $MouseCoord[1]
	If $direction = "up" Then
		$WheelDelta = 120
	Else
		$WheelDelta = -120
	EndIf
	For $i = 0 To $clicks
		DllCall("user32.dll", "int", "SendMessage", _
				"hwnd", WinGetHandle($Window), _
				"int", $WM_MOUSEWHEEL, _
				"long", _MakeLong(0, $WheelDelta), _
				"long", _MakeLong($X, $Y))
	Next
EndFunc   ;==>_MouseWheelPlus

Func _MakeLong($LoWord, $HiWord)
	Return BitOR($HiWord * 0x10000, BitAND($LoWord, 0xFFFF))
EndFunc   ;==>_MakeLong


Func cSend($iPressDelay, $iPostPressDelay = 0, $sKey = "Up")
	ControlSend("Squad", "", "", "{" & $sKey & " Down}")
	Sleep($iPressDelay)
	ControlSend("Squad", "", "", "{" & $sKey & " Up}")
	Sleep($iPostPressDelay)
	Return
EndFunc   ;==>cSend


Func setCoordinates()

	If WinExists("SquadGame") == 1 Then
		Local $aWinPos = WinGetClientSize("SquadGame")
		Global $iResolution = Eval("i" & $aWinPos[0] & "x" & $aWinPos[1])
	EndIf
	;=================================================== 1024x768
	$aCoordinates[$i1024x768][$iMortarAngleOcr][0] = 496
	$aCoordinates[$i1024x768][$iMortarAngleOcr][1] = 779
	$aCoordinates[$i1024x768][$iMortarAngleOcr][2] = 527
	$aCoordinates[$i1024x768][$iMortarAngleOcr][3] = 786

	$aCoordinates[$i1024x768][$iMortarRangeOcr][0] = 207
	$aCoordinates[$i1024x768][$iMortarRangeOcr][1] = 400
	$aCoordinates[$i1024x768][$iMortarRangeOcr][2] = 256
	$aCoordinates[$i1024x768][$iMortarRangeOcr][3] = 430

	$aCoordinates[$i1024x768][$iIsMapActive][0] = 700
	$aCoordinates[$i1024x768][$iIsMapActive][1] = 133
	$aCoordinates[$i1024x768][$iIsMapActive][2] = 900
	$aCoordinates[$i1024x768][$iIsMapActive][3] = 133

	$aCoordinates[$i1024x768][$iMapCoordinates][0] = 571
	$aCoordinates[$i1024x768][$iMapCoordinates][1] = 224
	$aCoordinates[$i1024x768][$iMapCoordinates][2] = 1010
	$aCoordinates[$i1024x768][$iMapCoordinates][3] = 662

	;=================================================== 1920x108
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][0] = 938
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][1] = 1052
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][2] = 980
	$aCoordinates[$i1920x1080][$iMortarAngleOcr][3] = 1063

	$aCoordinates[$i1920x1080][$iMortarRangeOcr][0] = 531
	$aCoordinates[$i1920x1080][$iMortarRangeOcr][1] = 513
	$aCoordinates[$i1920x1080][$iMortarRangeOcr][2] = 605
	$aCoordinates[$i1920x1080][$iMortarRangeOcr][3] = 560

	$aCoordinates[$i1920x1080][$iIsMapActive][0] = 1050
	$aCoordinates[$i1920x1080][$iIsMapActive][1] = 141
	$aCoordinates[$i1920x1080][$iIsMapActive][2] = 1500
	$aCoordinates[$i1920x1080][$iIsMapActive][3] = 141

	$aCoordinates[$i1920x1080][$iMapCoordinates][0] = 1086
	$aCoordinates[$i1920x1080][$iMapCoordinates][1] = 195
	$aCoordinates[$i1920x1080][$iMapCoordinates][2] = 1855
	$aCoordinates[$i1920x1080][$iMapCoordinates][3] = 964

	;=================================================== 2560x1440
	$aCoordinates[$i2560x1440][$iMortarAngleOcr][0] = 1250
	$aCoordinates[$i2560x1440][$iMortarAngleOcr][1] = 1403
	$aCoordinates[$i2560x1440][$iMortarAngleOcr][2] = 1305
	$aCoordinates[$i2560x1440][$iMortarAngleOcr][3] = 1417

	$aCoordinates[$i2560x1440][$iMortarRangeOcr][0] = 695
	$aCoordinates[$i2560x1440][$iMortarRangeOcr][1] = 688
	$aCoordinates[$i2560x1440][$iMortarRangeOcr][2] = 798
	$aCoordinates[$i2560x1440][$iMortarRangeOcr][3] = 750

	$aCoordinates[$i2560x1440][$iIsMapActive][0] = 1900
	$aCoordinates[$i2560x1440][$iIsMapActive][1] = 190
	$aCoordinates[$i2560x1440][$iIsMapActive][2] = 2200
	$aCoordinates[$i2560x1440][$iIsMapActive][3] = 190

	$aCoordinates[$i2560x1440][$iMapCoordinates][0] = 1448
	$aCoordinates[$i2560x1440][$iMapCoordinates][1] = 260
	$aCoordinates[$i2560x1440][$iMapCoordinates][2] = 2474
	$aCoordinates[$i2560x1440][$iMapCoordinates][3] = 1286

	;=================================================== 3840x1600
	$aCoordinates[$i3840x1600][$iMortarAngleOcr][0] = 1886
	$aCoordinates[$i3840x1600][$iMortarAngleOcr][1] = 1559
	$aCoordinates[$i3840x1600][$iMortarAngleOcr][2] = 1953
	$aCoordinates[$i3840x1600][$iMortarAngleOcr][3] = 1575

	$aCoordinates[$i3840x1600][$iMortarRangeOcr][0] = 1260
	$aCoordinates[$i3840x1600][$iMortarRangeOcr][1] = 765
	$aCoordinates[$i3840x1600][$iMortarRangeOcr][2] = 1380
	$aCoordinates[$i3840x1600][$iMortarRangeOcr][3] = 847

	$aCoordinates[$i3840x1600][$iIsMapActive][0] = 2560
	$aCoordinates[$i3840x1600][$iIsMapActive][1] = 210
	$aCoordinates[$i3840x1600][$iIsMapActive][2] = 3000
	$aCoordinates[$i3840x1600][$iIsMapActive][3] = 210

	$aCoordinates[$i3840x1600][$iMapCoordinates][0] = 2356
	$aCoordinates[$i3840x1600][$iMapCoordinates][1] = 289
	$aCoordinates[$i3840x1600][$iMapCoordinates][2] = 3495
	$aCoordinates[$i3840x1600][$iMapCoordinates][3] = 1429

EndFunc   ;==>setCoordinates
