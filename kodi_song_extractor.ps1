Import-Module Mysql

#
# SQL Query to select the songs you want to be added
# In this example I am selecting songs that I've rated 4* out of 5 or higher if not in lounge folder,
# and 4.5* out of 5 or higher if in the lounge folder
# It concats the Path and Filename to get an absolute path to the file
# Extracted songs will be stored in the Songs folde rin current directory

$query = "select concat(strPath,strFileName) as path from song s inner join path p on p.idPath = s.idPath where (userrating >= 8 and p.strPath not like '%/lounge%') or (userrating >= 9 and p.strPath like '%/lounge%')%';"

Write-Host "Copying Kodi DB Files using the following Query: "
Write-Host $query

$kodi_ip = "10.0.0.1"
$kodi_db = "MyMusic82"

$dbCred = Get-Credential
Connect-MySqlServer  -Credential $dbcred -ComputerName $kodi_ip -Database $kodi_db
$files = Invoke-MySqlQuery -Query $query

Write-Host "Starting..."

$count = 0
$success = 0
$fail = 0
$total = $files.count

for ($i = 0; $i -lt $files.count; $i++) {

    $count = $count + 1

    $filename = [System.IO.Path]::GetFileNameWithoutExtension($fileString)
    $filetype = [System.IO.Path]::GetExtension($fileString)
    $directory = [System.IO.Path]::GetDirectoryName($fileString)

    Write-Host "Copying $filename$filetype ($i of $total)`t`t"

    $x = copy-item -LiteralPath $fileString $PSScriptRoot\Songs -PassThru -force -errorvariable errors
    if ($x)
    {
        if ($filetype -ne ".mp3")
        {
             Write-Host "Converting to mp3" -foregroundColor yellow
             
            # Try and convert
            .\ffmpeg.exe -i $PSScriptRoot\Songs\$filename$filetype -b:a 320k "$PSScriptRoot\Songs\$filename.mp3"
            Write-Host "Removing $PSScriptRoot\Songs\$filename$filetype"
            Remove-Item $PSScriptRoot\Songs\$filename$filetype
        }

        Write-Host "Success" -foregroundColor green
        $success = $success + 1
    } 
    else
    {
        Write-Host "Fail" -ForegroundColor Red
        Write-Host $fileString -ForegroundColor Red

        foreach($error1 in $errors)
        {
            if ($error1.Exception -ne $null)
            {
                Write-Host $error1.Exception
            }
        }
        $fail = $fail + 1
    }
}


Write-Host "Done!"
Write-Host "Total Files copied: $count"
Write-Host "Total successful: $success"
Write-Host "Total fail: $fail"
Write-Host ($success / $count * 100) " %"

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
pause
