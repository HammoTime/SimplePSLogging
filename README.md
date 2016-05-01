# SimplePSLogging
A simple PowerShell logging library.

## Install
```Powershell
# Must be run as an administrator.
ICM -ScriptBlock ([ScriptBlock]::Create((IWR https://git.io/vwM52).Content))
```

## Updating
```Powershell
# Must be run as an administrator.
Update-SimplePSLogging
```

## Usage

```Powershell

Enable-FileLogging 'C:\Temp\Log.txt'
Write-Message 'This is an error message!' ERRR
Disable-FileLogging

```
