REGISTER '/usr/hdp/current/phoenix-client/phoenix-client.jar'

A = LOAD 'crimes_geohash' USING PigStorage('\t');
STORE A INTO 'hbase://CRIMES' USING org.apache.phoenix.pig.PhoenixHBaseStorage('$ZK_HOST:2181:/hbase-unsecure', '-batchSize 1000');
