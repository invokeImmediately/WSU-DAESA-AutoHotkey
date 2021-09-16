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
# @version 1.3.6
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
# TABLE OF CONTENTS:
####################
#   §1: Functions..............................................................................69
#     §1.1:  Compare-Directories...............................................................72
#     §1.2:  Copy-Current-Path................................................................105
#     §1.3:  Copy-Daesa-Website-Urls-List.....................................................112
#     §1.4:  Copy-GitHub-Repos-CSV-List.......................................................120
#     §1.5:  Copy-GitHub-Repos-List...........................................................128
#     §1.6:  Copy-Profiles-Path...............................................................137
#     §1.7:  Find-Files-in-GitHub-Repos.......................................................144
#     §1.8:  Get-Archives.....................................................................171
#     §1.9:  Get-Array-of-Github-Folder-Excludes..............................................179
#     §1.10: Get-Array-of-Daesa-Website-Urls..................................................190
#     §1.11: Get-Array-of-GitHub-Repos........................................................253
#     §1.12: Get-Array-of-Wsuwp-Operations....................................................283
#     §1.13: Get-Directory-Stats..............................................................305
#     §1.14: Get-Directories..................................................................439
#     §1.15: Get-Filtered-Archives............................................................447
#     §1.16: Get-Filtered-Directories.........................................................468
#     §1.17: Get-Image........................................................................489
#     §1.18: Get-Image-List...................................................................549
#     §1.19: Invoke-Git-Log...................................................................556
#     §1.20: Invoke-Git-Diff… Commands........................................................584
#     §1.21: Open-Daesa-Website...............................................................657
#     §1.22: Open-GitHub-Folder...............................................................722
#     §1.23: Open-GitHub-on-Chrome............................................................761
#     §1.24: Open-PowerShell-Instance.........................................................785
#     §1.25: Write-Commands-to-Host...........................................................797
#     §1.26: Write-Welcome-Msg-to-Host........................................................820
#   §2: Aliases...............................................................................862
#   §3: Execution Entry Point.................................................................901
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
    Compare-Object -ErrorAction Stop -ReferenceObject $fsoRef -DifferenceObject $fsoDiff -Property Name,Length,LastWriteTime -PassThru | Format-Table SideIndicator, Name, @{Label="Length (kb)"; Expression={[math]::Round( ( $_.Length / 1kb ),1 ) } }, LastWriteTime
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
Function Get-Archives {
  gci -Attributes Archive
}

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
###   @todo Add filtering capabilities
Function Get-Array-of-Daesa-Website-Urls {
  Param (
    [Parameter(Mandatory=$false)]
    [Alias("category", "cat")]
    [string]
    $ctgr = "",

    [Parameter(Mandatory=$false)]
    [Alias("nmm", "nm", "notmatch")]
    [bool]
    $notMatchMode = $false
  )

  # Specify the string of URLs to all DAESA websites we could potentially work with prepended by
  #   category designators.
  [ string[] ]$UrlsToDaesaSites = @(
    'daesa|https://ace.wsu.edu/'
    'other|https://advising.wsu.edu/'
    'daesa|https://ascc.wsu.edu/'
    'daesa|https://admission.wsu.edu/research-scholars/'
    'daesa|https://commonreading.wsu.edu/'
    'daesa|https://cougarsuccess.wsu.edu/'
    'daesa|https://daesa.wsu.edu/'
    'daesa|https://distinguishedscholarships.wsu.edu/'
    'other|https://emeritussociety.wsu.edu/'
    'daesa|https://firstyear.wsu.edu/'
    'daesa|https://learningcommunities.wsu.edu/'
    'daesa|https://lsamp.wsu.edu/'
    'ugr|daesa|https://marc.wsu.edu/'
    'ugr|daesa|https://mira.wsu.edu/'
    'oae|https://nse.wsu.edu/'
    'other|https://nsse.wsu.edu/'
    'other|https://phibetakappa.wsu.edu/'
    'oae|https://provost.wsu.edu/oae/'
    'other|https://provost.wsu.edu/teaching-academy/'
    'ugr|daesa|https://summerresearch.wsu.edu/'
    'ugr|daesa|https://surca.wsu.edu/'
    'daesa|https://transfercredit.wsu.edu/'
    'daesa|https://ucore.wsu.edu/'
    'daesa|https://ucore.wsu.edu/assessment/'
    'ugr|daesa|https://undergraduateresearch.wsu.edu/'
    'daesa|https://writingprogram.wsu.edu/'
    'other|https://wsuacada.wsu.edu/'
  )

  # Filter the URL list by category, if any.
  if ( $ctgr -eq "" ) {
    $ctgr = ".*?"
  }
  if ( $notMatchMode ) {
    $UrlsToDaesaSites = ( $UrlsToDaesaSites -notmatch ( $ctgr + '\|' ) ) -replace  '.+\|(.+?)$', '$1'
  } else {
    $UrlsToDaesaSites = ( $UrlsToDaesaSites -match ( $ctgr + '\|' ) ) -replace  '.+\|(.+?)$', '$1'
  }

  # Return a filtered list of URLs.
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

#########
### §1.12: Get-Array-of-Wsuwp-Operatons
function Get-Array-of-Wsuwp-Operations {
  [ string[] ]$Operations = @(
    'admin|login|wp-admin/'
    'gf|gravity-forms|wp-admin/admin.php?page=gf_edit_forms'
    'pg|pages|wp-admin/edit.php?post_type=page'
    'pgbd|pages-by-date|wp-admin/edit.php?post_type=page&orderby=wsu_last_updated&order=desc'
    'css|css-editor|wp-admin/themes.php?page=editcss'
    'js|custom-js|wp-admin/themes.php?page=custom-javascript'
    'po|posts|wp-admin/edit.php'
    'pobd|posts-by-date|wp-admin/edit.php?orderby=wsu_last_updated&order=desc'
    'ev|events|wp-admin/edit.php?post_type=tribe_events'
    'evbd|events-by-date|wp-admin/edit.php?post_type=tribe_events&orderby=wsu_last_updated&order=desc'
    'tp|table-press|wp-admin/admin.php?page=tablepress&orderby=last_modified&order=desc'
    'forms|wp-admin/admin.php?page=gf_edit_forms'
    'users|wp-admin/users.php'
    'rd|redirects/users.php|wp-admin/edit.php?post_type=redirect_rule'
  )
  Return $Operations
}

#########
### §1.13: Get-Directory-Stats
### @link https://gist.github.com/Bill-Stewart/cca4032f8d04b7388b5fc9a0d5b8806d
### @author Bill Stewart [bstewart@iname.com] (https://gist.github.com/Bill-Stewart)
function Get-Directory-Stats {
  [CmdletBinding(DefaultParameterSetName = "None")]
  Param (
    [Parameter(Position = 0,ValueFromPipeline = $true)]
    [String[]] $Path,

    [Switch] $FormatNumbers,

    [Switch] $CountHardlinks,

    [Parameter(ParameterSetName = "Levels")]
    [UInt32] $Levels = 1,

    [Parameter(ParameterSetName = "NoRecurse")]
    [Switch] $NoRecurse,

    [Parameter(ParameterSetName = "OutputSubdirs")]
    [Switch] $ShowSubdirs
  )
  begin {
    function Find-Disk-Usage-Reporter {
      # Try to find the disk usage executable that matches the system's memory architecture.
      if ( [Environment]::Is64BitProcess ) {
        $commandPath = (Get-Command 'du64.exe' -ErrorAction SilentlyContinue).Path
        if ( -not $commandPath ) {
          $commandPath = (Get-Command 'du.exe' -ErrorAction SilentlyContinue).Path
        }
        if ( -not $commandPath ) {
          throw "Could not find the Sysinternals 'du64.exe' or 'du.exe' command in the Path. Download it, copy it to a directory in your Path, and try again."
        }
      } else {
        $commandPath = (Get-Command 'du.exe' -ErrorAction SilentlyContinue).Path
        if ( -not $commandPath ) {
          throw "Could not find the Sysinternals 'du.exe' command in the Path. Download it, copy it to a directory in your Path, and try again."
        }
      }

      # Test the legitimacy of the disk usage executable found by the script.
      if ( (Get-Item $commandPath).VersionInfo.CompanyName -notmatch 'SysInternals' ) {
        throw "The file '$commandPath' is not the SysInternals version. Download it, copy it to a directory in your Path, and try again."
      }

      # Check whether the disk usage executable found by the script matches the system's memory
      #   architecture.
      if ( [Environment]::Is64BitProcess -and ((Split-Path $commandPath -Leaf) -eq 'du.exe') ) {
        Write-Warning "Found the SysInternals 'du.exe' command in the Path, but it may not be the 64-bit version. Recommend using the 64-bit version ('du64.exe') on 64-bit operating systems."
      }

      # Return the path to the disk usage executable.
      $commandPath
    }

    # Get the path to the disk usage executable.
    $CommandPath = Find-Disk-Usage-Reporter

    # Assume current file system location as our execution context if -Path was not specified.
    if ( -not $Path ) {
      $Path = $ExecutionContext.SessionState.Path.CurrentFileSystemLocation.Path
    }

    function Format-Output {
      process {
        $_ | Select-Object Path,
          @{Name = "CurrentFileCount";    Expression = {'{0:N0}' -f $_.CurrentFileCount}},
          @{Name = "CurrentFileSize";     Expression = {'{0:N0}' -f $_.CurrentFileSize}},
          @{Name = "FileCount";           Expression = {'{0:N0}' -f $_.FileCount}},
          @{Name = "DirectoryCount";      Expression = {'{0:N0}' -f $_.DirectoryCount}},
          @{Name = "DirectorySize";       Expression = {'{0:N0}' -f $_.DirectorySize}},
          @{Name = "DirectorySizeOnDisk"; Expression = {'{0:N0}' -f $_.DirectorySizeOnDisk}}
      }
    }

    function Get-DirStats {
      param(
        [String] $path
      )
      $commandArgs = '-accepteula','-nobanner','-c'
      switch ( $PSCmdlet.ParameterSetName ) {
        "Levels" {
          $commandArgs += '-l'
          $commandArgs += '{0}' -f $Levels
        }
        "NoRecurse" {
          $commandArgs += '-n'
        }
        "OutputSubdirs" {
          $commandArgs += '-v'
        }
      }
      if ( $CountHardlinks ) {
        $commandArgs += '-u'
      }
      if ( [Environment]::Is64BitProcess -and ((Split-Path $commandPath -Leaf) -eq 'du64.exe') ) {
        $uses64BitArch = $true;
      } else {
        $uses64BitArch = $false;
      }
      $commandArgs += $path
      if ( $uses64BitArch ) {
        & $CommandPath $commandArgs | ConvertFrom-Csv | Select-Object Path,
          @{Name = "CurrentFileCount";    Expression = {$_.CurrentFileCount -as [UInt64]}},
          @{Name = "CurrentFileSize";     Expression = {$_.CurrentFileSize -as [UInt64]}},
          @{Name = "FileCount";           Expression = {$_.FileCount -as [UInt64]}},
          @{Name = "DirectoryCount";      Expression = {$_.DirectoryCount -as [UInt64]}},
          @{Name = "DirectorySize";       Expression = {$_.DirectorySize -as [UInt64]}},
          @{Name = "DirectorySizeOnDisk"; Expression = {$_.DirectorySizeOnDisk -as [UInt64]}}
      } else {
        & $CommandPath $commandArgs | ConvertFrom-Csv | Select-Object Path,
          @{Name = "CurrentFileCount";    Expression = {$_.CurrentFileCount -as [UInt32]}},
          @{Name = "CurrentFileSize";     Expression = {$_.CurrentFileSize -as [UInt32]}},
          @{Name = "FileCount";           Expression = {$_.FileCount -as [UInt32]}},
          @{Name = "DirectoryCount";      Expression = {$_.DirectoryCount -as [UInt32]}},
          @{Name = "DirectorySize";       Expression = {$_.DirectorySize -as [UInt32]}},
          @{Name = "DirectorySizeOnDisk"; Expression = {$_.DirectorySizeOnDisk -as [UInt32]}}
      }
    }
  }

  process {
    foreach ( $PathItem in $Path ) {
      if ( -not $FormatNumbers ) {
        Get-DirStats $PathItem
      }
      else {
        Get-DirStats $PathItem | Format-Output
      }
    }
  }
}

########
### §1.14: Get-Directories
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the directory
###     attribute.
Function Get-Directories {
  gci -Attributes Directory
}

########
### §1.15: Get-Filtered-Archives
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
### §1.16: Get-Filtered-Directories
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
### §1.17: Get-Image
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
### §1.18: Get-Image-List
###   Get a list of properties for JPG and PNG images present in the current folder.
Function Get-Image-List {
  gci ("*.jpg", "*.png") | Get-Image | Select Filename, Width, Height, HdWScalar, HdVScalar, HdXOrigin, HdYOrigin | ft -auto | Out-File .\list_image-dimensions.txt -Confirm
}

########
### §1.19: Invoke-Git-Log
###   Execute a preferred form of the git log command in the terminal.
Function Invoke-Git-Log {
  Param(
    [ Parameter( Mandatory=$false,
      ValueFromPipeline=$true ) ]
    [Alias("num")]
    [ int32 ]$number = 5,

    [ Parameter( Mandatory=$false,
      ValueFromPipeline=$true ) ]
    [Alias("file","follow")]
    [ string ]$fileToFollow = ""
  )
  if ( $number -le 0 -and $fileToFollow -eq "" ) {
    $expr = "git --no-pager log --pretty=""format:%h | %cn | %cd | %s%n ╘═> %b%n"""
  } elseif ( $number -gt 0 -and $fileToFollow -eq "" ) {
    $expr = "git --no-pager log --pretty=""format:%h | %cn | %cd | %s%n ╘═> %b%n"" -$number"
  } elseif ( $number -le 0 -and $fileToFollow -ne "" ) {
    $expr = "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n ╘═> %b%n"" $fileToFollow"
  } else {
    $expr = "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n ╘═> %b%n"" -$number $fileToFollow"
  }
  Write-Host "`n$expr`n"
  $expr | Invoke-Expression
}

########
### §1.20: Invoke-Git-Diff… Commands
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

Function Invoke-Git-Diff-with-Output {
  git diff --color > diff.log.txt
}

Function Invoke-Git-Diff-on-List {
  Param(
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [string[]]
    $files,

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string]
    $dlmtr = ",",

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string]
    $logFN = "diff.log.txt"
  )

  $pastFirstFile = $false
  Write-Host "`nPerforming command Invoke-Git-Diff-on-List on " -NoNewLine
  Write-Host ($files -join ", ") -foregroundcolor Cyan
  Write-Host "└------»"
  $files | % {
    $file = $_
    if ( $pastFirstFile -eq $false ) {
      try {
        $result = gci -path $file -ErrorAction Stop
        git diff --color $file > $logFN
        $pastFirstFile = $true
        Write-Host "  Wrote result of diff on " -NoNewLine
        Write-Host $file -NoNewLine -foregroundcolor Cyan
        Write-Host " to " -NoNewLine
        Write-Host $logFN -NoNewLine -foregroundcolor DarkCyan
        Write-Host "."
      } catch [System.Exception] {
        Write-Host ("  " + $file) -NoNewLine -foregroundcolor DarkRed
        Write-Host " was not found; ignoring it."
      }
    } else {
      try {
        $result = gci -path $file -ErrorAction Stop
        git diff --color $file >> $logFN
        Write-Host "  Appended result of diff on " -NoNewLine
        Write-Host $file -NoNewLine -foregroundcolor Cyan
        Write-Host " to " -NoNewLine
        Write-Host $logFN -NoNewLine -foregroundcolor DarkCyan
        Write-Host "."
      } catch [System.Exception] {
        Write-Host ("  " + $file) -NoNewLine -foregroundcolor DarkRed
        Write-Host " was not found; ignoring it."
      }
    }
  }
  Write-Host "«------┘`nFinished processing files.`n"
}

########
### §1.21: Open-Daesa-Website
###   Open an optionally filtered list of DAESA websites in the Chrome web browser. The invoker can
###     specific pages within the WSUWP administration area to be opened; otherwise, the websites
###     will be opened on their homepages.
Function Open-Daesa-Website {
  Param(
    [Parameter(Mandatory=$false)]
    [Alias("site")]
    [string]
    $siteStub = "",

    [Parameter(Mandatory=$false)]
    [Alias("op","operation")]
    [string]
    $wsuwpOp = "",

    [Parameter(Mandatory=$false)]
    [Alias("cat","category")]
    [string]
    $ctgr = "",

    [Parameter(Mandatory=$false)]
    [Alias("nmm","notmatch")]
    [bool]
    $notMatchMode = $false,

    [Parameter(Mandatory=$false)]
    [int32]
    $timing = 500
  )

  # Populate an array of URL stubs to open in Chrome
  $wsto = Get-Array-of-Daesa-Website-Urls -cat $ctgr
  if ( $siteStub -ne "" ) {
    if ( $notMatchMode ) {
      $wsto = $wsto -notmatch $siteStub
    } else {
      $wsto = $wsto -match $siteStub
    }
  }

  # Determine what additional action to perform, if any.
  if ( $wsuwpOp -ne "" ) {
    $op = Get-Array-of-Wsuwp-Operations
    $op = ($op -match ($wsuwpOp + '\|'))[0] -replace '.+\|(.+?)$', '$1'
    $wsto = $wsto -replace "(.+)", ('$1' + $op)
  }

  # Open the websites on chrome as specified.
  Write-Host "`nOpening the requested DAESA websites on Chrome:`n-----------------------------------------------" -foregroundcolor Green
  $1stWsToLd = $true
  foreach( $ws in $wsto ) {
    $cli = "chrome ""$ws"""
    if ( $1stWsToLd ) {
      $cli = $cli + " --new-window"
      $1stWsToLd = $false
    }
    Write-Host "$cli" -foregroundcolor Cyan
    $cli | Invoke-Expression
    Start-Sleep -m $timing
  }
  Write-Host "-----------------------------------------------`n" -foregroundcolor Green
}

########
### §1.22: Open-GitHub-Folder
###   Move the terminal's location to the primary GitHub folder on the local machine; if the user
###     specifies a string representing a folder to a repo, attempt to use the string with wildcard
###     filtering to find the repo and enter it as well.
Function Open-GitHub-Folder {
  Param(
    [Parameter(Mandatory=$false)]
    [string]
    $folder
  )

  # First, move to the default installation location of GitHub repos.
  cd C:\GitHub

  # If no repo folder was provided, we are done and can return.
  if ( $folder -eq $null -or $folder -eq "") {
    return
  }

  # Since a repo folder string was provided, make sure that a wildcard is appended to the end of it.
  if ( -not $folder[$folder.length] -eq "*" ) {
    $folder = $folder + "*"
  }

  # See if the specified folder string returns a directory; if not, we will try prepending a
  #   wildcard to the front of the string.
  $results = gci $folder -Attributes Directory
  if ( $results.length -eq 0 -and -not( $folder[0] -eq "*" ) ) {
    $folder = "*" + $folder
    $results = gci $folder -Attributes Directory
  }

  # If the Get-ChildItem cmdlet found results, simply move into the first folder found.
  if ( -not ( $results.length -eq 0 ) ) {
    cd $results[0].Name
  }
}

########
### §1.23: Open-GitHub-on-Chrome
###   Open the author's GitHub profile in the Chrome web browser. The invoker can optionally specify
###     that the command open a search query, which can be made in general or specifically against
###     the author's commit history.
Function Open-GitHub-on-Chrome {
  Param(
    [Parameter(Mandatory=$false)]
    [string] $qStr = "",

    [ Parameter( Mandatory=$false ) ]
    [ bool ]
    $srchCmts = $false
  )
  if ( $qStr -eq "" ) {
    $cmd = "https://github.com/invokeImmediately"
  } elseif ( $srchCmts ) {
    $cmd = "https://github.com/search?q=user%3AinvokeImmediately+" + $qstr + "&s=committer-date&type=commits"
  } else {
    $cmd = "https://github.com/search?q=user%3AinvokeImmediately+" + $qstr
  }
  chrome $cmd
}

#########
### §1.24: Open-PowerShell-Instance
###   Use PowerShell to open a new instance of PowerShell.
Function Open-PowerShell-Instance {
    $procName = (Get-Process -Id $PID).ProcessName
    if ( $procName -eq "pwsh" ) {
      Start-Process pwsh.exe
  } else {
    Start-Process PowerShell.exe
  }
}

#########
### §1.25: Write-Commands-to-Host
###   Write a list of the commands and aliases in this PowerShell profile to the console.
Function Write-Commands-to-Host {
  # Write introductory output to the console explaining what this function will do to the user.
  $profLen = $Profile.ToString().Length
  Write-Host "`n$("-"*(20 + $profLen))`nCommands defined in $Profile`n$("-"*(20 + $profLen))" -foregroundcolor DarkCyan

  # Find all the functions present in this profile and output them to the console.
  Select-String -Path $Profile -Pattern "^Function" | % {
    $_.Line.Replace("Function ", "").Replace(" {", "")
  }
  Write-Host "`n$("-"*25)`nAliases to These Commands`n$("-"*25)" -foregroundcolor DarkCyan

  # Now find all the aliases present in this profile and output them to the console.
  Select-String -Path $Profile -Pattern "^Set-Alias -Name (.+?) -Value (.+?)$" | % {
    Write-Host "$($_.Matches.Groups[1].Value) -> $($_.Matches.Groups[2].Value)"
  }

  # To wrap up, output an extra empty line to the console as a whitespace separator.
  Write-Host "`n" -NoNewline
}

########
### §1.26: Write-Welcome-Msg-to-Host
###
Function Write-Welcome-Msg-to-Host {
  # Build the components of a message to indicate this profile was loaded; bracket the message in
  #   automatically generated separators whose length is limited to the console's window width.
  $preMsg = "PowerShell profile"
  $postMsg = "has been loaded."

  # Get the version number of the profile from the file header comment.
  $semVer = ""
  $strs = Select-String "^# @version ([0-9]+\.[0-9]+\.[0-9]+.*)$" $Profile.ToString()
  foreach( $str in $strs ) {
    $matched = $str.Line -match "^# @version ([0-9]+\.[0-9]+\.[0-9]+.*)$"
    if ( $matched ) {
      $semVer = " v" + $Matches.1
    }

    # The first selected string, being in the file header comment, should be the version number of
    #   the profile, so we only need one loop iteration.
    Break
  }

  # Determine the length of the separators we should use in the welcome message.
  $msgLen = $preMsg.Length + $Profile.ToString().Length + $semVer.Length + $postMsg.Length + 2
  $consoleLen = $Host.UI.RawUI.WindowSize.Width - 1
  $sepLen = [Math]::Min( $msgLen, $consoleLen )

  # Output the welcome message along with a suggestion to run the help function
  #   Write-Commands-to-Host to learn what new commands are made available in this profile.
  Write-Host "`n$("="*($sepLen))" -foregroundcolor DarkCyan
  Write-Host "$preMsg " -NoNewline -foregroundcolor DarkCyan
  Write-Host "$Profile" -NoNewline -foregroundcolor Cyan
  Write-Host "$semVer" -NoNewline -foregroundcolor Green
  Write-Host " $postMsg`n$("="*($sepLen))`n" -foregroundcolor DarkCyan
  Write-Host "Welcome back, " -NoNewline -foregroundcolor Green
  Write-Host ( [Environment]::UserName ) -NoNewline -foregroundcolor Cyan
  Write-Host ". As a reminder, you can use the command " -NoNewline -foregroundcolor Green
  Write-Host "Write-Commands-to-Host" -NoNewline -foregroundcolor Cyan
  Write-Host " to obtain a list of the additional commands and their aliases defined in this profile.`n" -foregroundcolor Green
}

#############
# §2: Aliases

Set-Alias -Name ccp -Value Copy-Current-Path

Set-Alias -Name compdirs -Value Compare-Directories

Set-Alias -Name chrome -Value 'C:\Program Files\Google\Chrome\Application\chrome.exe'

Set-Alias -Name gcia -Value Get-Archives

Set-Alias -Name gcid -Value Get-Directories

Set-Alias -Name gcifa -Value Get-Filtered-Archives

Set-Alias -Name gcifd -Value Get-Filtered-Directories

Set-Alias -Name ghgl -Value Invoke-Git-Log

Set-Alias -Name gtgh -Value Open-GitHub-Folder

Set-Alias -Name ghgd -Value Invoke-Git-Diff

Set-Alias -Name igd -Value Invoke-Git-Diff

Set-Alias -Name igl -Value Invoke-Git-Log

Set-Alias -Name igdwo -Value Invoke-Git-Diff-with-Output

Set-Alias -Name igdol -Value Invoke-Git-Diff-on-List

Set-Alias -Name odws -Value Open-Daesa-Website

Set-Alias -Name oghoc -Value Open-GitHub-on-Chrome

Set-Alias -Name opi -Value Open-PowerShell-Instance

Set-Alias -Name wcth -Value Write-Commands-to-Host

###########################
# §3: Execution Entry Point

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Welcome-Msg-to-Host
