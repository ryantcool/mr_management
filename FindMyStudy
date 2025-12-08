#!/usr/bin/env bash

: <<'Author_Comment'
    Rewritten Find-My-Study Script for Bash
    Author: Ryan Cool
    Last Updated: 2025-09-12
    Contact: ryan.cool@yale.edu
Author_Comment

scanner="${1}"
filter="${2}"

read -r -d '' HELPTEXT <<-EOM
	#################################
	#       FindMyStudy Script      #
	#################################

	USAGE: ${0} <ScannerName> [filter]

	    Accepted <ScannerName> Values: prismaa | prismab | prismac | sonata | trio | trioa | triob | timtrioa | timtriob | vida

	Examples:   ${0} prismab              <-- Lists all scans in prismab directory
	            ${0} prismaa constable    <-- Lists scans in prismaa directory for selected pi
	            ${0} prismac pc1234       <-- Lists info for prismac scan that matches the MR number

	#################################################################
	#    If you have any questions about this script please contact #
	#    Ryan at ryan.cool@yale.edu                                 #
	#################################################################
EOM

# Function to locate scanner directory where new scans are uploaded
check_scanner() {
	if [[ "${scanner,,}" == trio ]] || [[ "${scanner,,}" == timtrioa ]] || [[ "${scanner,,}" == prismab ]]; then
		cd /data1/prismab_transfer || exit 1
	elif [[ "${scanner,,}" == sonata ]] || [[ "${scanner,,}" == prismaa ]]; then
		cd /data1/prismaa_transfer || exit 1
	elif [[ "${scanner,,}" == timtrio ]] || [[ "${scanner,,}" == timtriob ]] || [[ "${scanner,,}" == prismac ]]; then
		cd /data1/prismac_transfer || exit 1
	elif [[ "${scanner,,}" == vida ]]; then
		cd /data1/vida_transfer || exit 1
	else
		printf "\nFalied to run, couldn't find %s directory\n" "${scanner}"
		printf "\n%s\n" "${HELPTEXT}"
		exit 1
	fi
	printf "\n**Successfully found the %s directory**\n" "${scanner}"
}

# Function that enters directory if found in check_scanner function
# and then looks up/matches info provided via medcon and grep
print_output() {
	printf "\n**Changing into %s directory**\n\n" "${scanner}"
	printf "\e[4m%30s | %20s | %10s\e[0m \n" "Folder Name" "PI" "MR Number"
	for i in ./*; do
		cd "${i}" || exit 1
		lastfile=$(find . -type f -name "MR*" | tail -n1)
		# Added if statement to handle no value provided in the ReferringPhysiciansName Tag
		if medcon -f "${lastfile}" 2>/dev/null | grep -e "ReferringPhysiciansName" | grep -q "no value"; then
			ReferringPhysiciansName="no value"
		else
			ReferringPhysiciansName=$(medcon -f "${lastfile}" 2>/dev/null | grep -e "ReferringPhysiciansName" | awk '{print $4}' | sed 's!^\[\(.*\)\]$!\1!')
		fi
		PatientID=$(medcon -f "${lastfile}" 2>/dev/null | grep -e " PatientID" | awk '{print $4}' | sed 's!^\[\(.*\)\]$!\1!')
		if [[ "${filter}" != "" ]]; then
			printf "%30s | %20s | %10s \n" "${i:2}" "${ReferringPhysiciansName}" "${PatientID}" | grep -i "${filter}"
		else
			printf "%30s | %20s | %10s \n" "${i:2}" "${ReferringPhysiciansName}" "${PatientID}"
		fi
		cd ../
	done
	printf "%67s\n" " " | tr " " "-"
	printf "*%27s %s %27s*\n" "" "Thank You" ""
	printf "%67s\n" " " | tr " " "-"
}

main() {
	if [[ "${scanner,,}" == "-h" ]] || [[ "${scanner,,}" == "--help" ]]; then
		printf "\n%s\n" "${HELPTEXT}"
		exit 0
	else
		check_scanner
		print_output
		exit 0
	fi
}

main
