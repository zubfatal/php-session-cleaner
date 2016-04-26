#!/usr/bin/env bash

# path(s) containing session data
session_path="/var/www/*/tmp"

# session lifetime in minutes
session_lifetime=24

# session filename mask
session_mask="sess_*"

# time prefix (see: man find)
time_prefix="+"

# delete command
del_cmd="-print0 | xargs -0 -r rm -f"

# enable debugging (changes $del_cmd to '-ls')
debug=0

# find files and list (debug) or delete them
function process_files()
{
    local _path=$1
    local _time=$2

    eval "find ${_path} -ignore_readdir_race -type f -mmin ${time_prefix}${_time} -iname '${session_mask}' ${del_cmd}"
}

# get session lifetime value from file
function get_session_lifetime_from_file()
{
    local _file=${1}
    local _ret=""

    if [ -f ${_file} ]; then
        _ret=$( egrep "^[0-9]+$" ${_file} | head -n1 | sed -r 's/^[0-9]+//g' )
    fi

    echo ${_ret}
}


### begin script ###
script_dir=$( dirname ${0} )
session_path_file=${1:-${script_dir}/php-session-cleaner.list}

if [ ${debug:-0} -eq 1 ]; then
    del_cmd="-ls"
fi


# $session_path_file exists
if [ -f "${session_path_file}" ]; then

    OIFS=$IFS
    IFS=$'\n'

    for _line in $( egrep "^/" ${session_path_file} ) ; do
        _path=$( echo "${_line}" | awk -F":" '{ print $1 }' )
        _file_time=$( echo "${_line}" | awk -F":" '{ print $NF }' | sed -r 's/^([0-9]+)(.*)$/\1/g' )
        _path_time=$( get_session_lifetime_from_file ${_path}/.php-session-cleaner )

        [[ ! -d "${_path}" ]] && continue

        # no time provided in file
        [[ "${_path}" == "${_file_time}" ]] && _file_time=${session_lifetime}

        # no override found in .php-session-cleaner
        [[ -z "${_path_time}" ]] && _time=${_file_time} || _time=${_path_time}

        # process files if _time > 0 otherwise, don't clean
        [[ ${_time} -gt 0 ]] && process_files "${_path}" ${_time}

    done

    IFS=$OIFS

else
    
    # $session_path_file argument not given, use default $session_path

    for _path in ${session_path} ; do
        [[ ! -d ${_path} ]] && continue

        # check override file
        _path_time=$( get_session_lifetime_from_file ${_path}/.php-session-cleaner )
        [[ -z "${_path_time}" ]] && _time=${session_lifetime} || _time=${_path_time}

        # process files if _time > 0 otherwise, don't clean
        [[ ${_time} -gt 0 ]] && process_files "${_path}" ${_time}
    done

fi

