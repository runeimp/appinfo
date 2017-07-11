#!/usr/bin/env bash
###################
# fileinfo
#
#####
# ChangeLog
# ---------
# 2017-01-22  1.2.0      Now can handle files provided with full path
# 2016-12-11  1.0.0      Initial script creation
#


#
# APP DATA
#
declare -r APP_NAME='FileInfo'
declare -r APP_VERSION='1.2.0'
declare -r APP_LABEL="$APP_NAME v$APP_VERSION"
declare -r CLI_NAME='fileinfo'


#
# VARIABLES
#
declare -i exit_code
declare -i file_size
declare -i hard_link

file_type=''
link_data=''
real_path=''


#
# FUNCTIONS
#
get_file_size()
{
	local -i file_size
	local file_path="$1"
	local file_type=$(stat -f '%HT' "$file_path")
	local dir_path=$(dirname "$file_path")

	file_size=$(stat -f%z "$file_path")
	# echo "get_file_size() | file_size: $file_size" 1>&2
	echo $file_size
}

get_real_path()
{
	local -i file_size
	local file_path="$1"
	local file_type=$(stat -f '%HT' "$file_path")
	local dir_path=$(dirname "$file_path")
	local real_path="$file_path"

	while [[ "$file_type" = 'Symbolic Link' ]]; do
		real_path=$(stat -f '%Y' "$real_path")
		cd "$dir_path"
		real_path=$(realpath "${real_path}")
		dir_path=$(dirname "$real_path")
		file_type=$(stat -f '%HT' "$real_path")
	done
	# echo "get_real_path() | file_path: $file_path" 1>&2
	# echo "get_real_path() | dir_path: $dir_path" 1>&2
	# echo "get_real_path() | real_path: $real_path" 1>&2
	echo "$real_path"
}

get_file_info()
{
	app_path="$1"

	file_type=$(stat -f '%HT' "$app_path")
	hard_link=$(stat -f '%l' "$app_path")
	if [[ "$file_type" = 'Symbolic Link' ]]; then
		file_type='Symlink to:  '
		link_data=$(get_real_path "$app_path")
		file_size=$(get_file_size "$link_data")
		# link_data=$(stat -f '%Y' "$app_path")
	else
		if [[ "$file_type" = 'Regular File' ]]; then
			file_type=''
		else
			file_type="${file_type}: "
		fi
		if [[ $hard_link -gt 1 ]]; then
			link_data="$hard_link hardlink copies"
		else
			link_data=''
		fi
		file_size=$(get_file_size "$app_path")
	fi

	echo "  File Path:   $app_path"
	if [[ $file_size -gt 1023 ]]; then
		echo "  File Size:   $(byteit $file_size) or $file_size Bytes"
	else
		echo "  File Size:   $file_size Bytes"
	fi
	if [[ "x${link_data}x" != 'xx' ]]; then
		echo "  ${file_type}$link_data"
	fi
	echo
}


#
# MAIN
#
if [[ $# -eq 0 ]]; then
	echo "$APP_LABEL"
	echo
	echo "Please specify the app name to get info for."
	echo
else
	echo
	until [[ $# -eq 0 ]]; do
		if [[ -e "$1" ]]; then
			get_file_info "$1"
		else
			for app_path in $(which -a $1); do
				get_file_info "$app_path"
			done
		fi

		shift
	done
fi

