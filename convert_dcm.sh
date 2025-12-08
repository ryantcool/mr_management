#!/usr/bin/env bash

#----------Default Values----------#
subj_pattern=".*[0-9]{4}_[a-z]{2}[0-9]{3}.*"
cwd=$(pwd)
#----------------------------------#

Help() {
	# Display Help Message
	cat <<EOF
Usage: ${0##*/} [options]
 	
Options:
	-d <arg>    Set directory to search (default: current directory)
	-s <arg>    Search pattern to use (default: .*[0-9]{4}_[a-z]{2}[0-9]{3}.*)
	-h          Displays this help message
	
Examples:
	${0##*/}
	${0##*/} -s 20250101_ab123
	${0##*/} -d /path/to/data
	${0##*/} -d /path/to/data -s 20250101_ab123
EOF
}

parse_args() {
	while getopts "hd:s:" option; do
		case "${option}" in
		h)
			Help
			exit 1
			;;
		d)
			if [[ -z "${OPTARG}" ]]; then
				printf "\n-d requires a non-empty argument\n\n"
				exit 1
			fi
			cwd="${OPTARG}"
			;;
		s)
			if [[ -z "${OPTARG}" ]]; then
				printf "\n-s requires a non-empty argument\n\n"
				exit 1
			fi
			subj_pattern=".*${OPTARG}.*"
			;;
		?)
			Help
			exit 1
			;;
		esac
	done

}

gather_files() {
	# Set subj_pattern matched dirs inside cwd to array
	mapfile -t subjects < <(find "${cwd}" -maxdepth 1 -type d -regextype posix-extended -regex "${subj_pattern}")
	if [[ ! "${subjects[*]}" ]]; then
		printf "\nNo subject(s) matching:\n\n%s\n\nin\n\n%s\n\n" "${subj_pattern}" "${cwd}"
		exit 1
	fi
}

# Check if nifti folder exists inside
# subject mr folder and make it if not
check_nifti() {
	local sub_dir="${1}"
	if [[ -d "${sub_dir}"/nifti ]]; then
		printf "\nNifti folder already exists, skipping\n"
		return 0
	else
		printf "\nCreating nifti folder\n"
		mkdir -p "${sub_dir}"/nifti || exit 1
		return 1
	fi
}

# dcm2niix wrapper function to be used
# in for loop
tonifti() {
	local output_dir="${1}"
	local dicom_dir="${2}"
	/home1/rtc29/.local/bin/dcm2niix -f %i_%p_S%s -z y -o "${output_dir}" "${dicom_dir}"
}

main() {
	parse_args "${@}"
	gather_files
	for i in "${subjects[@]}"; do
		printf "\nRunning for %s\n" "${i}"
		if [[ -d "${i}"/3d_dicom_orig ]]; then
			# If nifti dir doesn't exist then
			# create and run tonifti function
			if ! check_nifti "${i}"; then
				printf "\nStarting conversion of 3d_dicom_orig files for %s\n\n" "${i}"
				tonifti "${i}"/nifti "${i}"/3d_dicom_orig
			fi
		elif [[ -d "${i}"/3d_dicom ]]; then
			# If nifti dir doesn't exist then
			# create and run tonifti function
			if ! check_nifti "${i}"; then
				printf "\nStarting conversion of 3d_dicom files for %s\n\n" "${i}"
				tonifti "${i}"/nifti "${i}"/3d_dicom
			fi
		else
			printf "\nFailed to locate 3d_dicom | 3d_dicom_orig dirs in %s\n" "${i}"
			continue
		fi
	done
}

main "${@}"
