#!/bin/bash
#
# THIS SCRIPT BACKS UP THE DATABASE FOR 30 SECOND PITCH TO AMAZON S3
#
# Based on https://gist.github.com/2206527
# And augmented with http://stackoverflow.com/questions/12040816/mysqldump-in-csv-format

# Be pretty
echo -e " "
echo -e " .  ____  .    ______________________________"
echo -e " |/      \|   |                              |"
echo -e "[| \e[1;31m♥    ♥\e[00m |]  | S3 MySQL Backup Script v.0.1 |"
echo -e " |___==___|  /                © oodavid 2012 |"
echo -e "              |______________________________|"
echo -e " "

# Basic variables
mysqlpass="3dBz0098201jDjp$"
bucket="s3://3spdatabasebackups"
username="root"

# Timestamp (sortable AND readable)
stamp=`date +"%s - %A %d %B %Y @ %H%M"`

# List all the databases
databases=`mysql -u $username -p$mysqlpass -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)"`

# Feedback
echo -e "Dumping to \e[1;32m$bucket/$stamp/\e[00m"

# Loop the databases
for db in $databases; do

  # Define our filenames
  filename="$stamp - $db.sql.gz"
  tmpfile="/tmp/$filename"
  object="$bucket/$stamp/$filename"

  # Feedback
  echo -e "\e[1;34m$db\e[00m"

  # Dump and zip
  echo -e "  creating \e[0;35m$tmpfile\e[00m"
  mysqldump -u $username -p$mysqlpass --force --opt --databases "$db" | gzip -c > "$tmpfile"

  # Upload
  echo -e "  uploading..."
  s3cmd put "$tmpfile" "$object"

  # Delete
  rm -f "$tmpfile"

  usersfilename="users_$stamp.csv"
  userstmpfile="/tmp/$usersfilename"
  usersobject="$bucket/$stamp/$usersfilename"

  pitchvideosfilename="pitch_videos_$stamp.csv"
  pitchvideostmpfile="/tmp/$pitchvideosfilename"
  pitchvideosobject="$bucket/$stamp/$pitchvideosfilename"

  sharelinksfilename="share_links_$stamp.csv"
  sharelinkstmpfile="/tmp/$sharelinksfilename"
  sharelinksobject="$bucket/$stamp/$sharelinksfilename"

  # http://www.anattatechnologies.com/q/2011/07/mysqldump/
  # Now lets upload the plain CSV version for tables
  mysql -u $username -p$mysqlpass -ss \
  -e "SELECT id, first_name, last_name, email, phone, is_admin, bio, field_of_study, linkedin_url, is_profile_hidden FROM users" "$db" \
  | sed 's/\t/","/g;s/^/"/;s/$/"/' > "$userstmpfile"
  
  echo -e "  uploading..."
  s3cmd put "$userstmpfile" "$usersobject"

  mysql -u $username -p$mysqlpass -ss \
  -e "SELECT * FROM pitch_videos" "$db" \
  | sed 's/\t/","/g;s/^/"/;s/$/"/' > "$pitchvideostmpfile"

  echo -e "  uploading..."
  s3cmd put "$pitchvideostmpfile" "$pitchvideosobject"

  mysql -u $username -p$mysqlpass -ss \
  -e "SELECT * FROM share_links" "$db" \
  | sed 's/\t/","/g;s/^/"/;s/$/"/' > "/tmp/$sharelinksfilename"

  echo -e "  uploading..."
  s3cmd put "$sharelinkstmpfile" "$sharelinksobject"

done;

# Jobs a goodun
echo -e "\e[1;32mJobs done\e[00m"