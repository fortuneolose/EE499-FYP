# sync_fyp.ps1 - Auto-pull latest changes from EE499-FYP remote repository
# Runs at startup via Windows Startup folder, then repeats every $syncInterval minutes

$repoPath     = "$env:USERPROFILE\OneDrive\Documents\EE499-FYP"
$logFile      = Join-Path $repoPath "sync_fyp.log"
$syncInterval = 15   # minutes between each sync cycle

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $msg" | Out-File -Append -FilePath $logFile -Encoding utf8
}

function Wait-ForNetwork {
    $maxWait = 120
    $waited  = 0
    while (-not (Test-Connection -ComputerName github.com -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 5
        $waited += 5
        if ($waited -ge $maxWait) {
            Write-Log "ERROR: No network after ${maxWait}s - skipping this cycle."
            return $false
        }
    }
    Write-Log "Network available after ${waited}s."
    return $true
}

function Invoke-Sync {
    Set-Location $repoPath

    $fetchOut = git fetch origin 2>&1
    Write-Log "fetch: $fetchOut"

    $pullOut = git pull origin main 2>&1
    Write-Log "pull:  $pullOut"
}

# Trim log file if it grows beyond 500 KB
function Trim-Log {
    if (Test-Path $logFile) {
        $size = (Get-Item $logFile).Length
        if ($size -gt 512KB) {
            $lines = Get-Content $logFile -Tail 200
            $lines | Set-Content $logFile -Encoding utf8
            Write-Log "Log trimmed (was $([math]::Round($size/1KB)) KB)."
        }
    }
}

Write-Log "===== sync_fyp started (interval: ${syncInterval}m) ====="

while ($true) {
    Trim-Log

    if (Wait-ForNetwork) {
        Invoke-Sync
        Write-Log "Sync complete. Next sync in ${syncInterval}m."
    }

    Start-Sleep -Seconds ($syncInterval * 60)
}
