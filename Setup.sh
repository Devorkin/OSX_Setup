#! /bin/bash

. OS_version.sh

####
## Credits to:
## dannysmith/osx_setup.sh      -   https://gist.github.com/dannysmith/9369950
## hbiede/defaults.sh           -   https://github.com/hbiede/Scripts/blob/master/defaults.sh
## mathiasbynens/.macos         -   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
## kevinSuttle/macOS-Defaults   -   https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos
####

##### Missing #####
# Set OSX to dark mode or auto-mode
#####

# Script variables
set -o nounset
echo $(tput sgr0)
Args=("$@")
OSname=''
OStype=''
OSversion=''

# Output templates:
description_msg() {
	echo -e "$(tput setaf 10)--> $*$(tput sgr0)"
}
error_msg() {
	echo -e "$(tput setaf 1)(X) --> $*$(tput sgr0)"
}
notification_msg() {
	echo -e "$(tput setaf 3)##\n## $*\n##\n$(tput sgr0)"
}
output_msg() {
	echo -e "$(tput setaf 2)--> $*$(tput sgr0)"
}
query_msg() {
	echo -e "$(tput setaf 9)--> $*$(tput sgr0)"
}
warning_msg() {
	echo -e "$(tput setaf 3)(!) --> $*$(tput sgr0)"
}
function echodo {
	output_msg "$@"
	"$@"
}

### Main ###
if [ $EUID == 0 ]; then
	error_msg "### This script must run WITHOUT Root privileges!"
	exit 101
fi

OS_type
OS_version

if [[ ${OStype} != "OSX" ]]; then
    error_msg "This script supposed to be used on Mac OS only!"
    exit 106
fi

## Kill all affected processes
osascript -e 'tell application "System Preferences" to quit'

# OS
## Configures Screen Saver
# Enabling Screensaver and disabling auto-lock system while this script is running
echodo defaults -currentHost delete com.apple.screensaver 2> /dev/null
# Set specific screensaver
echodo defaults -currentHost write com.apple.screensaver 'moduleDict' '{ moduleName = Arabesque; path = "/System/Library/Screen Savers/Arabesque.saver"; }'
# Require the user to re-login after screensaver
echodo defaults -currentHost write com.apple.screensaver CleanExit -string "YES"
# Start screensaver after 5mins of idle time
echodo defaults -currentHost write com.apple.screensaver idleTime -string "300"
# Require password immediately after sleep or screen saver begins
echodo defaults write com.apple.screensaver askForPassword -int 1
echodo defaults write com.apple.screensaver askForPasswordDelay -int 0

## Configures computer name
echodo sudo scutil --set ComputerName "$USER-MBP"
echodo sudo scutil --set HostName "$USER-mbp"
echodo sudo scutil --set LocalHostName "`echo $USER | sed 's/\./-/g'`-MBP"
# Set NetBios computer name
echodo sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$USER-mbp"

## Configures SSH
# Make sure to allow UTF-8 encoding over SSH tunnel
echodo sudo sed -i.original 's/SendEnv/#SendEnv/' /etc/ssh/ssh_config

## Configures Energy saver
# Configuring system power usage while using battery power
echodo sudo pmset -b disksleep 15
echodo sudo pmset -b sleep 15
echodo sudo pmset -b displaysleep 10
echodo sudo pmset -b womp 0
echodo sudo pmset -b powernap 0

# Configuring system power usage while using power socket
echodo sudo pmset -c sleep 0
echodo sudo pmset -c disksleep 0
echodo sudo pmset -c womp 1
echodo sudo pmset -c displaysleep 0
echodo sudo pmset -c powernap 1
echodo sudo pmset -c autorestart 0

## Configures Displays
which brightness > /dev/null
if [ $? == 0 ]; then
    # Set Mac Book computer internal display to full brightness
    echodo /usr/local/bin/brightness 1 2> /dev/null
fi

## Configures Keyboard
# Enabling the keyboard full access over OS X GUI
echodo defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Set a really fast key repeat
echodo defaults write NSGlobalDomain KeyRepeat -int 1
# Disable holding pressed key action
echodo defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

## Configures Trackpad
# Disabling trackpad\Mouse scroll Apple natural behaviour
echodo defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 0
echodo defaults write -g com.apple.swipescrolldirection -bool false

## Configure Bluetooth
# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40                 # Should be tested

## Configures Time, Date & NTP
if [ "`sudo systemsetup -gettimezone`" != 'Time Zone: Asia/Jerusalem' ]; then
    # Configuring system time zone
    echodo sudo systemsetup -settimezone Asia/Jerusalem > /dev/null
fi
if [ "`sudo systemsetup -getusingnetworktime`" != 'Network Time: On' ]; then
    # Configuring system NTP
    echodo sudo systemsetup -setusingnetworktime on > /dev/null
fi

## Configure Bash
### Moved to Zsh shell instead - so this is disabled
### Zsh will be managed by another package
# if [[ ! -f $HOME/.bash_profile ]]; then
#     echodo cp ./Bash/bash_profile $HOME/.bash_profile
#     echodo source $HOME/.bash_profile
# else
#     warning_msg ".bash_profile configuration file is already exist!"
# fi

## Configures Dock
# Clearing all icons\shortcuts from the Dock for fresh start
echodo defaults write com.apple.dock persistent-apps -array
# Stopping auto-rearrange of Desktop spaces
echodo defaults write com.apple.dock mru-spaces -bool false
# Remove the auto-hiding Dock delay
echodo defaults write com.apple.dock autohide-delay -float 0
# Automatically hide and show the Dock
echodo defaults write com.apple.dock autohide -bool true
# Enable highlight hover effect for the grid view of a stack (Dock)
echodo defaults write com.apple.dock mouse-over-hilite-stack -bool true
# Minimize windows into their application’s icon
echodo defaults write com.apple.dock minimize-to-application -bool true
# Turn on Dock magnification
echodo defaults write 'com.apple.dock' 'magnification' -bool true
# Change Dock magnification largest size to 90px
echodo defaults write com.apple.dock 'largesize' -int 90
# Change Dock magnification normal size to 50px
echodo defaults write com.apple.dock 'tilesize' -int 50

## Configures Finder
# Show hidden files in Finder
echodo defaults write com.apple.Finder AppleShowAllFiles -bool true
# Show path bar in Finder
echodo defaults write com.apple.Finder ShowPathbar -bool true
# Show status bar in Finder
echodo defaults write com.apple.Finder ShowStatusBar -bool true
# Show Laptop battery capacity in percentage
# echodo defaults write com.apple.menuextra.battery ShowPercent -string "YES"
# Show laptop battery time 'till battery drain out of power
echodo defaults write com.apple.menuextra.battery ShowTime -string "NO"
# Show Date and Time format in the system bar
echodo defaults write com.apple.menuextra.clock DateFormat -string 'H:mm'
# Disabling Time Machine from automatic external drive detection
echodo defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
# Expand Print Dialog Boxes by default
echodo defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
echodo defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# Adding the Bluetooth icon to the Taskbar
echodo open '/System/Library/CoreServices/Menu Extras/Bluetooth.menu' 2> /dev/null
# Show warning before emptying the Trash
echodo defaults write 'com.apple.finder' 'WarnOnEmptyTrash' -bool false
# Display full POSIX path as Finder window title
echodo defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Keep folders on top when sorting by name
echodo defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Allow text selection in Quick Look
echodo defaults write com.apple.finder QLEnableTextSelection -bool true
# Show the home folder instead of all files when opening a new finder window
echodo defaults write com.apple.finder NewWindowTarget PfHm
# When performing a search, search the current folder by default
echodo defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Avoid creating .DS_Store files on network or USB volumes
echodo defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
echodo defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
echodo defaults write com.apple.finder FXPreferredSearchViewStyle -string "Nlsv"
echodo defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Disable the “Are you sure you want to open this application?” dialog
echodo defaults write com.apple.LaunchServices LSQuarantine -bool false
# Expand Print Dialog Boxes by default
echodo defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
echodo defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
# Show all filename extensions
echodo defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Disable the warning before emptying the Trash
echodo defaults write com.apple.finder WarnOnEmptyTrash -bool false
# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
echodo defaults write NSGlobalDomain AppleLanguages -array "en-IL" "he-IL"
echodo defaults write NSGlobalDomain AppleLocale -string "en_IL"
echodo defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
echodo defaults write NSGlobalDomain AppleMetricUnits -bool true
# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# AirDrop
# Use AirDrop over every interface. srsly this should be a default.
echodo defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Create Applications directory
echodo defaults read com.apple.dock persistent-others 2> /dev/null | grep '_CFURLString' | grep Applications > /dev/null
if [ $? != 0 ] ; then
    # Adding "Applications" directory shortcut to the Dock and changing the "Downloads" directory dock icon
    echodo dockutil --add /Applications --view grid --display folder --sort name
    echodo dockutil --add $HOME/Downloads --view grid --display folder --sort name --replacing Downloads
fi

## Configures Activity Monitor
# Show all processes in Activity Monitor
echodo defaults write com.apple.ActivityMonitor ShowCategory -int 0

## Configures App Store
# Set auto-OS update check for daily, by default set to weekly
echodo defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
# Enable the automatic update check
echodo defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
# Download newly available updates in background
echodo defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
# Automatically download apps purchased on other Macs
echodo defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
# Enable the WebKit Developer Tools in the Mac App Store
echodo defaults write com.apple.appstore WebKitDeveloperExtras -bool true
# Enable Debug Menu in the Mac App Store
echodo defaults write com.apple.appstore ShowDebugMenu -bool true

## Configures Dashboard
# Disable Dashboard
echodo defaults write com.apple.dashboard mcx-disabled -bool true
# Don’t show Dashboard as a Space
echodo defaults write com.apple.dock dashboard-in-overlay -bool true

## Configures Disk Utility
# Enable the debug menu in Disk Utility
echodo defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
echodo defaults write com.apple.DiskUtility advanced-image-options -bool true

# Configures Google Chrome
# Disable the all too sensitive backswipe on trackpads
echodo defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
echodo defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
# Disable the all too sensitive backswipe on Magic Mouse
echodo defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
echodo defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

## Configures Photos
# Prevent Photos from opening automatically when a device is plugged in
echodo defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

## Configures Terminal & iTerm2
# Disabling smart quotes
echodo defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false
# Configuring Terminal to use the \"Pro\" theme by default
echodo defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"
echodo defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
# Only use UTF-8 in Terminal.app
echodo defaults write com.apple.terminal StringEncodings -array 4

if [ -d /Applications/iTerm.app ]; then
    # Create local iTerm2 configuration directory
    if [ ! -d $HOME/.iterm2 ]; then
        echodo mkdir $HOME/.iterm2
    fi
    echodo cp $(pwd)/iTerm/* $HOME/.iterm2/
    # Importing iTerm2 configurtion
    echodo defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -int 1
    echodo defaults write com.googlecode.iterm2 NoSyncPermissionToShowTip -int 0
    echodo defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2/"
    echodo defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -int 1
fi

## Configures Safari
# Configuring Safari to work in Developer mode
echodo defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
# Checks if the Developer menu appears in Safari
echodo defaults write com.apple.Safari IncludeDevelopMenu -bool true
# Checks if the Developer Debug menu appears in Safari
echodo defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
# Another thing related to Safari Develper tools
echodo defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
# Allow hitting the Backspace key to go to the previous page in history
echodo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true
# Privacy: don’t send search queries to Apple
echodo defaults write com.apple.Safari UniversalSearchEnabled -bool false
echodo defaults write com.apple.Safari SuppressSearchSuggestions -bool true
# Enable continuous spellchecking
echodo defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
echodo defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false
# Warn about fraudulent websites
echodo defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true
# Enable “Do Not Track”
echodo defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
# Update extensions automatically
echodo defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

## Configures MS Visual Studio Code
if [ -d "/Applications/Visual\ Studio\ Code.app" ]; then
    if [ -f "$HOME/Library/Application\ Support/Code/User/settings.json" ]; then
        echodo rm -f "$HOME/Library/Application\ Support/Code/User/settings.json"
    fi
    echodo ln -s ./Code/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
fi

## Import Übersicht widget
# if [ -d /Applications/Übersicht.app ]; then
#     if [[ ! `pgrep Übersicht`]]
#     echodo /Applications/Übersicht.app/Contents/MacOS/Übersicht 2> /dev/null 1> /dev/null &bg
#     echodo cd $HOME/Library/Application\ Support/Übersicht/widgets
#     echodo git clone git@github.com:Devorkin/theonewidget.git
# fi

## Configures Wireshark
if [ -d /Applications/Wireshark.app ]; then
	# Setting ownership and configuration as needed
	echodo sudo dseditgroup -o edit -a $USER -t user access_bpf
fi

# Kill all affected processes & apps
osascript -e 'tell application "System Preferences" to quit'

for app in \
    "Activity Monitor" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"Google Chrome" \
	"Photos" \
	"Safari" \
	"SystemUIServer" \
	"iTerm" \
 	"iCal" \
    "Übersicht"; do
 	killall "${app}" &> /dev/null
done

query_msg "It is recommended to restart the system now, Unless you would like to run another script to continue and prepare your system."
warning_msg "Some changes requires a system restart to take effect!"
output_msg "To restart your system type: sudo shutdown -r now"