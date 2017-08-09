#!/bin/bash
#
# This script is used to control the # of times or the concurrency of executing some other program.
# In this example, this script will execute the script "sqlplus_client.sh".
# The script starts by executing the "sqlplus_client.sh" script in the background as determined by the MAX_CONCURRENCY value.
# 
# It will then check every second to see if the array of background PIDS meets the concurrency and if any scripts have exited, then it kick off another
# version of that script ..until the MAX_MINUTES have come about.

#
# This script is a way to simulate N concurrent executions of a script that does whatever you need, for a specific amount of time.
# So if you want to test a data model change and want to simulate N # of concurrent sessions running some typical transaction, you can use this
# script to do some simple benchmarking.
#
 
MAX_CONCURRENCY=10				# What concurrency should script run: 10
MAX_MINUTES=${1:-5}				# How many minutes should script run: defaults 5 min
_CHILDPROGRAM="sqlplus_client.sh"		# Name of Child Program
 
# ----------------------------------------------
# Configuration
# ----------------------------------------------
declare -a pidArray;
 
# populate array by kicking off up to MAX_CONCURRENCY of the child program.
echo -n "[`date`] - Populating array up to MAX_CONCURRENCY($MAX_CONCURRENCY): "
while (( ${#pidArray[*]}  < MAX_CONCURRENCY ))
do
	 ./${_CHILDPROGRAM} & 2> /dev/null;
	 pidArray=("${pidArray[@]}" $!);
	 # echo -n " starting: ${#pidArray[*]} .. "
done
 
# Now we iterate through the array of pids and see which one are still running.
# If we find any PIDs that are no longer running, we kick off another in its place...this way we maintain MAX_CONCURRENCY.
# Also, we will stop checking if the MAX_MINUTES has exceeded and let the remaining jobs finish up.
 
while [ $SECONDS -lt $(( MAX_MINUTES * 60 ))  ];
do
   #echo "Processes in array: ${#pidArray[*]}"
   for index in ${!pidArray[*]}
   do
	   if kill -0 "${pidArray[$index]}" 2>/dev/null;
	   then
			 #echo "Pid  ${pidArray[$index]} is alive";
			 echo -n;
	   else
			#echo -n "Pid  ${pidArray[$index]} is no longer running ..";
			 unset pidArray[$index];
			 ./${_CHILDPROGRAM} & 2>/dev/null;
			 pidArray=("${pidArray[@]}" $!);
			 let jobscompleted++;
	   fi
   done
 
# Every 30 seconds we will print out # of jobs in array..just to see some output on screen.
counter=`expr $SECONDS % 30`
if [ $counter -eq 0 ]
then
	   echo "[`date`]: Jobs currently running: ${#pidArray[*]}"
fi
 
# sleep for 1 second then check PIDs in the array again to maintain concurrency.
sleep 1;
done
 
# When we reach the time duration, we stop kicking off jobs and let the remaining MAX_CONCURRENCY jobs in the
# array finish up. We could add more code here to wait for those remaining jobs to finish, but that
# would be more work. We will just add $MAX_CONCURRENCY to the jobscompleted to get a rough figure of how many executions of
# the child program where performed.
 
echo "[`date`] - Jobs completed: `expr $jobscompleted + $MAX_CONCURRENCY`"
exit;
