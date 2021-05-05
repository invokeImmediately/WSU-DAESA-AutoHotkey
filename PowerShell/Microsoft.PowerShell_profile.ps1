####################################################################################################
# ▐▀▄▀▌▀█▀ ▄▀▀▀ █▀▀▄ ▄▀▀▄ ▄▀▀▀ ▄▀▀▄ █▀▀▀▐▀█▀▌  █▀▀▄ ▄▀▀▄▐   ▌█▀▀▀ █▀▀▄ ▄▀▀▀ █  █ █▀▀▀ █    █   
# █ ▀ ▌ █  █    █▄▄▀ █  █ ▀▀▀█ █  █ █▀▀▀  █    █▄▄▀ █  █▐ █ ▌█▀▀  █▄▄▀ ▀▀▀█ █▀▀█ █▀▀  █  ▄ █  ▄
# █   ▀▀▀▀  ▀▀▀ ▀  ▀▄ ▀▀  ▀▀▀   ▀▀  ▀     █  ▀ █     ▀▀  ▀ ▀ ▀▀▀▀ ▀  ▀▄▀▀▀  █  ▀ ▀▀▀▀ ▀▀▀  ▀▀▀ 
#
#            █▀▀▄ █▀▀▄ ▄▀▀▄ █▀▀▀ ▀█▀ █    █▀▀▀   █▀▀▄ ▄▀▀▀ ▄█  
#            █▄▄▀ █▄▄▀ █  █ █▀▀▀  █  █  ▄ █▀▀    █▄▄▀ ▀▀▀█  █  
#        ▀▀▀ █    ▀  ▀▄ ▀▀  ▀    ▀▀▀ ▀▀▀  ▀▀▀▀ ▀ █    ▀▀▀  ▄█▄▌
# --------------------------------
# PowerShell profile of Daniel C. Rieck used when working on web coordination and development of
#   websites for the Division of Academic Engagement and Student Achievement at Washington State
#   University.
#
# @version 1.0.0
#
# @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
# @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/master…
#   …/PowerShell/Microsoft.PowerShell_profile.ps1
# @link [Root:]\Users\[user]\[Windows Documents]\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# @link [Server Root]/[Folder(s)]/Backups/PowerShell Scripts/Microsoft.PowerShell_profile.ps1
# @license MIT License — Copyright (c) 2021 Daniel C. Rieck
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
#     and associated documentation files (the "Software"), to deal in the Software without
#     restriction, including without limitation the rights to use, copy, modify, merge, publish,
#     distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
#     Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or
#     substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
#     BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#     DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
####################################################################################################

###############
# §1: Functions

########
### §1.1: Compare-Directories
###   Find differences in the file structure between two directories.
Function Compare-Directories {
	Param (
		[ Parameter( Mandatory=$true ) ]
		[ string ]
		$diffName,

		[ Parameter( Mandatory=$true ) ]
		[ string ]
		$refName
	)
	Try
	{
		$diffItem = Get-Item -ErrorAction Stop -Path $diffName
		$refItem = Get-Item -ErrorAction Stop -Path $refName
		$fsoDiff = gci -ErrorAction Stop -Recurse -path $diffName | ? { $_.FullName -notmatch "node_modules" }
		$fsoRef = gci -ErrorAction Stop -Recurse -path $refName | ? { $_.FullName -notmatch "node_modules" }
		$separator = "-" * 100
		Write-Host (-join ($separator, "`nResults of Compare-Object with basis as name, length.`nDifference Object (=>) ", $diffItem.FullName, "`nReference Object (<=) ", $refItem.FullName, "`n", $separator))
		Compare-Object -ErrorAction Stop -ReferenceObject $fsoRef -DifferenceObject $fsoDiff -Property Name,Length, -PassThru | Format-Table SideIndicator, Name, @{Label="Length (kb)"; Expression={[math]::Round( ( $_.Length / 1kb ),1 ) } }, LastWriteTime
	}
	Catch
	{
		$itemName = $_.Exception.ItemName
		if ([string]::IsNullOrEmpty($itemName)) {
			$itemName = "Script error"
		}
		Write-Host (-join ($itemName, ": ", $_.Exception.Message))
	}
}

########
### §1.2: Copy-Current-Path
###   Copy the current path to the clipboard.
Function Copy-Current-Path {
	scb ( "'" + (gl).Path + "'" )
}

########
### §1.3: Copy-Daesa-Website-Urls-List
###   Copy the list of DAESA websites I regularly work with to the clipboard.
Function Copy-Daesa-Website-Urls-List {
	$urls = Get-Array-of-Daesa-Website-Urls
	scb ( $urls )
}

########
### §1.4: Copy-GitHub-Repos-CSV-List
###   Copy the CSV-formatted list of DAESA websites I regularly work with to the clipboard.
Function Copy-GitHub-Repos-CSV-List {
	$repos = Get-Array-of-GitHub-Repos
	scb ( ( -split $repos ) -Join ", " )
}

########
### §1.5: Copy-GitHub-Repos-List
###   Copy the list of repository folders associated with the GitHub projects for developing the
###     DAESA websites I regularly work with to the clipboard.
Function Copy-GitHub-Repos-List {
	$repos = Get-Array-of-GitHub-Repos
	scb ( $repos )
}

########
### §1.6: Copy-Profiles-Path
###   Copy the path where PowerShell profiles are stored on the local machine.
Function Copy-Profiles-Path {
	scb ( gci -Path $Profile | %{ $_.Directory.FullName } )
}

########
### §1.7: Find-Files-in-GitHub-Repos
###   Use a filter to search for files within GitHub project repos associated with front-end web
###     development work for WSU DAESA.
Function Find-Files-in-GitHub-Repos {
	Param (
		[ Parameter( Mandatory = $false,
			ValueFromPipelineByPropertyName = $true ) ]
		[ string ]
		$FileFilter = "*"
	)
	$Paths = Get-Array-of-GitHub-Repos
	$Excludes = Get-Array-of-Github-Folder-Excludes
	Write-Output @(
		"Searching for '$FileFilter' in all repos for DAESA web development projects."
		"+-The following exclusions will apply to full path names: "
		( "| +-" + $Excludes )
		"+-Please wait, this will take some time…"
	)
	$Files = Get-ChildItem -Path $Paths -Filter $FileFilter -Recurse |
		Where-Object { -not $_.FullName.contains( $Excludes ) } | %{
			$_.FullName
		}
	Write-Output "`r`nDone! Below are the full path names of all files found:"
	Write-Output $files
}

########
### §1.8: Get-Archives
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the archive 
###     attribute. 
Function Get-Archives { gci -Attributes Archive }

########
### §1.9: Get-Array-of-Github-Folder-Excludes
###   Get an array of filters used to exclude files or sub-folders when searching through GitHub
###     folders.
Function Get-Array-of-Github-Folder-Excludes {
	$Excludes = [ string[] ]$Excludes = @(
		'node_modules'
	)
	Return $Excludes
}

########
### §1.10: Get-Array-of-Daesa-Website-Urls
###   Get an array of URLs to DAESA's websites.
Function Get-Array-of-Daesa-Website-Urls {
	[ string[] ]$UrlsToDaesaSites = @(
		'https://ace.wsu.edu/'
		'https://ascc.wsu.edu/'
		'https://admission.wsu.edu/research-scholars/'
		'https://commonreading.wsu.edu/'
		'https://daesa.wsu.edu/'
		'https://distinguishedscholarships.wsu.edu/'
		'https://firstyear.wsu.edu/'
		'https://learningcommunities.wsu.edu/'
		'https://lsamp.wsu.edu/'
		'https://nse.wsu.edu/'
		'https://nsse.wsu.edu/'
		'https://phibetakappa.wsu.edu/'
		'https://provost.wsu.edu/oae/'
		'https://summerresearch.wsu.edu/'
		'https://surca.wsu.edu/'
		'https://teachingacademy.wsu.edu/'
		'https://transfercredit.wsu.edu/'
		'https://ucore.wsu.edu/'
		'https://ucore.wsu.edu/assessment/'
		'https://undergraduateresearch.wsu.edu/'
		'https://writingprogram.wsu.edu/'
	)
	Return $UrlsToDaesaSites
}

########
### §1.11: Get-Array-of-GitHub-Repos
###   Get an array of local paths to GitHub project repos associated with front-end web development
###     work for WSU DAESA.
Function Get-Array-of-GitHub-Repos {
	[ string[] ]$PathsToRepos = @(
		'C:\GitHub\ace.daesa.wsu.edu'
		'C:\GitHub\admissions.wsu.edu-research-scholars'
		'C:\GitHub\ascc.wsu.edu'
		'C:\GitHub\commonreading.wsu.edu'
		'C:\GitHub\daesa.wsu.edu'
		'C:\GitHub\distinguishedscholarships.wsu.edu'
		'C:\GitHub\firstyear.wsu.edu'
		'C:\GitHub\learningcommunities.wsu.edu'
		'C:\GitHub\lsamp.wsu.edu'
		'C:\GitHub\nse.wsu.edu'
		'C:\GitHub\nsse.wsu.edu'
		'C:\GitHub\phibetakappa.wsu.edu'
		'C:\GitHub\provost.wsu.edu_daesa_esteemed'
		'C:\GitHub\summerresearch.wsu.edu'
		'C:\GitHub\surca.wsu.edu'
		'C:\GitHub\teachingacademy.wsu.edu'
		'C:\GitHub\transfercredit.wsu.edu'
		'C:\GitHub\ucore.wsu.edu'
		'C:\GitHub\ucore.wsu.edu-assessment'
		'C:\GitHub\undergraduateresearch.wsu.edu'
	)
	Return $PathsToRepos
}

########
### §1.12: Get-Directories
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the directory 
###     attribute. 
Function Get-Directories { gci -Attributes Directory }

########
### §1.13: Get-Filtered-Archives
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the archive 
###     attribute, but employ a specified filter and possibly recursion. 
Function Get-Filtered-Archives {
	Param (
		[ Parameter( Mandatory=$true ) ]
		[ string ]
		$filter,

		[ Parameter( Mandatory=$false ) ]
		[ bool ]
		$recurse = $false
	)
	If ( $recurse -eq $true ) {
		gci -Attributes Archive -Filter $filter -Recurse
	} Else {
		gci -Attributes Archive -Filter $filter
	}
}

########
### §1.14: Get-Filtered-Directories
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the directory 
###     attribute, but employ a specified filter and possibly recursion. 
Function Get-Filtered-Directories {
	Param (
		[ Parameter( Mandatory=$true ) ]
		[ string ]
		$filter,

		[ Parameter( Mandatory=$false ) ]
		[ bool ]
		$recurse = $false
	)
	If ( $recurse -eq $true ) {
		gci -Attributes Directory -Filter $filter -Recurse
	} Else {
		gci -Attributes Directory -Filter $filter
	}
}

########
### §1.15: Get-Image
###   Get the properties of an image file.
Function Get-Image {
	Param(
		[Parameter(ValueFromPipeline=$true)]
		[System.IO.FileInfo]
		$file
	)
	begin {
		[System.Reflection.Assembly]::LoadWithPartialName( "System.Drawing" ) | Out-Null 
	}
	process {
		if ( $file.Exists ) {
			$fsImg = [System.Drawing.Image]::FromFile( $file )
			$image =  $fsImg.Clone()
			$fsImg.Dispose()
			$aspectRatio = $image.Width / $image.Height
			## Assumes the image has been scaled to size ###############################
			# $hdWScalar = [math]::Round( $image.Width / 1920, 4 )
			# $hdXOrigin = $image.Width / 2 - 906
			# $hdVScalar = [math]::Round( $image.Height / 1080, 4 )
			# $hdYOrigin = 486 - $image.Height / 2
			$hdWScalar = [math]::Round( 809 / $image.Height * $image.Width / 1920, 4 )
			$hdXOrigin = 809 / $image.Height * $image.Width / 2 - 906
			$hdVScalar = [math]::Round( $image.Height / 1080 * 809 / $image.Height, 4 )
			$hdYOrigin = 486 - 809 / $image.Height * $image.Height / 2
			$image | Add-Member `
				-MemberType NoteProperty `
				-Name FilePath `
				-Value $file.Fullname
			$image | Add-Member `
				-MemberType NoteProperty `
				-Name Filename `
				-Value $file.Name
			$image | Add-Member `
				-MemberType NoteProperty `
				-Name HdWScalar `
				-Value $hdWScalar
			$image | Add-Member `
				-MemberType NoteProperty `
				-Name HdVScalar `
				-Value $hdVScalar
			$image | Add-Member `
				-MemberType NoteProperty `
				-Name HdXOrigin `
				-Value $hdXOrigin
			$image | Add-Member `
				-MemberType NoteProperty `
				-Name HdYOrigin `
				-Value $hdYOrigin `
				-PassThru
		} else {
			Write-Host "File not found: $file" -fore yellow
		}
	}
	end {
	}
}

########
### §1.16: Get-Image-List
###   Get a list of properties for JPG and PNG images present in the current folder.
Function Get-Image-List {
	gci ("*.jpg", "*.png") | Get-Image | Select Filename, Width, Height, HdWScalar, HdVScalar, HdXOrigin, HdYOrigin | ft -auto | Out-File .\list_image-dimensions.txt -Confirm	
}

########
### §1.17: Invoke-Git-Log
###   Execute a preferred form of the git log command in the terminal.
Function Invoke-Git-Log {
	Param(
		[Parameter(ValueFromPipeline=$true)]
		[string]
		$num = "20"
	)
	git --no-pager log --pretty="format:%h | %cn | %cd | %s%n ╘═> %b%n" -$num
}

########
### §1.18: Invoke-Git-Diff
###   Execute a preferred form of the git diff command in the terminal.
Function Invoke-Git-Diff {
	Param(
		[Parameter(Mandatory=$true,
		ValueFromPipeline=$true)]
		[string]
		$file
	)
	git --no-pager diff $file
}

########
### §1.19: Open-GitHub-Folder
###   Move the terminal's location to the primary GitHub folder on the local machine.
Function Open-GitHub-Folder {
	cd C:\GitHub
}

#############
# §2: Aliases

Set-Alias -Name ccp -Value Copy-Current-Path

Set-Alias -Name compdirs -Value Compare-Directories

Set-Alias -Name chrome -Value 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'

Set-Alias -Name gcia -Value Get-Archives

Set-Alias -Name gcid -Value Get-Directories

Set-Alias -Name gcifa -Value Get-Filtered-Archives

Set-Alias -Name gcifd -Value Get-Filtered-Directories

Set-Alias -Name ghgl -Value Invoke-Git-Log

Set-Alias -Name gtgh -Value Open-GitHub-Folder

Set-Alias -Name ghgd -Value Invoke-Git-Diff
