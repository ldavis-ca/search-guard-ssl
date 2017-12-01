#!/bin/bash
# this will be a migration called from the migrations folder

# please call this your ansiblesite directory

OPENSSL_VER="$(openssl version)"

if [[ $OPENSSL_VER == *"0.9"* ]]; then
	echo "Your OpenSSL version is too old: $OPENSSL_VER"
	echo "Please install version 1.0.1 or later"
	exit -1
else
    echo "Your OpenSSL version is: $OPENSSL_VER"
fi

if [ -z "$1" ] ; then
  echo "Please note a destination directory"
  exit -1
fi

if [ ! -d "$1" ] ; then
  echo "Directory does not exist"
fi

set -e
cd submodules/search-guard-ssl/civis-scripts
./clean.sh
./gen_root_ca.sh capass changeit
./gen_node_cert.sh 1 changeit capass
./gen_node_cert.sh 2 changeit capass
./gen_node_cert.sh 3 changeit capass
./gen_node_cert.sh 4 changeit capass
./gen_node_cert.sh 5 changeit capass
./gen_client_node_cert.sh admin-client changeit capass

# import intermediate CA into trust store
# check for the existence of this tool before executing
keytool -importcert -keystore ./truststore.jks -storepass changeit -file ./ca/signing-ca.crt

# Base64 encode keystore files
mkdir ../../../tmp/search-guard
for jks in *.jks; do
  base64 -b 76 -i "$jks" -o ../../../tmp/search-guard/"$jks".b64
done

rm -f ./*tmp*