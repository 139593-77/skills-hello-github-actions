# Get the software name to be uninstalled
$softwareName = Read-Host "Enter the name of the software to uninstall"

# Get the list of installed software from the registry
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($keyPath in $uninstallKeys) {
    Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.DisplayName -like "*$softwareName*") {
            Write-Host "Found software: $($_.PSChildName)"
            $quietUninstallString = $_.QuietUninstallString
            $uninstallString = $_.UninstallString

            if ($quietUninstallString) {
                Write-Host "Executing QuietUninstallString: $quietUninstallString"
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $quietUninstallString" -Wait -NoNewWindow
            } elseif ($uninstallString) {
                Write-Host "Executing UninstallString: $uninstallString"
                if ($uninstallString -like "*msiexec*") {
                    # If the uninstall string is an MSI, add the /quiet flag
                    
                    $softwraeid = $_.PSChildName
                    Write-Host "Detected MSI uninstall. softwareid is $softwraeid"
                    #cmd /c msiexec.exe /uninstall $softwraeid /qn
                    #Start-Process -FilePath "msiexec.exe" -ArgumentList "/uninstall $softwraeid /qn" -Wait -NoNewWindow
                    #Start-Process "msiexec.exe" -ArgumentList "/x", "${softwraeid}", "/qn" -Wait
                    Get-Package -Name $($_.DisplayName) | Uninstall-Package
                    
                } else {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString /quiet" -Wait -NoNewWindow
                }
            } else {
                Write-Host "No uninstall string found for: $($_.DisplayName)"
            }
        }
    }
}
