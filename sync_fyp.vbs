' sync_fyp.vbs — Silent launcher for sync_fyp.ps1 (no console window)
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & _
    objShell.ExpandEnvironmentStrings("%USERPROFILE%") & _
    "\OneDrive\Documents\EE499-FYP\sync_fyp.ps1""", 0, False
