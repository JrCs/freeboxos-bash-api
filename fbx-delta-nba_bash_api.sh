#!/bin/bash

###########################################################################################
# 20211114 
# NBA : fbx-delta-nba_bash_api.sh : function for Freebox http/ws API 
# NBA : forked by NBA from https://github.com/JrCs/freeboxos-bash-api
#
# 20211116 :
# Modify by NBA to support version 8 of API and HTTPS over the internet :
# APPLICATIONS will be availiable remotely if Freebox allow admin connection from internet
#
# Ex : my freebox delta use its own PKI and has internet access on :
#     - Unsecure port : 2049
#     -   Secure port : 2059
#     -          URL1 : fbx.soartist.net
#     -          URL2 : fu2vg7hl.fbxos.fr
#     -           PKI : 14RV
#     -     Signed CA : 14RV-rootCA-RSA8192
#  CA : 14RV must be installed on the system or need to use '-k = --insecure' option of cURL
# URL : Using URL1
#
#
# 20220504 :
# Modify by NBA for testing the add-on of websockets
# Freebox Delta's API supports several commands for Virtual Machines and console / monitor
# interractive access through websockets 
# 
# => So adding functions to interract with the Freebox Delta websockets API
#    - using external tool : "websocat" a cURL like websockets client from :    
#      https://github.com/vi/websocat/releases/download/v1.9.0/websocat_linux64
#
#
# 20220506 : 
# Modify to add a check_tool function because this script use several external tools
# like "cURL" for requestion HTTP/HTTPS API and 2 others tools for exploiting 
# WEBSOCKET API : tools are : 
# "websocat" a cURL/ncap/socat like tool which can interract with websockets
# DEPRECATED on 20220509 : "rlwrap" a line-buffer wrapper for websocat 
# DEPRECATED on 20220509 : "rlfe" a line-buffer front-end
#
#
# 20220509 - part 1 - issue : 
# Detecting issue when using websocket API to connect VM console :
# The problem begin when after login the VM console using this websocket API function, 
# when trying to use tools like VIM or NANO for file editting : Arrows do not work and 
# those text editors are impossible to use, chars are not interpreted correctly
# ==> Opening issue #152 at https://github.com/vi/websocat/issues/152
# Maintener told me to have a look at :
# https://github.com/vi/websocat/issues/60#issuecomment-545911812
# Having a look at his recommendation, I made several changes to correct the issue
# Now, we will avoid using 'rlwrap' or 'rlfe', we will use the power of 'stty' for
# managing the behaviour of the terminal
# --> So, we do not need anymore external 'readline' tools like 'rlwrap' or 'rlfe'
# --> The issue is fixed 
# --> Accessing VM console through websocket API have the expected behaviour
#
# 20220509 - part 2 - code & clean : 
# --> Cleaning code (delete) where "rlwrap" or "rlfe" were use
# --> Replacing exec file './req' by variable "${req[@]}" containing exec string
# --> Deleting code where './req' file appears
# --> Adding 'DEPRECATED' mention to this changelog
#
#
###########################################################################################
## 
## websocat install : 
## $ wget https://github.com/vi/websocat/releases/download/v1.9.0/websocat_linux64
## $ sudo cp websocat_linux64 /usr/bin/websocat_linux64
## $ sudo ln -s /usr/bin/websocat_linux64 /usr/bin/websocat
## $ sudo chmod +x /usr/bin/websocat_linux64
#
## DEPRECATED on 20220509 : WARNING : 
## DEPRECATED on 20220509 : For websocat to work, you need WRITE access to this file directory
##






# Freebox local URL 

#FREEBOX_URL="http://mafreebox.freebox.fr"

# Freebox WAN URL 

FREEBOX_URL="https://fbx.mydomain.net:2011"

# In 2021 cURL does not natively support 8192 signed certificate signed by an 8192 CA
# even if the 8192 rootCA is properly installed on the system.
# wget does support such CA and certificate but we're using cURL here !
# A workarround is to specify either '-k = --insecure' on cURL command line (bad)
# or to specify the 8192 CA public key on cURL command line (preferred)

FREEBOX_CACERT='/usr/share/ca-certificates/nba/14rv-rootCA-RSA8192.pem'

# 20211116 NBA change API version to v8 (actual is 8.4)
# (real values are fullfiled automatically by function _check_freebox_api ) 
# Temporary filled _API_* variables 

_API_VERSION="8"
_API_BASE_URL="/api/"

# Temporary session tooken 

_SESSION_TOKEN="PFK0tGTHPI7gz45qNmpsmFn1cCoAFn76yE47e2BZrmu38LKwmbaOyYMUpz0RIjSU"






######## GLOBAL VARIABLES ########
_JSON_DATA=
_JSON_DECODE_DATA_KEYS=
_JSON_DECODE_DATA_VALUES=

case "$OSTYPE" in
    darwin*) SED_REX='-E' ;;
    *) SED_REX='-r' ;;
esac

if echo "test string" | egrep -ao --color=never "test" &>/dev/null; then
    GREP='egrep -ao --color=never'
else
    GREP='egrep -ao'
fi

######## FUNCTIONS ########

####### NBA CHECK TOOL #######
# This function allows you to check if the required tools have been installed.
function check_tool() {
  cmd=$1
  if ! command -v $cmd &>/dev/null
  then
    echo "$cmd could not be found"
    echo "Please install $cmd"
    exit 31
  fi
}

####### END CHECK TOOL #######




######## FUNCTIONS FROM JSON.SH ########
# This is from https://github.com/dominictarr/JSON.sh
# See LICENSE for more info.

_throw () {
    echo "$*" >&2
    exit 1
}

_tokenize_json () {
    local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    local CHAR='[^[:cntrl:]"\\]'
    local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
    # The Freebox api don't put quote between string values
    # STRING2 solve this problem
    local STRING2="[^:,][a-zA-Z][a-zA-Z0-9_-]*[^],}]"
    local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
    local KEYWORD='null|false|true'
    local SPACE='[[:space:]]+'

    $GREP "$STRING|$STRING2|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
    # " Fix xemacs fontification
}

_parse_array () {
    local index=0
    local ary=''
    read -r token
    case "$token" in
        ']') ;;
        *)
           while : ; do
               _parse_value "${1%*.}" "[$index]."
               index=$((index+1))
               ary="$ary""$value"
               read -r token
               case "$token" in
                   ']') break ;;
                   ',') ary="$ary," ;;
                   *) _throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
               esac
               read -r token
           done
           ;;
    esac
    value=$(printf '[%s]' "$ary")
}

_parse_object () {
    local key
    local obj=''
    read -r token
    case "$token" in
        '}') ;;
        *)
           while : ; do
               case "$token" in
                   '"'*'"') key=$token;;
                   *) _throw "EXPECTED string GOT ${token:-EOF}" ;;
               esac
               read -r token
               case "$token" in
                   ':') ;;
                   *) _throw "EXPECTED : GOT ${token:-EOF}" ;;
               esac
               read -r token
               _parse_value "$1" "$key"
               obj="$obj$key:$value"
               read -r token
               case "$token" in
                   '}') break ;;
                   ',') obj="$obj," ;;
                   *) _throw "EXPECTED , or } GOT ${token:-EOF}" ;;
               esac
               read -r token
           done
           ;;
    esac
    value=$(printf '{%s}' "$obj")
}

_parse_value () {
    local jpath="${1:-}${2:-}"
    case "$token" in
        '{') _parse_object "$jpath" ;;
        '[') _parse_array  "$jpath";;
        # At this point, the only valid single-character tokens are digits.
        ''|[!0-9]) _throw "EXPECTED value GOT ${token:-EOF}" ;;
        *) value=$token ;;
    esac
    [ "${value:-}" = '' ] && return
    jpath=${jpath//\"\"/.}
    jpath=${jpath//\"/}
    local key="${jpath%*.}"
    [[ "$key" = '' ]] && return
    _JSON_DECODE_DATA_KEYS+=("$key")
    value=${value#\"}  # Remove leading "
    value=${value%*\"} # Remove trailing "
    value=${value//\\\///} # convert \/ to /
    _JSON_DECODE_DATA_VALUES+=("$value")
}

_parse_json () {
    read -r token
    _parse_value
    read -r token
    case "$token" in
        '') ;;
        *) _throw "EXPECTED EOF GOT $token" ;;
    esac
}

######## END OF FUNCTIONS FROM JSON.SH ########

function _parse_and_cache_json {
    if [[ "$_JSON_DATA" != "$1" ]]; then
        _JSON_DATA="$1"
        _JSON_DECODE_DATA_KEYS=("")
        _JSON_DECODE_DATA_VALUES=("")
        _parse_json < <(echo "$_JSON_DATA" | _tokenize_json)
    fi
}

function get_json_value_for_key {
    _parse_and_cache_json "$1"
    local key i=1 max_index=${#_JSON_DECODE_DATA_KEYS[@]};
    while [[ $i -lt $max_index ]]; do
        if [[ "${_JSON_DECODE_DATA_KEYS[$i]}" = "$2" ]]; then
            echo ${_JSON_DECODE_DATA_VALUES[$i]}
            return 0
        fi
        ((i++))
    done
    return 1
}

function dump_json_keys_values {
    _parse_and_cache_json "$1"
    local key i=1 max_index=${#_JSON_DECODE_DATA_KEYS[@]};
    while [[ $i -lt $max_index ]]; do
        printf "%s = %s\n" "${_JSON_DECODE_DATA_KEYS[$i]}" "${_JSON_DECODE_DATA_VALUES[$i]}"
        ((i++))
    done
}

function _check_success {
    local value=$(get_json_value_for_key "$1" success)
    if [[ "$value" != true ]]; then
        echo "$(get_json_value_for_key "$1" msg): $(get_json_value_for_key "$1" error_code)" >&2
        return 1
    fi
    return 0
}

function _check_freebox_api {
    local answer=$(curl -s --cacert $FREEBOX_CACERT "$FREEBOX_URL/api_version")
    _API_VERSION=$(get_json_value_for_key "$answer" api_version | sed 's/\..*//')
    _API_BASE_URL=$(get_json_value_for_key "$answer" api_base_url)
}

function call_freebox_api {
    local api_url="$1"
    local data="${2-}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")
    [[ -n "$data" ]] && options+=(-d "$data")
    [[ -n "$FREEBOX_CACERT" ]] && options+=(--cacert "$FREEBOX_CACERT")
    answer=$(curl -s "$url" "${options[@]}")
    _check_success "$answer" || return 1
    echo "$answer"
}

####### NBA ADDING FUNCTION FOR USING FREEBOX WEBSOCKET API #######

## test if websocket is alive with cURL, example : 
#curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Host: echo.websocket.events" -H "Origin: https://www.websocket.events" https://echo.websocket.events

## but cURL do not allow interractive websocket flows and do not support 'ws://' addresses

## ==> NEED EXTERNAL PACKAGES (in 2022) : "websocat" : install : 
## $ wget https://github.com/vi/websocat/releases/download/v1.9.0/websocat_linux64
## $ sudo cp websocat_linux64 /usr/bin/websocat_linux64
## $ sudo ln -s /usr/bin/websocat_linux64 /usr/bin/websocat
## $ sudo chmod +x /usr/bin/websocat_linux64


function call_freebox-ws_api {
    local api_url="$1"
   #local data="${2-}"
    local options=("")
    local optws=("")
    local optsttys=("")
    local optsttye=("")
    local req=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    local wsurl=$(echo $url |sed 's@https@wss@g')
    echo
    echo Connecting VM console on Freebox websocket : $wsurl
    echo
    # DEBUG # [[ -n "$_SESSION_TOKEN" ]] && optws+=(-E --binary -vvvk) \
    [[ -n "$_SESSION_TOKEN" ]] && optws+=(-E --binary -k) \
    && optsttys+=(stty raw -echo) \
    && optsttye+=(stty sane cooked) \
    && options+=(-H \"X-Fbx-App-Auth: $_SESSION_TOKEN\") \
    && options+=(-H \"Connection: Upgrade\") \
    && options+=(-H \"Upgrade: websocket\") \
    && options+=(-H \"Sec-WebSocket-Version: 13\") \
    && options+=(-H \"Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==\") \
    && options+=(-H \"Sec-WebSocket-Protocol: chat, superchat\") \
    && options+=(-H \"Host: $FREEBOX_URL\") \
    && options+=(-H \"Origin: $FREEBOX_URL\") 

    # websocket send and recieve data interractively => no "$data" string 
    #[[ -n "$data" ]] && options+=(-d "$data")

    # websocat do not support --cacert option => using "-k" (--insecure) in ${optws[@]}
    #[[ -n "$FREEBOX_CACERT" ]] && options+=(--cacert "$FREEBOX_CACERT")

    req="${optsttys[@]}; websocat ${options[@]} ${optws[@]} \"$wsurl\"; ${optsttye[@]}"
    # DEBUG : #echo ${req[@]}
    bash -c "${req[@]}"

    # websocket send and recieve data interractively => no "$answer" string to parse
    #answer="bash -c \"${req[@]}\"" ; #_check_success "$answer" || return 1 ;  #echo "$answer"

    ret=$?
    echo -e "\n\nWebsocket connection is currently close" 
    exit $ret
}

####### NBA END FUNCTION FOR FREEBOX WEBSOCKET API #######


function login_freebox {
    local APP_ID="$1"
    local APP_TOKEN="$2"
    local answer=

    answer=$(call_freebox_api 'login') || return 1
    local challenge=$(get_json_value_for_key "$answer" "result.challenge")
    local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^(stdin)= //')
    answer=$(call_freebox_api '/login/session/' "{\"app_id\":\"${APP_ID}\", \"password\":\"${password}\" }") || return 1
    _SESSION_TOKEN=$(get_json_value_for_key "$answer" "result.session_token")
}

function authorize_application {
    local APP_ID="$1"
    local APP_NAME="$2"
    local APP_VERSION="$3"
    local DEVICE_NAME="$4"
    local answer=

    answer=$(call_freebox_api 'login/authorize' "{\"app_id\":\"${APP_ID}\", \"app_name\":\"${APP_NAME}\", \"app_version\":\"${APP_VERSION}\", \"device_name\":\"${DEVICE_NAME}\" }")
    local app_token=$(get_json_value_for_key "$answer" "result.app_token")
    local track_id=$(get_json_value_for_key "$answer" "result.track_id")

    echo 'Please grant/deny access to the application on the Freebox LCD...' >&2
    local status='pending'
    while [[ "$status" == 'pending' ]]; do
      sleep 5
      answer=$(call_freebox_api "login/authorize/$track_id")
      status=$(get_json_value_for_key "$answer" "result.status")
    done
    echo "Authorization $status" >&2
    [[ "$status" != 'granted' ]] && return 1
    echo >&2
    cat <<EOF
MY_APP_ID="$APP_ID"
MY_APP_TOKEN="$app_token"
EOF
}

function reboot_freebox {
    # NBA modify for getting reboot status from API 
    call_freebox_api '/system/reboot' '{}' 
    #call_freebox_api '/system/reboot' '{}' >/dev/null
}

######## MAIN ########

# fill _API_VERSION and _API_BASE_URL variables
_check_freebox_api
# NBA : 20220506 
# Call check_tool function to make sure we can use curl, websocat & rlwrap 
# Put next line in scripts which use functions from this file
check_tool curl
check_tool openssl
check_tool websocat
