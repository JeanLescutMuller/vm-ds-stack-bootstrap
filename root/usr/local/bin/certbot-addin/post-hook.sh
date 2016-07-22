#!/bin/sh

BASE=/etc/letsencrypt/live/luke.jeanl.me
cp -f $BASE/privkey.pem $BASE/total.pem 
cat $BASE/fullchain.pem >> $BASE/total.pem

service nginx start
