$vserver="vcenter.eckhardt.local"
Connect-VIServer($vserver)
$vm=Get-VM -Name server19-gui
$snapshot = Get-Snapshot -VM $vm -Name "Server-2019 Base"
$vmhost = Get-VMHost -Name "192.168.3.22"
$dstore = Get-DataStore datastore1
$linkedname = "{0}.linked" -f $vm.name
$linkedvm = New-VM -Name $linkedname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
$newvm = New-VM -Name "Server2019-gui-base" -VM $linkedvm -VMHost $vmhost -Datastore $dstore 
$newvm | new-snapshot -Name "Base"
$linkedvm | Remove-VM
Move-VM -VM $newvm -Destination "BASE-VMS"

