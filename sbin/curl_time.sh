#!/bin/bash
CURL="/usr/bin/curl"
AWK="/usr/bin/awk"
if [[ $# -ne 0 ]] ; then
	URL=$1
	shift
else
	echo -n "Please pass the url you want to measure: "
	read url
	URL="$url"
fi

result=`$CURL -o /dev/null -s -w %{time_connect}-%{time_starttransfer}-%{time_total}-%{http_code}-%{url_effective} $URL`
echo "Time_Connect Time_startTransfer Time_total Http_code Url_effective"
echo $result | $AWK -F- '{ print $1" "$2" "$3" "$4" "$5" "$6}' 

