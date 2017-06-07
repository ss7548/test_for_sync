#!/bin/bash

# Steve Silverman
# Jan 27, 2017
# Version 1.0.0

# Sample usage
# create.sh -n "Fake APP: problem found..." -m "Looking at a fake problem in fake app" -s investigating
# update.sh -i hvwq1444dhz3 -s identified -m "The problem has been identified"
# delete.sh -i hvwq1444dhz3

# Get the page ID ($PAGE) and the API key ($AUTH)
. ./status.env

URL="https://api.statuspage.io"

while getopts ":n:m:s:i" opt
do
  case $opt in
    n)
      NAME="$OPTARG"    # Incident name
      ;;
    m)
      MESSAGE="$OPTARG"
      ;;
    s)
      STATUS="$OPTARG"  # investigating|identified|monitoring|resolved
      ;;
    i)
      ID="$OPTARG"      # incident ID
      ;;
  esac
done

case `basename $0 .sh` in
  create)
      ACTION="POST"
      URI="incidents"
      ;;
  update)
      ACTION="PATCH"
      URI="incidents/$ID"
      ;;
  delete)
      ACTION="DELETE"
      URI="incidents/$ID"
      ;;
  *)
      echo "I'm stumped."
      exit 1
esac

URI="/v1/pages/${PAGE}/${URI}.json"

cmd='curl -s '${URL}${URI}' -H "Authorization: OAuth '${AUTH}'" -X '$ACTION
[[ -n "$NAME" ]] && cmd=$cmd' -d "incident[name]='$NAME'"'
[[ -n "$STATUS" ]] && cmd=$cmd' -d "incident[status]='$STATUS'"'
[[ -n "$MESSAGE" ]] && cmd=$cmd' -d "incident[message]='$MESSAGE'"'

eval $cmd | python -m json.tool > response.json
if [ $ACTION == "POST" ]
then
  ID=`awk '/incident_id/ {print $2;}' response.json | tr -d \",`
  echo "Incident ID is $ID"
fi

