#!/bin/bash -xe

echo "-----------------------------------" > /dev/null
echo "--------- INSTALLING SPARK --------" > /dev/null
echo "-----------------------------------" > /dev/null
ROOT=$(dirname $0)
tempdir=${tempdir:-/tmp}

# Source: http://devopspy.com/python/apache-spark-pyspark-centos-rhel/
java -version
cd /opt
wget https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz
tar -xzf spark-2.4.5-bin-hadoop2.7.tgz
ln -s /opt/spark-2.2.1-bin-hadoop2.7  /opt/spark

# Running Spark
./sbin/start-master.sh

#TODO : Create a SystemD service to run that
#TODO : Create a /etc/nginx/location.d/spark.conf to use nginx as a reverse proxy
