---
modulename: Docker-volumes
title: /chmod/
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: Change mode

Set permissions and ownership of a given _Docker_ volume mountpoint.  
This operation is performed from within a container which will mount the volume.

## Example

```sh
space -m docker-volumes /chmod/ -- "myvolume" "755" "ownername"
```

Exit status code is expected to be 0 on success.
