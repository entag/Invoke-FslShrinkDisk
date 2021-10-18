function Write-VhdOutput {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $true
        )]
        [System.String]$Path,

        [Parameter(
            Mandatory = $true
        )]
        [System.String]$Name,

        [Parameter(
            Mandatory = $true
        )]
        [System.String]$DiskState,

        [Parameter(
            Mandatory = $true
        )]
        [System.String]$OriginalSize,

        [Parameter(
            Mandatory = $true
        )]
        [System.String]$FinalSize,

        [Parameter(
            Mandatory = $true
        )]
        [System.String]$MaxSize,

        [Parameter(
            Mandatory = $true
        )]
        [System.String]$FullName,

        [Parameter(
            Mandatory = $true
        )]
        [datetime]$StartTime,

        [Parameter(
            Mandatory = $true
        )]
        [datetime]$EndTime,

        [Parameter(
        )]
        [Switch]$Passthru,

        [Parameter(
        )]
        [Switch]$JSONFormat,

        [Parameter(
        )]
        [Switch]$NoFile
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {

        #unit conversion and calculation should happen in output function
        $csvOutput = [PSCustomObject]@{
            Name                = $Name
            StartTime           = $StartTime.ToLongTimeString()
            EndTime             = $EndTime.ToLongTimeString()
            'ElapsedTime(s)'    = [math]::Round(($EndTime - $StartTime).TotalSeconds, 1)
            DiskState           = $DiskState
            'OriginalSize(GiB)' = [math]::Round( $OriginalSize / 1GB, 2 )
            'FinalSize(GiB)'    = [math]::Round( $FinalSize / 1GB, 2 )
            'MaxSize(GiB)'      = [math]::Round( $MaxSize / 1GB, 2 )
            'SpaceSaved(GiB)'   = [math]::Round( ($OriginalSize - $FinalSize) / 1GB, 2 )
            FullName            = $FullName
        }

        #JSON output is meant to be machine readable so times are changed to timestamps and sizes left in Bytes
        $jsonOutput = [PSCustomObject][Ordered]@{
            Name         = $Name
            StartTime    = $StartTime.GetDateTimeFormats()[18]
            EndTime      = $EndTime.GetDateTimeFormats()[18]
            ElapsedTime  = [math]::Round(($EndTime - $StartTime).TotalSeconds, 7)
            DiskState    = $DiskState
            OriginalSize = $OriginalSize
            FinalSize    = $FinalSize
            MaxSize      = $MaxSize
            SpaceSaved   = $OriginalSize - $FinalSize
            FullName     = $FullName
        }

        if ($Passthru) {
            if ($JSONFormat) {
                Write-Output $jsonOutput
            }
            else {
                Write-Output $csvOutput
            }
        }

        if ($JSONFormat) {
            $logMessage = $jsonOutput | ConvertTo-Json -Compress
            if (-not $NoFile) {
                $logMessage | Add-Content -Path $Path -ErrorAction Stop
            }

        }
        else {
            if (-not $NoFile) {
                $csvOutput | Export-Csv -Path $Path -NoClobber -Append -NoTypeInformation -Force -ErrorAction Stop
            }
        }

    } #Process
    END { } #End
}  #function Write-VhdOutput.ps1