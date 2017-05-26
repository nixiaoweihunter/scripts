#!/root/python27/bin/python
import atexit
import hashlib
import json

import random
import time

import requests
from pyVim import connect
from pyVmomi import vim

from tools import tasks

import ssl

vc_host = ''
vc_user = ''
vc_ds   = ''
vc_password = ''

def create_vm(name, service_instance, vm_folder, resource_pool,datastore):
    vm_name = 'VM-' + name
    datastore_path = '[' + datastore + '] ' + vm_name

    # bare minimum VM shell, no disks. Feel free to edit
    vmx_file = vim.vm.FileInfo(logDirectory=None,
                               snapshotDirectory=None,
                               suspendDirectory=None,
                               vmPathName=datastore_path)
    
    spec = vim.vm.ConfigSpec()
    scsi_ctr = vim.vm.device.VirtualDeviceSpec()
    scsi_ctr.operation = vim.vm.device.VirtualDeviceSpec.Operation.add
    scsi_ctr.device = vim.vm.device.VirtualLsiLogicController()
    scsi_ctr.device.deviceInfo = vim.Description()
    scsi_ctr.device.slotInfo = vim.vm.device.VirtualDevice.PciBusSlotInfo()
    scsi_ctr.device.slotInfo.pciSlotNumber = 16
    scsi_ctr.device.controllerKey = 100
    scsi_ctr.device.unitNumber = 3
    scsi_ctr.device.busNumber = 0
    scsi_ctr.device.hotAddRemove = True
    scsi_ctr.device.sharedBus = 'noSharing'
    scsi_ctr.device.scsiCtlrUnitNumber = 7

    unit_number = 0
    controller = scsi_ctr.device
    disk_spec = vim.vm.device.VirtualDeviceSpec()
    disk_spec.fileOperation = "create"
    disk_spec.operation = vim.vm.device.VirtualDeviceSpec.Operation.add
    disk_spec.device = vim.vm.device.VirtualDisk()
    disk_spec.device.backing = vim.vm.device.VirtualDisk.FlatVer2BackingInfo()
    disk_spec.device.backing.thinProvisioned = True
    disk_spec.device.backing.diskMode = 'persistent'
    disk_spec.device.backing.fileName = '%s.vmdk'% vm_name
    disk_spec.device.unitNumber = unit_number
    disk_spec.device.capacityInKB = 1 * 1024 * 1024
    disk_spec.device.controllerKey = controller.key

    #nicspec = vim.vm.ConfigSpec()
    nic_spec = vim.vm.device.VirtualDeviceSpec()
    nic_spec.operation = vim.vm.device.VirtualDeviceSpec.Operation.add
    nic_spec.device = vim.vm.device.VirtualE1000()
    nic_spec.device.deviceInfo = vim.Description()
    nic_spec.device.deviceInfo.summary = 'vCenter API'
    nic_spec.device.backing = vim.vm.device.VirtualEthernetCard.NetworkBackingInfo()
    nic_spec.device.backing.useAutoDetect = False
    nic_spec.device.backing.deviceName = "VM Network"
    #nic_spec.deivce.connectable = vim.vm.device.VirtualDevice.ConnectInfo()
    #nic_spec.device.connectable.startConnected = True
    #nic_spec.device.connectable.allowGuestControl = True
    #nic_spec.device.connectable.connected = False
    #nic_spec.device.connectable.status = 'untried'
    #nic_spec.device.wakeOnLanEnabled = True
    #nic_spec.device.addressType = 'assigned'
    #nic_spec.device.macAddress = mac

    dev_changes = []
    dev_changes.append( scsi_ctr )
    dev_changes.append( disk_spec )
    dev_changes.append( nic_spec )
#    spec.deviceChange = dev_changes

    
 
 
    config = vim.vm.ConfigSpec( 
                                name=vm_name, 
                                memoryMB=128, 
                                numCPUs=1,
                                files=vmx_file, 
				deviceChange=dev_changes,
                                guestId='dosGuest', 
                                version='vmx-07'
                              )

    print "Creating VM {} ...".format(vm_name)
    task = vm_folder.CreateVM_Task(config=config, pool=resource_pool)
    tasks.wait_for_tasks(service_instance, [task])


def main():
    name = 'testvm'
    vm = None
    context = None
    if hasattr(ssl, '_create_unverified_context'):
      context = ssl._create_unverified_context()
    service_instance = connect.SmartConnect(host=vc_host,
                                            user=vc_user,
                                            pwd=vc_password,
					    sslContext=context
                                           )

    if not service_instance:
        print("Could not connect to the specified host using specified "
              "username and password")
        return -1

    atexit.register(connect.Disconnect, service_instance)

    content = service_instance.RetrieveContent()
    datacenter = content.rootFolder.childEntity[0]
    vmfolder = datacenter.vmFolder
    hosts = datacenter.hostFolder.childEntity
    resource_pool = hosts[0].resourcePool


    create_vm(name, service_instance, vmfolder, resource_pool, vc_ds)


    return 0

# Start program
if __name__ == "__main__":
    main()


