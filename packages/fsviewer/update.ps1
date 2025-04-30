import-module -Name au\AU

$latest_release_url = 'https://www.faststone.org/FSIVDownload.htm' 

#$latest_release = Invoke-WebRequest $latest_release_url | ConvertFrom-Json
#  $latest_release.Links | ? href -match '\.exe/download$' | % href

function global:au_GetLatest {
    $latest_release = Invoke-WebRequest $latest_release_url
	$url = $latest_release.Links | ? href -match '\.exe' | % href | Select-Object -first 1
	$Searchtext ='<font face="Verdana" size="2">FastStone Image Viewer '
	[string]$latestrelstr = $latest_release
	$index = $latestrelstr.IndexOf($Searchtext)
	$Version = $latestrelstr.Substring($index + $Searchtext.Length, 3)

    return @{        Version = $Version;		URL32 = $url    }
}

function global:au_SearchReplace {
	write-host $Latest.Checksum
    return @{
         'tools\chocolateyInstall.ps1' = @{            
            "(^[$]url\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
            "(^[$]checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"			
		}
	}
}

#function global:au_BeforeUpdate($pkg) {
#    $pkg.NuspecXml.package.metadata.releaseNotes = $global:Latest.ReleaseNotes.ToString()
#}

update -ChecksumFor 32 -force
