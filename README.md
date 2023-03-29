# TryHackMe OpenVPN Troubleshooting Script

### Script to troubleshoot connectivity to the TryHackMe network using OpenVPN on Linux.

Usage:

- Download the `thm-troubleshoot` script. Saving it to the same place as your OpenVPN configuration pack (`~/Downloads` by default) is advisable, but not essential.
- In your Linux terminal, make the script executable with `chmod +x <path-to-script>`. If you downloaded the script to your Downloads folder, this will be `chmod +x ~/Downloads/thm-troubleshoot`.
- Run the script by typing `sudo` followed by the path to the script into your terminal and pressing enter. If the script is in your downloads, it will be the following command: `sudo ~/Downloads/thm-troubleshoot`.
- The script will instruct you on how to proceed from there.

**Disclaimer -- this script was originally designed to work on Kali, Ubuntu, or other Debian based systems to solve basic OpenVPN errors. If you're using a non-recommended distribution then it is assumed that you can also troubleshoot these errors manually**

**March 2023 update -- the script has been updated to support Arch linux users! With that said, Arch is still a non-recommended distribution. Using this flavor of linux is almost certainly guaranteed to lead to other more specific connection issues that this script won't be able to cover, ultimately taking away from the learning experience at TryHackMe. Use it at your own discretion.**

Any question or issues (or if connectivity problems persist), please ask in the [TryHackMe Discord server](https://discord.gg/F7ERYzz).
Happy Hacking!
