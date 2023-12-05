/*
# Get the current UTC time
$utcTime = Get-Date -Utc

# Convert the UTC time to CDT
$cdtTime = $utcTime.ToLocalTime('Central Standard Time')

# Check if the time is between 05:00 and 18:00 CDT
if ($cdtTime.Hour -ge 5 -and $cdtTime.Hour -lt 18) {
    # Stop the server
    Stop-Computer
} else {
    # Start the server
    Start-Computer
}
*/
#Get Current UTC Time (default time zone in all Azure regions)
$UTCNow = [System.DateTime]::UtcNow

#Get the Value of the "Operational-UTCOffset" Tag, that represents the offset from UTC
$UTCOffset = -6

#Get current time in the Adjusted Time Zone
if ($UTCOffset) {
    $TimeZoneAdjusted = $UTCNow.AddHours($UTCOffset)
    Write-Output "Current time of VM after adjusting the Time Zone is: $TimeZoneAdjusted"
}
else {
    $TimeZoneAdjusted = $UTCNow
}

          
$ScheduledTime = $ScheduledTime.Split("-")
$ScheduledStart = $ScheduledTime[0]
$ScheduledStop = $ScheduledTime[1]
            
$ScheduledStartTime = Get-Date -Hour $ScheduledStart -Minute 0 -Second 0
$ScheduledStopTime = Get-Date -Hour $ScheduledStop -Minute 0 -Second 0

If (($TimeZoneAdjusted -gt $ScheduledStartTime) -and ($TimeZoneAdjusted -lt $ScheduledStopTime)) {
    #Current time is within the interval
    Write-Output "VM should be running now"
    Write-Output "TimeZoneAdjusted:   $TimeZoneAdjusted"
    Write-Output "ScheduledStartTime: $ScheduledStartTime"
    Write-Output "ScheduledStopTime:  $ScheduledStopTime"
    $VMAction = "Start"
    $VMAction
            
}
else {
    #Current time is outside of the operational interval
    Write-Output "VM should be stopped now"
    Write-Output "TimeZoneAdjusted:   $TimeZoneAdjusted"
    Write-Output "ScheduledStartTime: $ScheduledStartTime"
    Write-Output "ScheduledStopTime:  $ScheduledStopTime"
    $VMAction = "Stop"
    $VMAction
}
