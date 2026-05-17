#Requires AutoHotkey v2

MainGui := Gui("+Resize", "Fazedor auto de AOT")
MainGui.OnEvent("Close", exit)

MainGui.AddText("+0x200 h20", "Max tempo total aceito:")
fullTimeMinutesEdit := MainGui.AddEdit("x+5 r1 w25", "4")
MainGui.AddText("x+2", ":")
fullTimeSecondsEdit := MainGui.AddEdit("x+2 r1 w25", "20")

MainGui.AddText("xM y+15 +0x200 h20", "Max p1 aceito:")
p1TimeMinutesEdit := MainGui.AddEdit("x+5 r1 w25", "1")
MainGui.AddText("x+2", ":")
p1SecondsEdit := MainGui.AddEdit("x+2 r1 w25", "20")

MainGui.AddText("xM +0x200 h20", "Max p2 aceito:")
p2TimeMinutesEdit := MainGui.AddEdit("x+5 r1 w25", "1")
MainGui.AddText("x+2", ":")
p2SecondsEdit := MainGui.AddEdit("x+2 r1 w25", "00")

MainGui.AddText("xM +0x200 h20", "Max p3 aceito:")
p3TimeMinutesEdit := MainGui.AddEdit("x+5 r1 w25", "1")
MainGui.AddText("x+2", ":")
p3SecondsEdit := MainGui.AddEdit("x+2 r1 w25", "00")

MainGui.AddText("xM +0x200 h20", "Max p4 aceito:")
p4TimeMinutesEdit := MainGui.AddEdit("x+5 r1 w25", "1")
MainGui.AddText("x+2", ":")
p4SecondsEdit := MainGui.AddEdit("x+2 r1 w25", "00")

StartPlaying := MainGui.AddButton("Default xM", "Iniciar automação")
StartPlaying.OnEvent("Click", startAOT)

CancelButton := MainGui.AddButton("Default Disabled x+10", "Parar")
CancelButton.OnEvent("Click", cancel)

StatusText := MainGui.AddText("xM r1 w170", "Ocioso")

ReloadButton := MainGui.Add("Button", "XM Default", "Reload")
ReloadButton.OnEvent("Click", reloadScript)

editInputs := [fullTimeMinutesEdit, fullTimeSecondsEdit, p1TimeMinutesEdit, p1SecondsEdit, p2TimeMinutesEdit, p2SecondsEdit, p3TimeMinutesEdit, p3SecondsEdit, p4TimeMinutesEdit, p4SecondsEdit]

Loop editInputs.Length {
    eInput := editInputs[A_Index]
    eInput.OnEvent("Change", validateInputs)
}

MainGui.Show()

aotPID := false

startAOT(*) {
    global aotPID

    Loop editInputs.Length {
        editInputs[A_Index].Enabled := false
    }

    p1Time := p1TimeMinutesEdit.Value * 60 + p1SecondsEdit.Value
    p2Time := p2TimeMinutesEdit.Value * 60 + p2SecondsEdit.Value
    p3Time := p3TimeMinutesEdit.Value * 60 + p3SecondsEdit.Value
    p4Time := p4TimeMinutesEdit.Value * 60 + p4SecondsEdit.Value
    fullTime := fullTimeMinutesEdit.Value * 60 + fullTimeSecondsEdit.Value

    Run(".\AOT.ahk " p1Time " " p2Time " " p3Time " " p4Time " " fullTime,,, &aotPID)

    StartPlaying.Enabled := false
    CancelButton.Enabled := true

    StatusText.Text := "Rodando"
}

cancel(*) {
    global aotPID

    if (aotPID) {
        PostMessage 0x111, 65307,,, "ahk_pid " aotPID
        aotPID := false
    }

    Loop editInputs.Length {
        editInputs[A_Index].Enabled := true
    }

    StartPlaying.Enabled := true
    CancelButton.Enabled := false

    StatusText.Text := "Ocioso"
}

validateInputs(*) {
    global editInputs
    global StartPlaying

    StartPlaying.Enabled := true
    StatusText.Text := "Ocioso"

    Loop editInputs.Length {
        val := editInputs[A_Index].Value
        if (!isNumber(val)) {
            StartPlaying.Enabled := false
            StatusText.Text := "Utilize apenas números nos tempos"
            return
        }
    }
}

reloadScript(*) {
	Reload
}

exit(*) {
    cancel()

	ExitApp
}
