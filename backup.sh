#!/bin/bash
# Backup script for PC. Backs up to both local and remote drives. Written by TastyDucks 2019-03-04
# Uses rsync over SSH for remote, so encryption should be fine.

# A WARNING! THIS SCRIPT DELETES NON-EXISTANT FILES FROM REMOTE SOURCES, SO MAKE SURE YOU ARE COPYING WHAT YOU WANT TO KEEP!
# RUNNING IT ON AN EMPTY DISK CAN DELETE EVERYTHING!
# It may be a good idea to only back up to a local HDD occasionally in order to prevent something bad from happening by accident.

# Dependancy: Requires sshpass



#
# IMPORTANT VARIABLES
#

# NAMING NOTE: Do not escape spaces in names, and include a trailing slash after all directories!



# LOCAL VARIABLES



# Top directory to mirror.
Directory="/home/"

# Backup log file location.
LogLocation="/home/backup.log"

# File containing directories and files to exclude from backup. Leave blank if you don't care about this. IMPORTANT: Directories in here will always be relative to the source (that is, "$Directory"). You should NEVER include a trailing slash before entries.
ExcludeFile="/home/rsync-exclude-list.txt"

# Local HDD directory.
LocalAddress="/run/media/HDD/"



# REMOTE VARIABLES (Leave these blank if you don't care about this.)



# Remote server username.
RemoteUsername="User"

# Remote server password. Be sure that this computer and your backup locations are secure!
RemotePassword="FooBar"

# Remote server address.
RemoteAddress="example.com"

# Remote directory.
RemoteDirectory="/backup/"

# Specify a SSH port other than the default if needed. Otherwise set this to 22!
ServerPort="22"



#
# SCRIPT
#



CtrlC()
{
	printf "\n[$(date --rfc-3339=s)] [FAIL] Exiting (user interrupt)... Backups are likely incomplete.\n" |& tee -a $LogLocation
	kill %%
	exit
}
trap CtrlC INT

printf "[$(date --rfc-3339=s)] [INFO] Started.\n" |& tee -a $LogLocation

notify-send -u "low" -c "transfer" "Backup script" "Started..."

#printf "[$(date --rfc-3339=s)] [INFO] Running organize.sh\n" |& tee -a $LogLocation

#bash ~/Documents/Scripts/organize.sh

# LOCAL

printf "[$(date --rfc-3339=s)] [INFO] rsync-ing with local HDD... ($LocalAddress)" |& tee -a $LogLocation
echo |& tee -a $LogLocation # With printf, rsync's "--info=progress2" output seems to erase the previous line for some reason... This does not happen with echo.
rm /tmp/LocalPipe &> /dev/null
mkfifo /tmp/LocalPipe
tee -a $LogLocation < /tmp/LocalPipe &
rsync -ahs --delete-before --info=progress2 --stats --exclude-from="$ExcludeFile" "$Directory" "$LocalAddress" > /tmp/LocalPipe
if [[ $? != 0 && $? != 24 ]] # A return value of 24 is used by rsync when a file transfer was only partially completed due to missing files. This is not counted as a condition in which the backup has "failed" because that usually just means there were temporary files caught in the backup's initial scan.
then
	printf "\n[$(date --rfc-3339=s)] [FAIL] Rsync with local HDD failed. See rsync output above.\n" |& tee -a $LogLocation
	notify-send -u "low" -c "transfer" "Backup script" "Local: X"
else
	printf "\n[$(date --rfc-3339=s)] [INFO] Rsync with local HDD completed.\n" |& tee -a $LogLocation
	notify-send -u "low" -c "transfer" "Backup script" "Local: √"
fi

# REMOTE

if [ ! $RemoteUsername = "" ]
then
	if [ $ServerPort != "22" ]
	then
		SSHOption="-p $ServerPort"
		SSHPort="$ServerPort"
	else
		SSHOption=""
		SSHPort="22"
	fi
	printf "[$(date --rfc-3339=s)] [INFO] rsync-ing with remote server... ($RemoteUsername@$RemoteAddress:$SSHPort)" |& tee -a $LogLocation
	echo |& tee -a $LogLocation
	Remote="$RemoteUsername"@"$RemoteAddress":"$RemoteDirectory"
	export SSHPASS="$RemotePassword"
	rm /tmp/RemotePipe &> /dev/null
	mkfifo /tmp/RemotePipe
	tee -a $LogLocation < /tmp/RemotePipe &
	sshpass -e rsync -ahs --delete-before --info=progress2 --stats --exclude-from="$ExcludeFile" -e "ssh $SSHOption -o StrictHostKeyChecking=no" "$Directory" "$Remote" > /tmp/RemotePipe
	if [[ $? != 0 && $? != 24 ]]
	then
		printf "\n[$(date --rfc-3339=s)] [FAIL] Rsync with remote server failed. See rsync output above.\n" |& tee -a $LogLocation
		notify-send -u "low" -c "transfer" "Backup script" "Remote: X"
	else
		printf "\n[$(date --rfc-3339=s)] [INFO] Rsync with remote server completed.\n" |& tee -a $LogLocation
		notify-send -u "low" -c "transfer" "Backup script" "Remote: √"
	fi	
fi

printf "[$(date --rfc-3339=s)] [INFO] Cleaning up log.\n" # This line is intentionally not logged. :)

grep -v "/s" $LogLocation > /tmp/TemporaryFile && mv /tmp/TemporaryFile $LogLocation

printf "[$(date --rfc-3339=s)] [INFO] Finished.\n\n" |& tee -a $LogLocation

notify-send -u "low" -c "transfer" "Backup script" "Done!"
