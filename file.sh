#!/bin/bash
vt_file() {
    # Submit a file
    APIKEY="XXXX"
    FILE="$1"
    local FSIZE=$(stat $FILE | grep "Size:" | awk '{print $2}')
    if [[ $FSIZE -gt 33554431 ]]; then
      vt_bigfile "$APIKEY" "$FILE"
    else
      curl -s --request POST --url "https://www.virustotal.com/api/v3/files" --header "x-apikey: $APIKEY" --form "file=@$FILE" > $name.file.output1
    fi
}

vt_bigfile() {
    # files > 32M need a special upload URL
    APIKEY="XXXX"
    FILE="$1"
    URL=$(curl -s --request GET --url "https://www.virustotal.com/api/v3/files/upload_url" --header "x-apikey: $APIKEY" | jq -r .data)
    curl -s --request POST --url "$URL" --header "x-apikey: $APIKEY" --form "file=@$FILE" > $name.file.output1
}
FILE="$1"
name=$(echo $FILE |awk -F "/" '{print $NF}' | awk -F "." '{print $1}')
vt_file "$FILE"
id=$(cat reverse.file.output1 | jq | grep id | awk -F "\"" '{print $4}')
rm $name.file.output1
sleep 10
curl -s --request GET --url "https://www.virustotal.com/api/v3/analyses/$id" --header "x-apikey: XXXX" > reverse.file.output2
echo -e "According to VirusTotal API:\n" > $name.file.report
cat reverse.file.output2 | grep -E "malicious|suspicious|undetected|harmless"  | grep -vE "category|result" | tr -d "\"," | sed 's/\<\([[:lower:]]\)\([[:alnum:]]*\)/\u\1\2/g' | sed 's/^ *//g' | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $3,"\n",$2,"\n",$1,"\n",$4}' | sed 's/^ *//g' >>$name.file.report
mal_list=$(cat reverse.file.output2 | grep -E "malicious" -A 5 | grep engine_name | awk -F "\"" '{print $4}' )
result=$(for i in $(echo $mal_list); do result=$(cat reverse.file.output2 | grep -w "$i\"" -A 3 | grep result | tr -d "\"," | awk -F ":" '{print $2}') ; echo "$i - $result" ; done
)
echo -e "\n\nResult:\n$result" >>$name.file.report
cat $name.file.report >> file.report
rm $name.file.output2
