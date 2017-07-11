#!/usr/bin/env bash
###################
# AppInfo
#
#####
# ChangeLog
# ---------
# 2017-05-11  1.3.2      Updated get_app_info() to handle Tcl/Tk.
# 2016-12-21  1.3.1      Cleaned up code a bit. Fixed a minor output bug.
# 2016-12-20  1.3.0      Updated version number RegEx.
#                        Switched back to xargs with echo for trimming.
#                        Restructured app.
# 2016-12-11  1.2.0      Added new label check method. No options...
#                        Now using my trim app instead of xargs.
# 2016-12-11  1.1.0      Now calls fileinfo script for basic file info
# 2016-12-10  1.0.0      Initial script creation
#

#
# APP DATA
#
declare -r APP_NAME='AppInfo'
declare -r APP_VERSION='1.3.2'
declare -r APP_LABEL="$APP_NAME v$APP_VERSION"
declare -r CLI_NAME='appinfo'


#
# CONSTANTS
#

declare -r VERSION_REGEX_RELAXED='([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(\.[0-9]+)?([a-zA-Z0-9_-]+)?'
declare -r VERSION_REGEX_STRICT='([0-9]+)\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-zA-Z0-9_-]+)?'


#
# VARIABLES
#
declare -i exit_code

app_label=''
app_ver=''
file_info=''


#
# FUNCTIONS
#
debug()
{
	# echo "$1" 1>&2
	local msg_fmt="$1"
	local -a args=( "$@" )

	args=( "${args[@]:1}" )

	printf "$msg_fmt\n" "${args[@]}" 1>&2
}


get_app_info()
{
	local -i exit_code
	local -i head_line=${1:-1}
	# debug "get_app_info() | \$app_path: '$app_path' | \$app_name: $app_name | \$head_line: '$head_line'"

	file_info=$(fileinfo "$app_path" | tail -n +2)

	if [[ "$app_name" == 'tclsh' ]]; then
		app_label="Tcl/Tk $(echo 'puts [info patchlevel]; exit 0' | "$app_path")"
		exit_code=$?
		if [[ $exit_code -eq 0 ]]; then
			app_ver=$(get_app_ver "$app_label")
		fi
		debug "get_app_info() | \$app_path: '$app_path' | \$app_name: $app_name | \$app_label: '$app_label' | \$app_ver: $app_ver"
	else
		app_label=$(get_app_label '--version' $head_line)
		# debug "get_app_info() | \$app_path: '$app_path' | \$head_line: '$head_line' | \$app_label: '$app_label'"
		exit_code=$?
		# debug "get_app_info() | \$exit_code: $exit_code | \$app_label: '$app_label'"
		if [[ $exit_code -eq 0 ]]; then
			app_ver=$(get_app_ver "$app_label")
			# debug "get_app_info() | --version | \$exit_code: $exit_code | \$app_ver: '$app_ver'"
		fi

		if [[ $exit_code -ne 0 ]] || [[ "x${app_label}x" == 'xx' ]]; then
			app_label=$(get_app_label '-v' $head_line)
			exit_code=$?
			if [[ $exit_code -eq 0 ]]; then
				app_ver=$(get_app_ver "$app_label")
				# debug "get_app_info() | -v        | \$exit_code: $exit_code | \$app_ver: '$app_ver'"
			fi
		fi

		if [[ $exit_code -ne 0 ]] || [[ "x${app_label}x" == 'xx' ]]; then
			app_label=$(get_app_label '-V' $head_line)
			exit_code=$?
			if [[ $exit_code -eq 0 ]]; then
				app_ver=$(get_app_ver "$app_label")
				# debug "get_app_info() | -V        | \$exit_code: $exit_code | \$app_ver: '$app_ver'"
			fi
		fi

		if [[ $exit_code -ne 0 ]] || [[ "x${app_label}x" == 'xx' ]]; then
			app_label=$(get_app_label "version" $head_line)
			exit_code=$?
			if [[ $exit_code -eq 0 ]]; then
				app_ver=$(get_app_ver "$app_label")
				# debug "get_app_info() | version   | \$exit_code: $exit_code | \$app_ver: '$app_ver'"
			fi
		fi

		if [[ $exit_code -ne 0 ]] || [[ "x${app_label}x" == 'xx' ]]; then
			app_label=$(get_app_label '' $head_line)
			exit_code=$?
			if [[ $exit_code -eq 0 ]]; then
				app_ver=$(get_app_ver "$app_label")
				# debug "get_app_info() | no option | \$exit_code: $exit_code | \$app_ver: '$app_ver'"
			fi
		fi

		if [[ $exit_code -ne 0 ]] || [[ "x${app_label}x" == 'xx' ]]; then
			app_ver=$(get_symlink_ver)
			exit_code=$?
		fi
	fi

	# debug "get_app_info() | \$exit_code: $exit_code | \$app_label: '$app_label'"

	if [[ $exit_code -eq 0 ]] && [[ "x${app_label}x" != 'xx' ]]; then
		# echo "  App Label:   '$app_label'"
		echo "  App Label:   $app_label"
	fi

	if [[ "x${app_ver}x" != 'xx' ]]; then
		echo "  App Version: $app_ver"
	fi

	echo "$file_info"
	echo

	return $exit_code
}


get_app_label()
{
	# debug "get_app_label() | \$#: $#"

	local -i exit_code
	local -i head_line="${2:-1}"
	local app_label=""
	local option="$1"

	# debug "get_app_label() | \$head_line: $head_line | \$option: $option"

	if [[ "x${option}x" == 'xx' ]]; then
		app_label=$("$app_path" 2> /dev/null)
	else
		app_label=$("$app_path" "$option" 2> /dev/null)
	fi
	
	exit_code=$?
	# debug "get_app_label() | %s %s | \$exit_code: %d | \$app_label: '%s'" "$app_path" "$option" $exit_code "$app_label"
	if [[ $exit_code -eq 0 ]]; then
		# app_label=$(echo "$app_label" | head "-$head_line" | xargs echo)
		app_label=$(echo "$app_label" | head "-$head_line" | xargs echo | perl -pe 's/\x1b\[[0-9;]*[mG]//g') # Perl bit needed for ANSI removal from tools like XMake
		# debug "get_app_label() | %s %s | \$app_label: '%s'" "$app_path" "$option" "$app_label"
		echo "$app_label"
		return 0
	else
		return 1
	fi
}


get_app_ver()
{
	local app_label="$1"

	if [[ "$app_label" =~ $VERSION_REGEX_STRICT ]]; then
		app_ver="${BASH_REMATCH[0]}"
	elif [[ "$app_label" =~ $VERSION_REGEX_RELAXED ]]; then
		app_ver="${BASH_REMATCH[0]}"
	else
		# app_ver=$(echo "$app_label" | rev | cut -d' ' -f1 | rev)
		# debug "get_app_ver() | no regex match"
		return 1
	fi

	echo "$app_ver"
	return 0
}


get_symlink_ver()
{
	local -i exit_code=1
	local app_ver=''
	local path=$(echo "$file_info" | tail -1 | head -1 | xargs echo)
	local symlink=( $path )

	if [[ "${symlink[0]}" == 'Symlink' ]]; then
		# debug "get_symlink_ver() | is symlink"
		if [[ "$path" =~ $VERSION_REGEX_RELAXED ]]; then
			# debug "get_symlink_ver() | \${BASH_REMATCH[0]}: ${BASH_REMATCH[0]}"
			app_ver="${BASH_REMATCH[0]}"

			if [[ "x${app_ver}x" != '' ]]; then
				exit_code=0
			fi
		fi
	fi
	
	echo "$app_ver"
	return $exit_code
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

	if [[ -e "$1" ]]; then
		app_path="$1"
		app_name="$(basename "$app_path")"
		get_app_info 1
	else
		for app_path in $(which -a $1); do
			app_name="$(basename "$app_path")"
			get_app_info 1

			# if [[ $? -ne 0 ]] && [[ "$app_label" = '' ]]; then
			# 	get_app_info 2
			# fi
		done
	fi
fi

