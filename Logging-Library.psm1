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
    $WindowWidth = $null
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

    if($Global:FileLoggingEnabled)
    {
        Try
        {
            Add-Content -Path $Global:LogFileLocation -Value ($OutputLine)
        }
        Catch
        {
            Write-Host -ForegroundColor Red ($_.Exception | Format-List -Force)
            Disable-LogWriting
        }
    }
}

Function Write-BlankLine
{
    param(
        [Switch]
        $IgnoreLogging # Added as people may not want to include blank lines in their files on some occassions.
    )
    Write-Host ('')

    if($Global:FileLoggingEnabled -and !$IgnoreLogging)
    {
        Add-Content -Path $Global:LogFileLocation -Value ''
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
    Write-Message -NoDate -NoMessageType ("$ScriptName [$Version]")
    Write-Message -NoDate -NoMessageType ("(c) $((Get-Date).ToString('yyyy')) $CompanyName. All rights reserved.")
    Write-BlankLine
}

Function Enable-LogWriting
{
    param
    (
        [Parameter(Mandatory=$True)]
        $OutputLocation
    )

    $OutputFolder = Split-Path -Parent $OutputLocation
    $FolderExists = $False
    $CanWrite = $False

    if(Test-Path $OutputFolder)
    {
        $FolderExists = $True

        Try
        {
            # System will throw an exception due to security policy
            # if we can't open write on the file.
            # This is also good, because it acts as a 'touch' if
            # the file doesn't exist, so we know we've been successful.
            [System.IO.File]::OpenWrite($OutputLocation).Close()
            $CanWrite = $True
        }
        Catch { }
    }

    if($FolderExists -and $CanWrite) 
    {
        $Global:FileLoggingEnabled = $True
        $Global:LogFileLocation = $OutputLocation

        Write-Message 'Logging is now enabled.'
        Write-Message "Log output will be available at '$OutputLocation'."
    }
    else
    {
        Write-Message 'Logging could not be activated!' ERRR -ForegroundColor Red -BackgroundColor Black
       
        if(!$FolderExists)
        {
            Write-Message "'$OutputFolder' doesn't exist." ERRR -ForegroundColor Red -BackgroundColor Black
        }
        else
        {
            if(!$CanWrite)
            {
                Write-Message "Sorry, you don't have permission to write to '$OutputLocation'." ERRR -ForegroundColor Red -BackgroundColor Black
            }
        }
    }
}

Function Disable-LogWriting
{
    $LoggingHasBeenDisabled = $False
    
    if($Global:FileLoggingEnabled)
    {
        Write-Message 'File logging now disabled on this system.'
        $Global:FileLoggingEnabled = $False
        $Global:LogFileLocation = $null
        $LoggingHasBeenDisabled = $True
    }

    if(!$LoggingHasBeenDisabled)
    {
        Write-Message -ForegroundColor Red 'Logging wasn''t enabled, no action has occured.' ERRR
    }
}

Export-ModuleMember -Function Write-Message
Export-ModuleMember -Function Write-ScriptHeader
Export-ModuleMember -Function Enable-LogWriting
Export-ModuleMember -Function Disable-LogWriting