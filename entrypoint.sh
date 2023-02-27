#!/bin/bash
set -e # abort on any error

hosts=$(curl --request GET \
        -s https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/web3/hostnames \
        -H 'Content-Type: application/json' \
        -Header "Authorization: Bearer $CLOUDFLARE_TOKEN") 
        
hostId=$(jq -r ".result | map(select(.name == \"${RECORD_DOMAIN}\")) | .[0].id" <<< "${hosts}" )

response=$(curl --request PATCH \
        -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
        -H "Content-Type: application/json" \
        -s "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/web3/hostnames/$hostId" \
        --data "{\"dnslink\": \"/ipfs/$1\"}")

success=$(jq -r  '.success' <<< "${response}" )

if [ $success != "true" ]; then
  echo "Pages Update: Failed to update record!"
  errors=$(jq -r  '.errors' <<< "${response}" )
  echo "Errors: $errors"
  exit 1
fi

echo "Pages Update: Success"
echo "  Webpage $RECORD_NAME updated to $1."
echo "  Update time will vary depending on your Cloudflare settings."
