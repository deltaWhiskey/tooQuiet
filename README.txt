OVERVIEW

This is a cron job that turns off a computer if it has been idle too long.
Handy for setting up dev instances to turn themselves off when not needed.

Normal use:  schedule this to run when you are not normally working.  If you
leave your SSH sessions open, or use screen, then you can be more agressive
and have this run every hour.


HOW THIS WORKS

Looks at last apache access, and last command line activity, and if they have
been both quiet for long enough, the machine will shut down.

If no one is logged into the command line, that counts as "has been quiet
forever".  Which is not a problem if you only run this script during "off"
hours, or leave your SSH sessions connected, or use "screen" and so leave
sessions open even when not connected to the server.


TODO

Deal with this scenario:  tooquiet.sh can only determine command line idle time
if someone is logged in to computer.  If all sessions are closed when
tooquiet.sh runs, and computer has been running for longer than the
"max idle time" settings, computer will shut off even if last log-off was only
a moment previous.  Tooquiet.sh needs to be smart enough to know that there
has been command line activity recently, even if no one is logged in at the
moment.
