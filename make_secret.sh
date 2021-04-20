#! /bin/bash

# default filename
FILENAME_DEFAULT=".secret"


read -p "Please enter password to encrypt (hidden input): " -s PASSWORD
printf "\n"
read -p "Please enter encryption key: " KEY
read -p "Please enter filename [$FILENAME_DEFAULT]: " FILENAME
FILENAME=${FILENAME:-$FILENAME_DEFAULT}

echo HASH=$(echo $PASSWORD | openssl enc -base64 -e -aes-256-cbc -pass pass:$KEY) > $FILENAME
echo KEY=$KEY >> $FILENAME
chmod 600 $FILENAME