#!/bin/bash
#
# This is scheduled in CRON.  It shuts down the computer if it has been
# too many hours since a logged-in user has been active.  This is for
# servers that need to turn themselves off when not in use (saving a
# few Amazon bux.)
#
# 30  *   *   *   *   bash <pathToTooQuiet>/tooquiet.sh
#

######################################################
## SETTINGS
## These are the defaults.  Do not edit.  To customize settings,
## see override-example.txt.

testMode=0 # 0 for normal operation, or 1 to disable shutdown and echo instead of emailing
email=`whoami` # This person gets "shutting down" emails
emailVerbosity=1 # 0=no mail, 1=only on shutdown, 2=email every time script runs
maxMinutesCommandLineInactive=120
maxMinutesApacheInactive=120
apacheAccessLog="/var/log/apache2/access.log"
tempFile="/tmp/tooquiet.tmp"

# A few more variables that will come in handy.
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
myUserName=`whoami`

# Load custom settings, if any.
if [ -f ${dir}/override.conf ]
then
    . ${dir}/override.conf
fi


######################################################
## FUNCTIONS

# Get minutes since last command line activity
function commandLineIdleTime ()
{
    local inactiveString=`who -a | grep ${myUserName} | cut -c 42-46 | sort | head -n1`

    if [ "$inactiveString" == "  .  " ]; then
        echo 0
    elif [ "$inactiveString" == "" ]; then
        # No current user sessions.  Figure computer has been idle since boot.
        echo $(upTime)
    else
        local inactiveHours=`echo $inactiveString | cut -c 1-2`
        local inactiveMinutes=`echo $inactiveString | cut -c 4-5`
        local inactiveHourMinutes=`expr ${inactiveHours} \* 60`
        inactiveMinutes=`expr ${inactiveMinutes} + ${inactiveHourMinutes}`
        echo ${inactiveMinutes}
    fi
}

# Get minutes since last apache hit.
function apacheIdleTime ()
{
    local apacheAccessed=`date -r ${apacheAccessLog} +%s`
    local now=`date +%s`
    local secondsPast=`expr ${now} - ${apacheAccessed}`
    local minutesPast=`expr ${secondsPast} / 60`

    # Never report that apache has been idle longer than computer has been on.
    local minutesSinceBoot=$(upTime)
    if [ "${minutesPast}" -gt "$minutesSinceBoot" ]
    then
        minutesPast=$minutesSinceBoot
    fi

    echo ${minutesPast}
}

# Get minutes since boot
function upTime ()
{
    local seconds=`cat /proc/uptime | sed 's/^\([^\.]*\)\..*/\1/'`
    local minutes=`expr ${seconds} / 60`
    echo ${minutes}
}

function logIt ()
{
    echo $1 >> $tempFile
}

function notify()
{
    local priority=${1} # 1 for not shutting down, 2 for shutting down
    if [ "$emailVerbosity" -ge "${priority}" ]; then
        logIt
        local today=`date`
        logIt "${today}" # To discourage Gmail web client from hiding the end of the email
        if [ "$testMode" -eq 0 ]
        then
            cat $tempFile | /usr/sbin/sendmail ${email}
        else
            cat $tempFile
        fi
    fi
    rm $tempFile
}



######################################################
## MAIN ROUTINE

# Initialize the temp file.  This may get used later to send email.
echo "Subject: ${0}" > $tempFile
logIt
logIt "${0} starting up"
logIt

commandLineMinutes=$(commandLineIdleTime)
apacheMinutes=$(apacheIdleTime)

logIt "max command line idle minutes: ${maxMinutesCommandLineInactive}"
logIt "current command line idle minutes: ${commandLineMinutes}"
logIt "max apache idle minutes: ${maxMinutesApacheInactive}"
logIt "current apache idle minutes:  ${apacheMinutes}"
logIt

if [ "$commandLineMinutes" -ge "$maxMinutesCommandLineInactive" ]; then
    if [ "$apacheMinutes" -ge "$maxMinutesApacheInactive" ]; then
        logIt "This machine is idle.  SHUTTING DOWN."
        notify 1
        if [ "${testMode}" -eq "0" ]
        then
            sudo shutdown -h +5
        fi
        exit
    fi
fi

logIt "This machine is still active. Remaining ON."
notify 2
exit


