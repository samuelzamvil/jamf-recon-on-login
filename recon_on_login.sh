#!/bin/bash
# Samuel Zamvil
# Stanford University

# Get UID of the current user
CURRENT_USERNAME=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
CURRENT_UID=$(id -u $CURRENT_USERNAME)


# Log function for script logging
# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    # You might want to add logging to a file here
}

if [ ! -d "/usr/local/com.github.samuelzamvil/scripts" ]
then
    log_message "Creating directory /usr/local/com.github.samuelzamvil/scripts"
    mkdir -p /usr/local/com.github.samuelzamvil/scripts
fi

log_message "Creating LaunchAgent and LaunchDaemon to run jamf recon on next login"

cat << EOF > /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.github.samuelzamvil.recentlogin</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>touch /tmp/recent_login.flag</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

if [ -f /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist ]; then
    log_message "Created LaunchAgent plist file: /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist"
else
    log_message "Failed to create LaunchAgent plist file: /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist"
    exit 1
fi

cat << EOF > /Library/LaunchDaemons/com.github.samuelzamvil.jamfrecon.onceonlogin.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.github.samuelzamvil.jamfrecon.onceonlogin</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>60</integer>
</dict>
</plist>
EOF

if [ -f /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist ]; then
    log_message "Created LaunchAgent plist file: /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist"
else
    log_message "Failed to create LaunchAgent plist file: /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist"
    exit 1
fi

log_message "Create main script to run jamf recon on next login and self-destruct"

cat << 'EOF' > /usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh
#!/bin/bash

if [ -f /tmp/recent_login.flag ]; then
    # Wait 45 seconds to ensure login processes are complete
    sleep 45
    
    # Remove the flag file
    rm /tmp/recent_login.flag

    # Run jamf recon
    /usr/local/jamf/bin/jamf recon

    # Clean up LaunchAgent
    sudo -u $CURRENT_USERNAME launchctl unload /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist
    rm -f /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist

    # Remove this script
    rm -f "/usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh"
    
    # Clean up LaunchDaemon
    rm -f /Library/LaunchDaemons/com.github.samuelzamvil.jamfrecon.onceonlogin.plist
    launchctl bootout system/com.github.samuelzamvil.jamfrecon.onceonlogin
fi
EOF

if [ -f /usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh ]; then
    log_message "Created script file: /usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh"
else
    log_message "Failed to create script file: /usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh"
    exit 1
fi

log_message "Setting permissions on LaunchAgent and LaunchDaemon plist files"

chown $CURRENT_UID:$CURRENT_UID /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist
if [ $? -ne 0 ]; then
    log_message "Failed to set permissions on LaunchAgent and LaunchDaemon plist files"
    exit 1
fi

chmod 644 /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist
if [ $? -ne 0 ]; then
    log_message "Failed to set permissions on LaunchAgent and LaunchDaemon plist files"
    exit 1
fi

chmod 644 /Library/LaunchDaemons/com.github.samuelzamvil.jamfrecon.onceonlogin.plist
if [ $? -ne 0 ]; then
    log_message "Failed to set permissions on LaunchAgent and LaunchDaemon plist files"
    exit 1
fi

log_message "Replacing the CURRENT_USERNAME variable in the script"

# Inline replacement method is used to prevent variable expansion in the above heredoc
sed -i '' "s/\$CURRENT_USERNAME/$CURRENT_USERNAME/" /usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh
if [ $? -ne 0 ]; then
    log_message "Failed to replace the CURRENT_USERNAME variable in the script"
    exit 1
fi

log_message "Setting permissions on the script file"

chmod 700 /usr/local/com.github.samuelzamvil/scripts/recon_on_login_then_self_destruct.sh
if [ $? -ne 0 ]; then
    log_message "Failed to set permissions on the script file"
    exit 1
fi

log_message "Loading LaunchAgent and LaunchDaemon"

# Load the LaunchAgent and LaunchDaemon
launchctl asuser $CURRENT_UID launchctl bootstrap gui/$CURRENT_UID /Library/LaunchAgents/com.github.samuelzamvil.recentlogin.plist
# if process failed log it and exit with error
if [ $? -ne 0 ]; then
    log_message "Failed to load LaunchAgent com.github.samuelzamvil.recentlogin.plist"
    exit 1
fi
launchctl bootstrap system /Library/LaunchDaemons/com.github.samuelzamvil.jamfrecon.onceonlogin.plist
# if process failed log it and exit with error
if [ $? -ne 0 ]; then
    log_message "Failed to load LaunchDaemon com.github.samuelzamvil.jamfrecon.onceonlogin.plist"
    exit 1
fi