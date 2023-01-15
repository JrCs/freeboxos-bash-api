fbx-delta-nba_bash_api.sh
==================

Access [FreeboxOS API](http://dev.freebox.fr/sdk/os/#api-list) from bash

Quick Start
-----------

You need to have `curl` and `openssl` installed.

Get the source:

    $ curl -L https://github.com/nbanb/fbx-delta-nba_bash_api.sh/raw/nbanb-freebox-api/fbx-delta-nba_bash_api.sh > fbx-delta-nba_bash_api.sh

Example
-------
```bash
#!/bin/bash

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"

# source the fbx-delta-nba_bash_api.sh
source ./fbx-delta-nba_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get xDSL data
answer=$(call_freebox_api '/connection/xdsl')

# extract max upload xDSL rate
up_max_rate=$(get_json_value_for_key "$up_xdsl" 'result.up.maxrate')

echo "Max Upload xDSL rate: $up_max_rate kbit/s"
```

API
---

#### *  authorize_application *app_id* *app_name* *app_version* *device_name*
It is used to obtain a token to identify a new application (need to be done only once)
##### Example
```bash
$ source ./fbx-delta-nba_bash_api.sh
$ authorize_application  'MyWonderfull.app'  'My Wonderfull App'  '1.0.0'  'Mac OSX'
Please grant/deny access to the app on the Freebox LCD...
Authorization granted

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"
```

#### *  login_freebox *app_id* *app_token*
It is used to log the application (you need the application token obtain from authorize_application function)
##### Example
```bash
#!/bin/bash

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"

# source the fbx-delta-nba_bash_api.sh
source ./fbx-delta-nba_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"
```

#### *  call_freebox_api *api_path* *{optionnal_json_object}*
It is used to call a freebox API. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Example
```bash
answer=$(call_freebox_api '/connection/xdsl')
```


#### *  add_freebox_api *api_path* *{json_object}*
It is used to call a freebox API with a define HTTP POST request forcing "Content-Type: application/json" header. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Example
```bash
answer=$(add_freebox_api '/vm/create' '{create_vm_json_object}')
```


#### *  update_freebox_api *api_path* *{json_object}*
It is used to call a freebox API with a define HTTP PUT request forcing "Content-Type: application/json" header. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Example
```bash
answer=$(update_freebox_api '/vm/8' '{update_vm_json_object}')
```


#### *  del_freebox_api *api_path*
It is used to call a freebox API with a define HTTP DELETE request. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Example
```bash
answer=$(del_freebox_api '/vm/8')
```


#### *  call_freebox-ws_api *api_path*
It is used to call a freebox Websocket API with websocket request. It need you install 'websocat' from [here](https://github.com/vi/websocat/) The function will return a websocket interractive connection and exit with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available websocket api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Example
```bash
answer=$(call_freebox-ws_api '/vm/8/console')
```


#### *  get_json_value_for_key *json_string* *key*
This function will return the value for the *key* from the *json_string*
##### Example
```bash
value=$(get_json_value_for_key "$answer" 'result.down.maxrate')
```

#### *  dump_json_keys_values *json_string*
This function will dump on stdout all the keys values pairs from the *json_string*
##### Example
```bash
answer=$(call_freebox_api '/connection/')
dump_json_keys_values "$answer"
echo
bytes_down=$(get_json_value_for_key "$answer" 'result.bytes_down')
echo "bytes_down: $bytes_down"
```
<pre>
success = true
result.type = rfc2684
result.rate_down = 40
result.bytes_up = 945912
result.rate_up = 0
result.bandwidth_up = 412981
result.ipv6 = 2a01:e35:XXXX:XXX::1
result.bandwidth_down = 3218716
result.media = xdsl
result.state = up
result.bytes_down = 2726853
result.ipv4 = XX.XXX.XXX.XXX
result = {"type":rfc2684,"rate_down":40,"bytes_up":945912,"rate_up":0,"bandwidth_up":412981,"ipv6":2a01:e35:XXXX:XXXX::1,"bandwidth_down":3218716,"media":xdsl,"state":up,"bytes_down":2726853,"ipv4":XX.XXX.XXX.XXX}

bytes_down: 2726853</pre>

#### *  reboot_freebox
This function will reboot your freebox. Return code will be 0 if the freebox is rebooting, 1 otherwise.
The application must be granted to modify the setup of the freebox (from freebox web interface).
##### Example
```bash
reboot_freebox
```


#### *  status_freebox
This function will return a json containing your freebox global status/infos (CPU, TEMP, FAN, DISK, etc). 
To be parsed by the script calling this function.
Return code will be 0 if the freebox is alive and send its status, 1 otherwise.
##### Example
```bash
status_freebox
```
Result : 
```bash
{"success":true,"result":{"mac":"34:27:92:xx:xx:xx","sensors":[{"id":"temp_hdd1","name":"Disque dur 2","value":39},{"id":"temp_hdd3","name":"Disque dur 4","value":40},{"id":"temp_hdd2","name":"Disque dur 3","value":45},{"id":"temp_hdd0","name":"Disque dur 1","value":47},{"id":"temp_t2","name":"Température 2","value":51},{"id":"temp_t1","name":"Température 1","value":47},{"id":"temp_t3","name":"Température 3","value":47},{"id":"temp_cpu_cp_slave","name":"Température CPU CP Slave","value":80},{"id":"temp_cpu_ap","name":"Température CPU AP","value":71},{"id":"temp_cpu_cp_master","name":"Température CPU CP Master","value":80}],"model_info":{"customer_hdd_slots":4,"net_operator":"free_fra","supported_languages":["fra"],"has_dsl":true,"has_dect":true,"wifi_country":"FR","has_home_automation":true,"wifi_type":"2d4_5g_5g","pretty_name":"Freebox v7 (r1)","has_lan_sfp":true,"name":"fbxgw7-r1\/full","has_separate_internal_storage":true,"internal_hdd_size":0,"default_language":"fra","has_vm":true,"has_expansions":true},"fans":[{"id":"fan1_speed","name":"Ventilateur 2","value":2401},{"id":"fan0_speed","name":"Ventilateur 1","value":4208}],"expansions":[{"type":"security","present":true,"slot":1,"probe_done":true,"supported":true,"bundle":"985700J12345678"},{"type":"ftth_pon","present":true,"slot":2,"probe_done":true,"supported":true,"bundle":"955800A12345678"}],"board_name":"fbxgw7r","disk_status":"active","uptime":"8 jours 14 heures 53 minutes 21 secondes","uptime_val":744801,"user_main_storage":"FBX-500G","box_authenticated":true,"serial":"957602K123456789","firmware_version":"4.5.7"}}
```


#### *  check_tool
This function will check for external tool needed when running this program. Return code will be 0 if the freebox is rebooting, exit with a return code of 31 otherwise.
##### Example
```bash
check_tool websocat
```


#### *  full_vm_detail
This function will print all json_vm_objects defined in the freebox
##### Example
```bash
full_vm_detail 
```
Result :
```bash
{"success":true,"result":[{"mac":"ce:3e:20:b9:66:fc","cloudinit_userdata":"","cd_path":"","id":0,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-wLnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-00","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"3e:6e:bd:2b:fe:c7","cloudinit_userdata":"","cd_path":"","id":1,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-zLnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-03","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"ae:2c:8c:f6:3e:fb","cloudinit_userdata":"","cd_path":"","id":2,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-xLnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-01","cloudinit_hostname":"","status":"running","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"5a:e3:85:db:26:ee","cloudinit_userdata":"","cd_path":"","id":3,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-yLnFjb3cy","vcpus":1,"memory":4096,"name":"14RV-FSRV-02","cloudinit_hostname":"","status":"running","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"5e:e3:3a:13:ab:20","cloudinit_userdata":"","cd_path":"","id":4,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-0LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-04","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"be:dd:fc:cc:53:8d","cloudinit_userdata":"","cd_path":"","id":5,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-1LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-05","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"ba:81:13:4f:2f:4e","cloudinit_userdata":"","cd_path":"","id":6,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-2LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-06","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"da:05:e4:43:33:5d","cloudinit_userdata":"","cd_path":"","id":7,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-3LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-07","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"ce:3c:ee:b4:f4:f0","cloudinit_userdata":"ssh_authorized_keys:\n- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEA3FSyQwBI6Z+nCSjUUk8EEAnnkhXlukKoUPND\/RRClWz2s5TCzIkd3Ou5+Cyz71X0XmazM3l5WgeErvtIwQMyT1KjNoMhoJMrJnWqQPOt5Q8zWd9qG7PBl9+eiH5qV7NZ mykey@host\n- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3I7VUf2l5gSn5uavROsc5HRDpZdQueUq5ozemNSj8T7enqKHOEaFoU2VoPgGEWC9RyzSQVeyD6s7APMcE82EtmW4skVEgEGSbDc1pvxzxtchBj78hJP6Cf5TCMFSXw+Fz5rF1dR23QDbN1mkHs7adr8GW4kSWqU7Q7NDwfIrJJtO7Hi42GyXtvEONHbiRPOe8stqUly7MvUoN+5kfjBM8Qqpfl2+FNhTYWpMfYdPUnE7u536WqzFmsaqJctz3gBxH9Ex7dFtrxR4qiqEr9Qtlu3xGn7Bw07\/+i1D+ey3ONkZLN+LQ714cgj8fRS4Hj29SCmXp5Kt5\/82cD\/VN3NtHw== smoser@brickies\n8ssh_keys:\nrsa_private: |\n -----BEGIN RSA PRIVATE KEY-----\n MIIBxwIBAAJhAKD0YSHy73nUgysO13XsJmd4fHiFyQ+00R7VVu2iV9Qcon2LZS\/x\n 1cydPZ4pQpfjEha6WxZ6o8ci\/Ea\/w0n+0HGPwaxlEG2Z9inNtj3pgFrYcRztfECb\n 1j6HCibZbAzYtwIBIwJgO8h72WjcmvcpZ8OvHSvTwAguO2TkR6mPgHsgSaKy6GJo\n PUJnaZRWuba\/HX0KGyhz19nPzLpzG5f0fYahlMJAyc13FV7K6kMBPXTRR6FxgHEg\n L0MPC7cdqAwOVNcPY6A7AjEA1bNaIjOzFN2sfZX0j7OMhQuc4zP7r80zaGc5oy6W\n p58hRAncFKEvnEq2CeL3vtuZAjEAwNBHpbNsBYTRPCHM7rZuG\/iBtwp8Rxhc9I5w\n ixvzMgi+HpGLWzUIBS+P\/XhekIjPAjA285rVmEP+DR255Ls65QbgYhJmTzIXQ2T9\n luLvcmFBC6l35Uc4gTgg4ALsmXLn71MCMGMpSWspEvuGInayTCL+vEjmNBT+FAdO\n W7D4zCpI43jRS9U06JVOeSc9CDk2lwiA3wIwCTB\/6uc8Cq85D9YqpM10FuHjKpnP\n REPPOyrAspdeOAV+6VKRavstea7+2DZmSUgE\n -----END RSA PRIVATE KEY-----\n\nrsa_public: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEAoPRhIfLvedSDKw7XdewmZ3h8eIXJD7TRHtVW7aJX1ByifYtlL\/HVzJ09nilCl+MSFrpbFnqjxyL8Rr\/DSf7QcY\/BrGUQbZn2Kc22PemAWthxHO18QJvWPocKJtlsDNi3 smoser@localhost\n\ndsa_private: |\n -----BEGIN DSA PRIVATE KEY-----\n MIIBuwIBAAKBgQDP2HLu7pTExL89USyM0264RCyWX\/CMLmukxX0Jdbm29ax8FBJT\n pLrO8TIXVY5rPAJm1dTHnpuyJhOvU9G7M8tPUABtzSJh4GVSHlwaCfycwcpLv9TX\n DgWIpSj+6EiHCyaRlB1\/CBp9RiaB+10QcFbm+lapuET+\/Au6vSDp9IRtlQIVAIMR\n 8KucvUYbOEI+yv+5LW9u3z\/BAoGBAI0q6JP+JvJmwZFaeCMMVxXUbqiSko\/P1lsa\n LNNBHZ5\/8MOUIm8rB2FC6ziidfueJpqTMqeQmSAlEBCwnwreUnGfRrKoJpyPNENY\n d15MG6N5J+z81sEcHFeprryZ+D3Ge9VjPq3Tf3NhKKwCDQ0240aPezbnjPeFm4mH\n bYxxcZ9GAoGAXmLIFSQgiAPu459rCKxT46tHJtM0QfnNiEnQLbFluefZ\/yiI4DI3\n 8UzTCOXLhUA7ybmZha+D\/csj15Y9\/BNFuO7unzVhikCQV9DTeXX46pG4s1o23JKC\n \/QaYWNMZ7kTRv+wWow9MhGiVdML4ZN4XnifuO5krqAybngIy66PMEoQCFEIsKKWv\n 99iziAH0KBMVbxy03Trz\n -----END DSA PRIVATE KEY-----\n\ndsa_public: ssh-dss AAAAB3NzaC1kc3MAAACBAM\/Ycu7ulMTEvz1RLIzTbrhELJZf8Iwua6TFfQl1ubb1rHwUElOkus7xMhdVjms8AmbV1Meem7ImE69T0bszy09QAG3NImHgZVIeXBoJ\/JzByku\/1NcOBYilKP7oSIcLJpGUHX8IGn1GJoH7XRBwVub6Vqm4RP78C7q9IOn0hG2VAAAAFQCDEfCrnL1GGzhCPsr\/uS1vbt8\/wQAAAIEAjSrok\/4m8mbBkVp4IwxXFdRuqJKSj8\/WWxos00Ednn\/ww5QibysHYULrOKJ1+54mmpMyp5CZICUQELCfCt5ScZ9GsqgmnI80Q1h3Xkwbo3kn7PzWwRwcV6muvJn4PcZ71WM+rdN\/c2EorAINDTbjRo97NueM94WbiYdtjHFxn0YAAACAXmLIFSQgiAPu459rCKxT46tHJtM0QfnNiEnQLbFluefZ\/yiI4DI38UzTCOXLhUA7ybmZha+D\/csj15Y9\/BNFuO7unzVhikCQV9DTeXX46pG4s1o23JKC\/QaYWNMZ7kTRv+wWow9MhGiVdML4ZN4XnifuO5krqAybngIy66PMEoQ= smoser@localhost\n\nno_ssh_fingerprints: false\nssh:\nemit_keys_to_console: false","cd_path":"L0ZCWDI0VC9pc28vZGViaWFuLTExLjAuMC1hcm02NC1EVkQtMS5pc28=","id":8,"os":"debian","enable_cloudinit":true,"disk_path":"freebox-disk-path-4LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-08","cloudinit_hostname":"14RV-FSRV-2048","status":"stopped","bind_usb_ports":["usb-external-type-c","usb-external-type-a"],"enable_screen":true,"disk_type":"qcow2"}]}
```


#### *  vm_resource
This function will print a json containing availiable ressources for VM on freebox chassis
##### Example
```bash
vm_resource 
```
Result :
```bash
{"success":true,"result":{"usb_used":false,"sata_used":false,"sata_ports":["sata-internal-p0","sata-internal-p1","sata-internal-p2","sata-internal-p3"],"used_memory":8192,"usb_ports":["usb-external-type-a","usb-external-type-c"],"used_cpus":3,"total_memory":15360,"total_cpus":3}}
```


