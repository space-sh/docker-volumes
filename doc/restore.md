---
modulename: Docker-volumes
title: /restore/
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: Restore

Restores a snapshot into a _Docker_ volume, possibly deleting all files first.
A snapshot can be retrieved from a `tar.gz` file, a path to a directory.

## Example

```sh
space -m docker-volumes /restore/ -- "myvolume" "archive-0001.tar.gz"
```

Exit status code is expected to be 0 on success.
