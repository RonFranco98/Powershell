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
    try{
        $CurrIP = $server.Value
        Write-Host "Stopping - " $server.Name
        Get-Service -Name mtwdsrv -ComputerName $CurrIP | stop-Service -ErrorAction Stop
        sleep 30
        Write-Host "Starting - " $server.Name
        Get-Service -Name mtwdsrv -ComputerName $CurrIP | start-Service -ErrorAction Stop

    }catch{
        Add-Content $LogFilePath ("there was an error in: "+$server.Value)
    }
}
