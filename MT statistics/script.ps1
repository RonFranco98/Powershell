Set-Location "C:\RonTools\MT statistics\res"
$temp = (Get-Date).AddDays(-3)
$date = get-date $temp -Format "yyyyMMdd"
$outFile = "$date.txt"
$fileName = "$date.log"

$Paths = @(
    "\\classified\D$\classified\logs\$fileName",
    "\\classified\D$\classified\logs\$fileName",
    "\\classified\D$\classified\logs\$fileName",
    "\\classified\D$\classified\logs\$fileName",
    "\\classified\E$\classified\logs\$fileName",
    "\\classified\E$\classified\logs\$fileName",
    "\\classified\D$\classified\logs\$fileName"
)

function getLine ($path){
    $contant = Get-Content $path
    foreach($line in $contant){
        if($line.Contains("12:00")){
            if($line.Contains("Monitor	connections")){
                Remove-Variable contant
                return $line
            }
        }
    }
    Remove-Variable contant
}

function getNum ($str){
    return ((($str -split "Monitor	connections: ")[1]) -split " ")[0]
}

New-Item $outFile
foreach($mt in $Paths){
    $currLine = getLine $mt
    Write-Host $currLine
    $currNum = getNum $currLine
    Write-Host $currNum
    Add-Content $outFile -Value $currNum
}

read-host "click any key"

 