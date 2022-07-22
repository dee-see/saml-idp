#!/bin/bash

cert_dir="$(dirname "$0")/cert"
if [ ! -d "$cert_dir" ]; then
    mkdir "$cert_dir"
    cd "$cert_dir"

    openssl req -x509 -new -newkey rsa:2048 -nodes \
        -subj '/C=US/ST=California/L=San Francisco/O=JankyCo/CN=Test Identity Provider' \
        -keyout idp-private-key.pem \
        -out idp-public-cert.pem -days 7300

    openssl req -x509 -new -newkey rsa:2048 -nodes \
        -subj '/C=US/ST=California/L=San Francisco/O=JankyCo/CN=Test Identity Provider' \
        -keyout https-private-key.pem \
        -out https-public-cert.pem -days 7300

    cd ..
fi

node app.js --acs "https://$OSDOMAIN/_dashboards/_opendistro/_security/saml/acs" --aud "https://$OSDOMAIN" --issuer urn:testsamlidp:idp \
    --cert "$cert_dir/idp-public-cert.pem" --key "$cert_dir/idp-private-key.pem" \
    --host 0.0.0.0 --https --httpsCert "$cert_dir/https-public-cert.pem" --httpsPrivateKey "$cert_dir/https-private-key.pem"
