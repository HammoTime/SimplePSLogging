<#
    Version:        1.0.4.0
    Author:         Adam Hammond
    Creation Date:  09/04/2016
    Last Change:    Added Update-SimplePSLogging
    Description:    This library contains a simple way to present useful and nice-looking
                    information out to the user at the console. It writes out a MessageType
                    and the current date out to the user, along with a message.
                    
                    If enabled, the output will also be written to a file.
    Link:           https://github.com/HammoTime/SimplePSLogging
    License:        The MIT License (MIT)
#>

Function Write-Message
{
    <#
        .SYNOPSIS
        
        Writes a message to the screen, and a file (if enabled)
        
        .DESCRIPTION
        
        Similar to Write-Host except it automatically adds the date/time and what kind
        of message is being written, and also writes the output to a file if that has
        been enabled.
        
        .PARAMETER Message
        
        What you want to write out.
        
        .PARAMETER MessageType
        
        The type of message you're writing out.
         - INFO = Informational.
         - DEBG = Debugging.
         - ERRR = Error.
         - WARN = Warning.
         
        .PARAMETER ForegroundColor
         
        The color you would like the text to be, must be part of the predefined list.
        * This has no effect on the file output.
         
        .PARAMETER BackgroundColor
         
        The color you would like the background of the console to be, must be part of
        the predefined list. * This has no effect on the file output.
         
        .PARAMETER NoDate
         
        Do not include the Date in the output.
         
        .PARAMETER NoMessageType
         
        Do not include the MessageType in the output.
        
        .PARAMETER NoNewLine
        
        Do not include a new line after writing the message.
         
        .EXAMPLE
         
        Write-Message 'This is an informational message.'
         
        Output:
        [2016-04-01 00:00:00] [INFO]: This is an informational message.
         
        .EXAMPLE
         
        Write-Message 'This is an error message.' ERRR
         
        Output:
        [2016-04-01 00:00:00] [ERRR]: This is an error message.
         
        .EXAMPLE
         
        Write-Message 'This is a message with no date.' -NoDate
         
        Output:
        [INFO]: This is a message with no date.
         
        .EXAMPLE
         
        Write-Message 'This is a message with no message type.' -NoMessageType
         
        Output:
        [2016-04-01 00:00:00]: This is a message with no message type.
         
        .EXAMPLE
         
        Write-Message 'This is a message with no date or message type.' -NoDate -NoMessageType
         
        Output:
        This is a message with no date or message type.
         
        .LINK
         
        https://github.com/HammoTime/SimplePSLogging/
    #>
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
        $NoMessageType,
        [Switch]
        $NoNewLine
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
    
    if(!$NoNewLine)
    {
        $WindowOutput += "`r`n"
        $OutputLine += "`r`n"
    }

    if([String]::IsNullOrEmpty($ForegroundColor) -and [String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host $WindowOutput -NoNewLine
    }
    elseif(![String]::IsNullOrEmpty($ForegroundColor) -and ![String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor $WindowOutput -NoNewLine
    }
    elseif(![String]::IsNullOrEmpty($ForegroundColor) -and [String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host -ForegroundColor $ForegroundColor $WindowOutput -NoNewLine
    }
    elseif([String]::IsNullOrEmpty($ForegroundColor) -and ![String]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host -BackgroundColor $BackgroundColor $WindowOutput -NoNewLine
    }

    if($Global:FileLoggingEnabled)
    {
        Try
        {
            # Changed to AppendAllText to support -NoNewLine correctly.
            [System.IO.File]::AppendAllText($Global:LogFileLocation, $OutputLine, [System.Text.Encoding]::Unicode)
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
    <#
        .SYNOPSIS
        
        Writes a blank line out.
        
        .DESCRIPTION
        
        Writes a blank line out to the screen, and to a file if it has been enabled.
        
        .PARAMETER IgnoreLogging
        
        Tells the script whether to explicitly exclude the blank line from file log output.
         
        .LINK
         
        https://github.com/HammoTime/SimplePSLogging/
    #>
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
    <#
        .SYNOPSIS
        
        Writes out a Microsoft-like header at the start of a script.
        
        .DESCRIPTION
        
        Writes out a Microsoft-like header at the start of a script.
        
        .PARAMETER ScriptName
        
        The name of the script you are running.
        
        .PARAMETER Version
        
        The current version of the script you are running.
        
        .PARAMETER CompanyName
        
        The company the script belongs to.
        
        .PARAMETER DontClearScreen
        
        A switch that tells the function whether it should run Clear-Host before
        printing out the details to screen.
         
        .EXAMPLE
         
        Write-ScriptHeader 'Test Script' '98.1.3' 'Veridian Dynamics'
         
        Output:
        Test Script [Version 98.1.3]
        (c) 2016 Veridian Dynamics. All rights reserved.
        
         
        .LINK
         
        https://github.com/HammoTime/SimplePSLogging/
    #>
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
    Write-Message -NoDate -NoMessageType ("$ScriptName [Version $Version]")
    Write-Message -NoDate -NoMessageType ("(c) $((Get-Date).ToString('yyyy')) $CompanyName. All rights reserved.")
    Write-BlankLine
}

Function Enable-LogWriting
{
        <#
        .SYNOPSIS
        
        Enables logging to file for the SimplePSLogging library.
        
        .DESCRIPTION
        
        Sets a few global variables that are looked for by 'Write-Message'. Once
        these are set, Write-Message will log every line out to the file given.
        
        .PARAMETER OutputLocation
        
        The file you want to write the output to.
        * Folder must exist.
        * File does not have to exist.
         
        .EXAMPLE
         
        Enable-LogWriting
         
        Output:
        [2016-04-01 00:00:00] [INFO]: Logging is now enabled.
        [2016-04-01 00:00:00] [INFO]: Log output will be available at 'C:\Temp\Log.txt'.
         
        .LINK
         
        https://github.com/HammoTime/SimplePSLogging/
    #>
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
        <#
        .SYNOPSIS
        
        Disables logging to file for the SimplePSLogging library.
        
        .DESCRIPTION
        
        Unsets a few global variables that are looked for by 'Write-Message'. Once
        these have been destroyed, Write-Message will no longer write output to file.
         
        .EXAMPLE
         
        Disable-LogWriting
         
        Output:
        [2016-04-01 00:00:00] [INFO]: File logging now disabled on this system.
         
        .LINK
         
        https://github.com/HammoTime/SimplePSLogging/
    #>
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

Function Update-SimplePSLogging
{
    <#
        .SYNOPSIS
        
        Updates the PS Logging Module from GitHub.
        
        .DESCRIPTION
        
        Checks the current releases on GitHub. If there is a new release, downloads the source
        files, copies them to the modules directory, and reloads the current runspace with
        the new module.
        
        .PARAMETER PreRelease
        
        If the latest release is a pre-release version and this switch is included, then
        it will install the pre-release version instead of the most recent production release.
         
        .LINK
         
        https://github.com/HammoTime/SimplePSLogging/
    #>
    
    Param(
        [Switch]
        $PreRelease
    )
    Clear-Host
    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + '] [INFO]: Updating SimplePSLogging.')

    $ModuleDirectory = $PSHome + '\Modules\SimplePSLogging\'
    $TempDirectory = $Env:TEMP + '\SimplePSLogging\'
    $ModuleZipLocation = $TempDirectory + 'SimplePSLogging.zip'
    $ReleasesURL = 'https://git.io/vwMSG'

    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Retrieving release information from '$ReleasesURL'.")
    Try
    {
        $ReleasesPage = Invoke-WebRequest $ReleasesURL
    }
    Catch
    {
        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Couldn't retrieve release information (Invalid Request).") -ForegroundColor Red
    }

    if($ReleasesPage.StatusCode -eq 200)
    {
        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + '] [INFO]: Release information retrieved successfully.')
        $Releases = ConvertFrom-Json $ReleasesPage.Content
        if($PreRelease)
        {
            $LatestRelease = $Releases | Sort-Object -Property Published_At -Descending | Select-Object -First 1
        }
        else
        {
            $LatestRelease = $Releases | Sort-Object -Property Published_At -Descending | Where-Object { ([Boolean]$_.Prerelease) -eq $False } | Select-Object -First 1
        }
        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Current release version at $($LatestRelease.Tag_Name).")
        $InstalledVersion = (Get-Module -ListAvailable | Where-Object { $_.Name -eq 'SimplePSLogging' }).Version
        $InstalledVersionNumber = 'v' + $InstalledVersion.Major + '.' + $InstalledVersion.Minor + '.' + $InstalledVersion.Build
        
        if($InstalledVersionNumber -eq $LatestRelease.Tag_Name)
        {
            Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Installed version at $($InstalledVersionNumber) (current).") -ForegroundColor Green
            Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: No update required.") -ForegroundColor Green
        }
        else
        {
            Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [WARN]: Installed version at $($InstalledVersionNumber) (out-of-date).") -ForegroundColor Yellow
            Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [WARN]: Update required.") -ForegroundColor Yellow
            Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Creating temporary directory at '$TempDirectory'.")
            New-Item $TempDirectory -ItemType Directory -Force | Out-Null
        
            Try
            {
                Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + '] [INFO]: Downloading release zip file.')
                Invoke-WebRequest $LatestRelease.ZipBall_Url -OutFile $ModuleZipLocation
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + '] [INFO]: Unpacking zip file.')
                [System.IO.Compression.ZipFile]::ExtractToDirectory($ModuleZipLocation, $TempDirectory)
                $ExtractedFiles = Get-ChildItem ($TempDirectory + (Get-ChildItem $TempDirectory -Directory | Select-Object -First 1).Name + '\SimplePSLogging\')

                Try
                {
                    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Deleting existing module files at '$ModuleDirectory'.")
                    Remove-Item $ModuleDirectory -Force -Recurse
                    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Creating module directory at '$ModuleDirectory'.")
                    New-Item $ModuleDirectory -ItemType Directory -Force | Out-Null

                    ForEach($ExtractedFile in $ExtractedFiles)
                    {
                        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: Copying '$($ExtractedFile.Name)' to module directory.")
                        Copy-Item -Path $ExtractedFile.FullName -Destination ($ModuleDirectory + $ExtractedFile.Name) -Force
                    }

                    Try
                    {
                        Remove-Module 'SimplePSLogging' -ErrorAction Stop -Force
                        Import-Module 'SimplePSLogging' -ErrorAction Stop -Force
                        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: 'SimplePSLogging' successfully reimported into current session.") -ForegroundColor Green
                        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [INFO]: 'SimplePSLogging' updated successfully.") -ForegroundColor Green
                    }
                    Catch
                    {
                        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Error reloading module into current session.") -ForegroundColor Red
                        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Please reload PowerShell to use new module.") -ForegroundColor Red
                    }
                }
                Catch
                {
                    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Error copying new module files to module directory.") -ForegroundColor Red
                }

                Try
                {
                    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + '] [INFO]: Deleting temporary files.')
                    Remove-Item $TempDirectory -Force -Recurse
                }
                Catch
                {
                    Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Error deleting temporary directory.") -ForegroundColor Red
                }
            }
            Catch
            {
                Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Error processing zip file.") -ForegroundColor Red
            }
        }
    }
    else
    {
        Write-Host ('[' + (Get-Date).ToString('dd/MM/yyyy hh:mm:ss') + "] [ERRR]: Couldn't retrieve release information (HTTP Status Code: $($ReleasesPage.StatusCode)).") -ForegroundColor Red
    }
}

Export-ModuleMember -Function Write-Message
Export-ModuleMember -Function Write-ScriptHeader
Export-ModuleMember -Function Enable-LogWriting
Export-ModuleMember -Function Disable-LogWriting
Export-ModuleMember -Function Write-BlankLine
Export-ModuleMember -Function Update-SimplePSLogging