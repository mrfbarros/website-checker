#!/bin/bash
source discord.secret

usage() { echo "Usage: $0 [--website <WEBSITE>] " 1>&2; exit 1; }

# Options

ARGS=$(getopt -o 'w:' --long 'website:' -- "$@") || exit 1

eval "set -- $ARGS"

while true; do
  case "$1" in
    (-w|--website)
      WEBSITE="$2"; shift 2;;
    (--) shift; break;;
    (*) usage;;
  esac
done


if [[ -z $WEBSITE ]]; then
        echo "missing website"
        usage
fi

#Check if website available
HTTP_CODE=`curl --silent --fail --insecure -I $WEBSITE -w '%{http_code}\n' -o /dev/null`
    if [ "$HTTP_CODE" != 200 ] && [ "$HTTP_CODE" != 301 ]; then
        printf "Error,Code $HTTP_CODE, Cannot properly retrieve '$WEBSITE'\n";
        exit 1
    fi

#Current Date
TIME=$(date +"%Y-%m-%d %T")

#Infinite loop , TOOD: Change to CronJob

while :
do
    #Checking if there's difference:
    #First we retrieve current website
    curl $WEBSITE > currentContent.html
    WAS_UPDATED=$(diff currentContent.html lastContent.html)

    if [ -z "$WAS_UPDATED" ]; then
        echo "No changes found"
    else
        cp currentContent.html lastContent.html
        # Hook can be changed to a personal one
        curl -i -X POST -H 'Content-Type: application/json' -d '{"content":"The website has changed: '$WEBSITE' "}' $DISCORDHOOK
    fi

    #TimeOut between comparisions, 3600 -> each hour
    sleep 3600

done


