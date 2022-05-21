set config cfssl-config.json
set ca_crt ca/nomad-ca.pem
set ca_key ca/nomad-ca-key.pem

function gencert
  set short_name (string join "-" $argv)
  set host_names \
    (string join "," (string replace -r '$' ".global.nomad" $argv))

  echo '{}' | cfssl gencert \
    -ca=$ca_crt -ca-key=$ca_key -config=$config \
    -hostname="$host_names,*.skynet.local,localhost,127.0.0.1" - \
    | cfssljson -bare $short_name
end

gencert server client

echo '{}' | cfssl gencert -ca=$ca_crt -ca-key=$ca_key -profile=client - \
  | cfssljson -bare cli

echo '{
  "CN": "nomad.browser"
}' | cfssl gencert -ca=$ca_crt -ca-key=$ca_key -profile=browser - \
  | cfssljson -bare browser
openssl pkcs12 -export -out browser.pfx -passout pass: \
  -in $ca_crt -in browser.pem -inkey browser-key.pem
