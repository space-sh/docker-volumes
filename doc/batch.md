---
modulename: Docker-volumes
title: /batch/
giturl: gitlab.com/space-sh/docker-volumes
editurl: /edit/master/doc/batch.md
weight: 200
---
# Docker-volumes module: Batch


## Conf file format

This is how you define docker volumes in a conf file:  
```sh
name      volume1
driver    local
type      persistent

name      volume2
driver    local
type      volatile

name      volume3
driver    local
type      persistent
archive   /home/user/data
```

Depending on the `type` of the volume different actions will be taken when performing create, rm and inspect.

The `create` node will only create `persistent` volumes.  
The 'rm' node will destroy all volumes except for the persistent volumes.  
The 'inspect' node will inspect all volumes defined in the conf file.

Defining `volatile` volumes in the conf file, that is, volumes that are implicitly created
by docker when starting a container and should be considered temporary, could be a good
strategy for handling all volumes associated with a project, to be inspected and removed in batch.

If a `persistent` volume has an `archive`, that directory or `tar.gz` archive will be copied into
the volume on creation.

## create

Deploy volumes batch defined in configuration file, optionally populating the newly mounted volumes with data, overwriting any existing data.

### Example

```sh
space -m docker-volumes /batch/create/ -- "batch.conf" "myvolumes"
```

Exit status code is expected to be 0 on success.

## rm

Unmount and destroy all volumes defined in configuration file, removing all data.

### Example
```sh
space -m docker-volumes /batch/rm/ -- "batch.conf" "myvolumes"
```

Exit status code is expected to be 0 on success.

## inspect

Check status for a batch of volumes defined in configuration file.

### Example
```sh
space -m docker-volumes /batch/inspect/ -- "batch.conf" "myvolumes"
```

Exit status code is expected to be 0 on success.

## Remotely manage volumes over SSH

To manage the volumes on a remote server simply wrap the command using the SSH module.

```sh
$ space -m ssh /wrap/ -eSSHHOST=address \
        -m docker-volumes /batch/inspect/ -- "batch.conf" "myvolumes"

```
