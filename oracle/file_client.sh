#!/bin/bash
#
# This is another "client" type script that we can have the master.sh script invoke.
# For example, say I pulled a number of SQL SELECT queries from a database cache and I wrote all those files into a directory called "testfiles".
# I know wanted to make a data model change and wanted to run these queries randomly before and after a data model or index change ..to help me validate
# my data model changes. This script runs a "random" file from a script, but I can alter this script if I wanted to run this script as needed.

# I would then have the master.sh script run this script with some sort of concurrency and for however many minutes I needed.
# Again, these are just quick and dirty scripts to validate changes and do concurrency & perfromance testing without a lot of expensive tools.
#
#

files=(testfiles/*.sql)
 
r=`od -vAn -N4 -tu4 < /dev/urandom`
n=${#files[@]}
 
scriptfile="${files[r % n]}"
 
sqlplus -s scott/tiger <<EOF
@$scriptfile
exit;
EOF
 
exit 0;
