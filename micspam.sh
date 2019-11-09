# Simple BASH script for piping audio into applications such as Discord or Team Fortress 2. Made by Tastyducks, 2019-08-25.

# Requires pulseaudio

# Grab input source

printf "### Micspam for Discord and TF2 ###\n"
printf "Select audio source:\n"
pactl list sink-inputs | grep -E "media\.name|application\.process\.binary|application\.name|Sink Input " | sed -E 's/(.*= |Sink Input )//' | paste - - - -
read -p "> Enter number: " SinkInputNumber
printf "Source set to Sink Input #$SinkInputNumber...\n"

# Pipe output

# Create null sink
pactl load-module module-null-sink sink_name=MicspamNullSink sink_properties=device.description=MicspamNullSink > /dev/null
# Create loopback so we can still hear the audio
pactl load-module module-loopback latency_msec=5 source=MicspamNullSink.monitor > /dev/null

# Grab output source.
printf "Select audio destination:\n"
pactl list source-outputs | grep -E "media\.name|application\.process\.binary|application\.name|Source Output " | sed -E 's/(.*= |Source Output )//' | paste - - - -
read -p "> Enter number: " AudioDestination

pactl move-sink-input $SinkInputNumber MicspamNullSink
pactl move-source-output $AudioDestination MicspamNullSink.monitor

# Exit

printf "Press q to quit..."
while : ; do
	read -n1 -s key
	if [ "$key" == "q" ]; then
		pactl unload-module module-loopback # It's really important that the loopback is removed first. Otherwise, we get a terrifying screeching feedback loop.
		pactl unload-module module-null-sink
		printf "\n"
		break
	fi
done
