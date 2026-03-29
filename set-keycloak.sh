#!/bin/sh

user=admin
password=admin
kk=http://keycloak.auth.svc.cluster.local:8080

while getopts "h:u:p:k:" opt; do
    case $opt in
        h ) echo "Usage: $0 -u <user> -p <password> -k <keycloak_url>" ; exit 0;;
        u ) user=$OPTARG;;
        p ) password=$OPTARG;;
        k ) kk=$OPTARG;;
        *) usage
        exit 1;;
    esac
done

ACCESS_TOKEN=`curl -s -X POST "${kk}/realms/master/protocol/openid-connect/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "username=$user" \
     -d "password=$password" \
     -d "grant_type=password" \
     -d "client_id=admin-cli" | jq '.access_token' | tr -d '"'`

if [ -z "$ACCESS_TOKEN" -o "$ACCESS_TOKEN" = "null" ]; then
    echo "Failed to get access token"
    exit 1
fi

CLIENT_UUID=$(curl -s -X GET "${kk}/admin/realms/master/clients?clientId=admin-cli" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.[0].id')

curl -s -X PUT "${kk}/admin/realms/master/clients/${CLIENT_UUID}" \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "clientId": "admin-cli",
       "publicClient": false,
       "serviceAccountsEnabled": true,
       "directAccessGrantsEnabled": true
     }'
SECRET=$(curl -s -X GET "${kk}/admin/realms/master/clients/${CLIENT_UUID}/client-secret" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.value')

#echo -e KeyCloak secret is:\n $SECRET
echo $SECRET > password_keycloak.txt