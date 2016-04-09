Function Write-Message
{
    param
    (
        [Parameter(Mandatory=$True)]
        [String]
        $Message,
        [ValidateSet('INFO', 'DEBG', 'ERRR', 'WARN')]
        [String]
        $MessageType = 'INFO',
        [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan',
                     'DarkRed','DarkMagenta', 'DarkYellow', 'Gray',
                     'DarkGray', 'Blue', 'Green', 'Cyan', 'Red',
                     'Magenta', 'Yellow', 'White')]
        [String]
        $ForegroundColor = $null,
        [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan',
                     'DarkRed','DarkMagenta', 'DarkYellow', 'Gray',
                     'DarkGray', 'Blue', 'Green', 'Cyan', 'Red',
                     'Magenta', 'Yellow', 'White')]
        [String]
        $BackgroundColor = $null,
        [Switch]
        $NoDate,
        [Switch]
        $NoMessageType
    )

    $OutputLine = $null
    $WindowOutput = ''
    $CurrentTime = (Get-Date).ToString('dd/MM/yyyy hh:mm:ss')

    if($NoDate -and !$NoMessageType)
    {
        $OutputLine = "[$MessageType]: $Message"
    }
    elseif(!$NoDate -and $NoMessageType)
    {
        $OutputLine = "[$CurrentTime]: $Message"
    }
    elseif($NoDate -and $NoMessageType)
    {
        $OutputLine = $Message
    }
    else
    {
        $OutputLine = "[$CurrentTime] [$MessageType]: $Message"
    }

    if($PsISE -eq $null)
    {
        $WindowWidth = (Get-Host).UI.RawUI.BufferSize.Width
        if($OutputLine.Length -ge $WindowWidth)
        {
            $WindowOutput = $OutputLine.Substring(0, $WindowWidth - 3).Replace("`r`n", ' ') + '..'
        }
        else
        {
            $WindowOutput = $OutputLine
        }
    }
    else
    {
        $WindowOutput = $OutputLine
    }

    if([String]::IsNullOrEmpty($ForegroundColor) -and [String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host $WindowOutput
    }
    elseif(![String]::IsNullOrEmpty($ForegroundColor) -and ![String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor $WindowOutput
    }
    elseif(![String]::IsNullOrEmpty($ForegroundColor) -and [String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host -ForegroundColor $ForegroundColor $WindowOutput
    }
    elseif([String]::IsNullOrEmpty($ForegroundColor) -and ![String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host -BackgroundColor $BackgroundColor $WindowOutput
    }

    if($Global:LoggingEnabled)
    {
        Add-Content -Path $Global:LogFileLocation -Value ($OutputLine)
    }
}

Function Write-ScriptHeader
{
    param
    (
        [Parameter(Mandatory=$True)]
        [String]
        $ScriptName,
        [Parameter(Mandatory=$True)]
        [String]
        $Version,
        [Parameter(Mandatory=$True)]
        [String]
        $CompanyName,
        [Switch]
        $DontClearScreen
    )

    if(!$DontClearScreen)
    {
        Clear-Host
    }
    Write-Host ("$ScriptName [$Version]")
    Write-Host ("(c) $((Get-Date).ToString('yyyy')) $CompanyName. All rights reserved.")
    Write-Host ('')
}

Function Enable-LogWriting
{
    param
    (
        [Parameter(Mandatory=$True)]
        $OutputLocation
    )

    $OutputFolder = Split-Path -Parent $OutputLocation

    if(Test-Path $OutputFolder) 
    {
        $Global:LoggingEnabled = $True
        $Global:LogFileLocation = $OutputLocation
        Write-Message 'Logging is now enabled.'
        Write-Message "Log output will be available at '$OutputLocation'."
    }
    else
    {
        Write-Message 'Logging could not be activated!' ERRR -ForegroundColor Red -BackgroundColor Black
        Write-Message "'$OutputFolder' doesn't exist!" ERRR -ForegroundColor Red -BackgroundColor Black
    }
}

Function Disable-LogWriting
{
    if($Global:LoggingEnabled)
    {
        Write-Message 'Logged now disabled on this system.'
        $Global:LoggingEnabled = $False
        $Global:LogFileLocation = $null
    }
    else
    {
        Write-Message ERRR -ForegroundColor Red 'Logging wasn''t enabled, no action has occured.'
    }
}

Export-ModuleMember -Function Write-Message
Export-ModuleMember -Function Write-ScriptHeader
Export-ModuleMember -Function Enable-LogWriting
Export-ModuleMember -Function Disable-LogWriting