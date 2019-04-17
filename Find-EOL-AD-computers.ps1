### https://github.com/border-blaster/Check-Active-Directory-for-end-of-life-computers
### v.2019-04-17

### Register functions for later
function HashMarks {
    $mark = 0
    do {
        write-host "#" -NoNewline
        $mark++
      } until ($mark -eq 60)
}


### Get the OS EOL data from Github. 
$FullyOSEOL = ConvertFrom-CSV (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/border-blaster/Check-Active-Directory-for-end-of-life-computers/master/os_eol_data.csv' -UseBasicParsing).ToString()

$CompsWithVersions = Get-ADComputer  -Filter 'Operatingsystem -like "*Windows*"'  -Properties operatingsystem, operatingsystemversion | select-object name, operatingsystem, operatingsystemversion | Sort-Object name
###

#Out of date
$OutOfDate = @()
foreach ($EOLDate in $FullyOSEOL) {
    if ([datetime]::parseexact($EOLDate.EOLDate, 'yyyy-MM-dd', $null) -lt (get-date)) {
        foreach ($Compo in $CompsWithVersions) {
            if ($Compo.operatingsystem -eq $EOLDate.OS -and $Compo.operatingsystemversion -eq $EOLDate.OSVer) {
                $OutOfDate += $Compo
            }
        }
    }
}

#Out of date in 1 year
$1yOutOfDate = @()
foreach ($EOLDate in $FullyOSEOL) {
    if ([datetime]::parseexact($EOLDate.EOLDate, 'yyyy-MM-dd', $null) -gt (get-date) -and [datetime]::parseexact($EOLDate.EOLDate, 'yyyy-MM-dd', $null) -lt (get-date).AddMonths(12) ) {
        foreach ($Compo in $CompsWithVersions) {
            if ($Compo.operatingsystem -eq $EOLDate.OS -and $Compo.operatingsystemversion -eq $EOLDate.OSVer) {
                $1yOutOfDate += $Compo
            }
        }
    }
}

#Good for at least a year - You don't really need to do this part as these comptuers won't need to be replaced for awhile.
$1yplusOutOfDate = @()
foreach ($EOLDate in $FullyOSEOL) {
    if ([datetime]::parseexact($EOLDate.EOLDate, 'yyyy-MM-dd', $null) -gt (get-date).AddMonths(12) ) {
        foreach ($Compo in $CompsWithVersions) {
            if ($Compo.operatingsystem -eq $EOLDate.OS -and $Compo.operatingsystemversion -eq $EOLDate.OSVer) {
                $1yplusOutOfDate += $Compo
            }
        }
    }
}


### Output
# Total count of computers checked - using a little math you can check if any systems got skipped.
write-host $CompsWithVersions.count " - Total computers found" 

#Out of date
write-host $OutOfDate.count " - Computers past end of life" -ForegroundColor Red
HashMarks
$OutOfDate | Format-Table

#Out of date in 1 year
write-host $1yOutOfDate.count " - Computers going EOL in the next year" -ForegroundColor yellow
HashMarks
$1yOutOfDate  | Format-Table

# #Good for at least a year - Not needed if you remove the 'good for at least a year' section
write-host $1yplusOutOfDate.count " - Computers with more than a year left till EOL"
HashMarks
$1yplusOutOfDate  | Format-Table
