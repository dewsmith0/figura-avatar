## focusedWindow
For `focusedWindow.lua` (the AFK emoji thing) to work, you need some external setup. 

1. **__Be on systemd-based Linux with KDE Plasma on Wayland. Very important step.__**
2. Get FocusNotifier. A copy with Step 3's changes already made has been provided here, but you can get it from the original repo [here](https://github.com/c-massie/FocusNotifier) if you don't trust me. 
3. Install FocusNotifier as a KWin script. Copy the folder you got to `~/.local/share/kwin/scripts` System Settings -> Window Management => KWin Scripts -> tick `FocusNotifier`, then click "Apply". 
4. *(Optional, if you got it from the source)* Remove or comment out the `echo` lines in `helpers/bashscripts/FocusNotifierListener.sh`, **ONLY where the line does NOT have a `>` or `|`. This will prevent it from spamming your system log whenever your window focus changes.
5. Run `install.sh` from the FocusNotifier directory. Not the 
6. As root, save the following script as `/usr/local/lib/figurafocus.sh`, and run `chmod 0744 /usr/local/lib/figurafocus.sh`:
```bash
#!/bin/bash
mkdir -p /tmp/FocusNotifier
FOCUS_TARGET_PATH=### CHANGE THIS TO "processdata" IN YOUR FIGURA DATA FOLDER 
FOCUS_TARGET_USER=1000:1000 ### CHANGE 1000:1000 TO YOUR OWN UID:GID, IF DIFFERENT
chown "$FOCUS_TARGET_USER" /tmp/FocusNotifier 

(/usr/bin/mountpoint -q "$FOCUS_TARGET_PATH")
FOCUS_MOUNTPOINT_CHECK=$?
echo "attempting to bind mount..."
if [ $FOCUS_MOUNTPOINT_CHECK -eq 32 ]; then
  /usr/bin/mount --bind /tmp/FocusNotifier --target "$FOCUS_TARGET_PATH"
  echo "bind mounted FocusNotifier!" 
else
  echo "FocusNotifier is already mounted"
fi
``` 
This script will make `/tmp/FocusNotifier` accessible in your Figura data folder, under the subdirectory `processdata`. **___Don't forget to change the values in the variables.___**  

7. As root, save the following file as `/usr/local/lib/systemd/system/figurafocus.service`, so that the previous script gets run on startup. Make sure to `chmod 644` it.
```ini
[Unit]
Description=FiguraFocus
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/lib/figurafocus.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
8. Enable and start the service you just made with `sudo systemctl enable --now figurafocus.service`. This will make it actually run on startup.
9. I forgot if there any other steps, sorry. It'll probably work, though. I don't know, only Roxi and I have used this script.
10. Oh right, if you want to change the emojis that appear in your nameplate, add their executable names to the `programEmojis` table in `focusedWindow.lua`.


### The other way
Instead of doing all this with the bind mounting and systemd service shit, you could just change FocusNotifier's target path in its scripts to be in your Figura data folder. The only drawback I see with this is it would do a lot of writes, which might degrade your SSD over time. If you still want to do this, change `VARDIR` in `activewindow` and `FocusNotifierListener.sh`, and skip steps 6 to 8. I do not take responsibility for SSD wear. 