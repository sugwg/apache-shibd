#!/bin/bash -v

set -e

for file in attribute-map.xml inc-md-cert.pem sp-encrypt-cert.pem sp-encrypt-key.pem shibboleth2.xml
  do cp -v /etc/shibboleth/${file} /mnt
done

if [ ! -d /run/shibboleth ] ; then
  mkdir -p /run/shibboleth
fi
chown shibd:shibd /run/shibboleth

export LD_LIBRARY_PATH=/opt/shibboleth/lib64
exec /usr/sbin/shibd -f -u shibd -g shibd -c /etc/shibboleth/shibboleth2.xml -p /var/run/shibboleth/shibd.pid -F -w 600
