README describing usage and example when using fbxvm-ctrl program
To be run on Freebox Delta hardware from FREE (French Internet Provider)
sourcing lib : fbx-delta-nba_bash_api.sh

--------------------------------------------------------------------------------------------------------------------
---> Help : 
--------------------------------------------------------------------------------------------------------------------

fbxvm-ctrl USE FREEBOX REST API TO MANAGE FREEBOX-DELTA VIRTUAL MACHINES

usage: ./fbxvm-ctrl list
usage: ./fbxvm-ctrl listdisk /path/to/freebox_VM/folder
usage: ./fbxvm-ctrl <verb> <object> <param>
usage: ./fbxvm-ctrl vmid <action> <param|mode(optionnal)>

- action = <start|shutdown(acpi)|stop(force)|restart|detail|modify|console>
- param  = <name=|vcpu=|memory=|disk_type=|disk_path=|...>
- mode   = ('console' only & optionnal) = <""|detached|screen>

VERB :   - add        : create virtual machine or create virtual machine disk 
         - del        : delete virtual machine or delete virtual machine disk 
         - resize     : resize virtual machine disk - disk-only 

ACTION : - start     : simply start VM
   	 - shutdown  : (acpi) send an ACPI shutdown command to VM
   	 - stop      : (force) set a PSU restart command to VM = electrical stop
   	 - restart   : simply restart VM 
   	 - detail    : print VM configuration detail (all parameters of Freebox API VM object)
   	 - modify    : modify VM parameter
   	 - console   : connect VM console

OBJECT : - vm        : freebox delta virtual machine 
         - disk      : freebox delta virtual machine

PARAM :  - name=                : name of this VM - VM-only (string, max 31 characters) 
         - vcpu=                : number of virtual CPUs to allocate to this VM - VM-only (integer)
  	 - memory=              : memory allocated to this VM in megabytes - VM-only (integer)
	 - disk_type=           : type of disk image, values : qcow2|raw - VM+disk (string)
  	 - disk_path=           : path to the hard disk image of this VM - VM+disk (string)
  	 - disk_size=           : hard disk final size in bytes (integer) - disk-only
  	 - disk_shrink=         : allow or not the disk to be shrink - disk-only (bool) DANGEROUS
  	 - cd_path=             : path to CDROM device ISO image - optional - VM-only (string) 
  	 - os=                  : VM OS: unknown|fedora|debian|ubuntu|freebsd|centos|jeedom|homebridge 
  	 - enable_screen=       : virtual screen using VNC websocket protocol - VM-only (bool) 
  	 - bind_usb_ports=      : syntax : bind_usb_ports='"usb-external-type-c","usb-external-type-a"' 
	 - enable_cloudinit=    : enable or not  passing data through cloudinit - VM-only (bool) 
  	 - cloudinit_hostname=  : when cloudinit is enabled: hostname (string, max 59 characters)
  	 - cloudinit_userdata=  : path to file containing user-data raw yaml (file max 32767 characters)

WARNING : when modifying VM, if you do not explicitly specify on the cmdline 'cloudinit_userdata=$val',
	  previous values for 'cloudinit_userdata' parameter will be reset to null ('') 

MODE ('console' only options) :
 	 - if <mode> is ommited, console is launched directly from terminal (basic mode)	
	 - if <mode> is "detached" console is launched detached from terminal (best mode)	
	 - if <mode> is "screen" console is launched in a screen (alternative mode)	

---> "detached" and "screen" mode require you install "GNU dtach" or "GNU screen" programm

  
--------------------------------------------------------------------------------------------------------------------
---> Help output on specific (major) command  
--------------------------------------------------------------------------------------------------------------------  


$ fbxvm-ctrl add disk

ERROR: <param> for 'add disk' must be:
disk_type=
disk_path=
size=

EXAMPLE:
fbxvm-ctrl add disk disk_type="qcow2" disk_path="/freeboxdisk/vmdiskpath/myvmdisk.qcow2" size="10737418240"     
  
  
--------------------------------------------------------------------------------------------------------------------  
 
$ fbxvm-ctrl resize disk

ERROR: <param> for 'resize disk' must be :
disk_shrink=
disk_path=
size=

EXAMPLE:
fbxvm-ctrl resize disk disk_shrink="0" disk_path="/freeboxdisk/vmdiskpath/myvmdisk.qcow2" size="10737418240"     

--------------------------------------------------------------------------------------------------------------------
	
fbxvm-ctrl del disk 14RV-FSRV-133.qcow2

ERROR: you must specify the option "disk_path="

EXAMPLE:
fbxvm-ctrl del disk disk_path="/FBX-2000G/box-vm/14RV-FSRV-49.qcow2"
	
--------------------------------------------------------------------------------------------------------------------

$ fbxvm-ctrl add vm

ERROR: <param> must be some of:
name=
vcpu=
memory=
disk_type=
disk_path=
cd_path=
os=
enable_screen=
bind_usb_ports=
enable_cloudinit=
cloudinit_hostname=
cloudinit_userdata=

NOTE: minimum parameters to specify on cmdline to create a VM: 
disk_type= 
disk_path= 
vcpus= 
memory= 
name= 

EXAMPLE:
fbxvm-ctrl add vm disk_type="qcow2" disk_path="/freeboxdisk/vmdiskpath/myvmdisk.qcow2" vcpus="1" memory="2048" cd_path="/freeboxdisk/vmisopath/debian-11.0.0-arm64-netinst.iso" os="debian" enable_screen="true" cloudinit_hostname="14RV-FSRV-49" cloudinit_userdata="cloudinit-userdata.yml" bind_usb_ports='"usb-external-type-c","usb-external-type-a"' name="14RV-FSRV-49.dmz.lan"

--------------------------------------------------------------------------------------------------------------------
fbxvm-ctrl del vm

ERROR: you must specify a VM id

EXAMPLE:
fbxvm-ctrl del vm 31 

--------------------------------------------------------------------------------------------------------------------
  
$ fbxvm-ctrl 8 modify

ERROR: <param> must be some of:
name=
vcpu=
memory=
disk_type=
disk_path=
cd_path=
os=
enable_screen=
bind_usb_ports=
enable_cloudinit=
cloudinit_hostname=
cloudinit_userdata=

NOTE: minimum parameters to specify on cmdline to modify a VM: 
disk_type= 
disk_path= 
vcpus= 
memory= 
name= 

EXAMPLE:
fbxvm-ctrl 31 modify disk_type="qcow2" disk_path="/freeboxdisk/vmdiskpath/myvmdisk.qcow2" vcpus="1" memory="2048" cd_path="/freeboxdisk/vmisopath/debian-11.0.0-arm64-netinst.iso" os="debian" enable_screen="true" cloudinit_hostname="14RV-FSRV-49" cloudinit_userdata="cloudinit-userdata.yml" bind_usb_ports='"usb-external-type-c","usb-external-type-a"' name="14RV-FSRV-49.dmz.lan"

WARNING: 
When modifying VM, if you do not explicitly specify on the cmdline 'cloudinit_userdata=$val' ('$val' must be a 'yaml cloudinit' file), previous values for 'cloudinit_userdata' parameter will be reset to null (''). Others values are retrieve automatically from existing VM configuration

 
--------------------------------------------------------------------------------------------------------------------
---> Output of informative command  (list, listdisk, detail)
--------------------------------------------------------------------------------------------------------------------  

 $ fbxvm-ctrl list

 CONTROL FREEBOX VM

URL CALLED : https://fbx.soartist.net:2059/api/v8/
API CALLED : vm
VERB|VM ID : list
ACTION : disk
RESULT :

VIRTUAL MACHINE ID, NAME, MAC AND STATUS : 

VM-0:	  id: 0 	 status: stopped 	name: 14RV-FSRV-00 	mac_address: ce:3e:20:b9:66:fc
VM-1:  	id: 1 	 status: stopped 	name: 14RV-FSRV-03 	mac_address: 3e:6e:bd:2b:fe:c7
VM-2:  	id: 2 	 status: running 	name: 14RV-FSRV-01 	mac_address: ae:2c:8c:f6:3e:fb
VM-3:  	id: 3 	 status: running 	name: 14RV-FSRV-02 	mac_address: 5a:e3:85:db:26:ee
VM-4:  	id: 4 	 status: stopped 	name: 14RV-FSRV-04 	mac_address: 5e:e3:3a:13:ab:20
VM-5:  	id: 5 	 status: stopped 	name: 14RV-FSRV-05 	mac_address: be:dd:fc:cc:53:8d
VM-6:   id: 6 	 status: stopped 	name: 14RV-FSRV-06 	mac_address: ba:81:13:4f:2f:4e
VM-7:	  id: 7 	 status: stopped 	name: 14RV-FSRV-07 	mac_address: da:05:e4:43:33:5d
VM-8:	  id: 8 	 status: stopped 	name: 14RV-FSRV-08 	mac_address: ce:3c:ee:b4:f4:f0
VM-9:	  id: 9 	 status: stopped 	name: 14RV-FSRV-09 	mac_address: 02:44:40:c3:c7:2b
VM-10:	id: 10 	 status: running 	name: 14RV-FSRV-10 	mac_address: 66:35:fc:a1:6b:9f
VM-11:	id: 11 	 status: stopped 	name: 14RV-FSRV-11 	mac_address: 5e:fb:d2:ad:01:5c
VM-12:	id: 12 	 status: stopped 	name: 14RV-FSRV-12 	mac_address: a6:3a:0a:8d:2f:18

--------------------------------------------------------------------------------------------------------------------

$ fbxvm-ctrl listdisk /FBX-2000G/box-vm/

CONTROL FREEBOX VM

URL CALLED : https://fbx.soartist.net:2059/api/v8/
API CALLED : vm
VERB|VM ID : listdisk
ACTION : /FBX-2000G/box-vm/
RESULT :

VIRTUAL MACHINE DISK LIST : 

DISK-2:  	  index: 2	name: 14RV-FSRV-00.qcow2	size: 2711289856 bytes
DISK-4:  	  index: 4	name: 14RV-FSRV-01.qcow2	size: 10517544960 bytes
DISK-6:  	  index: 6	name: 14RV-FSRV-02.qcow2	size: 6618480640 bytes
DISK-8:    	index: 8	name: 14RV-FSRV-03.qcow2	size: 2711289856 bytes
DISK-10:  	index: 10	name: 14RV-FSRV-04.qcow2	size: 2711289856 bytes
DISK-12:  	index: 12	name: 14RV-FSRV-05.qcow2	size: 2711289856 bytes
DISK-14:  	index: 14	name: 14RV-FSRV-06.qcow2	size: 2711289856 bytes
DISK-16:  	index: 16	name: 14RV-FSRV-07.qcow2	size: 2711289856 bytes
DISK-18:  	index: 18	name: 14RV-FSRV-08.qcow2	size: 2711289856 bytes
DISK-20:  	index: 20	name: 14RV-FSRV-09.qcow2	size: 2711289856 bytes
DISK-22:  	index: 22	name: 14RV-FSRV-10.qcow2	size: 3878092800 bytes
DISK-24:  	index: 24	name: 14RV-FSRV-11.qcow2	size: 2711289856 bytes
DISK-25:  	index: 25	name: 14RV-FSRV-13.qcow2	size: 197088 bytes
DISK-26:  	index: 26	name: 14RV-FSRV-14.qcow2	size: 197088 bytes
DISK-27:  	index: 27	name: 14RV-FSRV-15.qcow2	size: 197088 bytes
DISK-28:  	index: 28	name: 14RV-FSRV-16.qcow2	size: 197088 bytes
DISK-29:  	index: 29	name: 14RV-FSRV-17.qcow2	size: 197088 bytes
DISK-30:  	index: 30	name: 14RV-FSRV-22.qcow2	size: 197088 bytes
DISK-31:  	index: 31	name: 14RV-FSRV-23.qcow2	size: 197088 bytes
DISK-32:  	index: 32	name: 14RV-FSRV-24.qcow2	size: 197088 bytes
DISK-33:  	index: 33	name: 14RV-FSRV-25.qcow2	size: 197088 bytes
DISK-34:  	index: 34	name: 14RV-FSRV-26.qcow2	size: 197088 bytes
DISK-35:  	index: 35	name: 14RV-FSRV-27.qcow2	size: 197088 bytes
DISK-36:  	index: 36	name: 14RV-FSRV-28.qcow2	size: 197088 bytes
DISK-37:  	index: 37	name: 14RV-FSRV-29.qcow2	size: 197088 bytes
DISK-38:  	index: 38	name: 14RV-FSRV-30.qcow2	size: 197088 bytes
DISK-39:  	index: 39	name: 14RV-FSRV-31.qcow2	size: 197088 bytes
DISK-40:  	index: 40	name: 14RV-FSRV-32.qcow2	size: 197088 bytes
DISK-41:  	index: 41	name: 14RV-FSRV-33.qcow2	size: 197088 bytes
DISK-42:  	index: 42	name: 14RV-FSRV-43.qcow2	size: 197088 bytes
DISK-43:  	index: 43	name: 14RV-FSRV-48.qcow2	size: 327680 bytes
DISK-44:  	index: 44	name: 14RV-FSRV-133.qcow2	size: 196768 bytes

--------------------------------------------------------------------------------------------------------------------

$ fbxvm-ctrl 12 detail

CONTROL FREEBOX VM

URL CALLED : https://fbx.soartist.net:2059/api/v8/
API CALLED : vm
VERB|VM ID : 12
ACTION : detail
RESULT :

VM-11 : Full details properties :

	name = 14RV-FSRV-12
	id = 12
	status = running
	memory = 2048
	vcpus = 1
	disk_type = qcow2
	disk_path = /FBX-2000G/box-vm/14RV-FSRV-12.qcow2
	cd_path = /FBX-2000G/iso/debian-11.0.0-arm64-netinst.iso
	mac_address = 5e:fb:d2:ad:01:5c
	os = debian
	enable_screen = true
	bind_usb_ports = ["usb-external-type-c","usb-external-type-a"]
	enable_cloudinit = true
	cloudinit_hostname = 14RV-FSRV-12.dmz.lan
	cloudinit_userdata = ssh_authorized_keys:
- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEA3FSyQwBI6Z+nCSjUUk8EEAnnkhXlukKoUPND/RRClWz2s5TCzIkd3Ou5+Cyz71X0XmazM3l5WgeErvtIwQMyT1KjNoMhoJMrJnWqQPOt5Q8zWd9qG7PBl9+eiH5qV7NZ mykey@host
- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3I7VUf2l5gSn5uavROsc5HRDpZdQueUq5ozemNSj8T7enqKHOEaFoU2VoPgGEWC9RyzSQVeyD6s7APMcE82EtmW4skVEgEGSbDc1pvxzxtchBj78hJP6Cf5TCMFSXw+Fz5rF1dR23QDbN1mkHs7adr8GW4kSWqU7Q7NDwfIrJJtO7Hi42GyXtvEONHbiRPOe8stqUly7MvUoN+5kfjBM8Qqpfl2+FNhTYWpMfYdPUnE7u536WqzFmsaqJctz3gBxH9Ex7dFtrxR4qiqEr9Qtlu3xGn7Bw07/+i1D+ey3ONkZLN+LQ714cgj8fRS4Hj29SCmXp5Kt5/82cD/VN3NtHw== smoser@brickies
8ssh_keys:
rsa_private: |
 -----BEGIN RSA PRIVATE KEY-----
 MIIBxwIBAAJhAKD0YSHy73nUgysO13XsJmd4fHiFyQ+00R7VVu2iV9Qcon2LZS/x
 1cydPZ4pQpfjEha6WxZ6o8ci/Ea/w0n+0HGPwaxlEG2Z9inNtj3pgFrYcRztfECb
 1j6HCibZbAzYtwIBIwJgO8h72WjcmvcpZ8OvHSvTwAguO2TkR6mPgHsgSaKy6GJo
 PUJnaZRWuba/HX0KGyhz19nPzLpzG5f0fYahlMJAyc13FV7K6kMBPXTRR6FxgHEg
 L0MPC7cdqAwOVNcPY6A7AjEA1bNaIjOzFN2sfZX0j7OMhQuc4zP7r80zaGc5oy6W
 p58hRAncFKEvnEq2CeL3vtuZAjEAwNBHpbNsBYTRPCHM7rZuG/iBtwp8Rxhc9I5w
 ixvzMgi+HpGLWzUIBS+P/XhekIjPAjA285rVmEP+DR255Ls65QbgYhJmTzIXQ2T9
 luLvcmFBC6l35Uc4gTgg4ALsmXLn71MCMGMpSWspEvuGInayTCL+vEjmNBT+FAdO
 W7D4zCpI43jRS9U06JVOeSc9CDk2lwiA3wIwCTB/6uc8Cq85D9YqpM10FuHjKpnP
 REPPOyrAspdeOAV+6VKRavstea7+2DZmSUgE
 -----END RSA PRIVATE KEY-----

rsa_public: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEAoPRhIfLvedSDKw7XdewmZ3h8eIXJD7TRHtVW7aJX1ByifYtlL/HVzJ09nilCl+MSFrpbFnqjxyL8Rr/DSf7QcY/BrGUQbZn2Kc22PemAWthxHO18QJvWPocKJtlsDNi3 smoser@localhost
no_ssh_fingerprints: false
ssh:
emit_keys_to_console: false
	json_vm_object = {"mac":5e:fb:d2:ad:01:5c,"cloudinit_userdata":ssh_authorized_keys:
- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEA3FSyQwBI6Z+nCSjUUk8EEAnnkhXlukKoUPND/RRClWz2s5TCzIkd3Ou5+Cyz71X0XmazM3l5WgeErvtIwQMyT1KjNoMhoJMrJnWqQPOt5Q8zWd9qG7PBl9+eiH5qV7NZ mykey@host
- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3I7VUf2l5gSn5uavROsc5HRDpZdQueUq5ozemNSj8T7enqKHOEaFoU2VoPgGEWC9RyzSQVeyD6s7APMcE82EtmW4skVEgEGSbDc1pvxzxtchBj78hJP6Cf5TCMFSXw+Fz5rF1dR23QDbN1mkHs7adr8GW4kSWqU7Q7NDwfIrJJtO7Hi42GyXtvEONHbiRPOe8stqUly7MvUoN+5kfjBM8Qqpfl2+FNhTYWpMfYdPUnE7u536WqzFmsaqJctz3gBxH9Ex7dFtrxR4qiqEr9Qtlu3xGn7Bw07/+i1D+ey3ONkZLN+LQ714cgj8fRS4Hj29SCmXp5Kt5/82cD/VN3NtHw== smoser@brickies
8ssh_keys:
rsa_private: |
 -----BEGIN RSA PRIVATE KEY-----
 MIIBxwIBAAJhAKD0YSHy73nUgysO13XsJmd4fHiFyQ+00R7VVu2iV9Qcon2LZS/x
 1cydPZ4pQpfjEha6WxZ6o8ci/Ea/w0n+0HGPwaxlEG2Z9inNtj3pgFrYcRztfECb
 1j6HCibZbAzYtwIBIwJgO8h72WjcmvcpZ8OvHSvTwAguO2TkR6mPgHsgSaKy6GJo
 PUJnaZRWuba/HX0KGyhz19nPzLpzG5f0fYahlMJAyc13FV7K6kMBPXTRR6FxgHEg
 L0MPC7cdqAwOVNcPY6A7AjEA1bNaIjOzFN2sfZX0j7OMhQuc4zP7r80zaGc5oy6W
 p58hRAncFKEvnEq2CeL3vtuZAjEAwNBHpbNsBYTRPCHM7rZuG/iBtwp8Rxhc9I5w
 ixvzMgi+HpGLWzUIBS+P/XhekIjPAjA285rVmEP+DR255Ls65QbgYhJmTzIXQ2T9
 luLvcmFBC6l35Uc4gTgg4ALsmXLn71MCMGMpSWspEvuGInayTCL+vEjmNBT+FAdO
 W7D4zCpI43jRS9U06JVOeSc9CDk2lwiA3wIwCTB/6uc8Cq85D9YqpM10FuHjKpnP
 REPPOyrAspdeOAV+6VKRavstea7+2DZmSUgE
 -----END RSA PRIVATE KEY-----

rsa_public: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEAoPRhIfLvedSDKw7XdewmZ3h8eIXJD7TRHtVW7aJX1ByifYtlL/HVzJ09nilCl+MSFrpbFnqjxyL8Rr/DSf7QcY/BrGUQbZn2Kc22PemAWthxHO18QJvWPocKJtlsDNi3 smoser@localhost
no_ssh_fingerprints: false
ssh:
emit_keys_to_console: false,"cd_path":L21udC9mYngvRkJYLTIwMDBHL2lzby9kZWJpYW4tMTEuMC4wLWFybTY0LW5ldGluc3QuaXNv,"id":11,"os":debian,"enable_cloudinit":true,"disk_path":L0ZCWC0yMDAwRy9ib3gtdm0vMTRSVi1GU1JWLTEyLnFjb3cy,"vcpus":1,"memory":2048,"name":14RV-FSRV-12,"cloudinit_hostname":14RV-FSRV-12,"status":stopped,"bind_usb_ports":["usb-external-type-c","usb-external-type-a"],"enable_screen":true,"disk_type":qcow2}


  
  --------------------------------------------------------------------------------------------------------------------
  End of help / usage / example
  --------------------------------------------------------------------------------------------------------------------
  
  
  
  
