# Autoripper script thing. Made by Tastyducks, 2019-04-21.

# Requires abcde

clear
eject

while true
do
	cat /dev/sr0 |& grep -E -q "No medium found" && printf "\rInsert a disk..." || (clear; abcde -x -N -o flac; clear)
done
