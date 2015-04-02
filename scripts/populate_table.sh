#!/bin/bash

export ZK_HOST=

# Push the sample data file to HDFS
hdfs dfs -put data/crimes_sample1000.csv 

# Use the Geohash Pig UDF to compute the geohash column and add to the csv file
pig -f scripts/add_geohash.pig

# Create the CRIMES table in Phoenix
/usr/hdp/current/phoenix-client/bin/psql.py $ZK_HOST:2181:/hbase-unsecure scripts/create_table.sql

# Load the crime data with geohash via Pig 
pig -f scripts/ingest_crime_data.pig -param ZK_HOST=$ZK_HOST

