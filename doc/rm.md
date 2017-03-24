---
modulename: Docker-volumes
title: /rm/
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: Remove

Remove a _Docker_ volume by name.

## Example

```sh
space -m docker-volumes /rm/ -- "myvolume"
```

Exit status code is expected to be 0 on success.
