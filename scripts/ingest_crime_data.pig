REGISTER '/usr/hdp/current/phoenix-client/phoenix-client.jar'

A = LOAD 'crimes_geohash' USING PigStorage('\t') AS (id:int, case:chararray, d:chararray, block:chararray, iucr:chararray, pri:chararray, descr:chararray, loc_desc:chararray, arrest:chararray, domestic:chararray, beat:chararray, district:chararray, ward:int, comm:int, fbi:chararray, x:int, y:int, year:int, updated:chararray, latitude:double, longitude:double, location:chararray, geohash:chararray);

STORE A INTO 'hbase://CRIMES' USING org.apache.phoenix.pig.PhoenixHBaseStorage('$ZK_HOST:2181:/hbase-unsecure', '-batchSize 1000');
