#!/bin/bash
#
# This is a very simple example of a script that logs into an Oracle database and does something.
# What it does can be anything you want. You will then call this script from a "master" script to simulate concurrency and N number of
# active connections ... this depends on what we are trying to test.
#
#
#
_max_idle_secs=10
r=`od -vAn -N4 -tu4 < /dev/urandom`
sleep_secs=`expr $r % $_max_idle_secs`
 
sleep $sleep_secs
sqlplus -s scott/tiger <<EOF > /dev/null
DROP TABLE TEST_$$ purge;
CREATE TABLE TEST_$$ AS SELECT * FROM ALL_TABLES;
SELECT count(*) from TEST_$$;
EOF
exit 0;
