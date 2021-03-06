Set-Location "C:\data\Profiles\Staff" 
$DirectoryList = "C:\data\Profiles\Staff" # Build the list 
 
$Folders = Get-ChildItem $DirectoryList 
 
ForEach ($Folder in $Folders) { 
 
       trap [Exception] {  
      write-host "Trapped $Folder" -ForegroundColor R`eD 
      #write-host "Trapped $($_.Exception.Message)" -ForegroundColor Red 
      write-output "errored on $Folder" | out-file C:`\prOf`ilEfIX`ErROR`.tXT -append 
 
      continue} 
       
        $ProfilePath = "$DirectoryList\$Folder" 
        write-host "$ProfilePath" 
        $Contents = Get-ChildItem -Recurse -Force "$ProfilePath" | where{!$_.PsIsContainer} | select n`Ame,dir`e`CTory 
 
        ForEach ($Content in $Contents) { 
         
               trap [Exception] {  
                      write-host "Trapped $ProfilePath" -ForegroundColor r`Ed 
                      #write-host "Trapped $($_.Exception.Message)" -ForegroundColor Red 
                      write-output "Trapped $ProfilePath" | out-file C:\Pr`OfIL`EFi`x`eRR`OR.TXt -append 
 
      continue} 
            $Directory = $Content.directory 
            $File =  $Content.name 
            $Job = "$directory\$File" 
            #write-host $job 
            $acl = Get-Acl $job 
            write-host $job "is" ($acl.areaccessrulesprotected) 
            #$acl.areaccessrulesprotected 
            $isProtected = $false 
            $preserveInheritance = $true 
            $acl.SetAccessRuleProtection($isProtected, $preserveInheritance) 
            #$acl.areaccessrulesprotected 
            #write-host $job 
            Set-Acl -Path $job -AclObject $acl 
            write-host $job "is" ($acl.areaccessrulesprotected) 
            } 
        }
