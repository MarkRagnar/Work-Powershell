#Move files listed in CSV from source to destination
$Files = import-csv  "H:\Templates and Guides\whitepapers\source.csv"
$Files | ForEach-Object {
    Copy-Item -Path $_.Fullname -Destination $_.TargetPath
    #Remove-item $_.File
    
}
