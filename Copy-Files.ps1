#Move files listed in CSV from source to destination
$Files = import-csv  "H:\Templates and Guides\whitepapers\source.csv"
$targetDir = "C:\Test" 
$Files | ForEach-Object {
    Copy-Item -Path $_.File -Destination $targetDir -Recurse -Container
    #Remove-item $_.File
    
}
