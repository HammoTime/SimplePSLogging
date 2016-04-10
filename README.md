# SimplePSLogging
A simple PowerShell logging library.

## Install
```Powershell
# Must be run as an administrator.
$D = ($PSHome + '\Modules\SimplePSLogging\'); New-Item $D -ItemType Directory -Force; @( @('https://git.io/vV9jv', 'psd1'), @('https://git.io/vV9jJ', 'psm1') ) | % { IWR $_[0] -OutFile ($D + 'SimplePSLogging.' + $_[1]) }
```

## Usage

```Powershell

Enable-FileLogging 'C:\Temp\Log.txt'
Write-Message 'This is an error message!' ERRR
Disable-FileLogging

```
