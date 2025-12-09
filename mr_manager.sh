#!/usr/bin/env bash

: <<'Author_Comment'
    Author: Ryan Cool
    Last Updated: 2025-12-09
    Contact: ryan.cool@yale.edu
Author_Comment

Help() {
	underline=$(tput smul)
	nounderline=$(tput rmul)
	bold=$(tput bold)
	normal=$(tput sgr0)
	cat <<EOF
${underline}${bold}Usage:${nounderline} mr_manager (backup | transfer) <scanner> <{pi}>${normal}

	${bold}scanner:${normal}
		prismaa | prismab | prismac | vida

	${bold}pi:${normal}
		esterlis | cosgrove | davis | hillmer | morris

	${bold}examples:${normal}
		mr_manager backup prismaa esterlis
		mr_manager transfer prismab cosgrove
EOF
}

#---Default Values---#
scanner="${2,,}"
pi="${3,,}"
bkup_dir="/data26/mri_group/irina_sophie_data/dicom_backup"
#--------------------#

declare -a file_match
declare -a mris_to_copy

# Checks if there's a match for the pi's study
mr_search() {
	local gather_files
	printf "\nRunning search for %s on %s\n\n" "${pi}" "${scanner}"
	if FindMyStudy.sh "${scanner}" "${pi}" | grep -q "${pi}"; then
		printf "\nFound match for %s on %s\n\n" "${pi}" "${scanner}"
		mapfile -t gather_files < <(FindMyStudy.sh "${scanner}" "${pi}" | grep -i "${pi}" | awk '{print $1}')
		for i in "${gather_files[@]}"; do
			file_match+=("${i}")
		done
		# appends matches to mris_to_copy array
		for i in "${file_match[@]}"; do
			if [[ "${i}" == "${scanner}"* ]]; then
				mris_to_copy+=("${i}")
			fi
		done
	else
		printf "\nNone found for %s on %s!\n\n" "${pi}" "${scanner}"
		exit 0
	fi
}

run_backup() {
	printf "\nInitializing backup process....\n\n"
	printf "\nFound these to copy for %s:\n" "${pi}"
	printf "\n%s\n" "${mris_to_copy[@]}"
	# creates new directory to copy dicoms to if it doesn't exist already
	if [[ -d "${bkup_dir}/${pi}" ]]; then
		cd "${bkup_dir}/${pi}" || exit 1
	else
		mkdir -p "${bkup_dir}/${pi}"
		cd "${bkup_dir}/${pi}" || exit 1
	fi
	for i in "${mris_to_copy[@]}"; do
		if [[ -d "${i}" || -f "${i}".7z ]]; then
			printf "\n%s looks to be backed up already. Skipping.\n\n" "${i}"
		else
			mkdir "${i}"
			printf "\nCopying files for %s\n\n" "${i}"
			rsync -aW --info=progress2 /data1/"${scanner}"_transfer/"${i}"/* "${bkup_dir}/${pi}/${i}/"
		fi
	done
	printf "\nBackup complete!\n\n"
}

run_archive() {
	for i in "${mris_to_copy[@]}"; do
		if [[ -f "${i}".7z ]]; then
			printf "\n%s is already archived. Skipping.\n\n" "${i}"
		else
			printf "\nArchiving: %s\n\n" "${i}"
			7zz a "${i}".7z "${i}"
			rm -r "${i:?}"/
			printf "\nCompleted!\n\n"
		fi
	done
}

run_transfer() {
	printf "\nFound these to copy for %s: %s\n\n" "${pi}": "${mris_to_copy[@]}"
	# copies files from data1 to directory created

	ssh "${USER}@ursapet.med.yale.edu mkdir -p ~/dicom_backup/${pi}"
	for i in "${mris_to_copy[@]}"; do
		printf "\nCopying files for: %s\n\n" "${i}"
		rsync -rvzP /data1/"${scanner}"_transfer/"${i}" "${USER}"@ursapet.med.yale.edu:/home1/"${USER}"/dicom_backup/"${pi}"/
	done
	printf "\nTransfer complete!\n\n"
}

main() {
	if [[ "${#}" -lt 1 ]]; then
		# Will print error if not run correctly
		printf "\nIncorrect usage.\n\n"
		Help
		exit 1
	else
		# Prints usage info if detects help flags
		if [[ "${1}" = "-h" || "${1}" = "--help" ]]; then
			Help
			exit 0
		# Runs function if backup is specified
		elif [[ "${1}" = "backup" ]]; then
			mr_search
			run_backup
			run_archive
		# Runs function if transfer is specified
		elif [[ "${1}" = "transfer" ]]; then
			mr_search
			run_transfer
		else
			# Will print error if first argument isn't correct
			printf "\nBackup or Transfer never specified\n\n"
			Help
			exit 1
		fi
	fi
}

main "${@}"
