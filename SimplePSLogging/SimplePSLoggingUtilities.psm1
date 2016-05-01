<#
    Version:        1.1.0.0
    Author:         Adam Hammond
    Creation Date:  02/05/2016
    Last Change:    Created file.
    Description:    Contains utility functions that enhance SimplePSLogging
                    
    Link:           https://github.com/HammoTime/SimplePSLogging
    License:        The MIT License (MIT)
#>

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

Export-ModuleMember -Function Update-SimplePSLogging