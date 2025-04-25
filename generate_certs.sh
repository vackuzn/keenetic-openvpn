#!/bin/bash
export MSYS_NO_PATHCONV=1

# Remove existing certs directory if it exists
rm -rf certs

# Create directory for certificates
mkdir -p certs
cd certs

# -----------CA-----------

# Generate CA private key
openssl genrsa -out ca.key 2048

cat > ca-openssl.cnf <<EOF
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
x509_extensions    = v3_ca
prompt             = no

[ req_distinguished_name ]
CN = OpenVPN-CA

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign
EOF

# Generate CA certificate using standalone config
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -config ca-openssl.cnf -extensions v3_ca

# -----------Server-----------

# Generate server private key
openssl genrsa -out server.key 2048

# Generate server certificate signing request
openssl req -new -key server.key -out server.csr -subj "/CN=OpenVPN-Server"

# Create server extension file
cat > server-ext.cnf <<EOF
basicConstraints=CA:FALSE
keyUsage=critical, digitalSignature, keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:OpenVPN-Server
EOF

# Sign server certificate
openssl x509 -req -in server.csr -out server.crt -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -extfile server-ext.cnf

# Generate TLS auth key for HMAC firewall
(
  echo "-----BEGIN OpenVPN Static key V1-----"
  openssl rand -hex 256 | fold -w32
  echo "-----END OpenVPN Static key V1-----"
) > ta.key

# -----------Clients-----------

# Generate client1 private key
openssl genrsa -out client1.key 2048

# Generate client1 certificate signing request
openssl req -new -key client1.key -out client1.csr -subj "/CN=OpenVPN-Client1"

# Create client1 extension file
cat > client1-ext.cnf <<EOF
basicConstraints=CA:FALSE
keyUsage=critical, digitalSignature
extendedKeyUsage=clientAuth
EOF

# Sign client1 certificate
openssl x509 -req -in client1.csr -out client1.crt -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -extfile client1-ext.cnf


# Generate more client certificates if needed


# Generate Diffie-Hellman parameters
openssl dhparam -out dh.pem 2048

# Clean up certificate signing requests
rm *.csr
rm *.srl
rm *.cnf

# Set proper permissions
chmod 600 *.key
chmod 644 *.crt
chmod 644 dh.pem

echo "All certificates have been generated in the 'certs' directory."
echo "To generate OpenVPN configuration files, run process_templates.sh" 