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

#Set the location of the "inkscape.com" program 
$inkscape = "C:\Program Files\Inkscape\Inkscape.com"

#Set the scale factors you want the script to produce.
#When preparing your files, remember the script starts at the largest size, and scales down 
$scales = 400, 200, 150, 125, 100

#Set the directory containing all the source files (relative path from script location)
$inputFolder = "Templates\"

#Set the output directory for the scaled images (relative path from script location)
$outputFolder =".\"

#############################
#Do not edit below this line#
#############################
Import-Module .\Resize-Image.psm1

$scales = $scales | Sort-Object -Descending
$largestScale = $scales[0]

$fullLocation = $MyInvocation.MyCommand.Source
$location = $FullLocation.Substring(0,$fullLocation.LastIndexOf($MyInvocation.MyCommand.Name))

Get-ChildItem $inputFolder | where-object { $_.extension -eq ".svg" -and $_.BaseName -notlike "*_Template" } | ForEach-Object {
    $fullname = $_.FullName
    $name = $_.BaseName

    $curOutputFolder = "$outputFolder\$name"
    if(-not (Test-Path $curOutputFolder -PathType Container)) { New-Item $curOutputFolder -ItemType Directory }


    $newName = "$curOutputFolder\$name.Scale-$largestScale.png"

    . $inkscape -f $fullname -e $newName

    $scales | ForEach-Object {
        $scaleFactor = $_ / $largestScale
        if($scaleFactor -ne 1) {
            Write-Output "$location\$curOutputFolder\$name.Scale-$_.png"
            Resize-Image -InputFile ".\$newName" -OutputFile "$location\$curOutputFolder\$name.Scale-$_.png" -Scale ($scaleFactor * 100)
        }
    }
}