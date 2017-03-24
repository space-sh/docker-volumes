---
modulename: Docker-volumes
title: /batch/
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: Batch



## create

Deploy volumes batch defined in configuration file, optionally populating the newly mounted volumes with data, overwritting any existing data.

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


