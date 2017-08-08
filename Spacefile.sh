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

#======================
# DOCKER_VOLUMES_DEP_INSTALL
#
# Verify that Docker Engine is
# installed otherwise install it.
#
# Parameters:
#   $1: user to add to docker group.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_VOLUMES_DEP_INSTALL()
{
    SPACE_SIGNATURE="targetuser:1"
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
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_VOLUMES_INSTALL()
{
    SPACE_SIGNATURE="targetuser:1"
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
    SPACE_SIGNATURE="name:1 [driver opts label]"
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
    SPACE_SIGNATURE="name:1"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_ENTER_IMPL"
    SPACE_WRAP="DOCKER_WRAP_RUN"
    SPACE_BUILDARGS="${SPACE_ARGS}"

    local name="${1}"
    shift

    # These variables will get exported.
    local DOCKERIMAGE="alpine"
    local DOCKERFLAGS="-it --rm -v ${name}:/mountvol"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    local SPACE_ARGS="\"/mountvol\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
}

#=============================
# _DOCKER_VOLUMES_ENTER_IMPL
#
# The implementation for DOCKER_VOLUMES_ENTER.
#
#=============================
_DOCKER_VOLUMES_ENTER_IMPL()
{
    SPACE_SIGNATURE="targetdir:1"
    SPACE_DEP="PRINT"

    local targetdir="${1}"
    shift

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    # shellcheck disable=2034
    cd "${targetdir}" || exit 1

    # Hide function name when PRINT
    SPACE_FNNAME=""

    PRINT "Here we are, behold your volume and all it's files." "info"
    PRINT "Changes you make to files will stick." "warning"

    sh
}

#=======================
# DOCKER_VOLUMES_CAT
#
# Enter into a docker container where the
# volume is mounted and cat a file.
#
# This command will get wrapped and run inside a temporary container.
#
# Parameters:
#   $1: name of volume
#   $1: path to file, widcards allowed.
#
# Returns:
#   non-zero on error
#
#======================
DOCKER_VOLUMES_CAT()
{
    SPACE_SIGNATURE="name:1 filepath:1"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_CAT_IMPL"
    SPACE_WRAP="DOCKER_WRAP_RUN"
    SPACE_BUILDARGS="${SPACE_ARGS}"

    local name="${1}"
    shift

    local filepath="${1}"
    shift

    # These variables will get exported.
    local DOCKERIMAGE="alpine"
    local DOCKERFLAGS="-i --rm -v ${name}:/mountvol"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    local SPACE_ARGS="\"/mountvol\" \"${filepath}\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
}

#=============================
# _DOCKER_VOLUMES_CAT_IMPL
#
# The implementation for DOCKER_VOLUMES_CAT.
#
#=============================
_DOCKER_VOLUMES_CAT_IMPL()
{
    SPACE_SIGNATURE="targetdir:1 filepath:1"

    local targetdir="${1}"
    shift

    local filepath="${1}"
    shift

    # shellcheck disable=2034
    cd "${targetdir}" || exit 1

    cat ${filepath}
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
    SPACE_SIGNATURE="name:1"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_FILELIST_IMPL"
    SPACE_WRAP="DOCKER_WRAP_RUN"
    SPACE_BUILDARGS="${SPACE_ARGS}"

    local name="${1}"
    shift

    # These variables will get exported.
    local DOCKERIMAGE="alpine"
    local DOCKERFLAGS="-i --rm -v ${name}:/mountvol"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    local SPACE_ARGS="\"/mountvol\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
}

#=============================
# _DOCKER_VOLUMES_FILELIST_IMPL
#
# The implementation for DOCKER_VOLUMES_FILELIST.
#
#=============================
_DOCKER_VOLUMES_FILELIST_IMPL()
{
    SPACE_SIGNATURE="targetdir:1"
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
    SPACE_SIGNATURE="name:1 chmod:1 [chown]"
    # We have to chain to another cmd since we want to wrap it.
    SPACE_FN="_DOCKER_VOLUMES_CHMOD_IMPL"
    SPACE_WRAP="DOCKER_WRAP_RUN"
    SPACE_BUILDARGS="${SPACE_ARGS}"

    local name="${1}"
    shift

    local chmod="${1}"
    shift

    local chown="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # These variables will get exported.
    local DOCKERIMAGE="alpine"
    local DOCKERFLAGS="-i --rm -v ${name}:/mountvol"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    local SPACE_ARGS="\"/mountvol\" \"${chmod}\" \"${chown}\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
    YIELD "SPACE_ARGS"
}

#=====================
# _DOCKER_VOLUMES_CHMOD_IMPL
#
# The implementation for DOCKER_VOLUMES_CHMOD.
#
#=====================
_DOCKER_VOLUMES_CHMOD_IMPL()
{
    SPACE_SIGNATURE="targetdir:1 chmod:1 [chown]"
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
#   $@: volume(s)
#
#=====================
DOCKER_VOLUMES_INSPECT()
{
    SPACE_SIGNATURE="volume:1 [volume]"
    SPACE_DEP="PRINT"

    PRINT "Inspect volume(s): $*"

    docker volume inspect "$@"
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
    SPACE_SIGNATURE="name:1 [name]"
    SPACE_DEP="PRINT"

    PRINT "Remove volume(s): $*."
    docker volume rm "$@"
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
    docker volume ls "$@"
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
    SPACE_SIGNATURE="name:1"

    local name="${1}"
    shift

    if ! docker volume inspect "${name}" >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
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
    SPACE_SIGNATURE="name:1 archive:1 [empty preservepermissions]"
    SPACE_FN="_DOCKER_VOLUMES_RESTORE_IMPL"
    SPACE_WRAP="DOCKER_WRAP_RUN"
    SPACE_BUILDARGS="${SPACE_ARGS}"
    SPACE_BUILDDEP="PRINT"
    SPACE_BUILDENV="CWD"

    local name="${1}"
    shift

    local archive="${1}"
    shift

    local empty="${1:-0}"
    shift $(( $# > 0 ? 1 : 0 ))

    local preservepermissions="${1:-1}"
    shift $(( $# > 0 ? 1 : 0 ))

    local targetdir="/tmpmount"

    # This variable will get exported.
    local DOCKERFLAGS="-i --rm -v ${name}:${targetdir}"
    local DOCKERIMAGE="alpine"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    if [ "${archive}" = "-" ]; then
        if [ -t "0" ]; then
            PRINT "OMG STDIN is a terminal! I was totally expecting a tar.gz stream." "error"
            return 1
        fi
    else
        if [ "${archive:0:1}" == "/" -a -d "${archive}" ] || [ "${archive:0:1}" != "/" -a -d "${CWD}/${archive}" ]; then
            local SPACE_OUTER="_DOCKER_VOLUMES_RESTORE_OUTER"
            YIELD "SPACE_OUTER"
            local SPACE_OUTERARGS="${archive}"
            YIELD "SPACE_OUTERARGS"
            local SPACE_REDIR="<\${archive}"
            YIELD "SPACE_REDIR"
        else
            local SPACE_REDIR="<${archive}"
            YIELD "SPACE_REDIR"
        fi
    fi

    local SPACE_ARGS="\"${targetdir}\" \"${empty}\" \"${preservepermissions}\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
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
    SPACE_SIGNATURE="dir:1"

    local dir="${1}"
    shift

    local tempfile="/tmp/space.$$"
    PRINT "Creating temporary archive: ${tempfile} for directory: ${dir}."
    tar -czf $tempfile -C $dir .

    local archive="$tempfile"  # This will be in the redirection.
    _RUN_
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
    SPACE_SIGNATURE="targetdir:1 empty:1 preservepermissions:1"
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
    # shellcheck disable=2181
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
    SPACE_SIGNATURE="name:1"
    SPACE_FN="_DOCKER_VOLUMES_EMPTY_IMPL"
    SPACE_WRAP="DOCKER_WRAP_RUN"
    SPACE_BUILDARGS="${SPACE_ARGS}"
    SPACE_BUILDDEP="PRINT"

    local name="${1}"
    shift

    local targetdir="/tmpmount"

    # This variable will get exported.
    local DOCKERIMAGE="alpine"

    # This variable will get exported.
    local DOCKERFLAGS="-i --rm -v ${name}:${targetdir}"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    PRINT "Emptying volume: ${name}."
    local SPACE_ARGS="\"${targetdir}\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
}

#=====================
# _DOCKER_VOLUMES_EMPTY_IMPL
#
# Used by DOCKER_VOLUMES_EMPTY
#
#=====================
_DOCKER_VOLUMES_EMPTY_IMPL()
{
    SPACE_SIGNATURE="targetdir:1"
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
    SPACE_SIGNATURE="name:1 archive:1"
    # shellcheck disable=2034
    SPACE_WRAP="DOCKER_WRAP_RUN"
    # shellcheck disable=2034
    SPACE_FN="_DOCKER_VOLUMES_SNAPSHOT_IMPL"
    SPACE_BUILDARGS="${SPACE_ARGS}"
    SPACE_BUILDDEP="PRINT"
    # shellcheck disable=2034
    SPACE_BUILDENV="CWD"

    local name="${1}"
    shift

    local archive="${1}"
    shift

    local targetdir="/tmpmount"

    # This variable will get exported.
    local DOCKERIMAGE="alpine"
    local DOCKERFLAGS="-i --rm -v ${name}:${targetdir}"
    local DOCKERCONTAINER=
    local DOCKERCMD="sh -c"

    if [ "${archive}" = "-" ]; then
        if [ -t 1 ]; then
            PRINT "[error] OMG STDOUT is a terminal! You do not want this." "error"
            return 1
        fi
    else
        if [ "${archive:0:1}" == "/" -a -d "${archive}" ] || [ "${archive:0:1}" != "/" -a -d "${CWD}/${archive}" ]; then
            # shellcheck disable=2034
            local SPACE_REDIR="| tar -xzf - -C ${archive}"
            YIELD "SPACE_REDIR"
        else
            # shellcheck disable=2034
            local SPACE_REDIR=">${archive}"
            YIELD "SPACE_REDIR"
        fi
    fi

    # shellcheck disable=2034
    local SPACE_ARGS="${targetdir}"
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
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
    SPACE_SIGNATURE="targetdir:1"
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
# _DOCKER_VOLUMES_OUTER_BATCH_CREATE
#
# The outer function of DOCKER_VOLUMES_BATCH_CREATE
#
#==============================
_DOCKER_VOLUMES_OUTER_BATCH_CREATE()
{
    SPACE_SIGNATURE="conffile:1 [prefix]"
    SPACE_DEP="STRING_SUBST CONF_READ"

    local conffile="${1}"
    shift

    local prefix="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # We save the wrapped RUN because we want to alter it in each iteration.
    local RUN_ORIGINAL="${RUN}"

    local out_conf_lineno=0
    while [ "${out_conf_lineno}" -ne "-1" ]; do
        local name=
        local driver=
        local type=
        local archive=
        local chmod=
        local chown=
        local empty=

        if ! CONF_READ "${conffile}" "name driver type archive chmod chown empty"; then
            PRINT "Could not read conf file: ${conffile}." "error"
            return 1
        fi
        if [ -z "${name}" ]; then
            continue
        fi
        if [ "${type}" != "persistent" ]; then
            PRINT "Skipping non-persistent volume: ${name}."
            continue
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

        RUN="${RUN_ORIGINAL}"
        STRING_SUBST "RUN" "{DOCKERFLAGS}" "${flags}"
        STRING_SUBST "RUN" "{TARGETDIR}" "/volume"
        STRING_SUBST "RUN" "{CHMOD}" "${chmod}"
        STRING_SUBST "RUN" "{CHOWN}" "${chown}"
        STRING_SUBST "RUN" "{EMPTY}" "${empty}"
        STRING_SUBST "RUN" "{ARCHIVE}" "${usearchive}"

        _RUN_

        if [ -n "${tempfile}" ]; then
            PRINT "Removing temporary archive."
            rm "${tempfile}"
        fi
    done
}

#=======================
# DOCKER_VOLUMES_BATCH_CREATE
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
DOCKER_VOLUMES_BATCH_CREATE()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile:1 [name]"
    # shellcheck disable=SC2034
    SPACE_FN="_DOCKER_VOLUMES_BATCH_CREATE_IMPL"
    # shellcheck disable=SC2034
    SPACE_WRAP="DOCKER_WRAP_RUN"
    # shellcheck disable=SC2034
    SPACE_REDIR="<\$archive"
    # shellcheck disable=SC2034
    SPACE_OUTER="_DOCKER_VOLUMES_OUTER_BATCH_CREATE"
    SPACE_BUILDDEP="STRING_SUBST"
    SPACE_BUILDARGS="${SPACE_ARGS}"     # Pass the args into this build function.
    SPACE_ARGS="{NAME}"                 # We put this after because it's prior value is used above.

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
        name="${1}"
        shift
    fi
    name="${name:+${name}_}"

    local SPACE_OUTERARGS="\"${conffile}\" \"${name}\""

    # These variables will get exported.
    # shellcheck disable=SC2034
    local DOCKERIMAGE="alpine"
    # shellcheck disable=SC2034
    local DOCKERCONTAINER=
    # shellcheck disable=2034
    local DOCKERFLAGS="{DOCKERFLAGS}"
    # shellcheck disable=2034
    local DOCKERCMD="sh -c"

    # These arguments will get substituted by STRING_SUBST in RUNOUTER.
    local SPACE_ARGS="\"{TARGETDIR}\" \"{CHMOD}\" \"{CHOWN}\" \"{EMPTY}\" \"{ARCHIVE}\""
    YIELD "DOCKERIMAGE"
    YIELD "DOCKERFLAGS"
    YIELD "DOCKERCONTAINER"
    YIELD "DOCKERCMD"
    YIELD "SPACE_ARGS"
    YIELD "SPACE_OUTERARGS"
}


# Disable warning about indirectly reading program exit status code
# shellcheck disable=2181

#============================
# _DOCKER_VOLUMES_BATCH_CREATE_IMPL
#
# Implementation for DOCKER_VOLUMES_BATCH_CREATE
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
_DOCKER_VOLUMES_BATCH_CREATE_IMPL()
{
    SPACE_SIGNATURE="targetdir:1 chmod:1 chown:1 empty:1 archive:1"
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
# _DOCKER_VOLUMES_OUTER_BATCH_RM
#
# The outer function of DOCKER_VOLUMES_BATCH_RM
#
#==============================
_DOCKER_VOLUMES_OUTER_BATCH_RM()
{
    SPACE_SIGNATURE="conffile:1 [prefix]"
    SPACE_DEP="CONF_READ STRING_SUBST"

    local conffile="${1}"
    shift

    local prefix="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # We save the wrapped RUN because we want to alter it in each iteration.
    local RUN_ORIGINAL="${RUN}"

    local out_conf_lineno=0
    while [ "${out_conf_lineno}" -ne "-1" ]; do
        local name=
        local driver=
        local type=

        if ! CONF_READ "${conffile}" "name driver type"; then
            PRINT "Could not read conf file: ${conffile}." "error"
            return 1
        fi
        if [ -z "${name}" ]; then
            continue
        fi
        if [ "${type}" = "persistent" ]; then
            PRINT "Skipping persistent volume: ${name}"
            continue
        fi

        name="${prefix}${name}"

        PRINT "Remove volume: ${name}."
        continue

        RUN="${RUN_ORIGINAL}"
        STRING_SUBST "RUN" "{NAME}" "${name}"
        _RUN_
        : # Clear error
    done
}

#=======================
# DOCKER_VOLUMES_BATCH_RM
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
DOCKER_VOLUMES_BATCH_RM()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile:1 [name]"
    # shellcheck disable=SC2034
    SPACE_FN="DOCKER_VOLUMES_RM"
    # shellcheck disable=SC2034
    SPACE_OUTER="_DOCKER_VOLUMES_OUTER_BATCH_RM"
    SPACE_BUILDDEP="STRING_SUBST"
    SPACE_BUILDARGS="${SPACE_ARGS}"     # Pass the args into this build function.
    SPACE_ARGS="{NAME}"                 # We put this after because it's prior value is used above.

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
        name="${1}"
        shift
    fi
    name="${name:+${name}_}"

    local SPACE_OUTERARGS="\"${conffile}\" \"${name}\""
    YIELD "SPACE_OUTERARGS"
}

#==============================
#
# _DOCKER_VOLUMES_OUTER_BATCH_INSPECT
#
# The outer function of DOCKER_VOLUMES_BATCH_INSPECT
#
#==============================
_DOCKER_VOLUMES_OUTER_BATCH_INSPECT()
{
    # shellcheck disable=2034
    SPACE_SIGNATURE="conffile:1 [prefix]"
    # shellcheck disable=2034
    SPACE_DEP="CONF_READ STRING_SUBST"

    local conffile="${1}"
    shift

    local prefix="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    # We save the wrapped RUN because we want to alter it in each iteration.
    local RUN_ORIGINAL="${RUN}"

    local out_conf_lineno=0
    while [ "${out_conf_lineno}" -ne "-1" ]; do
        local name=

        if ! CONF_READ "${conffile}" "name"; then
            PRINT "Could not read conf file: ${conffile}." "error"
            return 1
        fi
        if [ -z "${name}" ]; then
            continue
        fi

        name="${prefix}${name}"

        PRINT "Inspect volume: ${name}."

        RUN="${RUN_ORIGINAL}"
        STRING_SUBST "RUN" "{NAME}" "${name}"
        _RUN_
    done
    return 0
}

#=======================
# DOCKER_VOLUMES_BATCH_INSPECT
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
DOCKER_VOLUMES_BATCH_INSPECT()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="conffile:1 [name]"
    # shellcheck disable=SC2034
    SPACE_FN="DOCKER_VOLUMES_INSPECT"
    # shellcheck disable=SC2034
    SPACE_OUTER="_DOCKER_VOLUMES_OUTER_BATCH_INSPECT"
    SPACE_BUILDDEP="STRING_SUBST"
    SPACE_BUILDARGS="${SPACE_ARGS}"     # Pass the args into this build function.
    SPACE_ARGS="{NAME}"                 # We put this after because it's prior value is used above.

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
        name="${1}"
        shift
    fi
    name="${name:+${name}_}"

    local SPACE_OUTERARGS="\"${conffile}\" \"${name}\""
    YIELD "SPACE_OUTERARGS"
}

#=============================
#
# _DOCKER_VOLUMES_SHEBANG_OUTER_HELP()
#
#
#=============================
_DOCKER_VOLUMES_SHEBANG_OUTER_HELP()
{
    SPACE_SIGNATURE="conffile:1"

    local conffile="${1}"
    shift

        printf "%s\n" "This is the Space.sh wrapper over docker-volumes.
Pass in a COMMAND as: -- command.
    create
    rm
    inspect

Example:
    ${conffile} -- create

"
}

# Disable warning about unused variable
# shellcheck disable=2034

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
    SPACE_SIGNATURE="conffile:1 [cmd]"
    # shellcheck disable=SC2034
    SPACE_FN="NOOP"
    # shellcheck disable=SC2034
    SPACE_BUILDARGS="${SPACE_ARGS}"
    SPACE_BUILDDEP="PRINT"

    local conffile="${1}"
    shift

    local cmd="${1:-help}"
    shift $(( $# > 0 ? 1 : 0 ))

    if [ "${cmd}" = "help" ]; then
        # This is just because in this situation Space requires an actual RUN, but we are only interested in the outer cmd.
        local SPACE_FN="PRINT"
        local SPACE_ARGS="Done debug"
        local SPACE_OUTER="_DOCKER_VOLUMES_SHEBANG_OUTER_HELP"
        local SPACE_OUTERARGS="\"${conffile}\""
        YIELD "SPACE_OUTER"
        YIELD "SPACE_OUTERARGS"
    elif [ "${cmd}" = "create" ]; then
        local SPACE_FN="DOCKER_VOLUMES_BATCH_CREATE"
        local SPACE_ARGS="\"${conffile}\""
    elif [ "${cmd}" = "rm" ]; then
        local SPACE_FN="DOCKER_VOLUMES_BATCH_RM"
        local SPACE_ARGS="\"${conffile}\""
    elif [ "${cmd}" = "inspect" ]; then
        local SPACE_FN="DOCKER_VOLUMES_BATCH_INSPECT"
        local SPACE_ARGS="\"${conffile}\""
    else
        PRINT "Unknown command: ${cmd}. Try create/rm/inspect/help" "error"
        return 1
    fi
    YIELD "SPACE_FN"
    YIELD "SPACE_ARGS"
}
