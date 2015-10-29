#!/bin/bash
#
# This is scheduled in CRON.  It shuts down the computer if it has been
# too many hours since a logged-in user has been active.  This is for
# servers that need to turn themselves off when not in use (saving a
# few Amazon bux.)
#
# 30  *   *   *   *   bash /home/ubuntu/bin/tooquiet.sh
#

######################################################
## SETTINGS

email="example@domain.com" # This person gets "shutting down" emails
emailVerbosity=1 # 0=no mail, 1=only on shutdown, 2=email every time script runs
maxMinutesCommandLineInactive=60
maxMinutesApacheInactive=60
apacheAccessLog="/var/log/apache2/access.log"
tempFile="/tmp/tooquiet.tmp"
defaultMinutesCommandLineInactive="999" # Used if can not determine inactivty time



######################################################
## FUNCTIONS

# Get minutes since last command line activity
function commandLineIdleTime ()
{
    local inactiveString=`who -a | grep ubuntu | cut -c 42-46 | sort | head -n1`

    if [ "$inactiveString" == "  .  " ]; then
        echo 0
    elif [ "$inactiveString" == "" ]; then
        # No current user sessions.  Treat as inactive.
        echo $defaultMinutesCommandLineInactive
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

    echo ${minutesPast}
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
        cat $tempFile | /usr/sbin/sendmail ${email}
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
        sudo shutdown -h +5
        exit
    fi
fi

logIt "This machine is still active. Remaining ON."
notify 2
exit


