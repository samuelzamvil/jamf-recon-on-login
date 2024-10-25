# Jamf Recon Once on Next Login

This script sets up a mechanism to run Jamf Recon on the next user login and then self-destruct.

## Overview

This Bash script creates a LaunchAgent and a LaunchDaemon to trigger a Jamf Recon inventory update when a user logs in. After the Recon is complete, the script and associated files clean up after themselves.

## Features

- Creates a LaunchAgent to detect user login
- Sets up a LaunchDaemon to run a script at regular intervals
- Runs Jamf Recon after a short delay on user login
- Self-destructs after successful execution

## Requirements

- macOS
- Jamf Pro client installed
- Root privileges to run the script

## Installation

1. Save the script to a file (e.g., `setup_jamf_recon_on_login.sh`)
2. Make the script executable: `chmod +x setup_jamf_recon_on_login.sh`
3. Run the script with root privileges: `sudo ./setup_jamf_recon_on_login.sh`

## How it works

1. The script creates a LaunchAgent (`com.github.samuelzamvil.recentlogin.plist`) that touches a flag file on user login.
2. It also creates a LaunchDaemon (`com.github.samuelzamvil.jamfrecon.onceonlogin.plist`) that runs a script every 60 seconds.
3. The script (`recon_on_login_then_self_destruct.sh`) checks for the flag file, runs Jamf Recon if present, and then cleans up all associated files and itself.

## Logging

The script logs its actions. You may want to modify the `log_message` function to write logs to a file for debugging purposes.

## Customization

- Modify the script paths if your Jamf installation is in a non-standard location.
- Adjust the sleep duration in the `recon_on_login_then_self_destruct.sh` script if needed.

## Author

Samuel Zamvil

## Caution

This script makes changes to the system's LaunchAgents and LaunchDaemons. Use with care and test thoroughly in a non-production environment before deployment.