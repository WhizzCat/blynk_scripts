#!/bin/bash
#
# Update script for Blynk Server on Linux-like systems.
# This script relies on the use of curl for fetching Blynk.jar file
# It also has a reference to "blynk.sh", which is my start script.
#
# My blynk.sh script refers to "server.jar" which is a symbolic link
# to the actual server.jar file. That way it's easy to use in startup
# routines etc.
#
# You can change the variables to your local situation (mine is a Raspberry
# Pi with OpenELEC, hence the Storage path).
#
# This is a really dirty script, it doesn't do RegEx, but just assumes
# that the URL for GitHub will always be the same length (which it
# probably will).

#----------------------------------------------------------
# BEGIN User variables, change these to your situation
#----------------------------------------------------------

# Base path to your Blynk server.jar file
BASE=/storage/blynk

# Startup script name (full path)
STARTUP="$BASE/blynk.sh"

# The symlink used in blynk.sh startup file (full path)
SYMLINK="$BASE/server.jar"

#----------------------------------------------------------
# END USER VARIABLES, change below only if you are sure
# about it ;-)
#----------------------------------------------------------

URL=https://github.com/blynkkk/blynk-server/releases/latest
REDIRECT=`curl $URL`
LATESTVERSION=${REDIRECT:89:6}
DOWNLOAD="http://github.com/blynkkk/blynk-server/releases/download/v$LATESTVERSION/server-$LATESTVERSION.jar"

CURRENT=`readlink $SYMLINK`
CURRENTVERSION=${CURRENT:7:6}

echo "### Current version from Symlink ###"
echo $CURRENTVERSION

echo "### New Version ###"
echo $LATESTVERSION

if [ $CURRENTVERSION = $LATESTVERSION ] ; then
	echo "You are up to date"
	exit 0
else
	echo "New version available, downloading"
	wget $DOWNLOAD
fi

echo "Removing old Symlink and making new one"
rm $SYMLINK
ln -s server-$LATESTVERSION.jar server.jar

# Call the other startup script here
echo "Restarting Blynk server"
/bin/bash $BASE/blynk.sh restart
echo "All done!"
