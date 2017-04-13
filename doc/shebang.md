---
modulename: Docker-volumes
title: Shebang
giturl: gitlab.com/space-sh/docker-volumes
weight: 200
---
# Docker-volumes module: #!shebang

You can make your `docker-volumes.conf` file executable by adding a `shebang line as first
line in the YAML file.  

As you might know the shebang line is the first line in a shell script that determines which
interpretor to run for the script. For Bash scripts it is usually `#!/bin/env bash`.

We can add a shebang line that tells the kernel that we want the _Space_ module
_docker-volumes_ to be the interpretor so it can directly run the conf file.

For Linux add this line as the very first line in your `docker-volumes.conf` file:  
```sh
#!/usr/bin/space -m docker-volumes /_shebang/
```

For MacOS systems add this line instead:  
```sh
#!/usr/bin/env space ! -m docker-volumes /_shebang/ !
```

Then you need to make the conf file executable:  

```sh
$ chmod +x docker-volumes.conf
```

Alright, it should be runnable directly from command line:  
```sh
$ ./docker-volumes.conf -- create
$ ./docker-volumes.conf -- rm
$ ./docker-volumes.conf -- inspect
```

We can wrap it using the SSH module to have it being deployed remotely:  

```sh
$ ./docker-volumes.conf -m ssh /wrap/ -eSSHHOST=address -- create
```

It is important to add `-m ssh /wrap/ -eSSHHOST=address` before the double dash `--`.
Because everything left of `--` are arguments to _Space_ and everything to the right of `--`
are arguments to the module.

Remember, that if you want to see the magic behind the scenes, add the `-d` flag to _Space_
to have it dump out the script for debugging, inspection and sharing.
