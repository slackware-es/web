+++
title = "Package Management"
date = 2018-08-04T08:01:21Z
description = "How to build your own slackware from "
draft = false
toc = true
categories = ["technology"]
tags = ["packages","slackbuild", "pkgtool", "installpkg", "slackpkg","slackpkg+", "how-to"]
+++

This document is a derivative of the [Slacbook:install](https://docs.slackware.com/slackbook:package_management). The aim is to produce an evolution and contribute it back to the original work.

Introduction
----

Package management is an essential part of any Linux distribution. The software included in Slackware, along with many third-party tools, is distributed as source code. But compiling all those thousands of different applications and libraries is tedious and time consuming. That's why many people prefer to install pre-compiled software packages. In fact, when you installed Slackware, the setup program run the package management tools on a list of packages. Here we'll look at the various tools used for handling Slackware packages.
 
Slackware packages are ```tar``` files compressed by ```gzip``` or ```xz```  whose name contains the software name and version, the computer architecture of the included binaries and the package maintainer tag.

```packageName-version-arch-tag.txz```

The package management tools use metadata stored in ```/var/log/packages```  to do their operations. This metadata is generated when the package is installed, and stored in files named after the package. In the next Slackware release the metadata will be stored in ```/var/lib/pkgtool```.

{{< scr "/scr/package_metadata_file.xhtml" >}}
package metadata file
{{< /scr >}}


You can see the installed packages  on your system by listing the contents of ```/var/log/packages```, and on each file you can explore the following metadata fields:

 - Package name
 - Compressed package size
 - Uncompressed package size
 - Package location
 - Package description
 - File list

Slackware packages were compressed with the ```gzip``` compression utility, which was a good compromise between compression speed and size. But new compression schemes have been added and today, official Slackware packages use the ```xz``` utility and end with ```.txz``` extensions. Older packages, and many third party packages, still use the ```.tgz``` extension.

It's worth emphasizing that ```.tgz``` and ```.txz``` (or, more succinctly, ```.t?z``` files) are standard, non-unique extensions for compressed ```.tar``` files. This has many advantages; they're easy to build on any UNIX system (many other package formats require special tools), and they're just as simple to de-construct.

However, it is also important to realize that just because all Slackware packages are ```.t?z``` files, not all ```.t?z``` files are Slackware packages. ```installpkg``` won't install just any ```.t?z``` file, only Slackware packages.

A package contains an ```install``` folder with scripts to execute in the install process. The documentation of ```makepkg`` contains the details of the install scripts.

Slackware package management tools do not automatically manage the package dependencies and there is no such information on the package metadata and are written in shell script.

In the next sections we describe the standard package management tools and mention non-standard ones for the advanced user.


pkgtool
-----

The way to perform package maintenance tasks is to invoke ```pkgtool```, a menu-driven interface which allows you to install or remove packages and view the contents of those packages and the list of installed packages in a user-friendly ncurses interface.

{{< scr "/scr/pkgtool.xhtml" >}}
pkgtool user interface
{{< /scr >}}

```pkgtool``` is a convenient and easy way to perform the most basic tasks, but for more advanced work we need more flexible tools.

Installing, Removing, and Upgrading Packages
-----

While ```pkgtool``` scores points for convenience, ```installpkg`` can handle odd tasks, such as installing a single package, installing an entire disk set of packages, or scripting an custom installation process.

```installpkg``` takes a list of packages to install and installs them asking no questions. Like all Slackware package management tools, it assumes that you know what you're doing and doesn't pretend to be smarter than you. In its simplest form, ```installpkg``` takes a list of packages to install, and does what you would expect.

{{< scr "/scr/installpkg.xhtml" >}}
pkgtool user interface
{{< /scr >}}

You can install multiple packages at a time, and in fact use shell wild cards.The following installs all the “N” series packages from a mounted CD-ROM:

{{< highlight bash >}}
darkstar:~# installpkg /mnt/cdrom/slackware/n/*.txz
{{< /highlight  >}}

```removepkg``` will check the contents of the package metadata file and will remove all the files and directories for that package with one caveat. It will not remove files used by multiple installed packages, or non-empty directories.

{{< highlight bash >}}
darkstar:~# removepkg blackbox-0.70.1-i486-2.txz```
{{< /highlight  >}}

```upgradepkg``` which first installs a new package, then removes whatever files and directories are left-over from the old package. It doesn't check if the installed package has a higher version number than the “new” package, so it can also downgrade a package to older versions.

{{< highlight bash >}}
darkstar:~# upgradepkg blackbox-0.70.1-i486-2.txz

+==============================================================================
| Upgrading blackbox-0.65.0-x86_64-4 package using
./blackbox-0.70.1-i486-2.txz
+==============================================================================

Pre-installing package blackbox-0.70.1-i486-2...

Removing package
/var/log/packages/blackbox-0.65.0-x86_64-4-upgraded-2010-02-23,16:50:51...
--> Deleting symlink /usr/share/blackbox/nls/POSIX
--> Deleting symlink /usr/share/blackbox/nls/US_ASCII
--> Deleting symlink /usr/share/blackbox/nls/de
--> Deleting symlink /usr/share/blackbox/nls/en
--> Deleting symlink /usr/share/blackbox/nls/en_GB
...
Package blackbox-0.65.0-x86_64-4 upgraded with new package
./blackbox-0.70.1-i486-2.txz.
{{< /highlight  >}}

These tools have useful arguments. For example, the –root to installpkg will install packages into an arbitrary directory. The –dry-run argument will instruct upgradepkg to tell you what it would attempt without changing the system. For complete details, refer to the man pages.


slackpkg
----

Slackpkg is an automated tool for management of Slackware Linux Packages. It Appeared in ```/extra``` for the release of slackware-12.1, and since the release of slackware-12.2 they have included it in the ```ap/``` series of a base installation.

You can find the latest version of slackpkg and its documentation at https://slackpkg.org.

Slacpkg can download packages from a mirror in Internet and install them into your computer. This is useful for security updates or application upgrades.

Without slackpkg, the process would be:

 - Notice in the Slackware change log they have released an update.
 - Look on your local Slackware mirror to find a download link of the package.
 - Download the package from a Slackware mirror to your hard drive.
 - Use either installpkg or pkgtool to install the downloaded package.

Slackpkg reduces the process to:

 - Notice in the Slackware change log they have released an update.
 - slackpkg install or upgrade the changed package

To use slackpkg, configure your system with a Slackware mirror by editing ```/etc/slackpkg/mirrors```  as ```root``` user. Find a mirror with your Slackware version and architecture and enable it by deleting the ```#``` at the start of the line. Only one mirror can be enabled at a time.

Then, update the local change log by issuing the command ```slackpkg update```. This command will download the change log and will compare it with your local copy. If there are any differences, the local file is updated with the remote contents.

You should do this any time you notice they have posted a new package (check in with the Slackware change log once a day!).

To search for a package, use ```slackpkg search foo```, and to install use ```slackpkg install foo```.

You can manage the packages installed with ```slackpkg``` using ```pkgtool``` and the other standard package management commands.

For more information see the man pages for slackpkg(8) and slackpkg.conf(5), and see its [website](http://www.slackpkg.org/)

There is also a novel tool called ```slackpkg+``` which augments the current slackpkg tool to work with multiple repositories, for more information see its [Guthub repository](https://github.com/zuno/slackpkgplus)


slackbuilds
-----

Original source: [slackbuilds.org](https://slackbuilds.org)

One of the frequent criticisms of Slackware is the lack of official packages available. While the official package set provides a good, stable, and flexible operating system (and is quite adequate for many individuals), the fact remains that many users want/need quite a few additional applications in order for it to meet their needs.

There are a few well-known third party package repositories, but many users justifiably do not want to install untrusted packages on their systems. For those users, the traditional solution has been to download the source code for desired applications and compile them manually.

This works, but introduces another set of problems associated with managing those applications; version updates and such require more of the admin's time than precompiled packages, and lack of notes will often mean that the admin forgot which configure flags were used earlier (as well as any other special issues encountered).

In our opinion, the best solution to this problem is for the admin to automate the compile process using a SlackBuild script. Patrick Volkerding, the maintainer of Slackware, uses SlackBuild scripts to compile the official packages, so it makes sense for us to use the same idea for extra applications we want to add.

Our goal is to have the largest collection of SlackBuild scripts available while still ensuring that they are of the highest quality - we test every submission prior to inclusion in the repository. We do not now nor will we ever provide precompiled packages for any of the applications for which we have SlackBuild scripts - instead, we want the system administrator (that's you) to be responsible for building the packages.

How to use it can be read in their fantastic documentation at their [website](https://www.slackbuilds.org/howto/)


Building a package
-----

Original source: [slack how-to](https://docs.slackware.com/howtos:slackware_admin:building_a_package)



Configure and compile the source as you usually do:

{{< highlight bash >}}
./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
make
{{< /highlight  >}}

Make a temporary destination directory available:

{{< highlight bash >}}
mkdir /tmp/build
{{< /highlight  >}}

Install into the temporary directory:

{{< highlight bash >}}
make install DESTDIR=/tmp/build
{{< /highlight  >}}

Now strip libs/bins within the temporary directory:

{{< highlight bash >}}
strip -s /tmp/build/usr/lib/* /tmp/build/usr/bin/*
{{< /highlight  >}}

You also want to make sure that anything in <tt>/usr/man</tt> is gzipped before you make the package:

{{< highlight bash >}}
gzip -9 /tmp/build/usr/man/man?/*.?
{{< /highlight  >}}

Create the install directory, this is where the description and install script will be stored:

{{< highlight bash >}}
cd /tmp/build
mkdir install
cd install
{{< /highlight  >}}

One-liner (for the copy & paste people):

{{< highlight bash >}}
cd /tmp/build; mkdir install; cd install
{{< /highlight  >}}

Using a text editor (or a tool), create a file called slack-desc and fill it with the following contents:

{{< highlight bash >}}
    appname: appname (Short description of the application)
    appname:      <this line is generally left blank>
    appname: Description of application  -  this description should be fairly
    appname: in-depth; in other words, make it clear what the package does (and 
    appname: maybe include relevant links and/or instructions if there's room),
    appname: but don't get too verbose.  
    appname: This file can have a maximum of eleven (11) lines of text preceded by
    appname: the "appname: " designation.  
    appname:
    appname: It's a good idea to include a link to the application's homepage too.
    appname:
{{< /highlight  >}}

The “appname” string must *exactly* match the application name portion of the Slackware package (for example, a package titled “gaim-1.5-i486-1.tgz” must have a slack-desc file with the <appname> string of “gaim: ” rather than “Gaim: ” or “GAIM: ” or something else.

The first line must show the application name followed by a short description (enclosed in parentheses).

Create the actual package:

{{< highlight bash >}}
cd /tmp/build
makepkg ../app-version-arch-tag.tgz
{{< /highlight  >}}

(The dashes should appear as above, so if the version has a subversion like say “1.0 RC2” make sure you use 1.0_RC2 not 1.0-RC2. The arch should be something like “i486” for example. The tag should consist of the build number and your initals, e.g. 1zb for Zaphod Beeblebrox's first build, 2zb for his second build, etc. Official slackware packages have only numbers as tags.)

 - When prompted to recreate symbolic links, say ```yes```
 - When prompted to reset permissions, say ```no```

Note: Using ```makepkg -l y -c n``` will give you the same behaviour as answering yes to the symlinks question, and no to the permissions question.

If all went well, you can now install the package. 

{{< highlight bash >}}
cd .. 
installpkg app-version-arch-tag.tgz
{{< /highlight  >}}

