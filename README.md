# GeohashDemo

## Objective: 
The goal of this project is to demostrate computing and querying over geohashes in Apache Phoenix/HBase.

## Overview
Data often has an associated latitude and longitude and is frequently queried based on spatial constraints. Querying 2-d geographic data by a bounding box in a range-partitioned database, such as HBase, often requires indexing one of the two dimensions and then brute-force searching over the other. This essentially equates to quickly grabbing a stripe of data around the whole world and then brute force search along the non-indexed dimension. 

Geohashing reduces a two-dimensional lat/long coordinate system to a one-dimensional system where spatially close coordinates are lexicographically close to one another (http://en.wikipedia.org/wiki/Geohash). This simplifies querying by bounding box to a single search across the indexed geohash dimension. The result of this query may contain false positives (results that lie outside of the bounding box) but will not miss any data that falls within the bounding box. Essentially what this does is very quickly reduces the target search area and then the remaining false positives can be weeded out.

This code in this repository leverages Apache Pig to apply a geohash to a sample dataset that has an associated lat/lon and then load that data into an Apache Phoenix table. The table is then available to be queried by geohash as noted in the examples below. Note that all of the data is from the City of Chicago Data Portal (https://data.cityofchicago.org/). Geohashes can be computed at this web site if you would like to build your own queries: http://geohash.org/

To clone the project ensure that you include the --recursive flag for git.

Notes/Todo:
- This project does not pre-split the Phoenix table. Ideally, the table would be pre-split based on key distribution to ensure that loading is as efficient as possible.
- Data could also be loaded via the Hive PhoenixStorageHandler and a custom Hive UDF (https://github.com/gbraccialli/GeohashHiveUDF).  
- Deeper analytics can be performed by snapshotting the HBase table and mapping from Hive.

## Pre-requisites:
This has been build and tested against HDP 2.2. Prerequisites include:
* Pig
* HBase
* Phoenix
* Maven

## Demo setup:
### Step 1: Build the Geohash Pig UDF
```
cd GeohashPigUDF
mvn package
cd ..
```

### Step 2: Edit the file scripts/populate_table.sh. Place the hostname of one of your Zookeeper servers as the value for ZK_HOST.

### Step 3: Execute the populate table script from the project root directory.
```
chmod +x scripts/populate_table.sh
./scripts/populate_table.sh
```
### Step 4: Open the sqlline client and test out some basic queries.
```
/usr/hdp/current/phoenix-client/bin/sqlline.py ZK_HOST:2181:/hbase-unsecure
```

* Count number of crimes in a specific bounding box by lat/lon without indexes:
```sql
select count(*) AS crime_total FROM CRIMES WHERE latitude > 41.88406793446202 AND latitude < 41.88860472371386 AND longitude > -87.6448917388916 AND longitude < -87.63922691345215;
```
* Count number of crimes in a specific bounding box with geohash
```sql
select count(*) AS crime_total FROM CRIMES WHERE geohash>'dp3wm8fbmupv' AND geohash < 'dp3wm9x4cczv';
```
  * Note that this is a quick and dirty approximation that may, and often does, include false positives. This means that the search very quickly weeds out things that are not inside the bounding box but also picks up a few outliers. 
  * The next step shows how to filter those with a nested select.
* Count number of crimes in a specific bounding box with geohash followed by filtering outliers:
```sql
select count(*) AS crime_total FROM (select latitude,longitude FROM CRIMES WHERE geohash>'dp3wm8fbmupv' AND geohash < 'dp3wm9x4cczv') AS t WHERE t.latitude > 41.88406793446202 AND t.latitude < 41.88860472371386 AND t.longitude > -87.6448917388916 AND t.longitude < -87.63922691345215;
```
* Count number of crimes in a specific bounding box by lat/lon with latitude index:
```sql
CREATE INDEX LAT_INDEX ON CRIMES (latitude) INCLUDE(longitude,geohash);
```
```sql
select count(*) AS crime_total FROM CRIMES WHERE latitude > 41.88406793446202 AND latitude < 41.88860472371386 AND longitude > -87.6448917388916 AND longitude < -87.63922691345215;
```
