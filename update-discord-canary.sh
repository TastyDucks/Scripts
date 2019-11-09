tar -xf ~/Downloads/discord-canary* -C ~/Downloads/
sudo cp -r ~/Downloads/DiscordCanary/* /usr/share/discord-canary/
trash ~/Downloads/DiscordCanary/
trash ~/Downloads/discord-canary*
echo "Discord updated. Launching..."
discord-canary
exit
