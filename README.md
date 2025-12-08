# TryHackMe OpenVPN Troubleshooting Script

Script to troubleshoot connectivity to the TryHackMe network using OpenVPN on Linux.

## Usage

1. Download the `thm-troubleshoot` script
2. Save it in the same folder as your `.ovpn` config file (or provide the path when prompted)
3. Make it executable: `chmod +x thm-troubleshoot`
4. Run with sudo: `sudo ./thm-troubleshoot`
5. Follow the on-screen instructions

**Check version:** `./thm-troubleshoot --version`

## Supported Distros

- **Debian/Ubuntu** (apt)
- **Arch Linux** (pacman)
- **Fedora/RHEL** (dnf)

Other distributions should work but may require manual OpenVPN installation.

## What This Script Checks

- Internet connectivity
- OpenVPN installation (offers to install if missing)
- VPN connection and tun0 interface
- Correct IP range (192.168.x.x for current infrastructure)
- Multiple VPN connection conflicts
- MTU issues
- Routes to target VMs (10.x.x.x)

## Known Issues

### OpenVPN 2.5 (Ubuntu 22.04 and older)
The new TryHackMe configs use inline `<auth-user-pass>` which requires OpenVPN 2.6+. The script will detect this and provide solutions.

### Network Rooms
This script does **not** support Network room VPNs (rooms with a network diagram at the top). Those use separate configs downloadable from the [Access page](https://tryhackme.com/manage-account/access).

## Links

- [TryHackMe Access Page](https://tryhackme.com/manage-account/access) - Download VPN configs
- [TryHackMe Discord](https://discord.gg/tryhackme) - Get help from the community

---

**Note:** Make sure your VPN server region matches your target VM region in the Access page settings.
