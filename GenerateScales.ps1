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

#############################
#Do not edit below this line#
#############################
Import-Module .\Resize-Image.psm1

$scales = $scales | Sort-Object -Descending
$largestScale = $scales[0]

Get-ChildItem .\ToScale | where-object { $_.extension -eq ".svg" } | ForEach-Object {
    $fullname = $_.FullName
    $name = $_.BaseName
    if(-not (Test-Path $name -PathType Container)) { New-Item $name -ItemType Directory }


    $newName = "$name\$name.Scale-$largestScale.png"

    . $inkscape -f $fullname -e $newName

    $scales | ForEach-Object {
        $scaleFactor = $_ / $largestScale
        if($scaleFactor -ne 1) {
            Resize-Image -InputFile ".\$newName" -OutputFile "$location\$name\$name.Scale-$_.png" -Scale ($scaleFactor * 100)
        }
    }
}

