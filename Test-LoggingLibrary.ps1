Import-Module 'C:\Users\HammoTime\Desktop\Logging-Library.psm1' -Force

Write-ScriptHeader 'Test Script I' '1.0.0' 'A Company'
Write-Message 'This is a test'
Write-Message 'This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window.'
Write-Message 'This is an error message' ERRR
Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red
Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black
Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black -NoDate
Write-Message 'I am about to enable file logging now' WARN -ForegroundColor Yellow
Enable-LogWriting "C:\Temp\TestLog-$((Get-Date).Ticks.ToString())-1.txt"
For($i = 0; $i -lt 100; $i++)
{
    Write-ScriptHeader 'Test Script I' '1.0.0' 'A Company' -DontClearScreen
    Write-Message 'This is a test'
    Write-Message 'This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window.'
    Write-Message 'This is an error message' ERRR
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black -NoDate
    Write-Message 'I am about to enable file logging now' WARN -ForegroundColor Yellow
}
Disable-LogWriting
Disable-LogWriting
For($i = 0; $i -lt 100; $i++)
{
    Write-ScriptHeader 'Test Script I' '1.0.0' 'A Company' -DontClearScreen
    Write-Message 'This is a test'
    Write-Message 'This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window.'
    Write-Message 'This is an error message' ERRR
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black -NoDate
    Write-Message 'I am about to enable file logging now' WARN -ForegroundColor Yellow
}
Enable-LogWriting "C:\Temp\TestLog-$((Get-Date).Ticks.ToString())-2.txt"
For($i = 0; $i -lt 100; $i++)
{
    Write-ScriptHeader 'Test Script I' '1.0.0' 'A Company' -DontClearScreen
    Write-Message 'This is a test'
    Write-Message 'This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window. This is a very long test that wouldn''t fit on a normal PS window.'
    Write-Message 'This is an error message' ERRR
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black
    Write-Message 'This is a coloured error message' ERRR -ForegroundColor Red -BackgroundColor Black -NoDate
    Write-Message 'I am about to enable file logging now' WARN -ForegroundColor Yellow
}
Disable-LogWriting
Enable-LogWriting "C:\A Location That Doesn't Exist\Log.txt"