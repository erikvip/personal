My Pi came w/ Noobs, which handled the base Rasbian install for me. 

- Choose Rasbian
- Also Create Ext4 extended file system
- I don't use scratch, since that's like a kids toy...

Install may take 20-30 minutes

After install, reboot

raspi-config
==============
- 2 : Change user password -> Create a unique password for your local 'pi' user
- 3 : Enable Boot to Desktop/Scratch -> Boot to desktop
- 4 : Internationization options
  -	-> Change Locale -> use en_US.UTF-8 UTF-8. Uncheck anything else. Mine was setup for GB instead of USA
  -	-> Change Timezone -> Choose your timezone (I'm in mountain)
- 8 : Advaned Options
  -	-> A1 Overscan -> Enable
  -	-> A2 Hostname -> Use a unique hostname, no spaces, a-z0-9 and -.  e.g. erikpi
  -	-> A3 Memory Split -> Set to 256
  -	-> A4 SSH -> Enable the SSH server (Make sure you picked a strong password in 'Change User Password')
  -	-> A6 SPI -> leave 'Disabled'
  -	-> A7 I2C -> Enabled, I believe this is necessary for my Piglow LED gpio

Thats's it. TAB to 'Finished' and reboot. 

If you need to get back into this config utility later, you can just run 'sudo raspi-config' from a terminal session. 

After rebooting, you'll be taken to the Rasbian Desktop. 

Setup the Wireless Connection
=============================

- Open termianl via Menu -> Accessories -> Terminal
- Network configuration settings are held under /etc/network/interfaces
- Run: sudo nano /etc/network/interfaces
- wlan0 is your Wireless interface, this is the one we'll be setting up:
  - You'll need to know the SSID (network name), and PSK (Pre shared key, or 'password' for the wireless network)
  - Set iface wlan0 inet dhcp (instead of manual)
  - Remove the wpa-config ... wpa_supplicant.conf line
  - Add wpa-ssid "Your wireless network name"
  - Add wpa-psk "Your wireless key"
  - The interfaces file should now look something like this:

     > auto wlan0

     > allow-hotplug wlan0

     > iface wlan0 inet dhcp

     > wpa-ssid "My Network"

     > wpa-psk mysupersecretpassword

- Save / exit the editor. (This is: ctrl+o, [enter], ctrl+x)
- Bring up the network by running these two commands:

   > sudo ifdown wlan0

   > sudo ifup wlan0

- Wireless *should* be connected, if everything was supplied correctly. 
- To test, run 'ifconfig wlan0' and look for the 'inet addr:' which is your IP address
- If you don't have an IP address, wait a few seconds and try again. 
- Once you have an address, you should be able to 'ping google.com and get a resonse, or load a webpage through Ephiphany Web Browser
- You should also have a Wireless Signal Strength indicator in the upper right of the screen, by the time. 

*Note:* Well, after typing all that crap...it looks like you may be able to just hit the 'Computer Network' icon in the upper right of the screen to configure wireless settings. Oh well, either way works. Just make sure you've got the internet working so we can install more packages. 

- Fix the user account
Keyboard inputs in Kodi won't take input from the keyboard, it only sees keys as shortcuts and you're unable to type directly into the inputs.  A dumbwork around is to chmod 0777 /etc/tty0 (But this must be done after every boot). 

A better fix, is change the account Kodi runs under ('kodi' by default). Change it to 'pi', so it has access to everything it's suppose to (like the /dev/input for the keyboard). 

- Edit /etc/init/kodi.conf file:

  > env USER=kodi

    to

  > env USER=pi

The above also seems to fix the blank screen after exiting Kodi. 

- Video may be choppy and/or unable to play certain files (black screen, but audio plays)

- Install VLC for additional codecs (apt-get install vlc)
- Under VLC preferences -> Video:
  - Video Output: "X11 video output (XCB)" **Not: XVideo output**
  - Audio Output: ALSA

- Verify shared memory is set to 256MB (raspi-config, or edit it under /boot/config.txt, gpu_mem=256)

Check out the max_usb_current ** config.txt option
http://elinux.org/RPiconfig#Memory

