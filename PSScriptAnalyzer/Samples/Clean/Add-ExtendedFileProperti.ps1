##############################################################################\n##\n## Add-ExtendedFileProperties\n##\n## From Windows PowerShell Cookbook (O'Reilly)\n## by Lee Holmes (http://www.leeholmes.com/guide)\n##\n##############################################################################\n\n<#\n\n.SYNOPSIS\n\nAdd the extended file properties normally shown in Exlorer's\n"File Properties" tab.\n\n.EXAMPLE\n\nGet-ChildItem | Add-ExtendedFileProperties.ps1 | Format-Table Name,"Bit Rate"\n\n#>\n\nbegin\n{\n    Set-StrictMode -Version Latest\n\n    ## Create the Shell.Application COM object that provides this\n    ## functionality\n    $shellObject = New-Object -Com Shell.Application\n\n    ## Store the property names and identifiers for all of the shell\n    ## properties\n    $itemProperties = $null\n}\n\nprocess\n{\n    ## Get the file from the input pipeline. If it is just a filename\n    ## (rather than a real file,) piping it to the Get-Item cmdlet will\n    ## get the file it represents.\n    $fileItem = $_ | Get-Item\n\n    ## Don't process directories\n    if($fileItem.PsIsContainer)\n    {\n        $fileItem\n        return\n    }\n\n    ## Extract the file name and directory name\n    $directoryName = $fileItem.DirectoryName\n    $filename = $fileItem.Name\n\n    ## Create the folder object and shell item from the COM object\n    $folderObject = $shellObject.NameSpace($directoryName)\n    $item = $folderObject.ParseName($filename)\n\n    ## Populate the item properties\n    if(-not $itemProperties)\n    {\n        $itemProperties = @{}\n\n        $counter = 0\n        $columnName = ""\n        do\n        {\n            $columnName = $folderObject.GetDetailsOf(\n                $folderObject.Items, $counter)\n            if($columnName) { $itemProperties[$counter] = $columnName }\n\n            $counter++\n        } while($columnName)\n    }\n\n    ## Now, go through each property and add its information as a\n    ## property to the file we are about to return\n    foreach($itemProperty in $itemProperties.Keys)\n    {\n        $fileItem | Add-Member NoteProperty $itemProperties[$itemProperty] `\n            $folderObject.GetDetailsOf($item, $itemProperty) -ErrorAction `\n            SilentlyContinue\n    }\n\n    ## Finally, return the file with the extra shell information\n    $fileItem\n}