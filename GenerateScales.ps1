##  Copyright 2016 Evan Williams
## 
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

########################
# Set Script Variables #
########################

#Set the location of the "inkscape.com" program 
$inkscape = "C:\Program Files\Inkscape\Inkscape.com"

#Set the directory containing all the source files (relative path from script location)
$inputFolder = "Templates\"

#Set the output directory for the scaled images (relative path from script location)
$outputFolder =".\"

#######################
#End Script Variables #
#######################

#Fetch the resize module
Import-Module .\Resize-Image.psm1

#Function to use inkscape to export an SVG as a png
function Export-SVG {
    param( [String] $inFile, [String] $outfile)
    . $inkscape -f $inFile -e $outfile
}

#Function to generate a filename in the format required by the UWP
function Generate-Filename {
    param( [string] $coreName, [string] $suffix, [int] $scale)
    
    Write-Output "$coreName.$suffix-$scale.png"
}

#Work out where this script is stored, so relative paths will work
$fullLocation = $MyInvocation.MyCommand.Source
$location = $FullLocation.Substring(0,$fullLocation.LastIndexOf($MyInvocation.MyCommand.Name))

#Grab all the non-template svgs in the input foder
Get-ChildItem $inputFolder | where-object { $_.extension -eq ".svg" -and $_.BaseName -notlike "*_Template" } | ForEach-Object {
    
    #Get the resize data from the file
    #If the file does not contain resize data, move on to the next file.
    [xml]$file = Get-Content $inputFolder\$_
    if($file.svg.Sizes) {
        #Get the sizes it needs to be scaled to
        #Currently this requires the sizes to be in order (or at the very least, start with the largest)
        #Would be good to sort them, but cannot work out how currently, as Sort-Object treats "Width" and "Height" as strings
        $sizes = $file.svg.Sizes.Size

        #Get the name of the current SVG. 
        $fullname = $_.FullName
        $name = $_.BaseName

        #Get the output folder, create it if it doesn't yet exist
        $curOutputFolder = "$outputFolder\$name"
        if(-not (Test-Path $curOutputFolder -PathType Container)) { New-Item $curOutputFolder -ItemType Directory }
        
        #Export the first png, from which all the others will be scaled
        $firstScale = $sizes[0].Scale
        $firstFile = Generate-Filename -coreName $_.BaseName -suffix $sizes[0].NameSuffix -scale $firstScale
        $firstFilePath = "$curOutputFolder\$firstFile"
        Export-SVG -inFile $_.FullName -outfile $firstFilePath

        #Resize the png to all the required sizes
        $sizes | ForEach-Object {
            #Make sure we're not trying to scale the first image to itself
            if($_.Scale -ne $firstScale) {
                #Get the full path for where the file needs to output
                $newName = Generate-Filename -coreName $name -suffix $_.NameSuffix -scale $_.Scale
                $fullOutputPath = "$location\$curOutputFolder\$newName"
                Write-Output $fullOutputPath

                #Resize the image
                Resize-Image -InputFile $firstFilePath -OutputFile $fullOutputPath -Width $_.Width -Height $_.Height
            }
        }
    }
}