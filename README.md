# replicate_nightly

This is a simple bash script for cron to copy target tables from a remote PostgreSQL DB to a local one every night.
Local tables are dropped and replaced with remote ones, resetting any changes made to them during the day.

## password encryption

Made quite simplistic here. Password is encrypted using openssl (version 1.0.2k) and its hash and key are written to the hidden file with limited permissions. Run `make_secret.sh` script and follow the prompt.

## script setup

Before running `replicate_nightly.sh` script, all the constants should be assigned proper values to make sense.

- PGDUMP - path to postgres pg_dump bin
- PSQL - path to postgres psql bin
- REMOTE_HOST - ip/host of a remote DB
- REMOTE_PORT - port to connect to the remote DB
- REMOTE_DB - remote DB name
- LOCAL_DB - local DB name
- TABLES - tables to copy
- REMOTE_USER - user to connect to the remote DB
- DUMP_DIR - path to a directory where remote dumps are stored
- DUMP_LIFETIME - days dumps are kept
- SECRET_FILE - hidden file from the previous step

This script is run from the user with trust postgres authentication method, so no credentials are used for the local connection.
After setting all the constants try running `replicate_nightly.sh` script to see that no errors are thrown and `finished successfully!` response is reached.

## automating the launch

Run `crontab -e` and write something like this (with a proper path to the script):

```
0 0 * * * /path/to/replicate_nightly.sh 2>&1 >/dev/null | logger -p user.error -t replicate_nightly.sh
```

It runs the script every night at 00:00 and writes any thrown error to the syslog.
