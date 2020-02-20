# Docker volumes management. | [![build status](https://gitlab.com/space-sh/docker-volumes/badges/master/pipeline.svg)](https://gitlab.com/space-sh/docker-volumes/commits/master)


## /batch/
	

+ create
+ inspect
+ rm

## /cat/
	Cat a file in a volume


## /chmod/
	Set the permissions and ownership of the mountpoint of a volume.

	This is done from within a container which will mount the volume.
	


## /create/
	Create a volume


## /empty/
	Delete all files in a volume


## /enter/
	Enter into volume using a shell


## /exists/
	Check if a volume exists


## /filelist/
	List all files inside a volume


## /inspect/
	Check simple status of volume


## /install/
	Install the latest Docker Engine.

	Downloads and installs the latest Docker Engine from Docker.
	Also adds the targetuser to the docker group.
	Will reinstall if already installed.
	


## /ls/
	List all volumes


## /restore/
	Restores a snapshot into a volume, possibly deletes all files first

	Archive, either path to tar.gz file,
	path to a directory to restore from
	or "-" for stdin.
	


## /rm/
	Remove a volume


## /snapshot/
	Take a snapshot of a volume

	Archive is either path to a tar.gz file,
	path to a directory to store snapshot in
	or "-" for stdout.
	


# Functions 

## DOCKER\_VOLUMES\_DEP\_INSTALL()  
  
  
  
Verify that Docker Engine is  
installed otherwise install it.  
  
### Parameters:  
- $1: user to add to docker group.  
  
### Returns:  
- 0: success  
- 1: failure  
  
  
  
## DOCKER\_VOLUMES\_INSTALL()  
  
  
  
Install latest Docker and make it available to the user.  
  
### Parameters:  
- $1: user to add to docker group.  
  
### Returns:  
- 0: success  
- 1: failure  
  
  
  
## DOCKER\_VOLUMES\_CREATE()  
  
  
  
docker volume create.  
  
### Parameters:  
- $1: name of volume  
- $2: driver, optional.  
- $3: opts, optional  
- $4: label, optional.  
  
### Returns:  
- non-zero on error  
  
  
  
## DOCKER\_VOLUMES\_ENTER()  
  
  
  
Enter into a docker container where the  
volume is mounted.  
  
This command will get wrapped and run inside a temporary container.  
  
### Parameters:  
- $1: name of volume  
  
### Returns:  
- non-zero on error  
  
  
  
## \_DOCKER\_VOLUMES\_ENTER\_IMPL()  
  
  
  
The implementation for DOCKER\_VOLUMES\_ENTER.  
  
  
  
## DOCKER\_VOLUMES\_CAT()  
  
  
  
Enter into a docker container where the  
volume is mounted and cat a file.  
  
This command will get wrapped and run inside a temporary container.  
  
### Parameters:  
- $1: name of volume  
- $1: path to file, widcards allowed.  
  
### Returns:  
- non-zero on error  
  
  
  
## \_DOCKER\_VOLUMES\_CAT\_IMPL()  
  
  
  
The implementation for DOCKER\_VOLUMES\_CAT.  
  
  
  
## DOCKER\_VOLUMES\_FILELIST()  
  
  
  
List all files inside a volume from within a container.  
  
This command will get wrapped and run inside a temporary container.  
  
### Parameters:  
- $1: name of volume  
  
### Returns:  
- non-zero on error  
  
- Outputs:  
- File list  
  
  
  
## \_DOCKER\_VOLUMES\_FILELIST\_IMPL()  
  
  
  
The implementation for DOCKER\_VOLUMES\_FILELIST.  
  
  
  
## DOCKER\_VOLUMES\_CHMOD()  
  
  
  
Set the permissions of the mountpoint of a volume.  
This function will mount the volume inside a container and  
then chmod/chown the mount point.  
  
This command will get wrapped and run inside a temporary container.  
  
### Parameters:  
- $1: name of volume  
- $2: chmod  
- $3: chown, optional.  
  
### Returns:  
- non-zero on error  
  
  
  
## \_DOCKER\_VOLUMES\_CHMOD\_IMPL()  
  
  
  
The implementation for DOCKER\_VOLUMES\_CHMOD.  
  
  
  
## DOCKER\_VOLUMES\_INSPECT()  
  
  
  
Inspect a volume.  
  
### Parameters:  
- $@: volume(s)  
  
  
  
## DOCKER\_VOLUMES\_RM()  
  
  
  
Remove one or more docker volumes.  
  
### Parameters:  
- $@: volume names  
  
  
  
## DOCKER\_VOLUMES\_LS()  
  
  
  
List docker volumes  
  
### Parameters:  
- $@: options  
  
  
  
## DOCKER\_VOLUMES\_EXISTS()  
  
  
  
Check so that a volume exists.  
  
### Parameters:  
- $1: name of volume  
  
  
  
## DOCKER\_VOLUMES\_RESTORE()  
  
  
  
Restore a tar.gz archive or local dir into a volume,  
possibly delete all files in volume first.  
  
If archive is local dir, beware of permissions, all files  
will be extracted as root:root, which may brake stuff if  
your applications runs as any other user than root.  
However when restoring a snapshotted tar.gz archive then  
permissions are preserved.  
  
If using $useacl1, which is the default, then a permissions  
dump is taken of the target directory and is used to restore  
permissions after the snapshot have been extracted.  
  
This command will get wrapped and run inside a temporary container.  
  
### Parameters:  
- $1: name of the volume  
- $2: archive, either path to tar.gz file, path to a directory or '-' for stdin.  
- $3: empty: set to '1' to first delete all files in volume before restoring, optional.  
- $4: preservepermissions, set to '1' to preserve permissions of existing file in the volume. optional, default is '1'.  
  
- Returns;  
- non-zero on error  
  
  
  
## \_DOCKER\_VOLUMES\_RESTORE\_OUTER()  
  
  
  
  
Helper to archive directory into STDIN.  
  
  
  
## \_DOCKER\_VOLUMES\_RESTORE\_IMPL()  
  
  
  
Used dy DOCKER\_VOLUMES\_RESTORE command  
  
  
  
## DOCKER\_VOLUMES\_EMPTY()  
  
  
  
Delete all files in a volume.  
  
This command will be wrapped to be run inside a temporary container  
  
### Parameters:  
- $1: name, the name of docker volume to empty of files.  
  
### Returns:  
- non-zero on error  
  
  
  
## \_DOCKER\_VOLUMES\_EMPTY\_IMPL()  
  
  
  
Used by DOCKER\_VOLUMES\_EMPTY  
  
  
  
## DOCKER\_VOLUMES\_SNAPSHOT()  
  
  
  
Archive all files inside volume into a tar.gz archive or to stdout.  
  
### Parameters:  
- $1: name, the name of the docker volume to snapshot.  
- $2: archive, either path to tar.gz file, path to a directory or '-' for stdout.  
  
  
  
## \_DOCKER\_VOLUMES\_SNAPSHOT\_IMPL()  
  
  
  
USed by DOCKER\_VOLUMES\_SNAPSHOT  
  
  
  
## \_DOCKER\_VOLUMES\_OUTER\_BATCH\_CREATE()  
  
  
  
  
The outer function of DOCKER\_VOLUMES\_BATCH\_CREATE  
  
  
  
## DOCKER\_VOLUMES\_BATCH\_CREATE()  
  
  
  
Create and populate docker volumes defined  
in conf file.  
  
The conffile is a key value based tex file, as:  
name    volume name  
archive directory|file.tar.gz (or empty) to populate the volume with.  
empty   set to 1 to have the volume cleared out.  
driver  drover to use, default is "local".  
chmod   set to have the mountpoint be given those permissions.  
chown   set to have the mountpoint be owned by that user:group.  
  
### Parameters:  
- $1: conffile The path to the conf file describing the volumes.  
- $2: optional name of composition, set to match a docker composition.  
- if unset name will be taken from conffile name if its format  
- is "name\_docker-volumes.conf".  
- An underscore "\_" will be appended to the name, just as Docker does  
- with volumes created with docker-compose.  
  
### Returns:  
- non-zero on error.  
  
  
  
## \_DOCKER\_VOLUMES\_BATCH\_CREATE\_IMPL()  
  
  
  
Implementation for DOCKER\_VOLUMES\_BATCH\_CREATE  
  
### Parameters:  
- $1: targetdir: the directory inside the container to where the volume is mounted.  
- $2: chmod: permissions to set the directory to, optional.  
- $3: chown: set owner of the directory, optional.  
- $4: empty: set to "true" to rm -rf the directory contents. WARNING!  
- $5: archive: Set to "1" to indicate that a tar.gz stream is piped on STDIN.  
  
### Returns:  
- non-zero on error  
  
  
  
## \_DOCKER\_VOLUMES\_OUTER\_BATCH\_RM()  
  
  
  
  
The outer function of DOCKER\_VOLUMES\_BATCH\_RM  
  
  
  
## DOCKER\_VOLUMES\_BATCH\_RM()  
  
  
  
Delete docker volumes defined in conf file.  
  
The conf file is a key value based tex file, as:  
name    volume name  
archive directory|file.tar.gz (or empty) to populate the volume with.  
empty   set to 1 to have the volume cleared out.  
driver  drover to use, default is "local".  
chmod   set to have the mountpoint be given those permissions.  
chown   set to have the mountpoint be owned by that user:group.  
  
### Parameters:  
- $1: conffile The path to the conf file describing the volumes.  
- $2: optional name of composition, set to match a docker composition.  
- if unset name will be taken from conffile name if its format  
- is "name\_docker-volumes.conf".  
- An underscore "\_" will be appended to the name, just as Docker does  
- with volumes created with docker-compose.  
  
### Returns:  
- non-zero on error.  
  
  
  
## \_DOCKER\_VOLUMES\_OUTER\_BATCH\_INSPECT()  
  
  
  
  
The outer function of DOCKER\_VOLUMES\_BATCH\_INSPECT  
  
  
  
## DOCKER\_VOLUMES\_BATCH\_INSPECT()  
  
  
  
Inspect one or many docker volumes defined in conf file.  
  
The conf file is a key value based tex file, as:  
name    volume name  
archive directory|file.tar.gz (or empty) to populate the volume with.  
empty   set to 1 to have the volume cleared out.  
driver  drover to use, default is "local".  
chmod   set to have the mountpoint be given those permissions.  
chown   set to have the mountpoint be owned by that user:group.  
  
### Parameters:  
- $1: conffile The path to the conf file describing the volumes.  
- $2: optional name of composition, set to match a docker composition.  
- if unset name will be taken from conffile name if its format  
- is "name\_docker-volumes.conf".  
- An underscore "\_" will be appended to the name, just as Docker does  
- with volumes created with docker-compose.  
  
### Returns:  
- non-zero on error.  
  
  
  
## \_DOCKER\_VOLUMES\_SHEBANG\_OUTER\_HELP()  
  
  
()  
  
  
  
  
## DOCKER\_VOLUMES\_SHEBANG()  
  
  
  
  
Handle the "shebang" invocations of docker-volumes files.  
  
### Parameters:  
- $1: conffile The path to the conf file describing the volumes.  
- $2: command to run: deploy|undeploy|help  
  
### Returns:  
- non-zero on error.  
  
  
  
