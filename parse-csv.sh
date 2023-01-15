#!/bin/bash

# first parameter is file name
filename=$1
# second parameter is number of days to parse
nb_of_days=$2
# output file
output="results.csv"

# associative array indexed by day
# will contain a sub array that contains the measured values
declare -a daily_names
declare -a daily_values

n=1
day=1
while read line; do
    case $line in
	# start of a day
	# 13/01/2023;; for example
	[0-9][0-9]/*)
	    # take the first 10 characters (ie 13/01/2023)
	    CUR_DAY=$(echo $line | cut -c 1-10)
	    if [ $day -gt $nb_of_days ]; then
		echo "Run on $nb_of_days days" > $output;
		for name in "${daily_names[@]}"; do echo $name >>$output; done
		for value in "${daily_values[@]}"; do echo $value >>$output; done
		echo "Find results in $output"
		exit;
	    fi
	    daily_names+=($CUR_DAY)
	    daily_values+=("")
	    echo "Working $day/$nb_of_days: $CUR_DAY"
	    day=$((day+1))
		      ;;
	# data for a given time
	# 23:30:00;473;Reelle
	[0-9][0-9]:[0-9][0-9]:*)
	    # get the value and the ';' (ie: ";473;") and remove the first ;
	    value=$(echo $line | grep -Po '\K;.*;' | cut -c 2-)
	    curvalue=$(echo ${daily_values[$day]})
	    # put the values in the reverse order
	    daily_values[$day]="$value$curvalue"
		      ;;
      *)
		      ;;
    esac
    n=$((n+1))
done < $filename
