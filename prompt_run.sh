#!/usr/bin/env bash

# This is a simple script that can
# generate a prompt when ssh-ing to a server
#
# Add:
# 	RequestTTY yes
#	RemoteCommand /path/to/file/on/remote/server/prompt_run.sh; exec tcsh  -l
#
# To the ~/.ssh/config entry of the host you're connecting to
#
# RequestTTY yes will always request a TTY when standard input is a TTY
# exec tcsh -l can be changed to work for whichever shell you're using on the server

printf "\nHello %s! Would you like to check for mri's? (y/n)\n" "${USER}"
read -r ANSWER
if [[ "${ANSWER}" == y || "${ANSWER}" == Y || "${ANSWER}" == YES || "${ANSWER}" == Yes || "${ANSWER}" == yes ]]; then
    # Change this to the file path of where the script is on the remote server
    /bin/bash -c /home/"${USER}"/Documents/codes/pseudo_cron_files/batch_run.sh
else
    printf "\nNot checking\n"
fi
