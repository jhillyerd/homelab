set local_wildcard "*.home.arpa"
set config cfssl-config.json
set ca_crt ca/nomad-ca.pem
set ca_key ca/nomad-ca-key.pem
set output certs

function gencert
  set short_name (string join "-" $argv)
  set host_names \
    (string join "," (string replace -r '$' ".global.nomad" $argv))

echo '{ "CN": "nomad.service.consul" }' | cfssl gencert \
  -ca=$ca_crt -ca-key=$ca_key -config=$config \
  -hostname="$host_names,$local_wildcard,nomad.service.consul,localhost,127.0.0.1" - \
  | cfssljson -bare $output/$short_name
end

mkdir -p $output

gencert server client

echo '{}' | cfssl gencert -ca=$ca_crt -ca-key=$ca_key -profile=client - \
  | cfssljson -bare $output/cli

echo '{ "CN": "nomad.browser" }' | cfssl gencert \
  -ca=$ca_crt -ca-key=$ca_key -profile=browser - \
  | cfssljson -bare $output/browser
openssl pkcs12 -export -out $output/browser.pfx -passout pass: \
  -in $ca_crt -in $output/browser.pem -inkey $output/browser-key.pem
