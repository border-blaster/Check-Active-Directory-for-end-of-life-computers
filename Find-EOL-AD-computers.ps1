### Get the OS EOL data from Github. 
$FullyOSEOL = ConvertFrom-CSV (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/border-blaster/Check-Active-Directory-for-end-of-life-computers/master/os_eol_data.csv').ToString()

$TodaysDate = get-date -Format yyyy-MM-dd
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

#Good for atleast a year
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


###
write-host "Out of date computers"
$OutOfDate

write-host "1 year left"
$1yOutOfDate

write-host "good for 1+ years"
$1yplusOutOfDate