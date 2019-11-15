#!/bin/bash -v

set -e

if [ ! -d /run/httpd ] ; then
  mkdir /run/httpd
fi
chown apache:apache /run/httpd/

exec $@
