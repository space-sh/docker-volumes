#
# Copyright 2016 Blockie AB
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

_source "${DIR}/../Spacefile.sh"

clone "docker-volumes"

_DOCKER_CHECK_NO_VOLUME ()
{
    SPACE_SIGNATURE="name"
    SPACE_DEP="DOCKER_VOLUMES_LS PRINT"

    local name="${1}"
    shift

    local volumes=
    volumes="$(DOCKER_VOLUMES_LS -q | grep "^${name}\$"; :)"
    if [ -n "${volumes}" ]; then
        PRINT "Volume ${name} exists." "error"
        return 1
    fi
}

_DOCKER_CHECK_VOLUME ()
{
    # shellcheck disable=2034
    SPACE_SIGNATURE="name"
    # shellcheck disable=2034
    SPACE_DEP="DOCKER_VOLUMES_LS PRINT"

    local name="${1}"
    shift

    local volumes=
    volumes="$(DOCKER_VOLUMES_LS -q | grep "^${name}\$"; :)"
    if [ -z "${volumes}" ]; then
        PRINT "Volume ${name} does not exist." "error"
        return 1
    fi
}
