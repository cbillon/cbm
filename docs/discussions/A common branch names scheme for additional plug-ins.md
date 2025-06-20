# A common branch names scheme for additional plug-ins

[site](https://moodle.org/mod/forum/discuss.php?d=454264)

## No standard rules for plugins
So, when upgrading Moodle, each plug-in needs to be done individually. In a very active site 50 upwards plug-ins are not uncommon in my vicinity. So upgrading has become very time consuming. 

## Andrew Lyons

From my experience, the vast majority of plugins have a single branch, and attempt to support all current versions of Moodle with a single plugin version.

Personally I'd like to see that change a little with one branch per set of releases (with a set ending on the LTS release - e.g. 5.0-5.4 is a set).
Now that the "set of releases", newly called series, is getting formalized in the core, what remains it to request the plug-in developers to open a branch per series.
## The problem

An explanation: In "how would you plan and execute the upgrades?" I used to term "upgrades" to mean all code upgrades:
- core, point releases (third digit) and major upgrades (second digit)
- plug-ins, as a result of core upgrades and/or new features and bug fixes in the plug-in of its own.

The problem I am trying so solve is that currently each component, the core and each plug-in, may need a different set of Git commands.

A couple of the Moodle instances have upward of 50 additional plug-ins installed. We are transitioning from 3.9 LTS to 4.1 LTS. I can see hours and hours of manual, individual Git commands in each plug-in directory.


 Developers of plugins do have to get their submission vetted and approved for listing in Moodle's plugins site. But from what I've read in the past, plugins are not checked ever again. It is up to developer of the plugin to maintain. Think they also have enough access to moodle HQ's plugin site to upload their latest versions.

The only missing part is clear instructions on how to set up and name the Git branches.


One of the nice things about moodle is it has plugins ... one of the bad things about moodle is same! 

## Ken Task

Developers of plugins do have to get their submission vetted and approved for listing in Moodle's plugins site.   But from what I've read in the past, plugins are not checked ever again.   It is up to developer of the plugin to maintain.   Think they also have enough access to moodle HQ's plugin site to upload their latest versions.

Those plugins one downloads (the zips) do not include .git diretories.   Heck, for that matter, neither does moodle releases - those are either .zip's or gzips (.tgz) - include hidden .git directory.   Was informed one time that reason was made the core releases larger ... and that is true.

## Davo Smith

 I'm just pointing out that the code in github is often 'work in progress' code, that may not be fully tested or ready for use in production.

The normal source of plugins that are ready to install on production sites is the Moodle plugins directory.

I'm also not suggesting you write individual git commands or manually install anything, I'm simply suggesting an automated script that pulls plugins from the Moodle plugins directory (gathering the details from the JSON file at the URL I already posted), then adding them to your git repo. Run the script, it fetches everything and commits it to your git repo - it should work for all existing sites and doesn't require any change in process for the deployment of your sites (assuming you are just deploying the branches from your repo for those sites).

As I said above, I know this process can be automated, because it's the main principal behind an internal script we've used to do something similar ourselves (but which also handles a lot of other internal processes, so not suitable to be shared).

## Mark Sharp

There are all sorts of ways of managing a Moodle codebase with plugins. One method I've taken to is to maintain a "codebase" repo that contains a single html folder with all the code in it. That's all brought together with bash scripts that download the respective git repos, and that's controlled by a CSV file where I specify the branch/tag/commit. My codebase repo in turn mirrors the Moodle branch naming schema.