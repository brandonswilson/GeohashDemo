# GeohashDemo

To clone the project ensure that you include the --recursive flag for git.

## Pre-requisites:
* This has been build and tested against HDP 2.2.
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
