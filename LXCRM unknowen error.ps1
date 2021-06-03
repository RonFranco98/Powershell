$UUID = Read-Host "please enter the UUID"
$File1 = Get-ChildItem -Path "C:\classifyed sorry" | sort LastWriteTime |select -Last 5


function makeTextFile($UUID , $contect){
    New-Item -Name "$UUID.txt"
    $str1 = ($contect | Select-String "Started a new business transaction;") -split ";"
    $fields1 = ($str1[1]) -split ","
    $str2 = ($contect | Select-String "with parameters: realAccountRegistrationRequest:") -split "with parameters"
    $fields2 = "parameters"+$str2[1]
    Add-Content "$UUID.txt" -Value $fields1
    Add-Content "$UUID.txt" -Value $fields2
}
function getTable($FIles , $UUID){
    foreach($FIle in $FIles){
        $contect = Get-Content $FIle.fullname | Select-String $UUID
        if($contect){
            makeTextFile $UUID $contect
            write-host "found in file" + $file.fullName

            read-host "please check the text file (:"
            exit
        }
    }
}
getTable $File1 $UUID
getTable $File2 $UUID
getTable $File3 $UUID
getTable $File4 $UUID
getTable $File5 $UUID
getTable $File6 $UUID

