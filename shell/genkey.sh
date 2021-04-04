#!/bin/bash

set -e
set -o pipefail

DAYS=365

help() {
  # Display help info.
  echo "A PKI Key generate script based on OpenSSL."
  echo
  echo "Syntax: genkey.sh [ca|DOMAIN|-h]"
  echo "Options:"
  echo "  ca         Generate CA key and CA certificate."
  echo "  DOMAIN     Sign certificate for domain DOMAIN if CA is already exist."
  echo "  -h         Print help information."
  echo 
  echo "Usage:"
  echo "  Generate CA:"
  echo "    'sh $0 ca': will create a 'ca' directory in current workspace and execute a interactive OpenSSL command to generate self-sign CA."
  echo
  echo "  Sign certificate:"
  echo "    'sh $0 domain.local': will create 'certs/domain.local' directory in current workspace and generate certificate for domain 'domain.local' sign by CA."
  echo  
  echo "Hint:"
  echo "  Destination files will be copied to 'backup' directory if exist."
  echo "  Change 'DAYS=?' in script to defins the number of days to certify the certificate for. Default 365 days."
}

check() {
  # Make sure OpenSSL installed.
  echo "Check OpenSSL Version:"
  openssl version || exit 1
  echo "..."
}

backup() {
  # Backup file if exist.
  dt=$(date +%Y%m%d.%H%M%S)
  if [ $1 = "ca" ];then
    echo "CA backup..."
    dstPath="backup/ca/${dt}"
    mkdir -p $dstPath
    cp ca/ca.* $dstPath
    echo "CA has copied to $dstPath"
  else
    echo "$1 backup..."
    dstPath="backup/cert/${1}/${dt}"
    mkdir -p $dstPath
    cp certs/${1}/${1}.* $dstPath
    echo "${1} has copied to $dstPath"
  fi
}

gen_ca() {
  # Generate CA.
  if [ -f ca/ca.key ];then
    backup ca
  fi 

  mkdir -p ca

  openssl genrsa -out ca/ca.key 4096
  openssl req -new -x509 -days $DAYS -key ca/ca.key -sha256 -out ca/ca.crt
}

sign_cert() {
  # Sign certificate.
  if [ -f certs/${1}/${1}.key ];then
    backup $1
  fi 

  certPath="certs/${1}"
  mkdir -p $certPath

  # Create REQ for domain
  openssl req -subj "/CN=${1}" -sha256 -newkey rsa:4096 -keyout ${certPath}/${1}.key -out ${certPath}/${1}.csr -nodes

  # Create extend info.
  echo "subjectAltName = DNS:${1}" > ${certPath}/${1}.cnf
  echo "extendedKeyUsage = serverAuth" >> ${certPath}/${1}.cnf

  # Sign certificate
  openssl x509 -req -days $DAYS -sha256 -in ${certPath}/${1}.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial \
    -out ${certPath}/${1}.crt -extfile ${certPath}/${1}.cnf
}


case $1 in
  "ca")
    check
    gen_ca
    ;;
  -h|--help)
    help
    ;;
  *)
    if [[ $1 =~ \. ]];then
      check
      sign_cert $1
    else
      help
    fi
    ;;
esac

