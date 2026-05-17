#Requires AutoHotkey v2
#include .\lib\OCR-1.0.2\Lib\OCR.ahk

/**
 * Script to keep replaying Grand Chase's Altar Of Time. PT-BR only
 * NOT INTENTED FOR REAL USE
 * THIS BREAKS KOG'S TERMS OF SERVICE, USE OF THIS SCRIPT MAY RESULT IN YOUR ACCOUNT BEING BANNED
 *   THIS SCRIPT WAS CREATED FOR EDUCATIONAL PURPOSES, THE AUTHOR JUST WANTED TO SEE IF THEY COULD
 *   AUTOMATE IT FOR FUN
 * You have been warned, stop cheating, click the damn game yourself!
*/

^!c:: {
	ExitApp
}

CoordMode "Mouse", "Client"

maxTimes := [80, 60, 60, 60]
maxSrTime := 4 * 60 + 20

hWnd := WinExist("GrandChase")
if !hWnd {
	throw Error("Grand Chase is not open")
}

WinGetPos(,,&W,&H)
Y := H / 6


Loop {
	;Grab all text from window
	result := OcrGcWindow()
	
	;Wait for AOT "lobby"
	try result.FindString("Repetir Resultado")
	catch {
		Sleep 500
		continue
	}
	
	;Check if all stages are complete
	notCompletes := result.FindStrings("Derrote")
	if (notCompletes.Length > 0) {
		;Not complete, run the battle
		if (notCompletes.Length > 1) {
			;Multiple stages not complete, run multi battle
			DoMultiBattle(&result)
		} else {
			;Not complete, run the missing battle
			result.Click(notCompletes[1])
			Sleep 10000
			DoBattle(&result)
		}
		continue
	}
	
	;All stages complete, grab reward
	if GetReward(&result) {
		;Got reward, go back to lobby
		continue
	} else {
		;Did not grab reward, reset a slow stage and retry
		ResetSlowTimes(&result)
		continue
	}
}

IsAnyStageNotComplete(&ocrResult) {
	notCompletes := ocrResult.FindStrings("Derrote")
	return notCompletes.Length
}

DoBattle(&ocrResult) {
	batalhas := ocrResult.FindStrings("Batalha")
	ocrResult.Click(batalhas[-1])
	
	battleResult := OCR.WaitText("Recompensa Adquirida",, OcrGcWindow)
	Sleep 3000
	sair := battleResult.FindString("Sair")
	battleResult.Click(sair)
	Sleep 2000
}

DoMultiBattle(&ocrResult) {
	tryResult := ocrResult
	Loop {	
		batalhas := tryResult.FindStrings("Batalha")
		try tryResult.Click(batalhas[-2])
		catch {
			;try another string
			try tryResult.Click(tryResult.FindString("Batalha Consecutiva"))
			catch { 
			}
		
			;failed to find the button, reload the whole script, it works in mysterious ways
			Reload
		}
		break
	}
	
	multiBattleResult := OCR.WaitText("Se falhar",, OcrGcWindow)
	Sleep 500
	multiBattleResult.Click(multiBattleResult.findStrings("Consecutiva")[-1])
	
	Sleep 5000
	if !WinActive(hwnd) {
		WinActivate(hwnd)
		WinWaitActive(hwnd,,1)
    }
	
	battleResult := ''
	Loop {
		battleResult := OCR.WaitText("Recompensa Adquirida",, OcrGcWindow)
		
		try battleResult.FindString("Batalha consecutiva em")
		catch {
			break
		}
	}
	
	Sleep 1000
	sair := battleResult.FindString("Sair")
	battleResult.Click(sair)
	Sleep 2000
}

GetReward(&ocrResult) {
	times := ocrResult.Filter((word) => RegExMatch(word.Text, "\d\d:\d\d"))
	totalTime := times.Lines[-1].Words[1].Text
	totalTimeParts := StrSplit(totalTime, ':')
	parsedTotalTime := Number(totalTimeParts[1]) * 60 + Number(totalTimeParts[2])
	
	if (parsedTotalTime > maxSrTime) {
		;SR rank not achieved
		return false
	}

	reward := ocrResult.findString("Receber recompensa")
	ocrResult.Click(reward)
	
	rewardResult := OCR.WaitText("Aviso",, OcrGcWindow)
	Sleep 500
	
	rewardConfirm := rewardResult.findString("Confirmar")
	rewardResult.Click(rewardConfirm)
	Sleep 2000
	
	delivered := OCR.WaitText("foi entregue",, OcrGcWindow)
	Sleep 1000
	if !WinActive(hwnd) {
		WinActivate(hwnd)
		WinWaitActive(hwnd,,1)
    }
	Click W/50, H/50
	Sleep 1000
	
	return true
}

ResetSlowTimes(&ocrResult) {
	times := ocrResult.Filter((word) => RegExMatch(word.Text, "\d\d:\d\d"))
	
	Loop 4 {
		time := times.Lines[A_Index].Words[1].Text
		maxTime := maxTimes[A_Index]
		
		timeParts := StrSplit(time, ':')
		parsedTime := Number(timeParts[1]) * 60 + Number(timeParts[2])
		
		if (parsedTime > maxTime) {
			;Reset the long stage
			resets := ocrResult.FindStrings("Resetar")
			ocrResult.Click(resets[A_Index])
			Sleep 1000
			
			confirmResetResult := OCR.WaitText("Reiniciando",,OcrGcWindow)
			confirmResetResult.Click(confirmResetResult.FindString("Resetar"))
			Sleep 5000
			
			derroteFound := OCR.WaitText("Derrote", 5000, OcrGcWindow)
			if !derroteFound {
				;cant find the resetted stage, reload the script, works in mysterious ways
				Reload
			}
			return
		}
	}
	
	throw Error("Could not find a time to reset")
}

OcrGcWindow() {
	return OCR.FromWindow("GrandChase",,2,{X: 0, Y: Y, W: W, H: H, onlyClientArea: 1 })
}
