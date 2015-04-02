REGISTER GeohashPigUDF/target/geohash-1.0-SNAPSHOT.jar;

A = LOAD 'crimes_sample1000.csv' USING PigStorage('\t');
B = FILTER A BY NOT($19 == '') AND NOT($20 == '');
C = FOREACH B GENERATE *,geohash.Encode($19, $20, 12);

STORE C INTO 'crimes_geohash' USING PigStorage('\t');
