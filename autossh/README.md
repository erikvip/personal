
cp autossh.default /etc/default/autossh
cp autossh.service /lib/systemd/system/autossh.service
sudo ln -s /lib/systemd/system/autossh.service /etc/systemd/system/autossh.service
sudo systemctl daemon-reload
# Debugging
systemctl status autossh --output cat --lines 2000

