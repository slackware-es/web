+++
title = "Packages"
date = 2018-07-28T08:01:21Z
description = "How to install, update and build (new) packages."
draft = false
toc = true
categories = ["technology"]
tags = ["packages","slackbuild", "pkgtool", "installpkg", "slackpkg","slackpkg+", "how-to"]
+++

This document is a derivative of the [Slacbook:install](https://docs.slackware.com/slackbook:package_management). The aim is to produce an evolution and contribute it back to the original work.

Introduction
----

Package management is an essential part of any Linux distribution. Every piece of software included by Slackware, along with many third-party tools are distributed as source code that can be compiled, but compiling all those thousands of different applications and libraries is tedious and time consuming. That's why many people prefer to install pre-compiled software packages. In fact, when you installed Slackware, the setup program primarily worked by running package management tools on a list of packages. Here we'll look at the various tools used for handling Slackware packages. 

pkgtool
-----

The simplest way to perform package maintenance tasks is to invoke pkgtool(8), a menu-driven interface to some of the other tools. pkgtool allows you to install or remove packages as well as view the contents of those packages and the list of currently installed packages in a user-friendly ncurses interface. 

{{< scr "/scr/pkgtool.xhtml" >}}
pkgtool user interface
{{< /scr >}}

pkgtool is a convenient and easy way to perform the most basic tasks, but for more advanced work more flexible tools are needed. 

Installing, Removing, and Upgrading Packages
-----

While pkgtool scores points for convenience, installpkg(8) is much more capable of handling odd tasks, such as quickly installing a single package, installing an entire disk set of packages, or scripting an install. installpkg takes a list of packages to install, and simply installs them without asking any questions. Like all Slackware package management tools, it assumes that you know what you're doing and doesn't pretend to be smarter than you. In its simplest form, installpkg simply takes a list of packages to install, and does exactly what you would expect. 


{{< scr "/scr/installpkg.xhtml" >}}
pkgtool user interface
{{< /scr >}}

You can of course install multiple packages at a time, and in fact use shell wild cards.The following installs all of the “N” series packages from a mounted CD-ROM:

{{< highlight bash >}}
darkstar:~# installpkg /mnt/cdrom/slackware/n/*.txz
{{< /highlight  >}}

At any given time, you can see what packages are installed on your system by listing the contents of /var/log/packages, which lists not only every application on your system but also the version number. Should you want to know what individual files were installed as a part of that package, cat the contents of the package:

{{< highlight bash >}}
darkstar:~#cat /var/log/packages/foo-1.0-x86_64.txz
{{< /highlight  >}}

This will return everything from the size of the package, a description of what it does, and the name and location of every file installed as a part of the package.

Removing a package is every bit as easy as installing one. As you might expect, the command to do this is removepkg(8). Simply tell it which packages to remove, and removepkg will check the contents of the package database and remove all the files and directories for that package with one caveat. If that file is included in multiple installed packages, it will be skipped and if a directory has new files in it, the directory will be left in place. Because of this, removing packages takes a good while longer than installing them.

{{< highlight bash >}}
darkstar:~# removepkg blackbox-0.70.1-i486-2.txz```
{{< /highlight  >}}

Finally, upgrading is just as easy with (you guessed it), upgradepkg(8) which first installs a new package, then removes whatever files and directories are left-over from the old package. One important thing to remember is that upgradepkg doesn't check to see if the previously installed package has a higher version number than the “new” package, so it can also be used to downgrade to older versions.

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

All of these tools have useful arguments. For example, the –root to installpkg will install packages into an arbitrary directory. The –dry-run argument will instruct upgradepkg to simply tell you what it would attempt without actually making any changes to the system. For complete details, you should (as always) refer to the man pages. 

Package Compression Formats
-----

In the past, all Slackware packages were compressed with the gzip(1) compression utility, which was a good compromise between compression speed and size.Recently, new compression schemes have been added and the package management tools have been upgraded to handle these. Today, official Slackware packages are compressed with the xz utility and end with .txz extensions.Older packages (and many third party packages) still use the .tgz extension.

It's worth emphasizing that .tgz and .txz (or, more succinctly, .t?z files) are very standard, non-unique extensions for compressed .tar files. This has many advantages; they're easy to build on nearly any UNIX system (many other package formats require special toolchains), and they're just as simple to de-construct.

However, it is also important to realize that just because all Slackware packages are .t?z files, not all .t?z files are Slackware packages. Installpkg won't magically install just any .t?z file, only Slackware packages.

slackpkg
----

Slackpkg is an automated tool for management of Slackware Linux Packages. It originally appeared in ```/extra``` for the release of slackware-12.1, and since the release of slackware-12.2 it has been included in the ```ap/``` series of a base installation.

Just as you are able to use installpkg to install Slackware packages from the ```/extra``` directory included on the install media, you can use slackpkg to pull packages from the Internet and install them. This is particularly useful for security updates or significant application upgrades that are posted to the Slackware servers, some of which you may want to start using on your own system.

Without slackpkg, the process would be:

 - Notice in the Slackware changelog that an update has been released.
 - Look on your local Slackware mirror to find a download link of the package.
 - Download the package from a Slackware mirror to your hard drive.
 - Use either installpkg or pkgtool to install the downloaded package.

With slackpkg, this is reduced to:

 - Notice in the Slackware changelog that an update for foo has been released.
 - slackpkg install foo

Clearly, this streamlines a fairly common task.

To use slackpkg, configure your system with a Slackware mirror by editing ```/etc/slackpkg/mirrors```  as root. Find the mirror that is associated with your Slackware version and architecture, and uncomment it. This list of mirrors offers ftp and http access, but you must uncomment only one mirror.

Once a mirror has been selected, update the list of remote files by issuing the initial command slackpkg update. This should be done any time you notice that a new package has been posted (regularly checking in with the Slackware changelog is recommended; see Chapter 18, Keeping Track of Updates for more information).

To search for a package, use slackpkg search foo, and to install use slackpkg install foo.

Once a package has been installed with slackpkg, it can be removed or upgraded using pkgtool and the other package management commands as detailed inInstalling, Removing, and Upgrading Packages.

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

