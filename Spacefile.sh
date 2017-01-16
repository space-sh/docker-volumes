#
# Copyright 2017 Blockie AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

clone os file docker conf string

#======================
# DOCKER_VOLUMES_DEP_INSTALL
#
# Verify that Docker Engine is
# installed otherwise install it.
#
# Parameters:
#   $1: user to add to docker group.
#
# Expects:
#   ${SUDO}: set to "sudo" to run as sudo.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_VOLUMES_DEP_INSTALL()
{
    SPACE_SIGNATURE="targetuser"
    SPACE_DEP="PRINT OS_IS_INSTALLED DOCKER_INSTALL"

    local targetuser="${1}"
    shift

    if OS_IS_INSTALLED "docker"; then
        PRINT "Docker is already installed. To reinstall run: space -m docker /install/." "ok"
    else
        DOCKER_INSTALL "${targetuser}"
    fi
}

#======================
# DOCKER_VOLUMES_INSTALL
#
# Install latest Docker and make it available to the user.
#
# Parameters:
#   $1: user to add to docker group.
#
# Expects:
#   ${SUDO}: set to "sudo" to run as sudo.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_VOLUMES_INSTALL()
{
    SPACE_SIGNATURE="targetuser"
    SPACE_DEP="PRINT DOCKER_INSTALL"

    local targetuser="${1}"
    shift

    DOCKER_INSTALL "${targetuser}"
}

#=====================
# DOCKER_VOLUMES_CREATE
#
# docker volume create.
#
# Parameters:
#   $1: name of volume
#   $2: driver, optional.
#   $3: opts, optional
#   $4: label, optional.
#
# Returns:
#   non-zero on error
#
#=====================
DOCKER_VOLUMES_CREATE()
{
    SPACE_SIGNATURE="name [driver opts label]"
    SPACE_DEP="PRINT"

    local name="${1}"
    shift

    local driver="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local opts="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # TODO allow for more than one label.
    local label="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    PRINT "Create Docker volume" "debug"
    # shellcheck disable=2086
    docker volume create --name "${name}" ${driver:+--driver ${driver}} ${opts:+--opt ${opts}} ${label:+--label ${label}}
}

#=======================
# DOCKER_VOLUMES_ENTER
#
# Enter into a docker container where the
# volume is mounted.
#
# This command will get wrapped and run inside a temporary container.
#
# Parameters:
#   $1: name of volume
#
# Returns:
#   non-zero on error
#
#======================
DOCKER_VOLUMES_ENTER()
{
    SPACE_SIGNATURE="name"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_ENTER_IMPL"
    SPACE_WRAP="DOCKER_RUN_WRAP"

    local name="${1}"
    shift

    # These variables will get exported.
    image="alpine"
    flags="-it --rm -v ${name}:/mountvol"
    container=
    cmd="sh -c"

    SPACE_ARGS="\"/mountvol\""
}

#=============================
# _DOCKER_VOLUMES_ENTER_IMPL
#
# The implementation for DOCKER_VOLUMES_ENTER.
#
#=============================
_DOCKER_VOLUMES_ENTER_IMPL()
{
    SPACE_SIGNATURE="targetdir"
    SPACE_DEP="PRINT"

    local targetdir="${1}"
    shift

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    cd "${targetdir}" &&
    SPACE_FNNAME=""
    PRINT "Here we are, behold your volume and all it's files." "ok"
    PRINT "Changes you make to files will stick." "ok"

    sh
}

#=======================
# DOCKER_VOLUMES_FILELIST
#
# List all files inside a volume from within a container.
#
# This command will get wrapped and run inside a temporary container.
#
# Parameters:
#   $1: name of volume
#
# Returns:
#   non-zero on error
#
# Outputs:
#   File list
#
#======================
DOCKER_VOLUMES_FILELIST()
{
    SPACE_SIGNATURE="name"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_FILELIST_IMPL"
    SPACE_WRAP="DOCKER_RUN_WRAP"

    local name="${1}"
    shift

    # These variables will get exported.
    image="alpine"
    flags="-i --rm -v ${name}:/mountvol"
    container=
    cmd="sh -c"

    SPACE_ARGS="\"/mountvol\""
}

#=============================
# _DOCKER_VOLUMES_FILELIST_IMPL
#
# The implementation for DOCKER_VOLUMES_FILELIST.
#
#=============================
_DOCKER_VOLUMES_FILELIST_IMPL()
{
    SPACE_SIGNATURE="targetdir"
    SPACE_DEP="PRINT"

    local targetdir="${1}"
    shift

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    ls -laR "${targetdir}"
}

#======================
# DOCKER_VOLUMES_CHMOD
#
# Set the permissions of the mountpoint of a volume.
# This function will mount the volume inside a container and
# then chmod/chown the mount point.
#
# This command will get wrapped and run inside a temporary container.
#
# Parameters:
#   $1: name of volume
#   $2: chmod
#   $3: chown, optional.
#
# Returns:
#   non-zero on error
#
#=====================
DOCKER_VOLUMES_CHMOD()
{
    SPACE_SIGNATURE="name chmod [chown]"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_CHMOD_IMPL"
    SPACE_WRAP="DOCKER_RUN_WRAP"

    local name="${1}"
    shift

    local chmod="${1}"
    shift

    local chown="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # These variables will get exported.
    image="alpine"
    flags="-i --rm -v ${name}:/mountvol"
    container=
    cmd="sh -c"

    SPACE_ARGS="\"/mountvol\" \"${chmod}\" \"${chown}\""
}

#=====================
# _DOCKER_VOLUMES_CHMOD_IMPL
#
# The implementation for DOCKER_VOLUMES_CHMOD.
#
#=====================
_DOCKER_VOLUMES_CHMOD_IMPL()
{
    SPACE_SIGNATURE="targetdir chmod [chown]"
    SPACE_DEP="PRINT"

    local targetdir="${1}"
    shift

    local _chmod="${1}"
    shift

    local _chown="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    if [ -n "${_chmod}" ]; then
        PRINT "chmod dir: ${targetdir} ${_chmod}."
        chmod "${_chmod}" "${targetdir}"
    fi

    if [ -n "${_chown}" ]; then
        PRINT "chown dir: ${targetdir} ${_chown}."
        chown "${_chown}" "${targetdir}"
    fi
}

#=====================
# DOCKER_VOLUMES_INSPECT
#
# Inspect a volume.
#
# Parameters:
#   $@: volume name
#
#=====================
DOCKER_VOLUMES_INSPECT()
{
    SPACE_SIGNATURE="name [name]"
    SPACE_DEP="PRINT"

    local name="${1}"
    shift

    PRINT "Volume inspect for: ${name}"

    local s=
    if ! s="$(docker volume inspect ${name})"; then
        return 1
    fi

    printf "%s\n" "${s}"
}

#=====================
# DOCKER_VOLUMES_RM
#
# Remove one or more docker volumes.
#
# Parameters:
#   $@: volume names
#
#=====================
DOCKER_VOLUMES_RM()
{
    SPACE_SIGNATURE="name [name]"
    SPACE_DEP="PRINT"

    PRINT "Remove volume(s): ${*}."
    docker volume rm "${@}"
}

#=====================
# DOCKER_VOLUMES_LS
#
# List docker volumes
#
# Parameters:
#   $@: options
#
#=====================
DOCKER_VOLUMES_LS()
{
    SPACE_SIGNATURE="[options]"
    if [ "$#" -gt 0 ]; then
        docker volume ls "${@}"
    fi
}

#=====================
# DOCKER_VOLUMES_EXISTS
#
# Check so that a volume exists.
#
# Parameters:
#   $1: name of volume
#
#=====================
DOCKER_VOLUMES_EXISTS()
{
    SPACE_SIGNATURE="name"

    local name="${1}"
    shift

    if ! docker volume inspect "${name}" >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

#=====================
# DOCKER_VOLUMES_INSPECT
#
# Run docker volume inspect
#
# Parameters:
#   $@: options
#
#=====================
DOCKER_VOLUMES_INSPECT()
{
    SPACE_SIGNATURE="name [args]"
    docker volume inspect "${@}"
}

#======================
# DOCKER_VOLUMES_RESTORE
#
# Restore a tar.gz archive or local dir into a volume,
# possibly delete all files in volume first.
#
# If archive is local dir, beware of permissions, all files
# will be extracted as root:root, which may brake stuff if
# your applications runs as any other user than root.
# However when restoring a snapshotted tar.gz archive then
# permissions are preserved.
#
# If using $useacl=1, which is the default, then a permissions
# dump is taken of the target directory and is used to restore
# permissions after the snapshot have been extracted.
#
# This command will get wrapped and run inside a temporary container.
#
# Parameters:
#   $1: name of the volume
#   $2: archive, either path to tar.gz file, path to a directory or '-' for stdin.
#   $3: empty: set to '1' to first delete all files in volume before restoring, optional.
#   $4: preservepermissions, set to '1' to preserve permissions of existing file in the volume. optional, default is '1'.
#
# Returns;
#   non-zero on error
#
#=====================
DOCKER_VOLUMES_RESTORE()
{
    SPACE_SIGNATURE="name archive.tar.gz|dir|- [empty preservepermissions]"
    SPACE_FN="_DOCKER_VOLUMES_RESTORE_IMPL"
    SPACE_WRAP="DOCKER_RUN_WRAP"

    local name="${1}"
    shift

    # Global due to possible import.
    archive="${1}"
    shift

    local empty="${1:-0}"
    shift $(( $# > 0 ? 1 : 0 ))

    local preservepermissions="${1:-1}"
    shift $(( $# > 0 ? 1 : 0 ))

    local targetdir="/tmpmount"

    # This variable will get exported.
    flags="-i --rm -v ${name}:${targetdir}"
    image="alpine"
    container=
    cmd="sh -c"

    if [ "${archive}" = "-" ]; then
        if [ -t "0" ]; then
            PRINT "OMG STDIN is a terminal! I was totally expecting a tar.gz stream." "error"
            return 1
        fi
    else
        if [ -d "${archive}" ]; then
            SPACE_OUTER="_DOCKER_VOLUMES_RESTORE_OUTER"
            SPACE_OUTERARGS="${archive}"
            SPACE_REDIR="<\${archive}"
        else
            SPACE_REDIR="<${archive}"
        fi
    fi

    SPACE_ARGS="\"${targetdir}\" \"${empty}\" \"${preservepermissions}\""
}

#=============================
#
# _DOCKER_VOLUMES_RESTORE_OUTER
#
# Helper to archive directory into STDIN.
#
#=============================
_DOCKER_VOLUMES_RESTORE_OUTER()
{
    SPACE_SIGNATURE="dir"

    local dir="${1}"
    shift

    local tempfile="/tmp/space.$$"
    PRINT "Creating temporary archive: ${tempfile} for directory: ${dir}."
    tar -czf $tempfile -C $dir .

    local archive="$tempfile"  # This will be in the redirection.
    _CMD_
    rm ${tempfile}
}

#=====================
# _DOCKER_VOLUMES_RESTORE_IMPL
#
# Used dy DOCKER_VOLUMES_RESTORE command
#
#=====================
_DOCKER_VOLUMES_RESTORE_IMPL()
{
    SPACE_SIGNATURE="targetdir empty preservepermissions"
    SPACE_DEP="PRINT FILE_GET_PERMISSIONS FILE_RESTORE_PERMISSIONS"

    local targetdir="${1}"
    shift

    local empty="${1}"
    shift

    local preservepermissions="${1}"
    shift

    if [ -t "0" ]; then
        PRINT "OMG STDIN is a terminal! I was so expecting a tar.gz stream." "error"
        return 1
    fi

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    if [ "${empty}" = "1" ]; then
        PRINT "Emptying volume."
        rm -rf "${targetdir:?}/"* 2>/dev/null
    fi

    local permissions=
    if [ "${preservepermissions}" = "1" ]; then
        permissions="$(FILE_GET_PERMISSIONS "${targetdir}")"
    fi

    PRINT "tar -xz -C ${targetdir}" "debug"

    PRINT "Restore archive into volume"
    tar -xz -C "${targetdir}"
    if [ "$?" -gt 0 ]; then
        PRINT "Error for tar -xz -C ${targetdir}" "error"
        return 1
    fi

    if [ "${preservepermissions}" = "1" ]; then
        FILE_RESTORE_PERMISSIONS "${targetdir}" "${permissions}"
    fi
}

#======================
# DOCKER_VOLUMES_EMPTY
#
# Delete all files in a volume.
#
# This command will be wrapped to be run inside a temporary container
#
# Parameters:
#   $1: name, the name of docker volume to empty of files.
#
# Returns:
#   non-zero on error
#
#=====================
DOCKER_VOLUMES_EMPTY()
{
    SPACE_SIGNATURE="name"
    SPACE_FN="_DOCKER_VOLUMES_EMPTY_IMPL"
    SPACE_WRAP="DOCKER_RUN_WRAP"

    local name="${1}"
    shift

    local targetdir="/tmpmount"

    # This variable will get exported.
    image="alpine"

    # This variable will get exported.
    flags="-i --rm -v ${name}:${targetdir}"
    container=
    cmd="sh -c"

    PRINT "Emptying volume: ${name}."
    SPACE_ARGS="\"${targetdir}\""
}

#=====================
# _DOCKER_VOLUMES_EMPTY_IMPL
#
# Used by DOCKER_VOLUMES_EMPTY
#
#=====================
_DOCKER_VOLUMES_EMPTY_IMPL()
{
    SPACE_SIGNATURE="targetdir"
    # shellcheck disable=2034
    SPACE_DEP="PRINT"

    local targetdir="${1}"
    shift

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    rm -rf "${targetdir:?}/"* 2>/dev/null
}

#=======================
# DOCKER_VOLUMES_SNAPSHOT
#
# Archive all files inside volume into a tar.gz archive or to stdout.
#
# Parameters:
#   $1: name, the name of the docker volume to snapshot.
#   $2: archive, either path to tar.gz file, path to a directory or '-' for stdout.
#
#=======================
DOCKER_VOLUMES_SNAPSHOT()
{
    SPACE_SIGNATURE="name archive.tar.gz|dir|-"
    # shellcheck disable=2034
    SPACE_WRAP="DOCKER_RUN_WRAP"
    # shellcheck disable=2034
    SPACE_FN="_DOCKER_VOLUMES_SNAPSHOT_IMPL"

    local name="${1}"
    shift

    local archive="${1}"
    shift

    local targetdir="/tmpmount"

    # This variable will get exported.
    image="alpine"
    flags="-i --rm -v ${name}:${targetdir}"
    container=
    cmd="sh -c"

    if [ "${archive}" = "-" ]; then
        if [ -t 1 ]; then
            PRINT "[error] OMG STDOUT is a terminal! You do not want this." "error"
            return 1
        fi
    else
        if [ -d "${archive}" ]; then
            # shellcheck disable=2034
            SPACE_REDIR="| tar -xzf - -C ${archive}"
        else
            # shellcheck disable=2034
            SPACE_REDIR=">${archive}"
        fi
    fi

    # shellcheck disable=2034
    SPACE_ARGS="${targetdir}"
}

#=======================
# _DOCKER_VOLUMES_SNAPSHOT_IMPL
#
# USed by DOCKER_VOLUMES_SNAPSHOT
#
##=======================
_DOCKER_VOLUMES_SNAPSHOT_IMPL()
{
    # shellcheck disable=2034
    SPACE_SIGNATURE="targetdir"
    # shellcheck disable=2034
    SPACE_DEP="PRINT"

    local targetdir="${1}"
    shift

    if [ -t "1" ]; then
        PRINT "OMG STDOUT is a terminal! We are so different, you and I." "error"
        return 1
    fi

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    cd "${targetdir}" && tar -cvz .
}

#==============================
#
# _DOCKER_VOLUMES_OUTER_UP
#
# The outer function of DOCKER_VOLUMES_UP
#
#==============================
_DOCKER_VOLUMES_OUTER_UP()
{
    SPACE_SIGNATURE="conffile [prefix]"
    SPACE_DEP="STRING_SUBST CONF_READ"

    local conffile="${1}"
    shift

    local prefix="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # We save the wrapped CMD because we want to alter it in each iteration.
    local CMD_ORIGINAL="${CMD}"

    local conf_lineno=0
    while true; do
        local name=
        local driver=
        local archive=
        local chmod=
        local chown=
        local empty=

        if ! CONF_READ "${conffile}" "name driver archive chmod chown empty"; then
            PRINT "Could not read conf file: ${conffile}." "error"
            return 1
        fi

        PRINT "Populate volume: ${prefix}${name}."

        # This variable will be used by the wrapper to run the container.
        local flags="-i --rm -v ${prefix}${name}:/volume"

        # Figure out the redir value for ${archive}:
        local tempfile=
        local usearchive=0
        if [ -n "${archive}" ]; then
            if [ -d "${archive}" ]; then
                # We'll create a temporary archive of the directory given.
                tempfile="/tmp/space.$$"
                PRINT "Creating temporary archive: ${tempfile} for directory: ${archive}."
                tar -czf $tempfile -C $archive .
                archive="$tempfile"
            else
                # We assume it's a tar.gz archive.
                archive="${archive}"
            fi
            usearchive=1
        else
            archive="/dev/null"
        fi

        CMD="${CMD_ORIGINAL}"
        STRING_SUBST "CMD" "{TARGETDIR}" "/volume"
        STRING_SUBST "CMD" "{CHMOD}" "${chmod}"
        STRING_SUBST "CMD" "{CHOWN}" "${chown}"
        STRING_SUBST "CMD" "{EMPTY}" "${empty}"
        STRING_SUBST "CMD" "{ARCHIVE}" "${usearchive}"

        _CMD_

        if [ -n "${tempfile}" ]; then
            PRINT "Removing temporary archive."
            rm "${tempfile}"
        fi

        if [ "${conf_lineno}" -eq 0 ]; then
            # Read done
            break
        fi
    done
}

#=======================
# DOCKER_VOLUMES_UP
#
# Create and populate docker volumes defined
# in conf file.
#
# The conffile is a key value based tex file, as:
#   name    volume name
#   archive directory|file.tar.gz (or empty) to populate the volume with.
#   empty   set to 1 to have the volume cleared out.
#   driver  drover to use, default is "local".
#   chmod   set to have the mountpoint be given those permissions.
#   chown   set to have the mountpoint be owned by that user:group.
#
# Parameters:
#   $1: conffile The path to the conf file describing the volumes.
#   $2: optional name of composition, set to match a docker composition.
#       if unset name will be taken from conffile name if its format
#       is "name_docker-volumes.conf".
#       An underscore "_" will be appended to the name, just as Docker does
#       with volumes created with docker-compose.
#
# Returns:
#   non-zero on error.
#
#=======================
DOCKER_VOLUMES_UP()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile [name]"
    # shellcheck disable=SC2034
    SPACE_FN="_DOCKER_VOLUMES_UP_IMPL"
    # shellcheck disable=SC2034
    SPACE_WRAP="DOCKER_RUN_WRAP"
    # shellcheck disable=SC2034
    SPACE_REDIR="<\$archive"
    # shellcheck disable=SC2034
    SPACE_OUTER="_DOCKER_VOLUMES_OUTER_UP"
    SPACE_DEP="STRING_SUBST"

    local conffile="${1}"
    shift

    local name=""
    if [ ! "${1+set}" = "set" ]; then
        name="${conffile%.conf*}"
        name="${name##*/}"
        name="${name%%_docker-volumes}"
        # Make name docker friendly.
        STRING_SUBST "name" "-" "" 1
        STRING_SUBST "name" "_" "" 1
        STRING_SUBST "name" "." "" 1
    else
        # Prefix is given, could be "".
        local name="${1}"
        shift
    fi
    name="${name:+${name}_}"

    SPACE_OUTERARGS="\"${conffile}\" \"${name}\""

    # These variables will get exported.
    # shellcheck disable=SC2034
    image="alpine"
    container=
    flags=
    cmd="sh -c"

    # These arguments will get substituted by STRING_SUBST in CMDOUTER.
    SPACE_ARGS="\"{TARGETDIR}\" \"{CHMOD}\" \"{CHOWN}\" \"{EMPTY}\" \"{ARCHIVE}\""
}

#============================
# _DOCKER_VOLUMES_UP_IMPL
#
# Implementation for DOCKER_VOLUMES_UP
#
# Parameters:
#   $1: targetdir: the directory inside the container to where the volume is mounted.
#   $2: chmod: permissions to set the directory to, optional.
#   $3: chown: set owner of the directory, optional.
#   $4: empty: set to "true" to rm -rf the directory contents. WARNING!
#   $5: archive: Set to "1" to indicate that a tar.gz stream is piped on STDIN.
#
# Returns:
#   non-zero on error
#
#============================
_DOCKER_VOLUMES_UP_IMPL()
{
    SPACE_SIGNATURE="targetdir chmod chown empty archive"
    SPACE_DEP="_DOCKER_VOLUMES_CHMOD_IMPL _DOCKER_VOLUMES_RESTORE_IMPL"

    local targetdir="${1}"
    shift

    local _chmod="${1}"
    shift

    local _chown="${1}"
    shift

    local empty="${1}"
    shift

    local archive="${1}"
    shift

    if [ -n "${_chmod}" ] || [ -n "${_chown}" ]; then
        _DOCKER_VOLUMES_CHMOD_IMPL "${targetdir}" "${_chmod}" "${_chown}"
        if [ "$?" -gt 0 ]; then
            return 1
        fi
    fi

    if [ "${empty}" = "1" ]; then
        PRINT "Emptying volume."
        rm -rf "${targetdir:?}/"* 2>/dev/null
        if [ "$?" -gt 0 ]; then
            return 1
        fi
    fi

    if [ "${archive}" -eq 1 ]; then
        _DOCKER_VOLUMES_RESTORE_IMPL "${targetdir}" "" "true"
        if [ "$?" -gt 0 ]; then
            return 1
        fi
    fi
}

#==============================
#
# _DOCKER_VOLUMES_OUTER_DOWN
#
# The outer function of DOCKER_VOLUMES_DOWN
#
#==============================
_DOCKER_VOLUMES_OUTER_DOWN()
{
    SPACE_SIGNATURE="conffile [prefix]"
    SPACE_DEP="CONF_READ"

    local conffile="${1}"
    shift

    local prefix="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local conf_lineno=0
    while true; do
        local name=
        local driver=

        if ! CONF_READ "${conffile}" "name driver"; then
            PRINT "Could not read conf file: ${conffile}." "error"
            return 1
        fi

        name="${prefix}${name}"

        # We here have block of variables from conf file.
        PRINT "Remove volume: ${name}."

        _CMD_

        if [ "${conf_lineno}" -eq 0 ]; then
            # Read done
            break
        fi
    done
}

#=======================
# DOCKER_VOLUMES_DOWN
#
# Delete docker volumes defined in conf file.
#
# The conf file is a key value based tex file, as:
#   name    volume name
#   archive directory|file.tar.gz (or empty) to populate the volume with.
#   empty   set to 1 to have the volume cleared out.
#   driver  drover to use, default is "local".
#   chmod   set to have the mountpoint be given those permissions.
#   chown   set to have the mountpoint be owned by that user:group.
#
# Parameters:
#   $1: conffile The path to the conf file describing the volumes.
#   $2: optional name of composition, set to match a docker composition.
#       if unset name will be taken from conffile name if its format
#       is "name_docker-volumes.conf".
#       An underscore "_" will be appended to the name, just as Docker does
#       with volumes created with docker-compose.
#
# Returns:
#   non-zero on error.
#
#=======================
DOCKER_VOLUMES_DOWN()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile [name]"
    # shellcheck disable=SC2034
    SPACE_FN="DOCKER_VOLUMES_RM"
    # shellcheck disable=SC2034
    SPACE_OUTER="_DOCKER_VOLUMES_OUTER_DOWN"
    SPACE_DEP="STRING_SUBST"

    local conffile="${1}"
    shift

    local name=""
    if [ ! "${1+set}" = "set" ]; then
        name="${conffile%.conf*}"
        name="${name##*/}"
        name="${name%%_docker-volumes}"
        # Make name docker friendly.
        STRING_SUBST "name" "-" "" 1
        STRING_SUBST "name" "_" "" 1
        STRING_SUBST "name" "." "" 1
    else
        # Prefix is given, could be "".
        local name="${1}"
        shift
    fi
    name="${name:+${name}_}"

    SPACE_OUTERARGS="\"${conffile}\" \"${name}\""

    SPACE_ARGS="\"\${name-}\""
}

#==============================
#
# _DOCKER_VOLUMES_OUTER_PS
#
# The outer function of DOCKER_VOLUMES_PS
#
#==============================
_DOCKER_VOLUMES_OUTER_PS()
{
    SPACE_SIGNATURE="conffile [prefix]"
    SPACE_DEP="CONF_READ"

    local conffile="${1}"
    shift

    local prefix="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local conf_lineno=0
    while true; do
        local name=

        if ! CONF_READ "${conffile}" "name"; then
            PRINT "Could not read conf file: ${conffile}." "error"
            return 1
        fi

        name="${prefix}${name}"

        _CMD_

        if [ "${conf_lineno}" -eq 0 ]; then
            # Read done
            break
        fi
    done
}

#=======================
# DOCKER_VOLUMES_PS
#
# Inspect one or many docker volumes defined in conf file.
#
# The conf file is a key value based tex file, as:
#   name    volume name
#   archive directory|file.tar.gz (or empty) to populate the volume with.
#   empty   set to 1 to have the volume cleared out.
#   driver  drover to use, default is "local".
#   chmod   set to have the mountpoint be given those permissions.
#   chown   set to have the mountpoint be owned by that user:group.
#
# Parameters:
#   $1: conffile The path to the conf file describing the volumes.
#   $2: optional name of composition, set to match a docker composition.
#       if unset name will be taken from conffile name if its format
#       is "name_docker-volumes.conf".
#       An underscore "_" will be appended to the name, just as Docker does
#       with volumes created with docker-compose.
#
# Returns:
#   non-zero on error.
#
#=======================
DOCKER_VOLUMES_PS()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile [name]"
    # shellcheck disable=SC2034
    SPACE_FN="DOCKER_VOLUMES_INSPECT"
    # shellcheck disable=SC2034
    SPACE_OUTER="_DOCKER_VOLUMES_OUTER_PS"
    SPACE_DEP="STRING_SUBST"

    local conffile="${1}"
    shift

    local name=""
    if [ ! "${1+set}" = "set" ]; then
        name="${conffile%.conf*}"
        name="${name##*/}"
        name="${name%%_docker-volumes}"
        # Make name docker friendly.
        STRING_SUBST "name" "-" "" 1
        STRING_SUBST "name" "_" "" 1
        STRING_SUBST "name" "." "" 1
    else
        # Prefix is given, could be "".
        local name="${1}"
        shift
    fi
    name="${name:+${name}_}"

    SPACE_OUTERARGS="\"${conffile}\" \"${name}\""

    SPACE_ARGS="\"\${name-}\""
}

#=============================
#
# _DOCKER_VOLUMES_SHEBANG_OUTER_HELP()
#
#
#=============================
_DOCKER_VOLUMES_SHEBANG_OUTER_HELP()
{
    SPACE_SIGNATURE="conffile"

    local conffile="${1}"
    shift

        printf "%s\n" "This is the SpaceGal wrapper over docker-volumes.
Pass in a COMMAND as: -- command.
    up
    down
    ps

Example:
    ${conffile} -- up

"
    #_CMD_
}

#=======================
# DOCKER_VOLUMES_SHEBANG
#
#
# Handle the "shebang" invocations of docker-volumes files.
#
# Parameters:
#   $1: conffile The path to the conf file describing the volumes.
#   $2: command to run: deploy|undeploy|help
#
# Returns:
#   non-zero on error.
#
#=======================
DOCKER_VOLUMES_SHEBANG()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile [cmd]"
    # shellcheck disable=SC2034
    SPACE_FN="NOOP"
    # shellcheck disable=SC2034

    local conffile="${1}"
    shift

    local cmd="${1:-help}"
    shift $(( $# > 0 ? 1 : 0 ))

    if [ "${cmd}" = "help" ]; then
        # This is just because in this situation Space requires an actual CMD, but we are only interested in the outer cmd.
        SPACE_FN="PRINT"
        SPACE_ARGS="Done debug"
        SPACE_OUTER="_DOCKER_VOLUMES_SHEBANG_OUTER_HELP"
        SPACE_OUTERARGS="\"${conffile}\""
    elif [ "${cmd}" = "up" ]; then
        SPACE_FN="DOCKER_VOLUMES_UP"
        SPACE_ARGS="\"${conffile-}\""
    elif [ "${cmd}" = "down" ]; then
        SPACE_FN="DOCKER_VOLUMES_DOWN"
        SPACE_ARGS="\"${conffile-}\""
    elif [ "${cmd}" = "ps" ]; then
        SPACE_FN="DOCKER_VOLUMES_PS"
        SPACE_ARGS="\"${conffile-}\""
    else
        PRINT "Unknown command: ${cmd}. Try up/down/ps/help" "error"
        return 1
    fi
}
