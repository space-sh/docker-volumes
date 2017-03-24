---
modulename: Docker-volumes
title: /filelist/
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: File list 

List all files inside a given _Docker_ volume.

## Example

```sh
space -m docker-volumes /filelist/ -- "myvolume"
```

Exit status code is expected to be 0 on success.
