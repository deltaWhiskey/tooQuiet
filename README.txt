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

    Instead of checking for activity on "ubuntu" user, check for activity
    on current user (crontab user.)


    Default to sending mail to current user, so that user can configure who
    gets notifications via .forward file.

