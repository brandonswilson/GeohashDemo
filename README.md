# GeohashDemo

To clone the project ensure that you include the --recursive flag for git.

Pre-requisites:
* This has been build and tested against HDP 2.2.
* Pig
* HBase
* Phoenix
* Maven

Step 1: Build the Geohash Pig UDF
```
cd GeohashPigUDF
mvn package
cd ..
```

Step 2: Edit the file scripts/populate_table.sh. Place the hostname of one of your Zookeeper servers as the value for ZK_HOST.

Step 3: Execute the populate table script from the project root directory.
```
chmod +x scripts/populate_table.sh
./scripts/populate_table.sh
```
Step 4: Test out some basic queries:
