$vserver="vcenter.eckhardt.local"
Connect-VIServer($vserver)
$vm=Get-VM -Name "vyos-480-fw22"
$snapshot = Get-Snapshot -VM $vm -Name "vyos-base"
$vmhost = Get-VMHost -Name "192.168.3.22"
$dstore = Get-DataStore datastore1
$linkedname = "{0}.linked" -f $vm.name
$linkedvm = New-VM -Name $linkedname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
$newvm = New-VM -Name "vyos-base" -VM $linkedvm -VMHost $vmhost -Datastore $dstore 
$newvm | new-snapshot -Name "Base"
$linkedvm | Remove-VM
Move-VM -VM $newvm -Destination "BASE-VMS"

