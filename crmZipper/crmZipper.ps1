$rootAzurePath = "N:\" 
function generateAzurePath($root , $path ,$srvName){
    $returnPath = Split-Path ($path.replace("$root\" , "$rootAzurePath$srvName\")) 
    return $returnPath
}
function checkAndCreatePath($path){
    if(!(Test-Path $path)){
        New-Item -Path $path -Force -Name "abcdefghijklmnopqrstuvwxyz.txt"
        Remove-Item "$path\abcdefghijklmnopqrstuvwxyz.txt"
    }
}
function Zip($apps , $root , $days){
    foreach($app in $apps){
        $currPath = "$root\$app"
        $files = gci -Path $currPath -Recurse -Include("*.txt" , "*.log") | where{$_.LastWriteTime -lt (Get-Date).AddDays($days)}
        foreach($file in $files){
            try{
                $fullPath = $file.FullName
                $base = $file.BaseName
                $dest = (Split-Path -path $fullPath)+"\$base.zip"
                $lastWriteTime = $file.LastWriteTime
                Compress-Archive -Path $fullPath -DestinationPath $dest -CompressionLevel Optimal -ErrorAction Stop
                (Get-Item $dest).LastWriteTime = $lastWriteTime
                Remove-Item $fullPath
            }catch{write-host "failed"}
        }
    }
}
function TransferToAzure($apps , $root, $serverName){
    foreach($app in $apps){
        $currPath = "$root\$app"
        $files = gci -Path $currPath -Recurse -Include("*.zip")
        foreach($file in $files){
            try{
                $fullPath = $file.FullName
                $azureDest = generateAzurePath $root $fullPath $serverName
                checkAndCreatePath $azureDest

                Move-Item -Path $fullPath -Destination $azureDest -ErrorAction Stop
            }catch{write-host "failed"}
        }
    }
}

$servers = Get-Content -Raw -path "serverList.json" | ConvertFrom-Json
foreach($server in $servers.PSObject.Properties){
    $serverName = $server.Name
    $apps = ($server.Value).apps
    $days = -($server.Value).days
    $root = ($server.Value).root
    Zip $apps $root $days
    TransferToAzure $apps $root $serverName
}