# Systemd example for OWI. Install as a USER unit (no root needed):
#
#   mkdir -p ~/.config/systemd/user
#   cp systemd/ollaya-webui.service ~/.config/systemd/user/
#   systemctl --user daemon-reload
#   systemctl --user enable --now ollaya-webui
#   journalctl --user -u ollaya-webui -f
#
# KillMode=process keeps a managed `ollaya mcp --http` child alive across
# OWI restarts. OWI_PORT sets the listen port (default 11524).
# For a SYSTEM unit instead, copy to /etc/systemd/system/ and replace
# %h with the absolute path (/home/<user>/Programs/ollaya/webui).
