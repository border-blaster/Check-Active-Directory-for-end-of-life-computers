### https://github.com/border-blaster/Check-Active-Directory-for-end-of-life-computers
### v.2019-05-31

### Register functions for later
function HashMarks {
    $mark = 0
    do {
        write-host "#" -NoNewline
        $mark++
      } until ($mark -eq 80)
}


### Get the OS EOL data from Github. 
$DATASource = 'https://raw.githubusercontent.com/border-blaster/Check-Active-Directory-for-end-of-life-computers/master/os_eol_data.csv'
$FullyOSEOL = ConvertFrom-CSV (Invoke-WebRequest -Uri $DATASource -UseBasicParsing).content.ToString()

$CompsWithVersions = Get-ADComputer  -Filter 'Operatingsystem -like "*Windows*"'  -Properties operatingsystem, operatingsystemversion | select-object name, operatingsystem, operatingsystemversion | Sort-Object name
###

#Out of date
$OutOfDate = @()
foreach ($EOLDate in $FullyOSEOL) {
    foreach ($Compo in $CompsWithVersions) {
        if ($Compo.operatingsystem -eq $EOLDate.OS -and $Compo.operatingsystemversion -eq $EOLDate.OSVer) {
            $OutOfDate += @([PSCustomObject]@{Name = $compo.Name;  Operatingsystem = $Compo.operatingsystem; Operatingsystemversion = $Compo.operatingsystemversion; EOLDate = $EOLDate.EOLDate})
        }
    }
}



#Add the days left until EOL
$SystemsWithEOLdays = @()
foreach ($SingleDate in $OutofDate) {
    #$DaystoGo = (New-TimeSpan -end $SingleDate.EOLDate -start (get-date -Format yyyy-MM-dd)).days
    $SystemsWithEOLdays += @([PSCustomObject]@{Name = $SingleDate.Name;  OS = $SingleDate.operatingsystem; OSver = $SingleDate.operatingsystemversion; EOLDate = $SingleDate.EOLDate; DaysToGo = (New-TimeSpan -end $SingleDate.EOLDate -start (get-date -Format yyyy-MM-dd)).days})
    }


### Output
# Total count of computers checked - using a little math you can check if any systems got skipped.
write-host $CompsWithVersions.count " - Total computers found" 

#Out of date
write-host $SystemsWithEOLdays.count " - Computer on list"
HashMarks

$SystemsWithEOLdays | Sort-Object DaystoGo, OS, OSver, Name | Format-Table

$SystemsWithEOLdays | sort-object DaystoGo | Group-Object -Property OS,OSver | Select-Object Name, Count

<#  ### Stuff I'm keeping around for error checking ###
$SystemsWithEOLdays2 = $SystemsWithEOLdays.name | sort-object
$CompsWithVersions2 = $CompsWithVersions.name | sort-object

Compare-Object $SystemsWithEOLdays2 $CompsWithVersions2 
#>
