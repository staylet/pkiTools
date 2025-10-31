# pkiTools
A Tools for easy generate PKI/TLS files.



# Shell verison

A PKI Key generate Shell script based on OpenSSL. This can be userful for TLS certificate testing.

## Syntax

```bash
genkey.sh [ca|DOMAIN|-h]

Options:
  ca [DAYS]      Generate CA key and CA certificate.
  DOMAIN [DAYS]  Sign certificate for domain DOMAIN if CA is already exist.
  -h             Print help information. 
```

## Example

**Generate CA:**

`sh shell/genkey.sh ca`  will create a 'ca' directory in current workspace and execute a **interactive** OpenSSL command to generate self-sign CA. 

Block in`{..}` you need type in:

```bash
// Those information is not importent if certs just use for test.

Country Name (2 letter code) []: {Your Contry}
State or Province Name (full name) []: {Your Province}
Locality Name (eg, city) []: {your City}
Organization Name (eg, company) []: {Your Organization}
Organizational Unit Name (eg, section) []: {Your Unit}
Common Name (eg, fully qualified host name) []: {You Hostname or somethine}
Email Address []: {Email address}
```



 **Sign certificate:**

`sh shell/genkey.sh domain.local`  will create 'certs/domain.local' directory in current workspace and generate certificate for domain 'domain.local' sign by CA.

## Hint

- Destination files will be copied to 'backup' directory if exist.
- Change ` DAYS=? ` in script to defins the number of days to certify the certificate for. Default 365 days.
