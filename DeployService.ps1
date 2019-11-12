function Uninstall-Service {
    <#
    .SYNOPSIS
    Removes/deletes a service.
 
    .DESCRIPTION
    Removes an existing Windows service. If the service doesn't exist, nothing happens. 
    The service is stopped before being deleted, so that the computer doesn't need to be restarted for the removal to complete. 
    Even then, sometimes it won't go away until a reboot. 
 
    .EXAMPLE
    Uninstall-Service -Name DeathStar
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The service name to delete.
        $Name
    )

    $service = Get-Service | Where-Object { $_.Name -eq $Name }
    $sc = (Join-Path $env:WinDir system32\sc.exe -Resolve)

    if( $service )
    {
        if( $pscmdlet.ShouldProcess( "service '$Name'", "remove" ) )
        {
            Stop-Service $Name
            $output = & $sc delete $Name
            if( $LASTEXITCODE )
            {
                if( $LASTEXITCODE -eq 1072 )
                {
                    Write-Warning -Message ('The {0} service is marked for deletion and will be removed during the next reboot.{1}{2}' -f $Name,([Environment]::NewLine),($output -join ([Environment]::NewLine)))
                }
                else
                {
                    Write-Error -Message ('Failed to uninstall {0} service (returned non-zero exit code {1}):{2}{3}' -f $Name,$LASTEXITCODE,([Environment]::NewLine),($output -join ([Environment]::NewLine)))
                }
            }
            else
            {
                $output | Write-Verbose
            }
        }
    }
}

Function Deploy_Service {
 <#
            .SYNOPSIS

            Check Service Exsists
            Check Service Runs
            Check Service Stopped
            Remove Service
            Install Service Start Service

            
            .DESCRIPTION
            Install Service after checking it is dead
            
            .PARAMETER ServiceName
            The service for which evaluation occurs
            First positional parameter.

            .EXAMPLE
            
            .Notes 
            Author:       Patrick Moss
            Email:        patrick.moss@cheetahdigital.com
            Pre-requisites:  
            Created:         November 2019
            Last Modified:   November 2019
            History:    v1.0 - Created                
        
            TODO:        Start Service?
                         Remoting or copy and run
                         Peer review 
            #>
    param (
        [Parameter(Mandatory = $true,HelpMessage = 'Name of Service')]
            [String]$ServiceName
         
    )

    Try{
        If (Get-Service $serviceName ) {
            If ((Get-Service $serviceName).Status -eq 'Running') {
                $s = Get-Service "ServiceName"
                Write-Output "Stopping $serviceName"
                $s.WaitForStatus('Stopped')
                Uninstall-Service $serviceName
            } 
            else {
                Write-Output "$serviceName is Stopped"
                Uninstall-Service $serviceName
            }
        }
    }
    catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        write-output "ERROR: $ErrorMessage $FailedItem"
        Break
    }
}# End Function

Deploy_Service -ServiceName "Jenkins" -Verbose

