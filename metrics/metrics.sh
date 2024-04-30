#!/bin/zsh

# function week2date () {
#   local year=$1
#   local week=$2
#   local dayofweek=$3
#   date -d "$year-01-01 +$(( $week * 7 + 1 - $(date -d "$year-01-04" +%u ) - 3 )) days -2 days + $dayofweek days" +"%Y-%m-%d"
# }

# date +"So this is week: %U of %Y"

# week2date $1 $2



# exit;


BASE=$(dirname "$0");

echo "DOWNLOADING LOGS FROM S3"
aws s3 sync s3://brianmcconnell.me $BASE/logs

echo "UNZIPPING LOGS"
gunzip -c -k -f $BASE/logs/E1TNSK7JF24IAY*gz > $BASE/log_raw

echo "SCRUBBING CRAWLERS & BOTS"
grep  -E -v -i -f $BASE/blacklist.txt log_raw > log_clean

# echo "SPLITTING LOG INTO MONTH LOGS"
# for i in {01..12}
# do
#     sed -n '/2024\-'$i'\-15/,/2024\-'$i'\-31/ p' log_clean > log_clean-2024$i;
#    goaccess $BASE/log_clean-2024$i -o $BASE/../www/metrics/2024$i.html --log-format=CLOUDFRONT;
# done

echo "ANALYZING LOGS"
goaccess $BASE/log_raw -o $BASE/../www/metrics/raw.html --log-format=CLOUDFRONT
goaccess $BASE/log_clean -o $BASE/../www/metrics/index.html --log-format=CLOUDFRONT --ignore-crawlers --unknowns-as-crawlers --tz="America/New York"

echo "GENERATING MOTHLY REPORTS"
for i in {04..12}
do
	sed -n '/2024\-'$i'\-15/,/2024\-'$i'\-31/ p' $BASE/log_clean | goaccess -a -o $BASE/../www/metrics/2024$i.html --log-format=CLOUDFRONT --ignore-crawlers --unknowns-as-crawlers --tz="America/New York"
done



#echo "GARBAGE COLLECTION"

exit;



