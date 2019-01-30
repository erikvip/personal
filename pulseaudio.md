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

### Set default sink output in /etc/pulse/default.pa

Get the name from 'pacmd list-sinks' output. This used to be 'combined', but 
seems to handle combining automatically now...

'''
#OLD
#load-module module-combine-sink sink_name=combined
#set-default-sink combined
set-default-sink alsa_output.pci-0000_00_07.0.analog-stereo

'''

### Audio permissions

Enable anonymous client connectivity from localhost.  
In /etc/pulse/default.pa:

```
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
```

#### Notes on permission

Pulseaudio runs as the local user. Daemons often run under a different user account, 
and thusly may have issues communicating with pulseaudio. MPD, example. 

You can add the user to the 'audio' group...didn't seem to work for me. Adding the 
above anonymous grant seemed to fix MPD. 


### MPD Troubleshooting

* Verify we only have 1 pulseaudio instance running.  MPD sometimes appears to launch it's own pulseaudio instance (if no permission?), which may cause MPD to not work, while system sounds work fine.  
* pulseaudio --kill will only control instances owned by the current user. 
* sudo killall pulseaudio && pulseaudio --start 
* sudo usermod -G audio <username>
* Verify mpd is set to use Pulseaudio, and *not* ALSA directly. 
** The ALSA config may work, but it blocks other apps, and may be blocked itself if a different application is playing audio. Pulse handles talking to ALSA and mixing all the app's sounds together. 

#### Example mpd.conf setup for Pulse audio

```
audio_output {
    type        "pulse"
    name        "My Pulse Output"
    server      "localhost"     # optional
    mixer_type  "software"
}
```


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


## PulseAudio MONO Setup
ATM I'm stuck with only one Monitor since the other broke.  Here's how to create a new 'MONO' sink that's only one channel, so MPD and stuff will sound right. 

### Test setup
This creates a temporary sink, which will be lost the next time Pulse stops / starts, good for testing -

```
# pacmd list-sinks | grep name:
        name: <combined>
        name: <mono>
        name: <alsa_output.pci-0000_00_07.0.analog-surround-51>
# pacmd load-module module-remap-sink sink_name=mono master=alsa_output.pci-0000_00_07.0.analog-surround-51 channels=2 channel_map=mono,mono
```
Note the master= attribute should be set to the physical device / sink. 

Should be ready to go now, open the volume/mixer controls (pavucontrol) and set the default stream output to the new remapped interface

To save this change, just put the load-module command from above into /etc/pulse/default.pa & stop/start pulseaudio




