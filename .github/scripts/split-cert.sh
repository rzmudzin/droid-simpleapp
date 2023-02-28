#!/bin/bash

echo "$JAVA_HOME"

# caCertsPath="../../../../_tool/Java_Temurin-Hotspot_jdk/11.0.18-10/arm64/Contents/Home/lib/security/cacerts"
caCertsPath="/Users/rzmud035/actions-runner-droid-simpleapp/_work/_tool/Java_Temurin-Hotspot_jdk/11.0.18-10/arm64/Contents/Home/lib/security/cacerts"

IFS=$'\n'
aliasKey="Alias name:"
# aliasEntries=($(keytool -list -keystore /Users/rzmud035/actions-runner-droid-simpleapp/_work/_tool/Java_Temurin-Hotspot_jdk/11.0.18-10/arm64/Contents/Home/lib/security/cacerts -storepass changeit -v | grep -E 'Alias name:'))
# aliasEntries=($(keytool -list -keystore cacerts -storepass changeit -v | grep -E 'Alias name:'))
aliasEntries=($(keytool -list -keystore ${caCertsPath} -storepass changeit -v | grep -E 'Alias name:'))

declare -a aliases

for aliasNameEntry in "${aliasEntries[@]}"; do
    # echo "$aliasNameEntry"
    alias="${aliasNameEntry/Alias name: /}" 
    alias="${alias/ [jdk/}" 
    alias="${alias/]/}" 
    aliases+=("$alias")
    echo $alias
done    

echo "Alias Count:  ${#aliases[*]}"
target="marriott_ca_cert-00"

rm -rf certs-intermediate
mkdir -p certs-intermediate
cd certs-intermediate
../gcsplit -sz -f marriott_ca_cert- ../marriott_cacerts.pem '/-----BEGIN CERTIFICATE-----/' {*}
files=(*)
# echo "${files[@]}"
for file in "${files[@]}"; do
    echo "$file"

    if [[ " ${aliases[@]} " =~ "$file" ]]; then
        echo "Keystore contains $file cert"
    else
        echo "Keystore does NOT contains $file cert" 
        echo "Loading file $file with alias $file"
        keytool -import -trustcacerts -noprompt -alias "$file" -file "$file" -keystore "$caCertsPath" -storepass changeit
    fi    

done
cd ..

# marriott_ca_cert-00
# marriott_ca_cert-01
# marriott_ca_cert-02
# marriott_ca_cert-03
# marriott_ca_cert-04


