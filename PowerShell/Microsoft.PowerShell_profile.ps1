################################################################################
# · · · · · █▀▀▄ ▄▀▀▄▐   ▌█▀▀▀ █▀▀▄ ▄▀▀▀ █  █ █▀▀▀ █    █ · · · · · · · · · · ·
# Microsoft.█▄▄▀ █  █▐ █ ▌█▀▀  █▄▄▀ ▀▀▀█ █▀▀█ █▀▀  █  ▄ █  ▄ _profile.ps1  · · ·
# · · · · · █     ▀▀  ▀ ▀ ▀▀▀▀ ▀  ▀▄▀▀▀  █  ▀ ▀▀▀▀ ▀▀▀  ▀▀▀ · · · · · · · · · ·
#
# PowerShell profile of Daniel C. Rieck used when working on web coordination and development of websites for the Division of Academic Engagement and Student Achievement at Washington State University.
#
# @version 1.12.0
#
# @author Daniel Rieck [daniel.rieck@wsu.edu] (https://github.com/invokeImmediately)
# @link https://github.com/invokeImmediately/WSU-DAESA-AutoHotkey/blob/main/PowerShell/Microsoft.Pow
#   erShell_profile.ps1
# @link [Root:]\Users\[user]\[Windows Documents]\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# @link [Server Root]/[Folder(s)]/Backups/PowerShell Scripts/Microsoft.PowerShell_profile.ps1
# @license MIT License — Copyright (c) 2023 Daniel C. Rieck
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################################
# TABLE OF CONTENTS:
####################
#   §1: Functions..........................................................78
#     §1.1:  Compare-Directories...........................................81
#     §1.2:  Convert-Uri-Str-to-Windows-Filename..........................114
#     §1.3:  Copy-Current-Path............................................150
#     §1.4:  Copy-Daesa-Website-Urls-List.................................157
#     §1.5:  Copy-GitHub-Repos-CSV-List...................................165
#     §1.6:  Copy-GitHub-Repos-List.......................................173
#     §1.7:  Copy-Profiles-Path...........................................182
#     §1.8:  Find-Files-in-GitHub-Repos...................................189
#     §1.9:  Get-Archives.................................................216
#     §1.10: Get-Array-of-Github-Folder-Excludes..........................224
#     §1.11: Get-Array-of-Daesa-Website-Urls..............................235
#     §1.12: Get-Array-of-GitHub-Repos....................................302
#     §1.13: Get-Array-of-Wsuwp-Operations................................375
#     §1.14: Get-Directory-Stats..........................................399
#     §1.15: Get-Directories..............................................533
#     §1.16: Get-Filtered-Archives........................................567
#     §1.17: Get-Filtered-Directories.....................................588
#     §1.18: Get-Image....................................................609
#     §1.19: Get-Image-List...............................................669
#     §1.20: Invoke-Git-Log...............................................676
#     §1.21: Invoke-Git-Diff… Commands....................................719
#     §1.22: Invoke-Git-Status............................................843
#     §1.23: Open-Chrome..................................................879
#     §1.24: Open-Daesa-Website...........................................907
#     §1.25: Open-GitHub-Folder...........................................978
#     §1.26: Open-GitHub-on-Chrome.......................................1017
#     §1.27: Open-List-of-Websites-on-Chrome.............................1077
#     §1.28: Open-PowerShell-Instance....................................1139
#     §1.29: Resize-Image................................................1151
#     §1.30: Save-Web-Page-Source-Code...................................1287
#     §1.31: Test-Web-Page-Uri-Format....................................1353
#     §1.32: Write-Commands-to-Host......................................1374
#     §1.33: Write-Welcome-Msg-to-Host...................................1397
#   §2: Aliases..........................................................1439
#   §3: Execution Entry Point............................................1480
################################################################################

Add-Type -AssemblyName 'System.Drawing'

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
    If ([string]::IsNullOrEmpty($itemName)) {
      $itemName = "Script error"
    }
    Write-Host (-join ($itemName, ": ", $_.Exception.Message))
  }
}

########
### §1.2:  Convert-Uri-Str-to-Windows-Filename

<#
.SYNOPSIS
    Convert a URI string into a string that is compatible with file naming rules
    in Windows.
.DESCRIPTION
    Replaces "/", ".", and ":" with "⁄" (U+2044: Fraction slash), "·" (U+00B7:
    Middle dot), and "¦" (U+00A6: Broken bar), respectively.
.PARAMETER  uri
    Mandatory uri string.
.PARAMETER  keepScheme
    Optional boolean flag that controls whether the scheme component followed by
    the two slashes preceding the authority component are dropped. Default:
    false
#>
Function Convert-Uri-Str-to-Windows-Filename {
  Param (
    [ Parameter( Mandatory = $true,
      ValueFromPipelineByPropertyName = $true ) ]
    [ string ]
    $uri,

    [ Parameter( Mandatory = $false,
      ValueFromPipelineByPropertyName = $true ) ]
    [ bool ]
    $keepProtocol = $false
  )
  If ( !$keepProtocol ) {
    $uri = $uri -replace "https?://", ""
  }
  $uriFn = ( ( $uri -replace '/', '⁄' ) -replace '\.', '·' ) -replace ':', '¦'
  Return $uriFn
}

########
### §1.3: Copy-Current-Path
###   Copy the current path to the clipboard.
Function Copy-Current-Path {
  scb ( "'" + (gl).Path + "'" )
}

########
### §1.4: Copy-Daesa-Website-Urls-List
###   Copy the list of DAESA websites I regularly work with to the clipboard.
Function Copy-Daesa-Website-Urls-List {
  $urls = Get-Array-of-Daesa-Website-Urls
  scb ( $urls )
}

########
### §1.5: Copy-GitHub-Repos-CSV-List
###   Copy the CSV-formatted list of DAESA websites I regularly work with to the clipboard.
Function Copy-GitHub-Repos-CSV-List {
  $repos = Get-Array-of-GitHub-Repos
  scb ( ( -split $repos ) -Join ", " )
}

########
### §1.6: Copy-GitHub-Repos-List
###   Copy the list of repository folders associated with the GitHub projects for developing the DAESA websites I regularly work with to the clipboard.
Function Copy-GitHub-Repos-List {
  $repos = Get-Array-of-GitHub-Repos
  scb ( $repos )
}

########
### §1.7: Copy-Profiles-Path
###   Copy the path where PowerShell profiles are stored on the local machine.
Function Copy-Profiles-Path {
  scb ( gci -Path $Profile | %{ $_.Directory.FullName } )
}

########
### §1.8: Find-Files-in-GitHub-Repos
###   Use a filter to search for files within GitHub project repos associated with front-end web development work for WSU DAESA.
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
### §1.9: Get-Archives
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the archive attribute.
Function Get-Archives {
  gci -Attributes Archive
}

########
### §1.10: Get-Array-of-Github-Folder-Excludes
###   Get an array of filters used to exclude files or sub-folders when searching through GitHub folders.
Function Get-Array-of-Github-Folder-Excludes {
  $Excludes = [ string[] ]$Excludes = @(
    'node_modules'
  )
  Return $Excludes
}

########
### §1.11: Get-Array-of-Daesa-Website-Urls
###   Get an array of URLs to DAESA's websites.
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

  # Specify the string of URLs to all DAESA websites we could potentially work with prepended by category designators.
  [ string[] ]$UrlsToDaesaSites = @(
    'daesa|https://ace.wsu.edu/'
    'daesa|https://advising.wsu.edu/'
    'daesa|https://ascc.wsu.edu/'
    'daesa|https://admission.wsu.edu/research-scholars/'
    'daesa|oae|https://cmm.wsu.edu/'
    'daesa|https://commonreading.wsu.edu/'
    'daesa|https://cougarsuccess.wsu.edu/'
    'daesa|https://daesa.wsu.edu/coug-succ-wds/'
    'daesa|https://daesa.wsu.edu/'
    'daesa|https://distinguishedscholarships.wsu.edu/'
    'daesa|https://em.wsu.edu/advising411/'
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
    'daesa|daesa|https://stage.web.wsu.edu/daesa-wds/'
    'ugr|daesa|https://summerresearch.wsu.edu/'
    'ugr|daesa|https://surca.wsu.edu/'
    'daesa|https://transfercredit.wsu.edu/'
    'daesa|https://ucore.wsu.edu/'
    'daesa|https://ucore.wsu.edu/assessment/'
    'ugr|daesa|https://undergraduateresearch.wsu.edu/'
    'daesa|https://writingprogram.wsu.edu/'
    'daesa|https://stage.web.wsu.edu/writ-prog-wds/'
    'other|https://wsuacada.wsu.edu/'
  )

  # Filter the URL list by category, if any.
  If ( $ctgr -eq "" ) {
    $ctgr = ".*?"
  }
  If ( $notMatchMode ) {
    $UrlsToDaesaSites = ( $UrlsToDaesaSites -notmatch ( $ctgr + '\|' ) ) -replace  '.+\|(.+?)$', '$1'
  } else {
    $UrlsToDaesaSites = ( $UrlsToDaesaSites -match ( $ctgr + '\|' ) ) -replace  '.+\|(.+?)$', '$1'
  }

  # Return a filtered list of URLs.
  Return $UrlsToDaesaSites
}

########
### §1.12: Get-Array-of-GitHub-Repos
###   Get an array of local paths to GitHub project repos associated with front-end web development work for WSU DAESA.
Function Get-Array-of-GitHub-Repos {
  Param (
    [Parameter(Mandatory=$false)]
    [Alias("url", "gu")]
    [bool]
    $getUrl = $false,

    [Parameter(Mandatory=$false)]
    [Alias("category", "cat")]
    [string]
    $ctgr = "",

    [Parameter(Mandatory=$false)]
    [Alias("nmm", "nm", "notmatch")]
    [bool]
    $notMatchMode = $false
  )

  # Specify the string of categorizes URLs + folders to git projects for front-end development for
  #   all DAESA websites we could potentially work with.
  [ string[] ]$PathsToRepos = @(
    'daesa|https://github.com/invokeImmediately/ace.daesa.wsu.edu|C:\GitHub\ace.daesa.wsu.edu'
    'daesa|https://github.com/invokeImmediately/admissions.wsu.edu-research-scholars|C:\GitHub\admissions.wsu.edu-research-scholars'
    'daesa|https://github.com/invokeImmediately/ascc.wsu.edu|C:\GitHub\ascc.wsu.edu'
    'daesa|https://github.com/invokeImmediately/commonreading.wsu.edu|C:\GitHub\commonreading.wsu.edu'
    'daesa|https://github.com/invokeImmediately/cougarsuccess.wsu.edu|C:\GitHub\cougarsuccess.wsu.edu'
    'daesa|https://github.com/invokeImmediately/daesa.wsu.edu|C:\GitHub\daesa.wsu.edu'
    'daesa|https://github.com/invokeImmediately/distinguishedscholarships.wsu.edu|C:\GitHub\distinguishedscholarships.wsu.edu'
    'daesa|https://github.com/invokeImmediately/firstyear.wsu.edu|C:\GitHub\firstyear.wsu.edu'
    'daesa|https://github.com/invokeImmediately/learningcommunities.wsu.edu|C:\GitHub\learningcommunities.wsu.edu'
    'daesa|https://github.com/invokeImmediately/lsamp.wsu.edu|C:\GitHub\lsamp.wsu.edu'
    'ugr|daesa|https://github.com/invokeImmediately/marc.wsu.edu|C:\GitHub\marc.wsu.edu'
    'ugr|daesa|https://github.com/invokeImmediately/mira.wsu.edu|C:\GitHub\mira.wsu.edu'
    'oae|https://github.com/invokeImmediately/nse.wsu.edu|C:\GitHub\nse.wsu.edu'
    'other|https://github.com/invokeImmediately/nsse.wsu.edu|C:\GitHub\nsse.wsu.edu'
    'other|https://github.com/invokeImmediately/phibetakappa.wsu.edu|C:\GitHub\phibetakappa.wsu.edu'
    'ugr|daesa|https://github.com/invokeImmediately/summerresearch.wsu.edu|C:\GitHub\summerresearch.wsu.edu'
    'ugr|daesa|https://github.com/invokeImmediately/surca.wsu.edu|C:\GitHub\surca.wsu.edu'
    'other|https://github.com/invokeImmediately/teachingacademy.wsu.edu|C:\GitHub\teachingacademy.wsu.edu'
    'daesa|https://github.com/invokeImmediately/transfercredit.wsu.edu|C:\GitHub\transfercredit.wsu.edu'
    'daesa|https://github.com/invokeImmediately/ucore.wsu.edu|C:\GitHub\ucore.wsu.edu'
    'daesa|https://github.com/invokeImmediately/ucore.wsu.edu-assessment|C:\GitHub\ucore.wsu.edu-assessment'
    'ugr|daesa|https://github.com/invokeImmediately/undergraduateresearch.wsu.edu|C:\GitHub\undergraduateresearch.wsu.edu'
    'daesa|https://github.com/invokeImmediately/WSU-DAESA-CSS|C:\GitHub\WSU-DAESA-CSS'
    'daesa|https://github.com/invokeImmediately/WSU-DAESA-JS|C:\GitHub\WSU-DAESA-JS'
  )

  # Filter the URL/folder list by category, if any.
  If ( $ctgr -eq "" ) {
    $ctgr = ".*?"
  }
  If ( $notMatchMode ) {
    $PathsToRepos = ( $PathsToRepos -notmatch ( $ctgr + '\|' ) ) -replace  '.+\|(.+?\|.+?)$', '$1'
  } else {
    $PathsToRepos = ( $PathsToRepos -match ( $ctgr + '\|' ) ) -replace  '.+\|(.+?\|.+?)$', '$1'
  }

  # Now filter out either URLs or folder paths.
  If ( $getUrl ) {
    $PathsToRepos = $PathsToRepos -replace  '^(.+?)\|(.+?)$', '$1'
  } else {
    $PathsToRepos = $PathsToRepos -replace  '^(.+?)\|(.+?)$', '$2'
  }

  # As specified by caller, return a filtered list of either local repo folders or remote GitHub
  #   URLs.
  Return $PathsToRepos
}

#########
### §1.13: Get-Array-of-Wsuwp-Operatons
function Get-Array-of-Wsuwp-Operations {
  [ string[] ]$Operations = @(
    'admin|login|wp-admin/'
    'gf|gravity-forms|wp-admin/admin.php?page=gf_edit_forms'
    'pg|pages|wp-admin/edit.php?post_type=page'
    'pgbd|pages-by-date|wp-admin/edit.php?post_type=page&orderby=wsu_last_updated&order=desc'
    'css|css-editor|wp-admin/themes.php?page=editcss'
    'cust|customize|customizer|wp-admin/customize.php'
    'js|custom-js|wp-admin/themes.php?page=custom-javascript'
    'img|media|wp-admin/upload.php'
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
### §1.14: Get-Directory-Stats
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
      If ( [Environment]::Is64BitProcess ) {
        $commandPath = (Get-Command 'du64.exe' -ErrorAction SilentlyContinue).Path
        If ( -not $commandPath ) {
          $commandPath = (Get-Command 'du.exe' -ErrorAction SilentlyContinue).Path
        }
        If ( -not $commandPath ) {
          throw "Could not find the Sysinternals 'du64.exe' or 'du.exe' command in the Path. Download it, copy it to a directory in your Path, and try again."
        }
      } else {
        $commandPath = (Get-Command 'du.exe' -ErrorAction SilentlyContinue).Path
        If ( -not $commandPath ) {
          throw "Could not find the Sysinternals 'du.exe' command in the Path. Download it, copy it to a directory in your Path, and try again."
        }
      }

      # Test the legitimacy of the disk usage executable found by the script.
      If ( (Get-Item $commandPath).VersionInfo.CompanyName -notmatch 'SysInternals' ) {
        throw "The file '$commandPath' is not the SysInternals version. Download it, copy it to a directory in your Path, and try again."
      }

      # Check whether the disk usage executable found by the script matches the system's memory
      #   architecture.
      If ( [Environment]::Is64BitProcess -and ((Split-Path $commandPath -Leaf) -eq 'du.exe') ) {
        Write-Warning "Found the SysInternals 'du.exe' command in the Path, but it may not be the 64-bit version. Recommend using the 64-bit version ('du64.exe') on 64-bit operating systems."
      }

      # Return the path to the disk usage executable.
      $commandPath
    }

    # Get the path to the disk usage executable.
    $CommandPath = Find-Disk-Usage-Reporter

    # Assume current file system location as our execution context if -Path was not specified.
    If ( -not $Path ) {
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
      param (
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
      If ( $CountHardlinks ) {
        $commandArgs += '-u'
      }
      If ( [Environment]::Is64BitProcess -and ((Split-Path $commandPath -Leaf) -eq 'du64.exe') ) {
        $uses64BitArch = $true;
      } else {
        $uses64BitArch = $false;
      }
      $commandArgs += $path
      If ( $uses64BitArch ) {
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
      If ( -not $FormatNumbers ) {
        Get-DirStats $PathItem
      }
      else {
        Get-DirStats $PathItem | Format-Output
      }
    }
  }
}

########
### §1.15: Get-Directories
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the directory attribute.
Function Get-Directories {
  Param(
    [ Parameter( Mandatory=$false ) ]
    [string[]]
    $Path = '',

    [ Parameter( Mandatory=$false ) ]
    [string]
    $Filter = '',

    [ Parameter( Mandatory=$false ) ]
    [switch]
    $Recurse,

    [ Parameter( Mandatory=$false ) ]
    [uint32]
    $Depth = 0
  )
  if ( $Recurse.IsPresent -and -not $Depth -gt 0 ) {
    gci -Path $Path -Filter $Filter -Attributes Directory -Recurse
  } elseif ( $Depth -gt 0 ) {
    gci -Path $Path -Filter $Filter -Attributes Directory -Depth $Depth
  } else {
    gci -Path $Path -Filter $Filter -Attributes Directory
  }
}

########
### §1.16: Get-Filtered-Archives
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the archive attribute, but employ a specified filter and possibly recursion.
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
### §1.17: Get-Filtered-Directories
###   Use the Get-Child-Item cmdlet to get files in the current directory that have the directory attribute, but employ a specified filter and possibly recursion.
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
### §1.18: Get-Image
###   Get the properties of an image file.
Function Get-Image {
  Param (
    [Parameter(ValueFromPipeline=$true)]
    [System.IO.FileInfo]
    $file
  )
  begin {
    [System.Reflection.Assembly]::LoadWithPartialName( "System.Drawing" ) | Out-Null
  }
  process {
    If ( $file.Exists ) {
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
### §1.19: Get-Image-List
###   Get a list of properties for JPG and PNG images present in the current folder.
Function Get-Image-List {
  gci ("*.jpg", "*.png") | Get-Image | Select Filename, Width, Height, HdWScalar, HdVScalar, HdXOrigin, HdYOrigin | ft -auto | Out-File .\list_image-dimensions.txt -Confirm
}

########
### §1.20: Invoke-Git-Log

<#
.SYNOPSIS
    Execute a preferred form of the git log command in the terminal.
.DESCRIPTION
    The invoker can optionally specify the number of commits to display as well
    as a file to follow.
.PARAMETER  number
    Optional query string to search for on GitHub. Default: Empty string.
    Default: 5. Aliases: n, num.
.PARAMETER  fileToFollow
    Optional switch for indicating that the commit history should be searched.
    Default: Empty string. Aliases: f, file, follow.
#>
Function Invoke-Git-Log {
  [ CmdletBinding( PositionalBinding=$false ) ]
  Param (
    [ Parameter( Mandatory=$false,
      ValueFromPipeline=$true ) ]
    [Alias("n", "num")]
    [ int32 ]$number = 5,

    [ Parameter( Mandatory=$false,
      ValueFromPipeline=$true ) ]
    [Alias("f","file","follow")]
    [ string ]$fileToFollow = ""
  )
  If ( $number -le 0 -and $fileToFollow -eq "" ) {
    $expr = "git --no-pager log --pretty=""format:%h | %cn | %cd | %s%n │%n ╘═> %b■%n%n"""
  } elseIf ( $number -gt 0 -and $fileToFollow -eq "" ) {
    $expr = "git --no-pager log --pretty=""format:%h | %cn | %cd | %s%n │%n ╘═> %b■%n%n"" -$number"
  } elseIf ( $number -le 0 -and $fileToFollow -ne "" ) {
    $expr = "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n │%n ╘═> %b■%n%n"" $fileToFollow"
  } else {
    $expr = "git --no-pager log --follow --pretty=""format:%h | %cn | %cd | %s%n │%n ╘═> %b■%n%n"" -$number $fileToFollow"
  }
  Write-Host "`n.> $expr`n" -foregroundcolor Cyan
  Write-Host "========`n"
  $expr | Invoke-Expression
}

########
### §1.21: Invoke-Git-Diff… Commands

<#
.SYNOPSIS
    Execute a preferred form of the git diff command in the terminal.
.DESCRIPTION
    The invoker can optionally specify a file to diff, whether the pager should
    be used, and a reference commit.
.PARAMETER  file
    Mandatory file path string to search for on GitHub. Default: Empty string.
    Aliases: f, path, p.
.PARAMETER  usePager
    Optional switch for indicating that the commit history should be searched.
    Default: False. Aliases: pager, pgr, uPgr, up.
.PARAMETER  refCommit
    Optional switch for indicating that the commit history should be searched.
    Default: False. Aliases: commit, ref, rc.
#>
Function Invoke-Git-Diff {
  Param (
    [Parameter(Mandatory=$false)]
    [string]
    [Alias("f", "path", "p")]
    $file = "",

    [Parameter(Mandatory=$false)]
    [bool]
    [Alias("pager", "pgr", "uPgr", "up")]
    $usePager = $false,

    [Parameter(Mandatory=$false)]
    [string]
    [Alias("ref", "commit", "rc")]
    $refCommit = ""
  )
  $pgrStr = $usePager ? "" : "--no-pager "
  $refCommit = ( $refCommit -ne "" ) ? " " + $refCommit : $refCommit
  $file = ( $file -ne "" ) ? " -- " + $file : $file
  $cli = "git " + $pgrStr + "diff" + $refCommit + $file
  Write-Host "$cli" -foregroundcolor Cyan
  $cli | Invoke-Expression
}

Function Invoke-Git-Diff-with-Output {
  Param (
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [string]
    $logFN = "diff.log.txt"
  )
  if( ( $logFN -ne "diff.log.txt" ) -and ( Test-Path( $logFN ) ) ) {
    Write-Host $logFN -NoNewLine -foregroundcolor DarkRed
    $confirmation = Read-Host " already exists. Are you sure you want to override it with git diff? (Y/es to proceed)"
    if( -not( ($confirmation -eq "Yes") -or ($confirmation -eq "Y") ) ) {
      Return
    }
  }
  git diff --color > $logFN
  Write-Host "`nPerformed command Invoke-Git-Diff-with-Output with diff output stored in " -NoNewLine
  Write-Host ( $logFN + ".`n" ) -foregroundcolor DarkCyan
}

Function Invoke-Git-Diff-on-List {
  Param (
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
    $logFN = "diff.log.txt",

    [Parameter(Mandatory=$false)]
    [string]
    [Alias("ref", "commit")]
    $refCommit = ""
  )

  $pastFirstFile = $false
  Write-Host "`nPerforming command Invoke-Git-Diff-on-List on " -NoNewLine
  Write-Host ($files -join ", ") -foregroundcolor Cyan
  Write-Host "└------»"
  $files | % {
    $file = $_
    If ( $pastFirstFile -eq $false ) {
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
### §1.22: Invoke-Git-Status

<#
.SYNOPSIS
    Execute a preferred form of the git status command in the terminal.
.DESCRIPTION
    The invoker can optionally specify options and the pathspec parameter.
.PARAMETER  file
    Mandatory file path string to search for on GitHub. Default: Empty string.
.PARAMETER  usePager
    Optional switch for indicating that the commit history should be searched.
    Default: False.
.PARAMETER  refCommit
    Optional switch for indicating that the commit history should be searched.
    Default: Empty string.
#>
Function Invoke-Git-Status {
  Param (
    [Parameter(Mandatory=$false)]
    [string]
    [Alias("opts")]
    $options = "",

    [Parameter(Mandatory=$false)]
    [string]
    [Alias("path", "ps")]
    $pathSpec = ""
  )
  $options = ( $options -ne "" ) ? $options + " " : $options
  $pathSpec = ( $pathSpec -ne "" ) ? " -- " + $pathSpec : $pathSpec
  $cli = "git " + $options + "status" + $pathspec
  Write-Host "$cli" -foregroundcolor Cyan
  $cli | Invoke-Expression
}

########
### §1.23: Open-Chrome
###   Open an optionally filtered list of DAESA websites in the Chrome web browser. The invoker can specific pages within the WSUWP administration area to be opened; otherwise, the websites will be opened on their homepages.
Function Open-Chrome {
  Param (
    [Parameter(Mandatory=$false)]
    [string]
    $cliTail = ""
  )

  # Options for paths to chrome.exe
  $pathOptX64 = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
  $pathOptX86 = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'

  # Determine which path chrome is valid on this system.
  If ( Test-Path $pathOptX64 ) {
    $cli = $pathOptX64
  } else {
    $cli = $pathOptX86
  }
  Write-Host $cli $cliTail

  # Start the chrome process using the CLI tail as the process argument list
  Start-Process $cli $cliTail
}

########
### §1.24: Open-Daesa-Website
###   Open an optionally filtered list of DAESA websites in the Chrome web browser. The invoker can specific pages within the WSUWP administration area to be opened; otherwise, the websites will be opened on their homepages.
Function Open-Daesa-Website {
  Param (
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
    $timing = 500,

    [Parameter(Mandatory=$false)]
    [bool]
    [Alias("nw", "newWin")]
    $opInNewWin = $false
  )

  # Populate an array of URL stubs to open in Chrome
  $wsto = Get-Array-of-Daesa-Website-Urls -cat $ctgr
  If ( $siteStub -ne "" ) {
    If ( $notMatchMode ) {
      $wsto = $wsto -notmatch $siteStub
    } else {
      $wsto = $wsto -match $siteStub
    }
  }

  # Determine what additional action to perform, if any.
  If ( $wsuwpOp -ne "" ) {
    $op = Get-Array-of-Wsuwp-Operations
    $op = ($op -match ($wsuwpOp + '\|'))[0] -replace '.+\|(.+?)$', '$1'
    $wsto = $wsto -replace "(.+)", ('$1' + $op)
  }

  # Open the websites on chrome as specified.
  Write-Host "`nOpening the requested DAESA websites on Chrome:`n-----------------------------------------------" -foregroundcolor Green
  $1stWsToLd = $true
  ForEach ( $ws in $wsto ) {
    $cli = "chrome ""$ws"
    If ( $1stWsToLd -and $opInNewWin) {
      $cli = $cli + " --new-window"
      $1stWsToLd = $false
    }
    $cli += """"
    Write-Host "$cli" -foregroundcolor Cyan
    $cli | Invoke-Expression
    Start-Sleep -m $timing
  }
  Write-Host "-----------------------------------------------`n" -foregroundcolor Green
}

########
### §1.25: Open-GitHub-Folder
###   Move the terminal's location to the primary GitHub folder on the local machine; if the user
###     specifies a string representing a folder to a repo, attempt to use the string with wildcard
###     filtering to find the repo and enter it as well.
Function Open-GitHub-Folder {
  Param (
    [Parameter(Mandatory=$false)]
    [string]
    $folder
  )

  # First, move to the default installation location of GitHub repos.
  cd C:\GitHub

  # If no repo folder was provided, we are done and can return.
  If ( $folder -eq $null -or $folder -eq "") {
    return
  }

  # Since a repo folder string was provided, make sure that a wildcard is appended to the end of it.
  If ( -not $folder[$folder.length] -eq "*" ) {
    $folder = $folder + "*"
  }

  # See if the specified folder string returns a directory; if not, we will try prepending a
  #   wildcard to the front of the string.
  $results = gci $folder -Attributes Directory
  If ( $results.length -eq 0 -and -not( $folder[0] -eq "*" ) ) {
    $folder = "*" + $folder
    $results = gci $folder -Attributes Directory
  }

  # If the Get-ChildItem cmdlet found results, simply move into the first folder found.
  If ( -not ( $results.length -eq 0 ) ) {
    cd $results[0].Name
  }
}

########
### §1.26: Open-GitHub-on-Chrome

<#
.SYNOPSIS
    Open the author's GitHub profile in the Chrome web browser.
.DESCRIPTION
    The invoker can optionally specify that the command open a search query,
    which can be made in general or specifically against the author's commit
    history.
.PARAMETER  qStr
    Optional query string to search for on GitHub. Default: Empty string.
.PARAMETER  srchCmts
    Optional switch for indicating that the commit history should be searched.
    Default: False. Aliases: commits, searchCommits
.PARAMETER  inNewWin
    Optional flag to indicate that the query should be performed in a new
    browser window. Default: False. Aliases: nw, newWin.
#>
Function Open-GitHub-on-Chrome {
  Param (
    [Parameter(Mandatory=$false)]
    [Alias("q")]
    [string] $qStr = "",

    [ Parameter( Mandatory=$false ) ]
    [ bool ]
    [Alias("commits", "searchCommits")]
    $srchCmts = $false,

    [ Parameter( Mandatory=$false ) ]
    [ bool ]
    [Alias("nw", "newWin")]
    $inNewWin = $false
  )
  # Start setting up the command line to open the chrome app.
  $cli = "chrome """

  # If present, ensure the query string is encoded properly.
  $qStr = [uri]::EscapeUriString($qStr)

  # Next, add the URL for the page on GitHub that should be opened.
  If ( $qStr -eq "" ) {
    $cli += "https://github.com/invokeImmediately"
  } elseIf ( $srchCmts ) {
    $cli += "https://github.com/search?q=user%3AinvokeImmediately+" + $qstr + "&s=committer-date&type=commits"
  } else {
    $cli += "https://github.com/search?q=user%3AinvokeImmediately+" + $qstr
  }

  # If appropriate, add a specification to open a new window in the command line expression.
  If ( $inNewWin -eq $true ) {
    $cli += " --new-window"
  }
  $cli += """"

  # Invoke the command line expression for opening chrome.
  $cli | Invoke-Expression
}

########
### §1.27: Open-List-of-Websites-on-Chrome

<#
.SYNOPSIS
   Open a list of websites on the Chrome web browser one at a time and
   temporally spaced out by an average but randomly determined delay.
.PARAMETER Uris
   An array of strings representing URIs to the web pages whose source code will
   be saved.
.PARAMETER AvgDelay
   The average delay time in seconds. The actual delay time between each website
   being opened is determined by multiplying this parameter by a randomly
   determined scalar that ranges from 0.5 to 1.5.
#>
Function Open-List-of-Websites-on-Chrome {
  [ CmdletBinding( PositionalBinding=$false ) ]
  Param (
    [Parameter(Mandatory=$True, ValueFromPipeline=$true)]
    [ValidateScript({
        $_ | ForEach-Object {
            Test-Web-Page-Uri-Format $_
        }
    })][String[]]$Uris,

    [Parameter(Mandatory=$False, ValueFromPipeline=$true)]
    [Alias( "delay" )]
    [Double]$AvgDelay = 5.0,

    [Parameter(Mandatory=$False, ValueFromPipeline=$true)]
    [Alias( "addlSlug" )]
    [String]$AdditionalUrlSlug = ""
  )
  $uriCount = 0
  ForEach ( $Uri in $Uris ) {
    $flNmPref4Uri = Convert-Uri-Str-to-Windows-Filename( $Uri )
    Write-Host "Opening URI «$Uri» on Chrome."
    Try {
      $cli = "chrome ""$Uri"
      If ( $AdditionalUrlSlug -ne "" ) {
        $cli += $AdditionalUrlSlug
      }
      $cli += """"
      Write-Host "$cli" -foregroundcolor Cyan
      $cli | Invoke-Expression
      If ( $uriCount -le $Uris.length ) {
        $delFac = Get-Random -Minimum 0.5 -Maximum 1.5
        $delay = $AvgDelay * $delFac
        Write-Host "Waiting $delay seconds before opening next site."
        Start-Sleep $delay
      }
      $uriCount++
    } Catch {
      $itemName = $_.Exception.ItemName
      If ([string]::IsNullOrEmpty($itemName)) {
        $itemName = "Script error"
      }
      Write-Host (-join ($itemName, ": ", $_.Exception.Message))
    }
  }
}

#########
### §1.28: Open-PowerShell-Instance
###   Use PowerShell to open a new instance of PowerShell.
Function Open-PowerShell-Instance {
    $procName = (Get-Process -Id $PID).ProcessName
    If ( $procName -eq "pwsh" ) {
      Start-Process pwsh.exe
  } else {
    Start-Process PowerShell.exe
  }
}

#########
### §1.29: Resize-Image

<#
.SYNOPSIS
   Resize a list of images of length n >= 1.
.DESCRIPTION
   Resize a list of images based on an array of strings representing paths to
   the images and a combination of scaling parameters that allows absolute
   dimensional resizing that is either unconstrained or based on a maintained
   aspect ratio, or resizing based on dimensional percentage. The execution of
   this CmdLet creates a new file named "OriginalName_$NmMod-$NewWidthw$NewHeigh
   th" and maintains the original file extension.
.PARAMETER ImgPath
   An array of strings representing paths to the images being resized.
.PARAMETER NewWidth
   The new width of the images. Should be given alone when the MaintainRatio
   flag is set.
.PARAMETER NewHeight
   The new height of the images. Should be given alone with the MaintainRatio
   flag is set.
.PARAMETER MaintainRatio
   Maintain the ratio of the images when resizing them based on either a set new
   width or a set new height. That is, setting both width and height while this
   flag parameter is set will result in an error.
.PARAMETER NewScale
   Scale the images to a new width and height that are a percentage of the
   original images' dimensions.
.PARAMETER SmoothingMode
   Sets the smoothing mode. Default is HighQuality.
.PARAMETER InterpolationMode
   Sets the interpolation mode. Default is HighQualityBicubic.
.PARAMETER PixelOffsetMode
   Sets the pixel offset mode. Default is HighQuality.
.PARAMETER NmMod
   Optional substring that is appended to the file name of each resized image.
   Default is resized.
.EXAMPLE
   Resize-Image -Height 45 -Width 45 -ImagePath "Path/to/image.ext"
.EXAMPLE
   Resize-Image -Height 45 -MaintainRatio -ImagePath "Path/to/image.ext"
.EXAMPLE
   #Resize to 50% of the given image
   Resize-Image -Percentage 50 -ImagePath "Path/to/image.ext"
.NOTES
   Adapted from a function written by Christopher Walker (github/someshinyobject
   and [https://someshinyobject.com/]). Reference function was found at [https:/
   /gist.github.com/someshinyobject/617bf00556bc43af87cd].
#>
Function Resize-Image {
  Param (
    [CmdLetBinding(
        SupportsShouldProcess=$true, 
        PositionalBinding=$false,
        ConfirmImpact="Medium",
        DefaultParameterSetName="Absolute"
    )]
    [Parameter(Mandatory=$True)]
    [ValidateScript({
        $_ | ForEach-Object {
            Test-Path $_
        }
    })][String[]]$ImgPath,
    [Parameter(Mandatory=$False)][Switch]$KeepAspectRatio,
    [Parameter(Mandatory=$False, ParameterSetName="Absolute")][Int]$NewHeight,
    [Parameter(Mandatory=$False, ParameterSetName="Absolute")][Int]$NewWidth,
    [Parameter(Mandatory=$False, ParameterSetName="Scaled")][Double]$NewScale,
    [Parameter(Mandatory=$False)][System.Drawing.Drawing2D.SmoothingMode]$SmoothingMode = "HighQuality",
    [Parameter(Mandatory=$False)][System.Drawing.Drawing2D.InterpolationMode]$InterpolationMode = "HighQualityBicubic",
    [Parameter(Mandatory=$False)][System.Drawing.Drawing2D.PixelOffsetMode]$PixelOffsetMode = "HighQuality",
    [Parameter(Mandatory=$False)][String]$NmMod = "resized"
  )
  Begin {
      If ($NewWidth -and $NewHeight -and $KeepAspectRatio) {
          Throw "KeepAspectRatio flag must be specified with either absolute width or height set, but not both."
      }

      If (($NewWidth -xor $NewHeight) -and (-not $KeepAspectRatio)) {
          Throw "If KeepAspectRatio flag is not used, both an absolute width and height must be set."
      }

      If ($Percentage -and $KeepAspectRatio) {
          Write-Warning "The KeepAspectRatio flag while using the Percentage parameter does nothing"
      }
  }
  Process {
    $CalcRelToNewHeight = $NewHeight ? $true : $false
    $SzFraction = $NewScale ? ($NewScale / 100) : $null
    If ( $NmMod -ne "" ) {
      $NmMod = $NmMod + "-"
    }
    ForEach ( $Img in $ImgPath ) {
      $InPath = (Resolve-Path $Img).Path
      Write-Host $InPath
      $ExtIdx = $InPath.LastIndexOf(".")
      
      $RefImg = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $InPath
      $RefH = $RefImg.Height
      $RefW = $RefImg.Width

      If ( $KeepAspectRatio -and -not $NewScale ) {
          If ( $CalcRelToNewHeight ) {
              $NewWidth = $RefW / $RefH * $NewHeight
          } Else {
              $NewHeight = $RefH / $RefW * $NewWidth
          }
      }

      If ( $NewScale ) {
          $NewHeight = $RefH * $SzFraction
          $NewWidth = $RefW * $SzFraction
      }

      $OutPath = $InPath.Substring(0,$ExtIdx) + "_" + $NmMod + $NewWidth + "w" + $NewHeight + "h" + $InPath.Substring($ExtIdx,$InPath.Length - $ExtIdx)

      $Bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $NewWidth, $NewHeight
      $NewImage = [System.Drawing.Graphics]::FromImage($Bitmap)
       
      #Retrieving the best quality possible
      $NewImage.SmoothingMode = $SmoothingMode
      $NewImage.InterpolationMode = $InterpolationMode
      $NewImage.PixelOffsetMode = $PixelOffsetMode
      $NewImage.DrawImage($RefImg, $(New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $NewWidth, $NewHeight))

      If ($PSCmdlet.ShouldProcess("Resized image based on $InPath", "save to $OutPath")) {
          $Bitmap.Save($OutPath)
          Write-Host "Resized $InPath and stored result as $OutPath."
      }
      
      $Bitmap.Dispose()
      $NewImage.Dispose()
      $RefImg.Dispose()
    }
  }
}

#########
### §1.30: Save-Web-Page-Source-Code

<#
.SYNOPSIS
   Save the source code for a list of websites to files whose file names are
   based on the URL.
.DESCRIPTION
   The source code is saved one website at a time, with each request and write
   operation and temporally spaced out by an average but randomly determined
   delay.
.PARAMETER Uri
   An array of strings representing URIs to the web pages whose source code will
   be saved.
.PARAMETER AvgDelay
   The average delay time in seconds. The actual delay time between each website
   being opened is determined by multiplying this parameter by a randomly
   determined scalar that ranges from 0.5 to 1.5.
#>
Function Save-Web-Page-Source-Code {
  Param (
    [Parameter(Mandatory=$True, ValueFromPipeline=$true)]
    [ValidateScript({
        $_ | ForEach-Object {
            Test-Web-Page-Uri-Format $_
        }
    })][String[]]$Uris,

    [Parameter(Mandatory=$False, ValueFromPipeline=$true)]
    [Alias( "delay" )]
    [Double]$AvgDelay = 5.0
  )
  $uriCount = 0
  $flNmSuf4Uris = "«—src-code.html"
  ForEach ( $Uri in $Uris ) {
    $flNmPref4Uri = Convert-Uri-Str-to-Windows-Filename( $Uri )
    Write-Host "Requesting resource at URI «$Uri»."
    Try {
      $resp = Invoke-WebRequest $Uri
      Write-Host "Storing web page content to file «.\$flNmPref4Uri$flNmSuf4Uris»."
      $curLoc = (Get-Location).Path
      $Stream = [System.IO.StreamWriter]::new( $curLoc + "\" + $flNmPref4Uri + $flNmSuf4Uris, $false, $resp.Encoding )
      Try {
          $Stream.Write( $resp.Content )
      } Finally {
          $Stream.Dispose()
      }
      $uriCount++
      If ( $uriCount -le $Uris.length ) {
        $delFac = Get-Random -Minimum 0.5 -Maximum 1.5
        $delay = $AvgDelay * $delFac
        Write-Host "Waiting $delay seconds before initiating next request."
        Start-Sleep $delay
      }
    } Catch {
      $itemName = $_.Exception.ItemName
      If ([string]::IsNullOrEmpty($itemName)) {
        $itemName = "Script error"
      }
      Write-Host (-join ($itemName, ": ", $_.Exception.Message))
    }
  }
  # Can use (?:^.*<nav class="wsu-navigation-site-vertical".+$\n)(^(?:.(?!</nav>))+$\n)+?</nav> to find WSUWP primary navigational components within web pages.
  # (Get-Content -Raw .\stage·web·wsu·edu⁄daesa-wds«—src-code.html) -match "(?:.*<nav class=""wsu-navigation-site-vertical"".+`n)((?:.(?!</nav>))+`n)+?</nav>" \ Write-Host $Matches[0]
}

#########
### §1.31: Test-Web-Page-Uri-Format

<#
.SYNOPSIS
   Tests a string for conformity to the standard for forming a valid URI
   for a web page.
.DESCRIPTION
   Returns true for a well formed URI string.
.PARAMETER Uri
   A string representing a prospective URI to be tested against the character
   format rules for URIs.
#>
Function Test-Web-Page-Uri-Format {
  Param (
    [Parameter(Mandatory=$True, ValueFromPipeline=$true)]
    [String]$Uri
  )
  Return $Uri -match "^((https?):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)?(.*)(#[\w\-]+)?$"
}

#########
### §1.32: Write-Commands-to-Host
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
### §1.33: Write-Welcome-Msg-to-Host
###
Function Write-Welcome-Msg-to-Host {
  # Build the components of a message to indicate this profile was loaded; bracket the message in
  #   automatically generated separators whose length is limited to the console's window width.
  $preMsg = "PowerShell profile"
  $postMsg = "has been loaded."

  # Get the version number of the profile from the file header comment.
  $semVer = ""
  $strs = Select-String "^# @version ([0-9]+\.[0-9]+\.[0-9]+.*)$" $Profile.ToString()
  ForEach ( $str in $strs ) {
    $matched = $str.Line -match "^# @version ([0-9]+\.[0-9]+\.[0-9]+.*)$"
    If ( $matched ) {
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

Set-Alias -Name chrome -Value Open-Chrome

Set-Alias -Name gcia -Value Get-Archives

Set-Alias -Name gcid -Value Get-Directories

Set-Alias -Name gcifa -Value Get-Filtered-Archives

Set-Alias -Name gcifd -Value Get-Filtered-Directories

Set-Alias -Name ghgl -Value Invoke-Git-Log

Set-Alias -Name gtgh -Value Open-GitHub-Folder

Set-Alias -Name ghgd -Value Invoke-Git-Diff

Set-Alias -Name igd -Value Invoke-Git-Diff

Set-Alias -Name igdwo -Value Invoke-Git-Diff-with-Output

Set-Alias -Name igdol -Value Invoke-Git-Diff-on-List

Set-Alias -Name igl -Value Invoke-Git-Log

Set-Alias -Name igs -Value Invoke-Git-Status

Set-Alias -Name odws -Value Open-Daesa-Website

Set-Alias -Name oghoc -Value Open-GitHub-on-Chrome

Set-Alias -Name opi -Value Open-PowerShell-Instance

Set-Alias -Name wcth -Value Write-Commands-to-Host

###########################
# §3: Execution Entry Point

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Welcome-Msg-to-Host
