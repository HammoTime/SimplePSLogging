# SimplePSLogging
A simple PowerShell logging library.

## Install
```
# Must be run as an administrator.
Invoke-WebRequest 'https://github.com/HammoTime/SimplePSLogging/blob/master/Logging-Library.psm1' -OutFile ($PSHome + '\Modules\Logging-Library.psm1')
```

## Usage

```Powershell

Enable-FileLogging 'C:\Temp\Log.txt'
Write-Message 'This is an error message!' ERRR
Disable-FileLogging

```
