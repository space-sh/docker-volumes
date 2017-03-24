---
modulename: Docker-volumes
title: /exists/
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: Exists

Check if a given _Docker_ volume exists.

## Example

```sh
space -m docker-volumes /exists/ -- "myvolume"
```

Exit status code is expected to be 0 on success.
