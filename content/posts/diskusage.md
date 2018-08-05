+++
title = "Disk usage"
date = 2018-08-04T08:01:21Z
description = "Analyzing disk usage in Slackware."
draft = false
toc = true
categories = ["documentation"]
tags = ["slackbook"]
type = "post"
+++

In this post we will explore how to free disk space without reinstalling the system, and will present some scripts to help in the process.

<!--more-->

Introduction
-----

After some time using your system, installing new software and trying out settings, it's inevitable to find that the disk usage is growing.

It could be a daunting process to free disk space, and most people will reinstall the systems again, adding to the new installation the experience got with the old one.

It's common to think the in the new system, this problem will go away because you've learned a lot, and the system space will remain low, while only your data will increase. But on my experience, most people install again the operating system to clean it out.

A new installed Slackware, using the recommended installation process, installs aournd 10GB of software in your computer. But poking around and trying out software, can get you to 40GB in no time.

Our strategy to clean up the system will be:

- check the filesystem to see where is used the space
- check temporary files
- check installed packages and see how much space the use
- check files which do not belong to any package


Useful tools
-----

There are multiple tools to get information about filesystem usage, for example:

 - [xdiskusage](http://xdiskusage.sourceforge.net/)
 
 {{< figure src="/img/xdiskusage_layout.png" caption="xdiskusage analisys of /" class="lazyload" >}}
 
  - [ncdu](https://dev.yorhel.nl/ncdu)
 
 {{< scr "/scr/ncdu_root_stats.xhtml" >}}
 ncdu showing / disk usage statistics
 {{< /scr >}}

But sometimes we need to understand the problem to be able to use those tools correctly. Also if you make our own tools we will be able to automate certain tasks.

Filesystem usage
-----

The ```du``` utility, which stands for disk usage, can give you the size of a file or a folder.

With no arguments ```du``` will print the size of all files and folders from the current folder. And with the options ```-s``` and ```-h``` will summarize and print information of the current folder converting the size from Kb to the biggest unite possible (Mb, Gb, etc.)

{{< highlight bash >}}
gdiazlo@darkstar:~$ du -sh
9.4G    .
gdiazlo@darkstar:~$ 
{{< /highlight  >}}

It also accepts a parameter to show which folder is the starting point to calculate sizes:

{{< highlight bash >}}
gdiazlo@darkstar:~$ du -sh $HOME
9.4G    .
gdiazlo@darkstar:~$ 
{{< /highlight  >}}

So knowing where is the space going, it might tempt us to do

{{< highlight bash >}}
gdiazlo@darkstar:~$ du -sh /*
{{< /highlight  >}}

but be aware: ```du``` will try to calculate the size of all mounted filesystems, including CD-ROMs, network shares, and synthetic filesystems like ```/proc```. That will slow the process or even show errors.

A solution found in [superuser.com](https://superuser.com/questions/638982/du-x-still-examines-mounted-filesystems-when-using-wildcard) site works well on a system with multiple mounted filesystems.

{{< highlight bash >}}
root@darkstar:~# for a in /*; do mountpoint -q -- "$a" || du -s -h -x "$a"; done
13M     /bin
35M     /boot
31M     /etc
9.4G    /home
559M    /lib
27M     /lib64
16K     /lost+found
64K     /media
56K     /mnt
212M    /opt
1.9G    /root
24M     /sbin
4.0K    /srv
4.9G    /tmp
16G     /usr
4.9G    /var
root@darkstar:~# 
{{< /highlight  >}}

We can see in the list the top 5 space users:

 - ```/usr``` uses 16G of space
 - ```/home``` uses 9.5G of space
 - ```/var``` uses 4.9G of space
 - ```/tmp``` uses 4.9G of space
 - ```/root``` uses 1.9G of space

All that combined is 37.2G of space.

The space used in ```/usr``` and ```/var``` should correspond to files from the operating system: installed software, packages, logs, databases, and together they account for 20.9G of space.

The space used in ```/tmp``` should be disposable as it only serves the purpose to contain ephemeral information.

And the ``/root``` and ```/home``` contain personal files from the administrator and the users of the computer.

With this information we state a different strategy to each case:

 - system files: check packages and files that do not belong to any installed package
 - temporary files: delete them if possible
 - administrator and user files: check the downloads and temporary files, delete on your discretion
 

Identify system files
-----

We read about [package managemt in Slackware](/docs/packages/) to devise an strategy to:

 - calculate the space used by installed packages
 - identify orphan files (not related to any package) and their disk usage

#### Disk usage by installed packages

We analize the space each packae uses throught its metadata files stored in ```/var/log/packages```.

To show the packages ordered by its uncompressed size in ascending order:

{{< highlight bash >}}
#!/bin/bash

for p in `ls -1 /var/log/packages`; do
        head -n 3 /var/log/packages/$p | awk  '
/PACKAGE NAME:/ { name=$3 }
/UNCOMPRESSED PACKAGE SIZE:/ { size=$4 }
END{
        print size, " " , name
}'
done | numfmt --from=si | sort -n -k 1 | numfmt --to=si

{{< /highlight  >}}

The script is not very fast, but produce good results:

{{< highlight bash >}}
root@darkstar:~# ./pkgsize-meta | tail -n 10
168M   emacs-26.1-x86_64-1
176M   seamonkey-2.49.4-x86_64-1
220M   kernel-modules-4.14.60-x86_64-1
285M   mariadb-10.3.8-x86_64-1
297M   kernel-firmware-20180730_7b5835f-noarch-1
335M   qt5-5.11.1-x86_64-1alien
428M   texlive-2018.180630-x86_64-2
529M   rust-1.28.0-x86_64-1
718M   llvm-6.0.1-x86_64-1
800M   kernel-source-4.14.60-noarch-1
root@darkstar:~#
{{< /highlight  >}}

Another example is calculate the size of all packages toghether:

{{< highlight bash >}}
root@darkstar:~# ./pkgsize-meta | numfmt --from=si | awk '{print $1}' | paste -sd+ | bc | numfmt --to=si
13G
root@darkstar:~# 
{{< /highlight  >}}


An installed file can grow over time, and this script will not take that into account. We
can look in the disk ourselves instead of using the size provided by the package's metadata file:

{{< highlight bash >}}
#!/bin/bash

PKGS="/var/log/packages"
LOGFILE=$(mktemp /tmp/pkgsize.XXXXXX)
packages=$(ls -1 ${PKGS}/$1)

total=0

for p in ${packages[@]}; do
        files=($(cat $p | sed '1,/FILE LIST/d' | sed 's/^/\//g' | grep -v "\/$" ))
        pkgsize=$(
        for i in $(seq 0 200 ${#files[@]}); do
                echo $(stat --printf="%s " ${files[@]:$i:200} 2>$LOGFILE) | sed 's/ /\n/g'
        done | paste -sd+ | bc
        )
        echo $pkgsize $p | numfmt --to=si
        total=$(( total + pkgsize ))
done
echo $total | numfmt --to=si
{{< /highlight  >}}



{{< highlight bash >}}
root@darkstar:~# ./pkgsize kernel-source-*
784M /var/log/packages/kernel-source-4.14.60-noarch-1
784M
{{< /highlight  >}}

In the examples, the kernel package reported to use 800M in the metadata file and 784M using ```stat``` agains all the files and adding the result.

With this information we may decide to delete the packages we don't use.

#### Identify orphan files

An orphan file does not correspond to any installed package. This could mean is software or data generated during the system use. Maybe we installed or tried to install applications that polluted our system with files and didn't user the package management tools.

To decrease the number of orphan files, use [Appimage](https://appimage.org/) or [flatpak](https://flatpak.org/) to install software which do not have a package for Slackware. Also consider making your own packages, it is easy and allows you to control all the files on your system.

We can devise a script to find all orphan files and list them along with their size in Kb. Be aware this script is slow and requires a considerable amount of RAM (around 400M on our case). See the contribution below for a better approach.

{{< highlight bash >}}
#!/bin/bash

LOGFILE=$(mktemp /tmp/pkgorphan.XXXXXX)

files=()
TMP=$(mktemp -d /tmp/orphan.XXXXXX)

cd $TMP

for p in `ls -1 /var/log/packages`; do
        cat /var/log/packages/$p |sed -e '1,/FILE LIST/d' | sed 's/^/\//g' | sed 's/\/$//g' 
done | sort -u > meta

for i in usr bin sbin lib lib64 opt srv var etc root; do
        find /$i -type f
done | sort -u > disk


awk 'NR==FNR { A[$1] ; next } !($1 in A) { print $1 }' meta disk > orphans

files=($(cat orphans))
for i in $(seq 0 200 ${#files[@]}); do
        ls -d -s -1 ${files[@]:$i:200} 2>$LOGFILE
done > orphans-size

{{< /highlight  >}}

A brave soul on #irc contributed another way to look for orphans, with better performance:

{{< highlight bash >}}
#!bin/bash
# This needs bash for arrays
#
# Author: Jakub Jankowski <shasta@slackware.pl>
#
 
ONLY_FSTYPES_RGXP='^(btrfs|ext[234]|xfs|jfs)$'
SKIP_PATHS=( '/root/*' '/home/*' '/mnt/*'
             '/var/run/*' '/var/tmp/*' '/var/spool/*'
             '/var/log/pkgtools/*' '/var/lib/pkgtools/*' '/var/lib/sbopkg/*'
             '/var/cache/lxc/*'
             '/usr/src/linux*'
             '/tmp/*' )
 
# create temporary files
FROM_PKGS=$(mktemp)
FROM_FS=$(mktemp)
 
set -e
 
# list all files/dirs brought by packages;
# we are also stripping .new suffix as that's how config
# files come in, but they are later mv'd "foo.new" "foo"
for pkg in /var/log/packages/*; do
  sed -e '1,/^FILE LIST:/d;
         /^\.\/$/d;
         /^install\//d;
         s,^,/,;
         s,\.new$,,;
         s,/$,,' "$pkg"
done > "$FROM_PKGS"
 
# find all files/directories on filesystem, but only if fs type is one of $ONLY_FSTYPES_RGXP;
# on't descend to other filesystems (-xdev), and ignore paths from $SKIP_PATHS
declare -a EXCL=( )
for p in "${SKIP_PATHS[@]}"; do
  if [ ${#EXCL[@]} -eq 0 ]; then
    EXCL=( "${EXCL[@]}" '-path' "$p" '-prune' )
  else
    EXCL=( "${EXCL[@]}" '-o' '-path' "$p" '-prune' )
  fi
done
[ ${#EXCL[@]} -gt 0 ] && EXCL=( "${EXCL[@]}" '-o' '-print' )
 
find $(awk -v fstypes="$ONLY_FSTYPES_RGXP" '$3 ~ fstypes {print $2}' /proc/mounts) \
  -xdev "${EXCL[@]}" 2>/dev/null > "$FROM_FS"
 
# output needs to be sorted for join(1) to work
LC_ALL=C sort -u -o "$FROM_PKGS" "$FROM_PKGS"
LC_ALL=C sort -u -o "$FROM_FS" "$FROM_FS"
 
# see which paths in $FROM_FS are not in $FROM_PKGS
LC_ALL=C join -a 2 -v 2 "$FROM_PKGS" "$FROM_FS"
 
# clean up other two temp files
rm "$FROM_FS" "$FROM_PKGS"
{{< /highlight  >}}

The script will give us a list of orphans. We can compute the size they use on disk using that list.


We can further explore the results the script generated in the file ```orphans-size```:

 - show the top-ten orphan files by its disk usage:

{{< highlight bash >}}
root@darkstar:/tmp/orphan.xvA0L1# cat orphans-size | sort -k 1 -n -u | tail -n 10 | sed 's/ \//K \//' | numfmt --from=si --to=si
96M /var/lib/flatpak/repo/objects/05/91c08407fbaa7dccc4cbc541865d27d4714b14d51417dc658841e3cd96d489.commitmeta
105M /usr/local/cuda-9.2/lib64/libcufft_static.a
115M /usr/local/cuda-9.2/nsightee_plugins/com.nvidia.cuda.repo-1.0.0-SNAPSHOT.zip
117M /usr/local/cuda-9.2/lib64/libcusolver.so.9.2.148
124M /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/0591c08407fbaa7dccc4cbc541865d27d4714b14d51417dc658841e3cd96d489/files/extra/share/spotify/libcef.so
132M /var/tmp/elvis1.ses
177M /usr/local/cuda-9.2/lib64/libnvgraph_static.a
252M /var/lib/flatpak/repo/objects/69/74b95360b298f4cfe1be4025689ea20e918b689a5110984b3ffe7d339faf45.file
252M /var/lib/flatpak/repo/objects/df/45dafc31028c33ba2b26b08342dfe4044937e54eb9a3305c1cea28b5e9dfb5.file
330M /var/cache/sbopkg/qt-everywhere-opensource-src-5.7.1.tar.xz
root@darkstar:/tmp/orphan.xvA0L1# 
{{< /highlight  >}}

 - summary the size of an specific folder

{{< highlight bash >}}
root@darkstar:/tmp/orphan.xvA0L1# cat orphans-size | grep "/usr/local/cuda-9.2*" | awk '{print $1}' | sort -n -k 1 | paste -sd+ | bc | sed 's/$/K/' | numfmt --from=si --to=si
2.9G
root@darkstar:/tmp/orphan.xvA0L1# 
{{< /highlight  >}}


 - summary to the second level directory hierarchy
 
{{< highlight bash >}}
root@darkstar:/tmp/orphan.xvA0L1# cat orphans-size | cut -d '/' -f 1,2,3 | sort -n -k 1 -u | awk '{size[$2]+=$1}END{for (s in size){print size[s]," ", s}}' | sort -k1 -n | sed 's/ /K /' | numfmt --from=si --to=si | tail -n 10
88M   /root/.cache
115M   /usr/share
125M   /root/NVIDIA_CUDA-9.2_Samples
138M   /var/tmp
165M   /opt/calibre
188M   /usr/lib64
515M   /var/cache
1.2G   /root/latest
2.4G   /var/lib
2.5G   /usr/local
root@darkstar:/tmp/orphan.xvA0L1#
{{< /highlight  >}}

After all this work, isn't there an application to work this out without arcane shell commands?


Delete unwanted files
-----

After the analysis we've identified where the disk space is and what kind of files use them:


- ```/usr/local``` contains 2.5G of unaccounted space, used by cuda, plan9ports and go installations
- ```/var/lib``` contains 2.4G of unaccounted space, used by pacakge tools like SlackBuilds or Flatpak. 
- ```/root``` cotains 1.2G of unaccounted space, used by cuda and other scripts

Also we identified packages we don't use which use a lot of disk space like ```MariaDB```, ```Rust```, or ```TeX```.

With that in mind we can free up a couple of GB easily without breaking anything on the system, just deleting the folders with ```rm```.



