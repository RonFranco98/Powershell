#here you set the absolute path of th NSSM. if the folder that you put LeverateCrasher is deiffernt you need to change it
Set-Location "C:\Tools\LeverateCrasher\nssm-2.24\win64"

#here you put the executable. same drill but add nssm.exe
$nssm = "C:\tools\LeverateCrasher\nssm-2.24\win64\nssm.exe"

#no need to change
$serviceName = 'LeverateCrasher'
$powershell = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

#this is the path of the crash script. from this file the service will be built
$scriptPath = 'C:\tools\LeverateCrasher\crash.ps1'

#do not change
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
& $nssm install $serviceName $powershell $arguments
& $nssm status $serviceName
Start-Service $serviceName
Get-Service $serviceName