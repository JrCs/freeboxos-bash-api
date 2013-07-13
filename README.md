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
MY_APP_TOKEN="P9A8VnjqCmfJp03KJ6mEPzgXmIk9ne1yJI6qqAnYUMa9JcPn4EwDn5PhgSQtxfIe"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get xDSL datas
answer=$(call_freebox_api '/connection/xdsl')

# get result values
result=$(get_json_value_for_key "$answer" 'result')

# get upload xDSL data
up_xdsl=$(get_json_value_for_key "$result" 'up')

# get up max xDSL rate
up_max_rate=$(get_json_value_for_key "$up_xdsl" 'maxrate')

echo "Max Upload xDSL rate: $up_max_rate kbit/s"
```
