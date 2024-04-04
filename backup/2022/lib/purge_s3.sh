#!/bin/zsh

# ensure we know which bucket to target.
if [ $# -eq 0 ]; then
    echo "Please specify an S3 bucket to clean up."
	exit;
fi

#### COMPILE THE FILE LIST
# download an inventory of files
aws s3 ls s3://"$1" > file_list.txt
# remove the date prefixes and filesize.
sed -E 's/^[0-9\-]+\ +[0-9\:]+\ +[0-9]+\ +([0-9a-zA-Z\.\-]+)/{"Key": "\1"},/g' file_list.txt | \
# remove any "PREFIXES" or folders
sed -r 's/^\ +PRE\ +([0-9a-zA-Z\.\-\/]+)$/*/g' | \
# remove empty lines
sed -r '/^\s*$/d' \
> file_list.json


#### PREPARE THE JSON REQUEST
# remove any older files
rm files_*
# AWS s3api has a 1000 file limit on delete requests, so we split the file list.
split -l 1000 file_list.json "files_"

# add the JSON filename suffix
for i in ./files_*;do mv "$i" "$i.json";done;
# remove the trailing comma
for i in ./files_*;do truncate -s -2 "$i";done;
# add the request JSON
for i in ./files_*;do echo '{"Objects": [' | cat - "$i" > temp && mv temp "$i";done;
for i in ./files_*;do echo '\n],"Quiet": true}' >> "$i";done;


#### TAKE ACTION
# run the purge
for i in ./files_*;do aws s3api delete-objects --bucket "$1" --delete "file://$i";done;



#JSON REQUEST FORMAT
#{
#  "Objects": [
#    {"Key": "2019-05-17-17-32-32-A991BA9F14F2FD7A"},
#    {"Key": "2019-05-17-17-39-31-4BAF795D3B361893"}
#  ],
#  "Quiet": false
#}