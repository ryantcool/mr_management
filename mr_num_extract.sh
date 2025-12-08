#!/usr/bin/env bash

parse_args() {
	if [[ $# -eq 0 ]]; then
		printf "\nNo subject specified\n\n"
		exit 1
	fi
	subject="${1}"
}

check_match() {
	# Set potential matches to array
	matches=(/pet/data/*_mr/*"${subject}")
	local tmp_dir=""
	subj_dir=""
	if [[ -d "${matches[0]}" ]]; then
		tmp_dir=("${matches[@]}")
	else
		printf "\nNo matches found for %s in /pet/data/*_mr\n\n" "${subject}"
		exit 1
	fi
	if [[ "${#tmp_dir[@]}" -gt 1 ]]; then
		printf "\nThere's more than one file, which would you like to use?\n"
		ndx=0
		for i in "${tmp_dir[@]}"; do
			printf "\n%s: %s\n" "${ndx}" "${i}"
			((ndx = ndx + 1))
		done
		read -rp $'\nEnter number of mr you want: ' number
		subj_dir="${tmp_dir["${number}"]}"
	elif [[ ${#tmp_dir[@]} == 1 ]]; then
		subj_dir="${tmp_dir[0]}"
	else
		printf "\n\nsubject not in data8\n\n"
		exit 1
	fi
}

dcm_parser() {
	if [[ -d "${subj_dir}/3d_dicom" ]]; then
		file_path=("${subj_dir}"/3d_dicom/MR*)
		file=${file_path[0]}
		output=$(grep -aoziE -m1 "\b[ptv][abcd][[:digit:]]+\b" "${file}" | tr '\0' '\n')
		printf "\nMR Number is: %s\nMR Location: %s\n\n" "${output}" "${subj_dir}"
	else
		printf "\n3d_dicom dir not found for %s\n\n" "${subj_dir}"
		exit 1
	fi
}

main() {
	parse_args "${@}"
	check_match
	dcm_parser
}

main "${@}"
