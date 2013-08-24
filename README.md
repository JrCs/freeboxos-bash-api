freeboxos-bash-api
==================

Access FreeboxOS API from bash

Quick Start
-----------

You need to have `curl` and `openssl` installed.

Get the source:

    $ curl -L http://https://github.com/JrCs/freeboxos-bash-api/raw/master/freeboxos_bash_api.sh > freeboxos_bash_api.sh

Example
-------
```bash
#!/bin/bash

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"
MY_APP_NAME="My Wonderfull App"
MY_APP_VERSION="1.0.0"
MY_DEVICE_NAME="Mac OSX"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get xDSL data
answer=$(call_freebox_api '/connection/xdsl')

# get result values
result=$(get_json_value_for_key "$answer" 'result')

# get upload xDSL data from xDSL data
up_xdsl=$(get_json_value_for_key "$result" 'up')

# get up max xDSL rate from upload xDSL data
up_max_rate=$(get_json_value_for_key "$up_xdsl" 'maxrate')

echo "Max Upload xDSL rate: $up_max_rate kbit/s"
```

API
---

#### *  authorize_application *app_id* *app_name* *app_version* *device_name*
It is used to obtain a token to identify a new application (need to be done only once)
##### Example
```bash
$ source ./freeboxos_bash_api.sh
$ authorize_application  'MyWonderfull.app'  'My Wonderfull App'  '1.0.0'  'Mac OSX'
Please grant/deny access to the app on the Freebox LCD...
Authorization granted

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"
MY_APP_NAME="My Wonderfull App"
MY_APP_VERSION="1.0.0"
MY_DEVICE_NAME="Mac OSX"
```

#### *  login_freebox *app_id* *app_token*
It is used to log the application (you need the application token obtain from authorize_application function)
##### Example
```bash
#!/bin/bash

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"
MY_APP_NAME="My Wonderfull App"
MY_APP_VERSION="1.0.0"
MY_DEVICE_NAME="Mac OSX"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"
```

#### *  call_freebox_api *api_path*
It is used to call a freebox API. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Example
```bash
answer=$(call_freebox_api '/connection/xdsl')
```

#### *  get_json_value_for_key *json_string* *key*
This function will return the value for the *key* from the *json_string*
##### Example
```bash
value=$(get_json_value_for_key "$answer" 'maxrate')
```

#### *  reboot_freebox
This function will reboot your freebox. Return code will be 0 if the freebox is rebooting, 1 otherwise.
The application must be granted to modify the setup of the freebox (from freebox web interface).
##### Example
```bash
reboot_freebox
```
