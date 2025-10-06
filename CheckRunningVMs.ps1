<#
1.Shuts down all running VMs
2. Disables automatic start
3. Confirmattion all VMs are in 'off' state

Created:  10.6.25
===================================================================
#>


# Define log file path
$logPath = "C:\applog\vm_upgrade_log.txt"

# Ensure log directory exists
if (!(Test-Path "C:\applog")) {
    New-Item -Path "C:\applog" -ItemType Directory -Force
}

# Logging function
function Write-Log {
    param (
        [string]$Message,
        [string]$Status = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp [$Status] $Message"
    Add-Content -Path $logPath -Value $entry
}

# Start log
Write-Log "=== VM Upgrade Prep Script Started ==="

try {
    # Step 1: Get all running VMs
    $runningVMs = Get-VM | Where-Object {$_.State -eq 'Running'}
    Write-Log "Found $($runningVMs.Count) running VM(s)."

    # Step 2: Shut down all running VMs
    foreach ($vm in $runningVMs) {
        Write-Log "Attempting to stop VM: $($vm.Name)"
        Stop-VM -Name $vm.Name -Force
        Write-Log "Successfully stopped VM: $($vm.Name)"
    }

    # Step 3: Disable automatic start actions
    $allVMs = Get-VM
    foreach ($vm in $allVMs) {
        Set-VM -Name $vm.Name -AutomaticStartAction Nothing
        Write-Log "Disabled auto-start for VM: $($vm.Name)"
    }

    # Step 4: Confirm all VMs are off
    $vmStates = Get-VM | Select-Object Name, State
    foreach ($vm in $vmStates) {
        Write-Log "VM '$($vm.Name)' is in state: $($vm.State)"
    }

    Write-Log "=== VM Upgrade Prep Script Completed Successfully ===" "SUCCESS"
}
catch {
    Write-Log "Error occurred: $_" "ERROR"
    Write-Log "=== VM Upgrade Prep Script Failed ===" "FAILURE"
}
