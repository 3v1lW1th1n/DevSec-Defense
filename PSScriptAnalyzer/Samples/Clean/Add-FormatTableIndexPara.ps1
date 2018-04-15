##############################################################################\n##\n## Add-FormatTableIndexParameter\n##\n## From Windows PowerShell Cookbook (O'Reilly)\n## by Lee Holmes (http://www.leeholmes.com/guide)\n##\n##############################################################################\n\n<#\n\n.SYNOPSIS\n\nAdds a new -IncludeIndex switch parameter to the Format-Table command\nto help with array indexing.\n\n.NOTES\n\nThis commands builds on New-CommandWrapper, also included in the Windows\nPowerShell Cookbook.\n\n.EXAMPLE\n\nPS >$items = dir\nPS >$items | Format-Table -IncludeIndex\nPS >$items[4]\n\n#>\n\nSet-StrictMode -Version Latest\n\nNew-CommandWrapper Format-Table `\n    -AddParameter @{\n        @{\n            Name = 'IncludeIndex';\n            Attributes = "[Switch]"\n        } = {\n\n        function Add-IndexParameter {\n            begin\n            {\n                $psIndex = 0\n            }\n            process\n            {\n                ## If this is the Format-Table header\n                if($_.GetType().FullName -eq `\n                    "Microsoft.PowerShell.Commands.Internal." +\n                    "Format.FormatStartData")\n                {\n                    ## Take the first column and create a copy of it\n                    $formatStartType =\n                        $_.shapeInfo.tableColumnInfoList[0].GetType()\n                    $clone =\n                        $formatStartType.GetConstructors()[0].Invoke($null)\n\n                    ## Add a PSIndex property\n                    $clone.PropertyName = "PSIndex"\n                    $clone.Width = $clone.PropertyName.Length\n\n                    ## And add its information to the header information\n                    $_.shapeInfo.tableColumnInfoList.Insert(0, $clone)\n                }\n\n                ## If this is a Format-Table entry\n                if($_.GetType().FullName -eq `\n                    "Microsoft.PowerShell.Commands.Internal." +\n                    "Format.FormatEntryData")\n                {\n                    ## Take the first property and create a copy of it\n                    $firstField =\n                        $_.formatEntryInfo.formatPropertyFieldList[0]\n                    $formatFieldType = $firstField.GetType()\n                    $clone =\n                        $formatFieldType.GetConstructors()[0].Invoke($null)\n\n                    ## Set the PSIndex property value\n                    $clone.PropertyValue = $psIndex\n                    $psIndex++\n\n                    ## And add its information to the entry information\n                    $_.formatEntryInfo.formatPropertyFieldList.Insert(\n                        0, $clone)\n                }\n\n                $_\n            }\n        }\n\n        $newPipeline = { __ORIGINAL_COMMAND__ | Add-IndexParameter }\n    }\n}
