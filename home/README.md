# Initial Setup

The `work` and `work-workstation` home profiles are expected to run on Ubuntu 24.04.

## Electron / Chromium sandboxing

Some kernel parameters need to be set.
To make this persistent, add a file under `/etc/sysctl.d/`, via this command:

```shell
sudo tee /etc/sysctl.d/99-electron-sandbox.conf >/dev/null <<'EOF'
kernel.unprivileged_userns_clone=1
kernel.apparmor_restrict_unprivileged_userns=0
EOF
```

Reboot.
