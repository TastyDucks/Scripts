# A simple todo script.
# Written by tastyducks, 2019-09-10.

# USAGE: All entries must have " - " before them.
# "todo": Edit todo list.
# "todo done": List completed tasks.

#
# Important variables.
#

Directory="/home/tastyducks/Documents/TODO/" # A trailing "/" is required.
LogFile="Log.txt"
TodoFile="TODO.txt"

#
# Script body.
#

Todo=$Directory$TodoFile
Temp=$Directory.$TodoFile.tmp
Log=$Directory$LogFile

if [ $1 ]; then
	if [ $1 == "done" ]; then
		echo "Completed tasks:"
		grep "DEL" $Log
	fi
exit 1
fi

touch $Todo
touch $Temp
touch $Log

cp $Todo $Temp

nano $Todo # Edit todo file as desired.

Entries="$(diff $Todo $Temp | grep "<" | sed -E "s/<[^\S\r\n]+-\s+//" | sed -E "s/^/$(date --rfc-3339=s), ADD, /")" # New entries.
if [[ $Entries ]]; then
	echo "New entries:"
	echo "$Entries" |& tee -a $Log
fi

Entries="$(diff $Todo $Temp | grep ">" | sed -E "s/>[^\S\r\n]+-\s+//" | sed -E "s/^/$(date --rfc-3339=s), DEL, /")" # Deleted entries.
if [[ $Entries ]]; then
	echo "Deleted entries:"
	echo "$Entries" |& tee -a $Log
fi

rm $Temp # Delete temp copy.
