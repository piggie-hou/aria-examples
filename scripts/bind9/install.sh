#!/bin/bash

set -e

####################################################################################################################

# Install BIND.

echo -e "127.0.0.1 bind9-host" | sudo tee -a /etc/hosts

sudo apt-get update

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install bind9 bind9utils bind9-doc --yes

####################################################################################################################

# Update BIND configuration with the specified zone and key.

touch /tmp/named.conf.local

cat >> /tmp/named.conf.local << EOF

key example.com. {
  algorithm "HMAC-MD5";
  secret "8r6SIIX/cWE6b0Pe8l2bnc/v5vYbMSYvj+jQPP4bWe+CXzOpojJGrXI7iiustDQdWtBHUpWxweiHDWvLIp6/zw==";
};


zone "example.com" IN {
  type master;
  file "/var/lib/bind/db.example.com";
  allow-update {
    key example.com.;
  };
};

zone "openstacklocal" {type master; file "/etc/bind/openstack.local";};

EOF

sudo mv /tmp/named.conf.local /etc/bind/named.conf.local

####################################################################################################################

touch /tmp/cloud.local
cat > /tmp/openstack.local << EOF
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     openstacklocal. root.openstacklocal. (
                           2         ; Serial
                          604800         ; Refresh
                          86400         ; Retry
                          2419200         ; Expire
                          604800 )       ; Negative Cache TTL
;
@       IN      NS      openstacklocal.
;@      IN      A       127.0.0.1
;@      IN      AAAA    ::1
EOF

sudo mv /tmp/openstack.local /etc/bind/openstack.local

####################################################################################################################
echo -e "Create basic zone configuration."
ctx logger info "DNS IP address is ${dns_ip}"
echo ${dns_ip} > /home/ubuntu/dnsfile

####################################################################################################################

touch /tmp/db.example.com
cat > /tmp/db.example.com << EOF

; example.com
\$ORIGIN example.com.
\$TTL 1h
@ IN SOA ns admin\@example.com. ( $(date +%Y%m%d%H) 1d 2h 1w 30s )
@ NS ns
ns A $(hostname -I)
EOF

sudo mv /tmp/db.example.com /var/lib/bind/db.example.com
sudo chown root:bind /var/lib/bind/db.example.com

####################################################################################################################

echo -e "Now that BIND configuration is correct, kick it to reload."
sudo service bind9 reload

ping example.com -c 2 -i 4

####################################################################################################################
