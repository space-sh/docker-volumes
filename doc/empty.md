---
modulename: Docker-volumes
title: /empty/
giturl: gitlab.com/space-sh/docker-volumes
editurl: /edit/master/doc/empty.md
weight: 200
---
# Docker-volumes module: Empty

Deletes all files in a _Docker_ volume.

## Example

```sh
space -m docker-volumes /empty/ -- "myvolume"
```

Exit status code is expected to be 0 on success.
