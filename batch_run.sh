#!/usr/bin/env bash
#
# This is a batch file that is called by prompt_run.sh
#
# This file utilizes the mr_manager script
# and executes it on the name's of the PI's whose scan's you're
# looking to manage, as well as the names of the scanners used
# as defined in the arrays labeled pis and scanners

# Change this to match th pi's you are working with
pis=('esterlis' 'cosgrove' 'davis' 'hillmer' 'morris')
# Change this to the scanners used
scanners=('prismaa' 'prismab' 'prismac')

for scanner in "${scanners[@]}"; do
	for pi in "${pis[@]}"; do
		# Change this to location of where the mr_manager script is on your system
		/home/"${USER}"/codes/pseudo_cron_files/mr_manager backup "${scanner}" "${pi}"
	done
done
