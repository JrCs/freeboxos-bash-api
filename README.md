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
