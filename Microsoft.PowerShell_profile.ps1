
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH\di4am0nd.omp.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

Set-Alias ll ls
Set-Alias grep findstr
Set-Alias cl clear

function lf {
    <#.SYNOPSIS
    Lists all function names defined in the PowerShell profile file.
    #>

    $profilePath = $PROFILE
    $profileContent = Get-Content -Path $profilePath -ErrorAction SilentlyContinue

    if ($profileContent -eq $null) {
        Write-Host "No PowerShell profile file found."
        return
    }

    $functionNames = $profileContent | Where-Object { $_ -match "function ([a-zA-Z0-9_-]+)\s*\{" } | ForEach-Object {
        $matches[1]
    }

    if ($functionNames.Count -eq 0) {
        Write-Host "No functions found in the PowerShell profile."
    } else {
        Write-Host
        $functionNames | ForEach-Object {
            Write-Host "- $_"
        }
    }
}


function gst { 
    <#.SYNOPSIS
    Displays the Git status of the current repository.
    #>
    git status 
}
function gaa { 
    <#.SYNOPSIS
    Adds all changes to the Git staging area.
#>

    git add . 
}
function gcmt { 
    <#.SYNOPSIS
    Commits changes to a Git repository with an optional commit message.
#>

    param([string]$message) git commit -m $message 
}
function gpsh { 
    <#.SYNOPSIS
    Pushes changes to a remote Git repository.
#>
    git push 
}






# Git-AddCommit: Add and commit changes with a message.
function gac {
<#.SYNOPSIS
    Adds and commits changes to a Git repository with an optional commit message.
#>
    param(
        [string]$message
    )

    # Check if $message is empty, and prompt for a message if it is
    if ([string]::IsNullOrEmpty($message)) {
        $message = Read-Host -Prompt "Enter commit message:"
    }

    # Add all changes
    git add .

    # Commit changes with the provided message
    git commit -m $message
}

function gacp { 
    <#.SYNOPSIS
    Adds, commits, and pushes changes to a Git repository with an optional commit message.
#>

    param([string]$message)
    # Check if $message is empty, and prompt for a message if it is
    if ([string]::IsNullOrEmpty($message)) {
        $message = Read-Host -Prompt "Enter commit message"
    }

    gaa
    git commit -m $message
    git push
}


function vab {
    <#
.SYNOPSIS
    Initializes a new web project based on the Vite.js and Aframe frameworks.

.DESCRIPTION
    The 'vab' (Vite Aframe Boilerplate) func automates the setup of a new web project. It clones a template repository,
    initializes a Git repository, and pushes the project to a specified remote repository on GitHub. Optionally, it can also
    open the project directory in your preferred code editor.

.PARAMETER template
    Specifies the URL of the template repository on GitHub. The default is "https://github.com/jendahorak/vite-aframe-boilerplate.git".

.PARAMETER project
    Specifies the URL of the remote repository where the new project will be pushed. This parameter is mandatory.

.EXAMPLE
    vab -project "https://github.com/yourusername/your-new-project.git"

    Initializes a new project using the default template repository and a custom project URL.

.EXAMPLE
    vab -template "https://github.com/yourusername/custom-template.git" -project "https://github.com/yourusername/your-new-project.git"

    Initializes a new project using a custom template repository and project URL.

.NOTES
    Before using this function, ensure that Git is installed on your system and that you are authenticated with your GitHub account if needed.

    Replace "code" with your preferred code editor command in the script for optional code editor integration.

#>
    param (
        [string]$template = "https://github.com/jendahorak/vite-aframe-boilerplate.git",
        [Parameter(Mandatory = $true)]
        [string]$project
    )

    # Extract the repository name from the project URL
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension($project)

    # Create a new folder with the repository name and set $here to it
    $here = Join-Path (Get-Location).Path $repoName
    New-Item -Path $here -ItemType Directory

    # Clone the template GitHub repository to the current project directory
    git clone $template $here

    # Change directory to the current project
    Set-Location $here

    # Remove the .git directory from the cloned template (to avoid conflicts with the new project's Git repository)
    Remove-Item -Path .git -Force -Recurse
    Remove-Item -Path README.md -Force

    # Initialize a new Git repository for the project
    git init

    # Add the remote repository URL of your project
    git remote add origin $project
    git pull origin main

    # Add all files to the new repository
    git add .

    # Commit the initial state
    git commit -m "Initial commit"

    # Push the project to GitHub
    git push -u origin main

    # Optionally, open the project directory in your code editor
    # Replace "code" with your preferred code editor command
    code .
}

function initProject {
    <#
    .SYNOPSIS
    Initializes a new project folder structure.

    .DESCRIPTION
    Creates a new project folder with a set of first-level folders based on the type of project.

    .PARAMETER n
    Specifies the name of the project folder.

    .PARAMETER t
    Specifies the type of project. Valid values are "default", "gis", "web", and "python".

    .EXAMPLE
    PS C:\> initProject -n "MyProject" -t "web"
    Initializes a new project folder named "MyProject" with a set of first-level folders for a web project.

    .EXAMPLE
    PS C:\> initProject -n "MyProject" -t "gis"
    Initializes a new project folder named "MyProject" with a set of first-level folders for a GIS project.
    #>



    [CmdletBinding(DefaultParameterSetName = 'ByProjectType')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$n,

        [Parameter(ParameterSetName = 'ByProjectType')]
        [ValidateSet('default', 'gis', 'web', 'python')]
        [string]$t = 'default',

        [Parameter(ParameterSetName = 'ByTemplate')]
        [ValidateScript({ Test-Path $_ })]
        [string]$TemplatePath,

        [Parameter(ParameterSetName = 'ByTemplate')]
        [string]$TemplateName = 'default',

        [Switch]$Force
    )

    # Create the root project folder
    New-Item -Itemt Directory -Path $n

    # Determine the ns of the first-level folders based on the t of project
    switch ($t) {
        "gis" {
            $Folders = @("00_Resources", "01_Developement", "02_Data", "03_Results" )
        }
        "web" {
            $Folders = @("css", "js", "img")
        }
        "python" {
            $Folders = @("src", "tests")
        }
        default {
            $Folders = @("src", "bin", "lib")
        }
    }

    # Create the first-level folders
    foreach ($Folder in $Folders) {
        New-Item -Itemt Directory -Path "$n\$Folder"
    }

    if ($t -eq "gis") {
        New-Item -ItemType Directory -Path "$n\01_Developement\gis"
        New-Item -ItemType Directory -Path "$n\01_Developement\src"
    }
}


function rmAll {
        <#.SYNOPSIS
        Removes all files in Folder
        #>
    Remove-Item -Path .\* -Recurse -Confirm
}
function Rename-Photos {
    <#.SYNOPSIS
    Renames photos in a folder based on their creation date.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Path = (Get-Location).Path
    )

    # Get all the JPG files in the specified directory that don't have "_thumb" in their name
    $files = Get-ChildItem -Path $Path -Filter "*.jpg" | Where-Object { $_.Name -notmatch "_thumb" }

    # Delete all files that contain "_thumb" in their name
    $thumbFiles = Get-ChildItem -Path $Path -Filter "*_thumb.jpg"
    foreach ($file in $thumbFiles) {
        Remove-Item -Path $file.FullName -Force
    }

    # Set the initial serial number
    $serialNumber = 1

    # Loop through each file and rename it
    foreach ($file in $files) {
        # Get the date string from the file name using regular expression
        $dateString = [regex]::Match($file.Name, '\d{2}-\d{2}-\d{4}').Value

        try {
            $date = [datetime]::ParseExact($dateString, "dd-MM-yyyy", $null)
        }
        catch {
            Write-Host "Skipping file $($file.Name) - Invalid date format"
            continue
        }

        # Build the new file name with the serial number
        $newFileName = "telegram_photo_" + $serialNumber.ToString("000") + "@" + $date.ToString("dd-MM-yyyy") + ".jpg"

        # Rename the file
        try {
            Rename-Item $file.FullName -NewName $newFileName
        }
        catch {
            Write-Host "Error renaming file $($file.Name)"
        }

        # Increment the serial number
        $serialNumber++
    }
}


    
function Export-FileList {
    <#.SYNOPSIS
    Exports a list of file names in the current folder to a text file on desktop and opens it in notepad.
#>

    $folderPath = Get-Location
    $files = Get-ChildItem -Path $folderPath | Where-Object { $_.PSIsContainer -eq $false }

    $outputFilePath = "C:\Users\horin\Desktop\file_list.txt"

    $files | ForEach-Object { $_.Name } | Out-File -FilePath $outputFilePath
    
    Start-Process "notepad.exe" -ArgumentList $outputFilePath
}


function Remove-FilesEndingWith1 {
    <#.SYNOPSIS
    Removes files with names ending in " 1.md", " 1.png", or " 1.css" in the current folder.
#>
    $folderPath = Get-Location

    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Name -match " 1\.(md|png|css)$" }

    if ($files.Count -eq 0) {
        Write-Host "No files found that match the pattern ' 1.md' or ' 1.png' in $folderPath"
        return
    }

    $files | ForEach-Object {
        $filePath = $_.FullName
        Remove-Item -Path $filePath -Force
        Write-Host "Removed file: $filePath"
    }
}


function Get-Encoding {
    
<#.SYNOPSIS
    Determines the encoding of a file.
#>

    param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]
        $Path
    )
 
    process {
        $bom = New-Object -TypeName System.Byte[](4)
         
        $file = New-Object System.IO.FileStream($Path, 'Open', 'Read')
     
        $null = $file.Read($bom, 0, 4)
        $file.Close()
        $file.Dispose()
     
        $enc = [Text.Encoding]::ASCII
        if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) 
        { $enc = [Text.Encoding]::UTF7 }
        if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) 
        { $enc = [Text.Encoding]::Unicode }
        if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) 
        { $enc = [Text.Encoding]::BigEndianUnicode }
        if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) 
        { $enc = [Text.Encoding]::UTF32 }
        if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) 
        { $enc = [Text.Encoding]::UTF8 }
         
        [PSCustomObject]@{
            Encoding = $enc
            Path     = $Path
        }
    }
}

function Find-GitRepository {

    <#
    .SYNOPSIS
    Find Git repositories
    #>

    [cmdletbinding()]
    Param(
        [Parameter(
            Position = 0,
            HelpMessage = "The top level path to search"
        )]
        [ValidateScript({
                if (Test-Path $_) {
                    $True
                }
                else {
                    Throw "Cannot validate path $_"
                }
            })]    
        [string]$Path = "."
    )

    Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
    Write-Verbose "[PROCESS] Searching $(Convert-Path -path $path) for Git repositories"

    Get-ChildItem -path $Path -Hidden -filter .git -Recurse | 
    Select-Object @{Name = "Repository"; Expression = { Convert-Path $_.PSParentPath } },
    @{Name = "Branch"; Expression = {
            #save current location
            Push-Location
            #change location to the repository
            Set-Location -Path (Convert-Path -path ($_.psparentPath))
            #get current branch with out the leading asterisk
    (git branch).where({ $_ -match "\*" }).Substring(2)
    
        }
    },
    @{Name = "LastAuthor"; Expression = { git log --date=local --format=%an -1 } },
    @{Name = "LastLog"; Expression = {
    (git log --date=iso --format=%ad -1 ) -as [datetime]
            #change back to original location
            Pop-Location
        }
    }

    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"

} #end function