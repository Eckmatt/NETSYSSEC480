$defaultConfig = Get-Content defaults.json | ConvertFrom-Json


Function connect_server(){

    Try
    {
        $vserver= Read-Host "Please enter the FQDN or IP address of your Vcenter server [$defaultConfig.vCenterName]: "
        if ([string]::IsNullOrWhiteSpace($vserver))
        {
            Connect-VIServer($defaultConfig.vCenterName) -ErrorAction Stop
        }else{
            Connect-VIServer($vserver) -ErrorAction Stop
        }
        

    }Catch{
        Write-Output "!!!Error!!! - Could not connect to vCenter. Check your Vcenter server name and your Vcenter credentials."
        
    }
}

Function select_vm(){
    Try{
        $vmName = Read-Host "Enter the VM Name you wish to clone: "
        $vm=Get-VM -Name $vmName -ErrorAction Stop
        return $vm

    }Catch{
        Write-Output "!!!Error!!! - Enter an existing VM name"
        exit
    }
}

Function pick_snapshot(){
    [CmdletBinding()]
    param (
        $vm
    )
    Try{
        $snapName = Read-Host "Enter the Name of "$vm.Name"'s Snapshot you wish to clone" 
        $snapshot=Get-Snapshot -VM $vm -Name $snapName -ErrorAction Stop
        return $snapshot
    }Catch{
        Write-Output "!!!Error!!! - Snapshot not found!"
        exit
}
}
Function pick_datastore(){
    Try{
        $dname = Read-Host "Enter the Name of the datastore you wish to store your clone [$defaultConfig.dstoreName]"
        if ([string]::IsNullOrWhiteSpace($dname))
        {
            $dstore = Get-DataStore $defaultConfig.dstoreName -ErrorAction Stop
        }else{
            $dstore = Get-DataStore $dname -ErrorAction Stop
        }
        return $dstore
    

    }Catch{
        Write-Warning $Error[0]
        exit

    }
}
Function pick_hostname(){
    Try{

        $hostname = Read-Host "Enter the Name of the esxi host you wish to store your clone [$defaultConfig.hostname]"
        if ([string]::IsNullOrWhiteSpace($hostname))
        {
            $vmhost = Get-VMHost -Name $defaultConfig.hostname -ErrorAction Stop
        }else{
            $vmhost = Get-VMHost -Name $hostname -ErrorAction Stop
        }
        
        return $vmhost

    }Catch{
        Write-Warning $Error[0]
        exit
    }

}

Function pick_folder(){
    param(
        $vmhost
    )
    Try{

        $folderName = Read-Host "Enter the Name of the Folder you wish to store your clone [$defaultConfig.FolderName]"
        if ([string]::IsNullOrWhiteSpace($folderName))
        {
            $folder = Get-Folder -Name $defaultConfig.FolderName -ErrorAction Stop
        }else{
            $folder = Get-Folder -Name $folderName -ErrorAction Stop
        }
        return $folder

    }Catch{
        Write-Warning $Error[0]
        exit
    }

}


function cloner () {
    
    connect_server
    $vm = select_vm
    $snapshot = pick_snapshot -vm $vm
    $vmhost = pick_hostname
    $dstore = pick_datastore
    $folder = pick_folder

    $choice = Read-Host "Create a Linked Clone or Full Clone? Enter [L/l] for Linked Clone or [F/f] for Full Clone"
    If($choice -eq 'F' -or $choice -eq 'f' )
    {
        $Tempname = "{0}.temp" -f $vm.Name
        $Tempvm = New-VM -Name $Tempname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore
        $newname = Read-Host "Enter a name for your New VM"

        $newvm = New-VM -Name $newname -VM $Tempvm -VMHost $vmhost -Datastore $dstore -Location $folder
        $newvm | new-snapshot -Name "Base"
        $Tempvm | Remove-VM

    }elseif ($choice -eq 'L' -or $choice -eq 'l' ) {

        $newname = "{0}.linked" -f $vm.Name
        $newvm = New-VM -Name $newname -VM $vm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -Location $folder

    }else{
        throw "Select Either [L]inked Clone or [F]ull Clone"
    }

}

function createNetwork () {
    [CmdletBinding()]
    param (
        [string[]]$networkName = "blueX-LAN", [string[]]$esxiHost = "192.168.3.22", [string[]]$vcenterServer = "vcenter.eckhardt.local"

    )
    Connect-VIServer $vcenterServer -User riku
    $newVSwitch = New-VirtualSwitch -Name $networkName -VMHost $esxiHost
    $newPortGroup = New-VirtualPortGroup -Name $networkName -VirtualSwitch $newVSwitch

}

function pick_portgroup () {
    Try{

        $groupName = Read-Host "Enter the Name of the esxi host you wish to store your clone [$defaultConfig.groupName]"
        if ([string]::IsNullOrWhiteSpace($groupName))
        {
            $portgroup = Get-VirtualPortGroup -Name $defaultConfig.groupName -ErrorAction Stop
        }else{
            $portgroup = Get-VirtualPortGroup -Name $groupName -ErrorAction Stop
        }
        
        return $portgroup

    }Catch{
        Write-Warning $Error[0]
        exit
    }


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