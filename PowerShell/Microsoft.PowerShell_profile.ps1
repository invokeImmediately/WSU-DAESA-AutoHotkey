####################################################################################################
# Microsoft.PowerShell_profile.ps1, v0.3.0
# ----------------------------------------
# PowerShell profile of Daniel C. Rieck.
#
# MIT License — Copyright (c) 2020 Daniel C. Rieck
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
####################################################################################################

###############
# §1: Functions

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

Function Copy-Current-Path {
	scb ( "'" + (gl).Path + "'" )
}

Function Copy-GitHub-Repos-CSV-List {
    scb ( Get-Array-of-GitHub-Repos() -Join ", " )
}

Function Copy-Profiles-Path {
    scb ( gci -Path $Profile | %{ $_.Directory.FullName } )
}

Function Get-Archives { gci -Attributes Archive }

Function Get-Directories { gci -Attributes Directory }

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

Function Get-Array-of-GitHub-Repos {
    [ string[] ]$PathsToRepos = @(
        'C:\GitHub\ace.daesa.wsu.edu',
        'C:\GitHub\admissions.wsu.edu-research-scholars',
        'C:\GitHub\ascc.wsu.edu',
        'C:\GitHub\commonreading.wsu.edu',
        'C:\GitHub\daesa.wsu.edu',
        'C:\GitHub\distinguishedscholarships.wsu.edu',
        'C:\GitHub\firstyear.wsu.edu',
        'C:\GitHub\learningcommunities.wsu.edu',
        'C:\GitHub\lsamp.wsu.edu',
        'C:\GitHub\nse.wsu.edu',
        'C:\GitHub\nsse.wsu.edu',
        'C:\GitHub\phibetakappa.wsu.edu',
        'C:\GitHub\provost.wsu.edu_daesa_esteemed',
        'C:\GitHub\summerresearch.wsu.edu',
        'C:\GitHub\surca.wsu.edu',
        'C:\GitHub\teachingacademy.wsu.edu',
        'C:\GitHub\transfercredit.wsu.edu',
        'C:\GitHub\ucore.wsu.edu',
        'C:\GitHub\ucore.wsu.edu-assessment',
        'C:\GitHub\undergraduateresearch.wsu.edu'
    )
    Return $PathsToRepos
}

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

Function Get-Image-List {
	gci ("*.jpg", "*.png") | Get-Image | Select Filename, Width, Height, HdWScalar, HdVScalar, HdXOrigin, HdYOrigin | ft -auto | Out-File .\list_image-dimensions.txt -Confirm	
}

Function Invoke-Git-Log {
	Param(
		[Parameter(ValueFromPipeline=$true)]
		[string]
		$num = "20"
	)
	git --no-pager log --pretty="format:%h | %cn | %cd | %s%n ╘═> %b%n" -$num
}

Function Invoke-Git-Diff {
	Param(
		[Parameter(Mandatory=$true,
		ValueFromPipeline=$true)]
		[string]
		$file
	)
	git --no-pager diff $file
}

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
