# Jamf Recon on Next Login

This script sets up a mechanism to run Jamf Recon on the next user login and then self-destruct.

## Overview

This Bash script creates a LaunchAgent and a LaunchDaemon to trigger a Jamf Recon inventory update when a user logs in. After the Recon is complete, the script and associated files clean up after themselves.

## Features

- Creates a LaunchAgent to detect user login
- Sets up a LaunchDaemon to run a script at regular intervals
- Runs Jamf Recon after a short delay on user login
- Self-destructs after successful execution

## Important Warning

⚠️ This script creates LaunchAgent and LaunchDaemon items that may trigger a "Background Items Added" prompt on macOS. To prevent this, you must have a configuration profile in place that allows managed login items for the following labels:

- `com.github.samuelzamvil.recentlogin`
- `com.github.samuelzamvil.jamfrecon.onceonlogin`

Without this configuration profile, users will see notifications about background items being added, which may cause confusion or concern.

## Requirements

- macOS
- Jamf Pro
- Root privileges to run the script

## Installation in Jamf Pro

1. Log in to your Jamf Pro server.

2. Add the script to Jamf Pro:
   - Go to Settings > Computer Management > Scripts
   - Click "New"
   - Name the script (e.g., "Setup Jamf Recon on Next Login")
   - Copy and paste the entire script content into the "Script Contents" field
   - Save the script

3. Create a policy to run the script:
   - Go to Computers > Policies
   - Click "New"
   - General
     - Name the policy (e.g., "Run Jamf Recon on Next Login")
     - Trigger: Choose as needed (e.g., Recurring Check-in, Custom)
     - Execution Frequency: Once per computer
   - Scripts
     - Add the script you created in step 2
   - Scope
     - Configure the scope as needed for your environment
   - Save the policy

4. The policy will now run on computers in the specified scope, setting up the Jamf Recon on next login mechanism.

## How it works

1. The script creates a LaunchAgent (`com.github.samuelzamvil.recentlogin.plist`) that touches a flag file on user login.
2. It also creates a LaunchDaemon (`com.github.samuelzamvil.jamfrecon.onceonlogin.plist`) that runs a script every 60 seconds.
3. The script (`recon_on_login_then_self_destruct.sh`) checks for the flag file, runs Jamf Recon if present, and then cleans up all associated files and itself.

## Logging

The script logs its actions. You may want to modify the `log_message` function to write logs to a file for debugging purposes.

## Customization

- Modify the script paths if your Jamf installation is in a non-standard location.
- Adjust the sleep duration in the `recon_on_login_then_self_destruct.sh` script if needed.

## Troubleshooting

- Check the Jamf Pro policy logs to ensure the script is running as expected.
- If the Recon isn't triggering, verify that the LaunchAgent and LaunchDaemon are being created correctly.
- Ensure that the script has the necessary permissions to run on the target machines.

## Author

Samuel Zamvil

## Caution

This script makes changes to the system's LaunchAgents and LaunchDaemons. Use with care and test thoroughly in a non-production environment before deployment.