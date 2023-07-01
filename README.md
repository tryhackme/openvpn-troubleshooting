# TryHackMe OpenVPN Troubleshooting Script

### Script to troubleshoot connectivity to the TryHackMe network using OpenVPN on Linux.

### Usage:

- Download the `thm-troubleshoot` script. Saving it to the same place as your OpenVPN configuration pack (`~/Downloads` by default) is advisable, but not essential.
- In your Linux terminal, make the script executable with `chmod +x <path-to-script>`. If you downloaded the script to your Downloads folder, this will be `chmod +x ~/Downloads/thm-troubleshoot`.
- Run the script by typing `sudo` followed by the path to the script into your terminal and pressing enter. If the script is in your downloads, it will be the following command: `sudo ~/Downloads/thm-troubleshoot`.
- The script will instruct you on how to proceed from there.

**Disclaimer -- this script was originally designed to work on Kali, Ubuntu, or other Debian based systems to solve basic OpenVPN errors. If you're using a non-recommended distribution then it is assumed that you can also troubleshoot these errors manually**

**March 2023 update -- the script has been updated to support Arch linux users! With that said, Arch is still a non-recommended distribution. Using this flavor of linux is almost certainly guaranteed to lead to other more specific connection issues that this script won't be able to cover, ultimately taking away from the learning experience at TryHackMe. Use it at your own discretion.**

### Arguments:

- `-n` or `--no-interaction`: Run the script without any interaction. (Use default options for all prompts)
    <blockquote>
    
    This is useful if you want to run the script from another script, or if you want to run the script in the background. 
    
    If you want to run the script in the background, you can use the following command: `sudo ~/Downloads/thm-troubleshoot --no-interaction &`. This will run the script in the background and allow you to continue using your terminal. 
    
    If you want to suppress output, you can use the following command: `sudo ~/Downloads/thm-troubleshoot --no-interaction > ~/Downloads/thm-troubleshoot.log`. This will run the script in the background and save the output to a log file in your Downloads folder.

    Be sure to run the script with `sudo` and make sure you have your OpenVPN configuration file at the same path as the script if you want to use the `--no-interaction` argument.

    </blockquote>

Any question or issues (or if connectivity problems persist), please ask in the [TryHackMe Discord server](https://discord.gg/F7ERYzz).
Happy Hacking!
