## definding function for future use
function CreateLog($Path){
    if(!(Test-Path $Path)){
        New-Item -path $Path
    }
}
function Zip($Items , $DaysAgo , $DestUNC , $TimeStamp , $LogFilePath, $Name, $JobName, $SrcUNC){
    try{
        $itemstozip = $Items | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($DaysAgo) -and $_.LastWriteTime -lt (Get-Date).AddDays(-2))}
        $itemstozip | Compress-Archive  -DestinationPath ($DestUNC +"\"+ $TimeStamp) -CompressionLevel Optimal -ErrorAction Stop
        foreach($file in $itemstozip){
            Remove-Item "$SrcUNC\$File"
        }
    }catch{
        Add-Content -path $LogFilePath ((Get-Date -f HH:mm:ss) + " there was an error in Job:"+$JobName+" on server:"+$Name+" while compressing")
    }
}

function Transfer($Items , $DaysAgo , $DestUNC , $LogFilePath, $Name ,$JobName){
    try{
        $Items |
        Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($DaysAgo) -and $_.LastWriteTime -lt (Get-Date).AddDays(-2))} |
        Move-Item -Destination $DestUNC -ErrorAction stop
    }catch{
        Add-Content -path $LogFilePath ((Get-Date -f HH:mm:ss) + " there was an error in Job:"+$JobName+" on server:"+$Name+" while transfering files")
    }
}

function Backup($Items, $DestUNC, $LogFilePath, $Name ,$JobName){
    try{
        $LastBackupDate = (Get-ChildItem $DestUNC) | Measure-Object -Property LastWriteTime -Maximum | Select-Object -Property Maximum
            
        $Items | 
        Where-Object {($_.LastWriteTime -gt $LastBackupDate.Maximum -and $_.LastWriteTime -lt (Get-Date).AddDays(-2))} |
        Copy-Item -Destination $DestUNC -ErrorAction Stop
    }catch{
        Add-Content -path $LogFilePath ((Get-Date -f HH:mm:ss) + " there was an error in Job:"+$JobName+" on server:"+$Name+" while Backuping")
    }
}
function getUNC($IP , $Drive , $Path){
    return "\\"+$IP+"\"+$Drive+"$\"+$Path
}




$JSONFilePath = $PSScriptRoot+'\ServerList.json'
$JSONTree = Get-Content $JSONFilePath -Raw | ConvertFrom-Json
$TimeStamp = Get-Date -f yyyy-MM-dd
$LogFilePath = $PSScriptRoot+"\Logs\"+$TimeStamp+".txt"
CreateLog $LogFilePath

foreach($Server in $JSONTree.PSObject.Properties){
    $Name = $server.Name
    foreach($Job in $Server.Value.PSObject.Properties){
        #getting Data from Json File
        $JobName = $Job.Name
        $SrcIP = $Job.Value.SrcIP
        $SrcDrive = $Job.Value.SrcDrive
        $SrcPath = $Job.Value.SrcPath
        $SrcUNC = getUNC $SrcIP $SrcDrive $SrcPath
        $DestUNC = $Job.Value.DestUNC 
        $Operation = $Job.Value.Operation
        $DaysAgo = $Job.Value.DaysAgo

        $Items = Get-ChildItem -Path $SrcUNC -File

        #opertions
        if($Operation -eq "Zip"){
            Zip $Items $DaysAgo $DestUNC $TimeStamp $LogFilePath $Name $JobName $SrcUNC
        }
        if($Operation -eq "Transfer"){
            Transfer $Items $DaysAgo $DestUNC $LogFilePath $Name $JobName
        }
    
        if($Operation -eq "Backup"){
            Backup $Items $DestUNC $LogFilePath $Name $JobName
        }
    }
}
