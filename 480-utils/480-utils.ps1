

Try
{
    $vserver= Read-Host "Please enter the FQDN or IP address of your Vcenter server: " 
    $user = "riku"
    $pass = "DuckHun+D0g"
    Connect-VIServer($vserver) -User $user -Password $pass -ErrorAction Stop

}Catch{
    Write-Output "!!!Error!!! - Could not connect to vCenter. Check your Vcenter server name and your Vcenter credentials."

}
Try{
    $vmName = Read-Host "Enter the VM Name you wish to clone: "
    $vm=Get-VM -Name $vmName -ErrorAction Stop

}Catch{
    Write-Output "!!!Error!!! - Enter an existing VM name"

}
Try{
    $snapName = Read-Host "Enter the Name of "$vmName"'s Snapshot you wish to clone" 
    $snapshot=Get-Snapshot -VM $vm -Name $snapName -ErrorAction Stop
}Catch{
    Write-Output "!!!Error!!! - Snapshot not found!"
}Try{
    $dname = Read-Host "Enter the Name of the datastore you wish to store your clone: "
    $dstore = Get-DataStore -Name $dname -ErrorAction -Stop

}Catch{
    Write-Output "!!!Error!!! - Datastore not found!"

}Try{
    $hostname = Read-Host "Enter the Name of the esxi host you wish to store your clone: "
    $vmhost = Get-VMHost -Name $hostname -ErrorAction -Stop

}Catch{
    Write-Output "!!!Error!!! - VM Host not found!"
}
        
$choice = Read-Host "Create a Linked Clone or Full Clone? Enter [L/l] for Linked Clone or [F/f] for Full Clone"
If($choice -eq 'F' -or $choice -eq 'f' )
{
    $Tempname = "{0}.temp" -f $vmName
    $Tempvm = New-VM -Name $Tempname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
    $newname = Read-Host "Enter a name for your New VM"

    $newvm = New-VM -Name $newname -VM $Tempvm -VMHost $vmhost -Datastore $dstore 
    $newvm | new-snapshot -Name "Base"
    $Tempvm | Remove-VM

}elseif ($choice -eq 'L' -or $choice -eq 'l' ) {

    $newname = "{0}.linked" -f $vmName
    $newvm = New-VM -Name $newname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore

}else{
    throw "Select Either [L]inked Clone or [F]ull Clone"
}





#Try{}Catch{}




#Connect-VIServer($vserver)
#$vm=Get-VM -Name server19-gui
#$snapshot = Get-Snapshot -VM $vm -Name "Server-2019 Base"
#$vmhost = Get-VMHost -Name "192.168.3.22"
#$dstore = Get-DataStore datastore1
#$linkedname = "{0}.linked" -f $vm.name
#$linkedvm = New-VM -Name $linkedname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
#$newvm = New-VM -Name "Server2019-gui-base" -VM $linkedvm -VMHost $vmhost -Datastore $dstore 
#$newvm | new-snapshot -Name "Base"
#$linkedvm | Remove-VM
#Move-VM -VM $newvm -Destination "BASE-VMS"