---
modulename: Docker-volumes
title: /snapshot/
giturl: gitlab.com/space-sh/docker-volumes
editurl: /edit/master/doc/snapshot.md
weight: 200
---
# Docker-volumes module: Snapshot

Takes a snapshot of a _Docker_ volume and save it to a `tar.gz` archive, copy over to a directory or stream to `stdout`.

## Example

Saving `myvolume` _Docker_ volume to a `tar.gz` file:
```sh
space -m docker-volumes /snapshot/ -- "myvolume" "archive-0001.tar.gz"
```

Saving `myvolume` _Docker_ volume to a directory:
```sh
space -m docker-volumes /snapshot/ -- "myvolume" "/home/user/myvolume/"
```

Exit status code is expected to be 0 on success.
