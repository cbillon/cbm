# logging

Here is what I would like to achieve:
[site](https://blog.tratif.com/2023/01/09/bash-tips-1-logging-in-shell-scripts/)
- When running a script a user is presented with concise descriptions of steps performed. It is important to avoid visual clutter and provide the user with the bare minimum of information.
- All commands run, and their outputs (stdout and stderr) logged in detail to a file, which can later be looked at for debugging or confirmation.
- Logs should contain at least some timestamps – we want to know when the script was executed.
- We don’t want the above defined functionalities to impact our process of writing shell scripts.

other formulation

[site](https://developer.cyberark.com/blog/improving-logs-in-bash-scripts/)

The ambitious goal I set out to achieve was a separation of log content by severity so that readers would not have to be forced to wade through mounds of irrelevant information. That means that, if you’re running a suite of integration tests, the main output should contain an overview of the steps that took place and the results. The rest of the output could be stored in different buckets so you can look at it by category as and when you please

# settings
This library sets the following shell options:

`set -uo pipefail`

This is a recommended default for any scripts you write:
  * You should not use unbound variables (-u)
  * You should ensure pipelines fail if any of the commands in the pipeline fail (-o pipefail)

This library does _not_ `set -e` because automatically exiting a script
when any error is encountered is lazy and a poor user experience.
Errors should be caught and handled by your scripts.
This can be supported by the use of this library's 'error' log-level.

If you do not like these settings - change them or remove them.

##

I also read a lot of bullshit about testing the $- bash variable. 
$- can tell if you're in an interactive shell or not.
So if you're wondering exactly what is an interactive shell, please read:
http://zsh.sourceforge.net/Guide/zshguide02.html#l7

Just to quote the most interesting part:

when you are typing at a prompt and waiting for each command to run, the shell is interactive;
in the other case, when the shell is reading commands from a file, it is, consequently, non-interactive.

Checking $- doesn't distinguish between a script run by hand and a script run by Cron: both are non-interactive. 

## explanations

-t is a bash builtin test that checks if a file descriptor is opened and refers to a terminal (man bash for more info).
for normal logs that are supposed to go to stdout (file descriptor number 1), we just check if stdout is connected to a terminal ([[ -t 1 ]]). If yes, we can use echo.

## log levels

Common Log LevelsPermalink
Here’s a breakdown of common log levels, from least to most severe:

DEBUG: Detailed information, typically valuable only for diagnosing problems. These messages contain information that’s most useful when troubleshooting and should include variables, state changes, and decision points.
```
  [DEBUG] "Processing file: $filename with parameters: $params"

```

INFO: Confirmation that things are working as expected. These messages track the normal flow of execution and significant events in your script.
```
  [INFO] "Backup process started for database: $db_name"
```

WARN: Indication that something unexpected happened, or that a problem might occur in the near future (e.g., filesystem running out of space). The script can continue running, but you should investigate.
```
  [WARN] "Less than 10% disk space remaining on $mount_point"
```
ERROR: Due to a more serious problem, the script couldn’t perform some function. This doesn’t necessarily mean the script will exit, but it indicates that an operation failed.
```
  [ERROR] "Failed to connect to database after 3 attempts"
```
FATAL: A severe error that will likely lead to the script aborting. Use this for critical failures that prevent the script from continuing execution.
```
  [FATAL] "Required configuration file not found: $config_file"
```
When to Use Each LevelPermalink
Use DEBUG liberally during development but sparingly in production. It’s perfect for tracing execution flow and variable values.
Use INFO to track normal operation milestones - script start/end, major function completions, or configuration loading.
Use WARN when something unexpected happens but the script can recover or continue.
Use ERROR when an operation fails but the script can still perform other tasks.
Use FATAL only for critical failures that prevent the script from functioning at all.
With proper log levels, both you and others can quickly filter logs to the appropriate level of detail needed for the task at hand - whether that’s real-time monitoring (INFO/WARN/ERROR) or detailed troubleshooting (DEBUG).

