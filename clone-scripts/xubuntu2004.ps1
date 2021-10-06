$vserver="vcenter.eckhardt.local"
Connect-VIServer($vserver)
$vm=Get-VM -Name xubuntu-wan
$snapshot = Get-Snapshot -VM $vm -Name "Base-xubuntu"
$vmhost = Get-VMHost -Name "192.168.x.xx"
$dstore = Get-DataStore datastore1
$linkedname = "{0}.linked" -f $vm.name
$linkedvm = New-VM -Name $linkedname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
$newvm = New-VM -Name "xubuntu-20.04-base" -VM $linkedvm -VMHost $vmhost -Datastore $dstore 
$newvm | new-snapshot -Name "Base"
$linkedvm | Remove-VM
Move-VM -VM $newvm -Destination "BASE-VMS"
