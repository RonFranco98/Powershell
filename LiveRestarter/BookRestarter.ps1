function CreateLog($Path){
    if(!(Test-Path $Path)){
        New-Item -path $Path
    }
}

$TimeStamp = Get-Date -f yyyy-MM-dd
$LogFilePath = $PSScriptRoot+"\Logs\"+$TimeStamp+".txt"
CreateLog $LogFilePath

$filePath = $PSScriptRoot+"\ServerList.Json"
$jsonTree = Get-Content $filePath -Raw | ConvertFrom-Json
foreach($server in $jsonTree.PSObject.Properties){
    do{
        $CurrIP = $server.Value
        Write-Host "Stopping Live in - " $server.Name " - " $CurrIP
        (Get-WmiObject Win32_Process -ComputerName $CurrIP | ?{ $_.ProcessName -match "Live" }).Terminate()
        sleep 10
        $service = Get-Service -Name LeverateLiveServiceV2.8 -ComputerName $CurrIP
        Start-Service $service
        sleep 10
    }
    while($service.Status -ne 'Running')
}
foreach($server in $jsonTree.PSObject.Properties){
    $service = Get-Service -Name LeverateLiveServiceV2.8 -ComputerName $server.Value
    Write-Host $server.Value + " status is:" + $service.Status
}
Read-Host "press any key to exit"

