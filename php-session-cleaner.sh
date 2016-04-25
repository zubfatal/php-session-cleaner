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
del_cmd="-exec rm -f '{}' \;"

# enable debugging (changes $del_cmd to '-ls')
debug=0

### begin script ###
script_dir=$( dirname ${0} )
session_path_file=${1:-${script_dir}/php-session-cleaner.list}

if [ ${debug:-0} -eq 1 ]; then
        del_cmd="-ls"
fi

for _path in ${session_path} ; do
        if [ -f "${_path}/.php-session-cleaner" ]; then
                _time=$( egrep "^[0-9]+$" "${_path}/.php-session-cleaner" | tail -1 )
        elif [ -f "${session_path_file}" ]; then
                _match=$( egrep "^${_path}\:" "${session_path_file}" )
                _time=$( echo "${_match}" | awk -F":" '{ print $NF }' | sed -r 's/^[^0-9]+//g' )
        fi

        eval "find ${_path} -ignore_readdir_race -type f -iname '${session_mask}' -mmin ${time_prefix}${_time:-${session_lifetime}} ${del_cmd}"
done
