#here you put the absolut path of the folder you want to copy from:
$src = "E:\MetaTraderServer4\logs\crash"

#here you put the absolute folder you want to copy to :
$dest = "E:\MetaTraderServer4\LeverateCrasher"

#setting the watcher object
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $src
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher "Created" -Action {
    Copy-Item ($src+"\*") -Destination $dest -force
}
Register-ObjectEvent $watcher "Changed" -Action {
    Copy-Item ($src+"\*") -Destination $dest -force
}


while($true) {sleep 5}