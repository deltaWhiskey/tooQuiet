OVERVIEW

This is a cron job that turns off a computer if it has been idle too long.
It was originally developed to help a programmer keep his bills down by making
computers shut themselves off when not needed.


HOW THIS WORKS

tooquiet.sh looks at last apache access, and last command line activity, and if
they have been both quiet for long enough, it shuts down the computer.

If no one is logged into the command line (that includes no Byobu or Screen
sessions), tooquiet.sh will assume the computer has been idle since last bootup.


INSTALL INSTRUCTIONS

1) Place tooquiet.sh wherever you like.
2) If you want to override some settings, copy override-example.conf to
   "override.conf" in the same directory as tooquiet.sh, and make any changes
   you like.
3) Add tooquiet.sh to crontab.  There are two strategies:  if you only need
   the computer to shut off "after hours" (and only if you're not working late
   that night), then schedule the job to run at night, or whevever you are
   normally away from the keyboard.  If you want tooquiet.sh to be more active
   (for example, so your computer will shut down if you get called into an
   all-afternoon meeting) then you can make this run more often.  Here's an
   example of a crontab entry that runs this job every 30 minutes:
       30  *   *   *   *   bash <pathToTooQuiet>/tooquiet.sh



TODO

Deal with this scenario:  tooquiet.sh can only determine command line idle time
if someone is logged in to computer.  If all sessions are closed when
tooquiet.sh runs, and computer has been running for longer than the
"max idle time" settings, computer will shut off even if last log-off was only
a moment previous.  Tooquiet.sh needs to be smart enough to know that there
has been command line activity recently, even if no one is logged in at the
moment.
