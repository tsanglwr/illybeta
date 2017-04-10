#!/bin/sh
HOSTNAME=ec2-35-162-38-46.us-west-2.compute.amazonaws.com
USERNAME=ubuntu
KEYFILEPATH="/Users/sauron/NewestDropbox/Dropbox/QIWIBEE_PROJECTS/Inhouse/keys/hyper/hyper_ecz_prod.pem"
echo "Starting deploy to server... $HOSTNAME"
echo "Deleting logs/*"
rm -rf log
echo "Deleting tmp/cache..."
rm -rf tmp/cache
rsync -rav -e "ssh -i $KEYFILEPATH"  --progress --exclude-from='./exclude_files_rsync.txt' ./ ubuntu@$HOSTNAME:~/app
echo "\nDONE deploying to $HOSTNAME\n"

echo "\nSigning in and restarting..."
ssh -t -i $KEYFILEPATH ubuntu@$HOSTNAME bash -c "'
cd app && touch tmp/restart.txt
exit
'"

echo "\nDone. Bye..."
exit