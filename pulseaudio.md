# PulseAudio Setup

Notes on my pulseaudio installation. PA was acting screwy in 14.04, after  
upgrading to 16.04, it appeared fixed, but had issues w/ my video driver. After screwing with the nvidia driver, audio was completely broken.  This is a general troubleshooting guide. 

## Audio Setup

I use front and back outputs, which must be combined. 

As usual, try restarting pulseaudio and alsa

'''
pulseaudio --kill
pulseaudio --start
sudo alsa force-reload
'''

### Reinstall Pulseaudio and ALSA

'''
sudo apt-get purge alsa-base pulseaudio
sudo apt-get install alsa-base pulseaudio
'''

### Enable combined output in /etc/pulse/default.pa

'''
load-module module-combine-sink sink_name=combined
set-default-sink combined
'''

### Useful commands

'''
pulseaudio --dump-modules
pulseaudio --dump-conf
paman
pacmd list-sinks
paprefs
aplay -l
'''

### Pulseaudio equalizer

Package must be installed from wepupd8 ppa

'''
sudo add-apt-repository ppa:nilarimogard/webupd8; 
sudo apt-get update;
sudo apt-get install pulseaudio-equalizer
'''

## More info

Some useful pulseaudio example configs :

https://wiki.archlinux.org/index.php/PulseAudio/Examples#PulseAudio_over_network

