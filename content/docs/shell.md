+++
title = "Shell"
date = 2018-08-05T23:01:21Z
description = "Introduction to the Slackware shell environment"
draft = false
toc = true
categories = ["technology"]
tags = ["build", "how-to"]
+++



This document is a derivative of the [Slacbook:bash](https://docs.slackware.com/slackbook:bash) and [Slackbook beta](https://slackbook.org/beta/#ch_install). The aim is to produce an evolution and contribute it back to the original work.


What Is A Shell?
-----

A shell is a program that give access to the operating system's services. In Slackware the command-line interface (CLI) shell is the Bourne-again shell or [bash](https://www.gnu.org/software/bash/).

The first program Slackware executes after you log into the system is the shell command-line interface:

There are many shells included with a full install of Slackware, but in this chapter we will only discuss ```bash```, the Bourne Again Shell. Advanced users might want to consider using the powerful ```zsh```, and users familiar with older UNIX systems might appreciate ```ksh``` or ```csh```, but new users should stick to ```bash```.

The main tasks a user does in the shell is executing commands, i.e. telling the computer what to do next.

Users can also program in the shell. Programs written in shell language are shell scripts and the Linux kernel execute them as if they were binary programs.

A lot of Slackware tools are written in bash.

A complete guide on how to use ```bash``` is available in its [web](https://www.gnu.org/software/bash/manual/bashref.html). In this chapter we will make a gentle introduction to the ```bash``` shell, focused on its use in the Slackware Linux distribution.

Quick-start
-----

So you've installed Slackware and you're staring at a terminal prompt, what now? Now would be a good time to learn about the basic command-line tools. And since you're staring at a blinking curser, you may need a little help in knowing how to get around.

We type a command at the prompt and press the key enter, and the shell executes it. It prints the result of the command below and when the command ends shows the prompt again.

Here you have a quick reference of commands taken from the fantastic [Introduction to Linux](http://tldp.org/LDP/intro-linux/html/intro-linux.html) by the [TLDP](http://tldp.org):

 - ```ls```: displays a list of files in the current working directory
 - ```cd```: directory change directories
 - ```passwd```: change the password for the current user
 - ```file filename```: display file type of file with name filename
 - ```cat textfile```: throws content of textfile on the screen
 - ```pwd```: display present working directory
 - ```exit``` or ```logout```: leave this session
 - ```man command```: read man pages on command
 - ```info command```: read Info pages on command
 - ```apropos string```: search the whatis database for strings

And a quick reference on how to edit what you type at the prompt:

 - Ctrl+A: move cursor to the beginning of the command line.
 - Ctrl+E: move cursor to the end of the command line.
 - Ctrl+C: End a running program and return the prompt, see Chapter 4.
 - Ctrl+D: Log out of the current shell session, equal to typing exit or logout.
 - Ctrl+H: Generate a backspace character.
 - Ctrl+L: Clear this terminal.
 - Ctrl+R: Search command history, see Section 3.3.3.4.
 - Ctrl+Z: Suspend a program, see Chapter 4.
 - ArrowLeft and ArrowRight: Move the cursor one place to the left or right on the command line, so you can insert characters at other places than just at the beginning and the end.
 - ArrowUp and ArrowDown: Browse history. Go to the line you want to repeat, edit details and press Enter to save time.
 - Shift+PageUp and Shift+PageDown: Browse terminal buffer (to see text that has "scrolled off" the screen).
 - Tab: Command or filename completion; when multiple choices are possible, the system will either signal with an audio or visual bell, or, if too many choices are possible, ask you if you want to see them all.
 - Tab Tab: Shows file or command completion possibilities.

The prompt
-----

It is the message the shell prints to show it is ready to accept new instructions. ```bash``` generates the prompt based in a template. The default template in Slackware is ```\u@\h:\w\$``` which generate prompts like ```root@darkstar:~#```. ```\u``` stands for the user name, ```\h``` stands for the host name ```\w``` stands for the current path in the filesystem and ```\$``` shows if the user has administration privileges ```#``` or not ```$```.

PS1 variable contains the template to configure the prompt.

Configuration
-----

The shell is configured editing the following files, depending on what kind of configuration we want to make.

  - ```/etc/profile```: The systemwide initialization file, executed for login shells
  - ```~/.bash_profile```:  The personal initialization file, executed for login shells
  - ```~/.bashrc```:  The individual per-interactive-shell startup file
  - ```~/.bash_logout```:  The individual login shell cleanup file, executed when a login shell exits
  - ```~/.inputrc```:  Individual ```readline``` initialization file

Those files accept bash commands as their content, and those commands are the ones which will configure the bash environment when it starts.

Environment
-----

An environment is a compound of properties and variables defined in the shell when it starts. We can change most without restarting the shell.

All shells make certain tasks easier for the user by keeping track of things in environment variables. An environment variable is a shorter name for some bit of information that the user wishes to store and make use of later. For example, the environment variable PS1 tells bash how to format its prompt. Other variables may tell applications how to run.

Setting your own environment variables is easy. ```bash``` includes two built-in functions for handling this: ```set``` and ```export```. We can remove an environment with ```unset```. Don't panic if you accidently unset an environment variable and don't know what it would do. You can reset all the default variables by logging out of your terminal and logging back in. You can reference a variable by placing a dollar sign ($) in front.

{{< highlight bash >}}
darkstar:~$ set FOO=bar
darkstar:~$ echo $FOO
bar
{{< /highlight  >}}

The primary difference between set and export is that export will make the variable available to any sub-shells. (A sub-shell is another shell running inside a parent shell.) You can see this behavior when working with the PS1 variable that controls the bash prompt.

{{< highlight bash >}}
darkstar:~$ set PS1='FOO '
darkstar:~$ export PS1='FOO '
FOO
{{< /highlight  >}}

There are many important environment variables that bash and other shells use, but one of the most important ones you will run across is PATH. It contains a list of directories to search through for applications.

For example, ```top``` is in ```/usr/bin/top```. You could run it by specifying the complete path, but if ```/usr/bin``` is in your PATH variable, bash will check there for you when you type ```top``` at the prompt. You will most likely first notice this when you try to run a program and it is not in your PATH.

{{< highlight bash >}}
darkstar:~$ ifconfig
bash: ifconfig: command not found
darkstar:~$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin:/usr/games:/opt/www/htdig/bin:.
{{< /highlight  >}}

Above, you see a typical PATH for a regular user (see the $ in the prompt). You can change it on your own the same as any other environment variable. If you login as root however, you'll see that root has a different PATH.

{{< highlight bash >}}
darkstar:~$ su -
Password:
darkstar:~# echo $PATH
/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin:/usr/games:/opt/www/htdig/bin
{{< /highlight  >}}


Writing commands (II)
-----

### Wildcards

Wildcards are symbols used as placeholders for other characters.  The use case for these in a shell is to complete strings like file names.

The asterisk matches any character or a characters combination, including none. Thus b* would match strings like b, ba, bab, babc, bcdb, and so forth. Less common is the ?. This wildcard matches one instance of any character, so b? would match ba and bb, but not b or bab.

{{< highlight bash >}}
darkstar:~$ touch b ba bab
darkstar:~$ ls *
b ba bab
darkstar:~$ ls b?
ba
{{< /highlight  >}}

No, the fun doesn't stop there! Besides these two we also have the bracket pair "[ ]" which allows us to fine tune what we want to match. Whenever bash see the bracket pair, it substitutes the contents of the bracket with any combination of letters or numbers specified, as long as they are comma separated.

{{< highlight bash >}}
darkstar:~$ ls a[1-4,9]
a1 a2 a3 a4 a9
{{< /highlight  >}}

We can specify a range of letters or numbers  typing a ```-``` between the start and the end of the range.

```bash``` treat capital and lower-case letters as different. All capital letters come before all lower-case letters in alphabetical order. This is important when working with ranges.

{{< highlight bash >}}
darkstar:~$ ls 1[W-b]
1W 1X 1Y 1Z 1a 1b
darkstar:~$ ls 1[w-B]
/bin/ls: cannot access 1[b-W]: No such file or directory
{{< /highlight  >}}

In the second example, ```1[b-W]``` isn't a valid range, so the shell treats it as a filename, and since that file doesn't exist, ```ls``` tells you so.

### Tab Completion

```bash``` completes your commands and filenames when you write just press the key ```Tab```.  Even if you haven't typed in enough text to identify a filename or command, the shell will fill in as much as it can for you. Hitting ```Tab``` a second time will make it display a list of all matches for you.

### Input and Output Redirection

One of the defining features of Linux and other UNIX-like operating systems is the number of small, simple applications and the ability to stack them together to create complex systems. In ```bash``` we can make the output of a command the input of another one or into a file.

A shell command has three channels to control its input/output operations:
 
 - The standard output (stdout or 1) is where the commands write their result
 - The standard error (stderr or 2) is where the commands write their errors
 - The standard input (stdin or 0) is where the commands read their input

To get started, we will show you how to redirect the output (stdout) of a program to a file.  We  do this with the ```>``` character. When bash sees the ```>``` character, it redirects all the output  to whatever file name follows.

{{< highlight bash >}}
darkstar:~$ echo foo
foo
darkstar:~$ echo foo > /tmp/bar
darkstar:~$ cat /tmp/bar
foo
{{< /highlight  >}}

If we do not redirect the ```stdout``` of echo, it prints the string given as its argument to its ``` stdout```. But if we redirect that ```stdout``` to a file we cannot see the output of the echo command.

If ```/tmp/bar``` does not exist, ```bash``` creates it and write the output as its contents.  If ```/tmp/bar```  exist, then its contents are over-written. This might not be the best idea if you want to keep those contents in place.

```bash``` supports ```>>``` which will append the output to the file, instead of over-write it.

{{< highlight bash >}}
darkstar:~$ echo foo
foo
darkstar:~$ echo foo > /tmp/bar
darkstar:~$ cat /tmp/bar foo
darkstar:~$ echo foo2 >> /tmp/bar
darkstar:~$ cat /tmp/bar
foo
foo2
{{< /highlight  >}}

You can also re-direct the standard error to a file using ```2>``` instead of just ```>```.

{{< highlight bash >}}
darkstar:~$ rm bar
rm: cannot remove `bar': No such file or directory
darkstar:~$ rm bar 2> /tmp/foo
darkstar:~$ cat /tmp/foo
rm: cannot remove `bar': No such file or directory
{{< /highlight  >}}

You may also redirect the standard input  with the '<' character, though it's not used often.

{{< highlight bash >}}
darkstar:~$ fromdos < dosfile
{{< /highlight  >}}

You can redirect the output of one program as input to another using the ```|``` character. ```bash``` uses pipes to connect the ```stdout``` of a command to the ```stdin``` of another.

{{< highlight bash >}}
darkstar:~$ ps auxw | grep getty
root 2632 0.0 0.0 1656 532 tty2 Ss+ Feb21 0:00 /sbin/agetty 38400 tty2 linux
root 3199 0.0 0.0 1656 528 tty3 Ss+ Feb15 0:00 /sbin/agetty 38400 tty3 linux
root 3200 0.0 0.0 1656 532 tty4 Ss+ Feb15 0:00 /sbin/agetty 38400 tty4 linux
root 3201 0.0 0.0 1656 532 tty5 Ss+ Feb15 0:00 /sbin/agetty 38400 tty5 linux
root 3202 0.0 0.0 1660 536 tty6 Ss+ Feb15 0:00 /sbin/agetty 38400 tty6 linux
{{< /highlight  >}}

Task Management
-----

```bash``` has yet another cool feature to offer: the ability to suspend and resume tasks. This allows you halt a running process, perform other task, then resume it or make it run in the background. Upon pressing ```CTRL-Z```,``` bash``` will suspend the running process and return you to a prompt. You can return to that process later. You can suspend multiple processes in this way. The ```jobs``` built-in command will display a list of suspended tasks.

{{< highlight bash >}}
darkstar:~$ jobs
[1]- Stopped vi TODO
[2]+ Stopped vi chapter_05.xml
{{< /highlight  >}}

To return to a suspended task, run the ```fg``` built-in to bring the last suspended task back into the foreground. If you have multiple suspended tasks, you can specify a number as well to bring one to the foreground.

{{< highlight bash >}}
darkstar:~$ fg # "vi TODO"
darkstar:~$ fg 1 # "vi chapter_05.xml"
{{< /highlight  >}}

You can also background a task with  ```bg```. This allows the process to run without maintaining control of your shell. You can bring it back to the foreground with ```fg``` in the same way as suspended tasks. Also, if you type ```&``` at the end of a command, ```bash``` send it to the background.

Terminals
-----

Terminals were keyboards and monitors (sometimes even mice) wired into a mainframe or server via serial connections. Today however, most terminals are virtual. This allow users to connect to the computer without requiring expensive and often incompatible hardware.

Slackware Linux and other UNIX-like operating systems use virtual terminals to interact with its users.

The most common virtual terminals (every Slackware Linux machine will have at least one) are the ```gettys```. ```agetty(8)``` runs six instances by default on Slackware and allows local users (those who can sit down in front of the computer and type at the keyboard) to login and run applications.
Each of these ```gettys``` is available on different ```tty``` devices that are accessible by pressing the ```ALT``` key and one of the function keys from ```F1``` through ```F6```. Using these ```gettys``` allows you to login multiple times, perhaps as different users, and run applications in those users' shells.

On desktops, laptops, and other workstations where the user prefers a graphical interface, most terminals are graphical. Slackware includes many graphical terminals, but the most used are KDE's ```konsole```, ```XFCE's Terminal``` and the standard ```xterm```.

If you are using a graphical interface, check your toolbars or menus. Each desktop environment or window manager has a virtual terminal (often called a terminal emulator), and they are all labelled differently. Typically though, you will find them under a "System" sub-menu in desktop environments. Executing any of these will give you a graphical terminal and automatically run your default shell.


Basic shell commands
-----

### System Documentation

Your Slackware Linux system comes with lots of built-in documentation for nearly every installed application. Perhaps the most common method of reading system documentation is ```man```. ```man``` (short for manual) will bring up the included man-page for any application, system call, a configuration file, or library you tell it too. For example, ```man man``` will bring up the man-page for itself.

You may not always know what application you need to use for the task at hand. But man has built-in search abilities to help. Using the [-k] switch will make ```man``` to search for every man-page that matches your search terms.

The man-pages are organized into groups or sections by their content type. For example, Section 1 is for user applications. man will search each section in order and display the first match it finds. Sometimes you find that a man-page exists in more than one section for an entry. In that case, you will need to specify the exact section to look in.

In this book, all applications and several other things will have a number on their right-hand side in parentheses. This number is the man page section where you will find information on that tool.

{{< highlight bash >}}
darkstar:~$ man -k printf
printf               (1)  - format and print data
printf               (3)  - formatted output conversion
darkstar:~$ man 3 printf
{{< /highlight  >}}

The sections of the manual pages are:
 - Section 1: User Commands
 - Section 2: System Calls
 - Section 3: C Library Calls
 - Section 4: Devices
 - Section 5: File Formats / Protocols
 - Section 6: Games
 - Section 7: Conventions / Macro Packages
 - Section 8: System Administration
 - Section 9: Kernel API Descriptions
 - Section n: "New" - typically used to Tcl/Tk

### Files and directories: The filesystem

{{< blockquote cite="Wikipedia" citelink="https://en.wikipedia.org/wiki/File_system" >}}

In computing, a file system or filesystem controls how data is stored and retrieved. Without a file system, information placed in a storage medium would be one large body of data with no way to tell where one piece of information stops and the next begins. By separating the data into pieces and giving each piece a name, the information is easily isolated and identified. Taking its name from the way paper-based information systems are named, each group of data is called a "file". The structure and logic rules used to manage the groups of information and their names is called a "file system" 

{{< /blockquote >}}

In Slackware and other UNIX-like operating systems, the file systems is a hierarchical tree-like structure which starts at the root directory denoted by ```/```. All other directories and files are referenced from its relation to the root.


#### Listing Files and Directory Contents

We use ```ls(1)```  to list files and directories, their permissions, size, type, inode number, owner and group, and plenty of additional information. For example, let's list what's in the ```/``` directory for your new Slackware Linux system.

{{< highlight bash >}}
darkstar:~$ ls /
bin/ dev/ home/  lost+found/  mnt/ proc/  sbin/  sys/  usr/
boot/ etc/ lib/ media/ opt/ root/  srv/   tmp/ var/
{{< /highlight  >}}


Notice that each of the listings is a directory. These are distinguished from regular files due to the trailing /; standard files do not have a suffix. Executable files will have an asterisk suffix. But ls can do so much more. To get a view of the permissions of a file or directory, you must do a "long list".

{{< highlight bash >}}
darkstar:~$ ls -l /home/alan/Desktop
-rw-r--r-- 1 alan users 15624161 2007-09-21 13:02 9780596510480.pdf
-rw-r--r-- 1 alan users 3829534 2007-09-14 12:56 imgscan.zip
drwxr-xr-x 3 alan root 168 2007-09-17 21:01 ipod_hack/
drwxr-xr-x 2 alan users 200 2007-12-03 22:11 libgpod/
drwxr-xr-x 2 alan users 136 2007-09-30 03:16 playground/
{{< /highlight  >}}


A long listing lets you view the permissions, user and group ownership, file size, last modified date, and the file name itself. Notice that the first two entire are files, and the last three are directories. This is denoted by the first character on the line. Regular files get a "-"; directories get a "d". There are several other file types with their own denominators. Symbolic links for example will have an "l".

We'll show you how to list dot-files, or hidden files. Unlike other operating systems such as Microsoft Windows, there is no special property that differentiates "hidden" files from "unhidden" files. A hidden file begins with a dot. To display these files along with all the others, you need to pass the [-a] argument to ls.

{{< highlight bash >}}
darkstar:~$ ls -a
.xine/   .xinitrc-backup  .xscreensaver  .xsession-errors  SBo/
.xinitrc  .xinitrc-xfce   .xsession   .xwmconfig/ Shared/
{{< /highlight  >}}


You also likely noticed that your files and directories appear in different colors. Many of the enhanced features of ls such as these colors or the trailing characters showing file-type are special features of the ls program enabled by passing various arguments. As a convenience, Slackware sets up ls to use many of these optional arguments by default. These are controlled by the LS_OPTIONS and LS_COLORS environment variables. 

#### Moving Around the Filesystem

```cd``` is the command used to change directories. Unlike most other commands, ```cd``` is not it's own program, but is a shell built-in. That means ```cd``` does not have its own man page. You must check your shell's documentation for more details on the cd you may be using. Mostly though, they all behave the same.

{{< highlight bash >}}
darkstar:~$ cd /
darkstar:/$ls
bin/ dev/ home/  lost+found/  mnt/ proc/  sbin/  sys/  usr/
boot/ etc/ lib/ media/ opt/ root/  srv/   tmp/ var/
darkstar:/$cd /usr/local
darkstar:/usr/local$
{{< /highlight  >}}

Notice how the prompt changed when we changed directories? The default Slackware shell does this as a quick, easy way to see your current directory, but this is not a ```cd``` function. If your shell doesn't operate in this way, you can get your current working directory with the ```pwd(1)``` command. 

{{< highlight bash >}}
bash4.4$ pwd
/usr/local
{{< /highlight  >}}

#### File and Directory Creation and Deletion

While most applications can and will create their own files and directories, you'll often want to do this on your own. It's easy using ```touch(1)``` and ```mkdir(1)```.

```touch``` modifies the time stamp on a file, but if that file doesn't exist, it will be created.

{{< highlight bash >}}
darkstar:~/foo$ ls -l
-rw-r--r-- 1 alan users 0 2012-01-18 15:01 bar1
darkstar:~/foo$ touch bar2
-rw-r--r-- 1 alan users 0 2012-01-18 15:01 bar1
-rw-r--r-- 1 alan users 0 2012-01-18 15:05 bar2
darkstar:~/foo$ touch bar1
-rw-r--r-- 1 alan users 0 2012-01-18 15:05 bar1
-rw-r--r-- 1 alan users 0 2012-01-18 15:05 bar2
{{< /highlight  >}}

Note how ```bar2``` was created in our second command, and the third command  updated the time stamp on ```bar1```.

```mkdir``` is used for making directories. ```mkdir foo``` will create the directory ```foo``` within the current working directory. You can also use the ```-p``` argument to create any missing parent directories.

{{< highlight bash >}}
darkstar:~$ mkdir foo
darkstar:~$ mkdir /slack/foo/bar/
mkdir: cannot create directory `/slack/foo/bar/': No such file or directory
darkstar:~$ mkdir -p /slack/foo/bar/
{{< /highlight  >}}

In the latter case, mkdir will first create ```/slack```, then ```/slack/foo```, and ```/slack/foo/bar```. If you failed to use the [-p] argument, man would fail to create ```/slack/foo/bar``` unless the first two already existed, as you saw in the example.

Removing a file is as easy as creating one. The ```rm(1)``` command will remove a file (assuming you have permission to do this). There are a few common arguments to rm. The first is [-f] and is used to force the removal of a file you may lack explicit permission to delete. The [-r] argument will remove directories and their contents recursively.

There is another tool to remove directories, the humble rmdir(1). rmdir will only remove directories that are empty and complain about those that contain files or sub-directories.

{{< highlight bash >}}
darkstar:~$ ls
foo_1/ foo_2/
darkstar:~$ ls foo_1
bar_1
darkstar:~$ rmdir foo_1
rmdir: foo/: Directory not empty
darkstar:~$ rm foo_1/bar
darkstar:~$ rmdir foo_1
darkstar:~$ ls foo_2
bar_2/
darkstar:~$ rm -fr foo_2
darkstar:~$ ls
{{< /highlight  >}}

#### Links

Links are a method of referring to one file by multiple names. By using the ```ln(1)``` application, a user can reference one file with multiple names. The two files are not carbon-copies of one another, but rather are the same file, just with a different name. To remove the file, all of its names must be deleted. (This is the result of how rm and other tools like it work. Rather than remove the contents of the file, they remove the reference to the file, freeing that space to be re-used. ln will create a second reference or "link" to that file.)

{{< highlight bash >}}
darkstar:~$ ln /etc/slackware-version foo
darkstar:~$ cat foo
Slackware 14.0
darkstar:~$ ls -l /etc/slackware-version foo
-rw-r--r-- 1 root root 17 2007-06-10 02:23 /etc/slackware-version
-rw-r--r-- 1 root root 17 2007-06-10 02:23 foo
{{< /highlight  >}}

Another type of link exists, the symlink. Symlinks, rather than being another reference to the same file, are a special file in their own right. These symlinks point to another file or directory. The primary advantage of symlinks is that they can refer to directories and files, and they can span multiple filesystems. We create them with the [-s] argument.

{{< highlight bash >}}
darkstar:~$ ln -s /etc/slackware-version foo
darkstar:~$ cat foo
Slackware 140
darkstar:~$ ls -l /etc/slackware-version foo
-rw-r--r-- 1 root root 17 2007-06-10 02:23 /etc/slackware-version
lrwxrwxrwx 1 root root 22 2008-01-25 04:16 foo -> /etc/slackware-version
{{< /highlight  >}}

When using symlinks, remember that if the original file is deleted, your symlink is useless; it points at a file that doesn't exist anymore.

#### Reading files

UNIX and UNIX-like operating systems use text files extensively, and that at some point in time, the system's users will need to read and modify them. There are plenty of ways of reading these files, and we'll show you the most common ones.

In the early days, if you wanted to see the contents of a file  you would use ```cat(1)``` to view them. ```cat``` is a simple program, which takes one or more files, concatenates them (hence the name) and sends them to the standard output, which is usually your terminal screen.

This was fine when the file was small and wouldn't scroll off the screen, but inadequate for larger files as it had no built-in way of moving within a document and reading it a paragraph at a time. Today, cat is still used predominately in scripts or for joining two or more files into one.

{{< highlight bash >}}
darkstar:~$ cat /etc/slackware-version
Slackware 14.2
{{< /highlight  >}}

Given the limitations of ```cat``` some very intelligent people sat down and worked on an application to let them read documents one page at a time. Such applications began to be known as "pagers". One of the earliest of these was ```more(1)```, named because it would let you see "more" of the file whenever you wanted.

##### more

```more``` will display the first few lines of a text file until your screen is full, then pause. Once you've read through that screen, you can proceed down one line by pressing Enter, or an entire screen by pressing Space, or by a specified number of lines by typing a number and then the Space bar. more can also search through a text file for keywords; once you've displayed a file in more, press the / key and enter a keyword. Upon pressing Enter, the text will scroll until it finds the next match.

This is a big improvement over cat, but still suffers from some annoying flaws; more cannot scroll back up through a piped file to allow you to read something you might have missed, the search function does not highlight its results, there is no horizontal scrolling, and so on. 

##### less

To address the short-comings of more, a new pager was developed and ironically dubbed ```less(1)```. ```less``` is a powerful pager that supports all the functions of more while adding lots of additional features. To begin with, less allows you to use your arrow keys to control movement within the document.

Due to its popularity, many Linux distributions have excluded more in favor of less. Slackware includes both. Slackware also includes a handy little pre-processor for less called lesspipe.sh. This allows a user to execute less on several non-text files. lesspipe.sh will generate text output from running a command on these files, and display it in less.

Less provides as much functionality as one might expect from a text editor without being a text editor. We can move line-by-line can be done vi-style with j and k, or with the arrow keys, or Enter. In the event that a file is too wide to fit on one screen, you can even scroll with the left and right arrow keys. The g key takes you to the top of the file, while G takes you to the end.

Searching is done as with more, by typing the / key and then your search string, but notice how the search results are highlighted for you, and typing n will take you to the next occurrence of the result while N takes you to the previous occurrence.

Also as with more, files may be opened directly in less or piped to it:

{{< highlight bash >}}
  darkstar:~$ less
  /usr/doc/less-*/README
  darkstar:~$ cat
  /usr/doc/less*/README
  /usr/doc/util-linux*/README | less
{{< /highlight  >}}

There is much more to less; from within the application, type ```h``` for a full list of commands.

#### Archive and Compression

Everyone needs to package a lot of small files together for easy storage from time to time, or perhaps you need to compress very large files into a more manageable size? Maybe you want to do both together? there are several tools to do just that.

##### zip and unzip

You're probably familiar with .zip files. These are compressed files that contain other files and directories.

To create a zip file, you'll use the ```zip(1)``` command. You can compress either files or directories (or both) with ```zip```, but you must use the [-r] argument for recursive action to deal with directories.

{{< highlight bash >}}
darkstar:~$ zip -r /tmp/home.zip /home
darkstar:~$ zip /tmp/large_file.zip /tmp/large_file
{{< /highlight  >}}

The order of the arguments is very important. The first filename must be the zip file to create (```zip``` will add the ```.zip``` file extension for you) and the rest are files or directories to be added to the zip file.

```unzip(1)``` will decompress a zip archive file.

{{< highlight bash >}}
darkstar:~$ unzip /tmp/home.zip
{{< /highlight  >}}

##### gzip

One of the oldest compression tools included in Slackware is gzip(1), a compression tool which operate on a single file at a time or stream at a time. While zip is both a compression and an archival tool, gzip does only compression. At first glance this seems like a draw-back, but it is a strength. The UNIX philosophy of making small tools that do their small jobs well allows us to combine them in myriad ways. To compress a file (or multiple files), pass them as arguments to gzip. Whenever gzip compresses a file, it adds a .gz extension and removes the original file.

{{< highlight bash >}}
darkstar:~$ gzip /tmp/large_file
{{< /highlight  >}}

Decompressing is just as straight-forward with ```gunzip``` which will create a new uncompressed file and delete the old one.

{{< highlight bash >}}
darkstar:~$ gunzip /tmp/large_file.gz
darkstar:~$ ls /tmp/large_file*
/tmp/large_file
{{< /highlight  >}}

But suppose we don't want to delete the old compressed file, we want to read its contents or send them as input to another program? The ```zcat``` program will read the ```gzip``` file, decompress it in memory, and send the contents to the standard output.

{{< highlight bash >}}
darkstar:~$ zcat /tmp/large_file.gz
Wed Aug 26 10:00:38 CDT 2009
Slackware 13.0 x86 is released as stable!  Thanks to everyone who helped
make this release possible -- see the RELEASE_NOTES for the credits.
The ISOs are off to the replicator.  This time it will be a 6 CD-ROM
32-bit set and a dual-sided 32-bit/64-bit x86/x86_64 DVD.  We're taking
pre-orders now at store.slackware.com.  Please consider picking up a copy
to help support the project.  Once again, thanks to the entire Slackware
community for all the help testing and fixing things and offering
suggestions during this development cycle.
{{< /highlight  >}}

##### bzip2

One alternative to gzip is the ```bzip2(1)```xt compression utility which works in almost the same way. The advantage to bzip2 is that it boasts greater compression strength. Achieving that greater compression is a slow and CPU-intensive process, so bzip2 typical takes much longer to run than other alternatives.

##### XZ / LZMA

The latest compression utility added to Slackware is xz, which implements the LZMA compression algorithm. This is faster than bzip2 and often compresses better. In fact, its blend of speed and compression strength caused it to replace gzip as the compression scheme of choice for Slackware. We can compress files using the [-z] argument, and decompression with [-d].

{{< highlight bash >}}
darkstar:~$ xz -z /tmp/large_file
{{< /highlight  >}}

##### tar

So great, we know how to compress files using many programs, but none of them can archive files like zip does.

The Tape Archiver, or ```tar(1)``` is the most used archival program in Slackware. Like other archival programs, ```tar``` generates a new file that contains other files and directories. It does not compress the generated file (often called a "tarball") by default; however, the version of ```tar``` included in Slackware supports a variety of compression schemes, including the ones mentioned above.

Invoking tar can be as easy or as complicated as you like. Creating a tarball is done with the [-cvzf] arguments. Let's look at these in depth.

 - c: create a tarball
 - x: extract the contents of a tarball
 - t: display the contents of a tarball
 - v: be more verbose
 - z: use gzip compression
 - j: use bzip2 compression
 - J: use LZMA compression
 - p: preserve permissions

```tar``` requires more precision than other applications in the order of its arguments. The ```[-f]``` argument must be present when reading or writing to a file for example, and the very next thing to follow must be the filename. Consider the following examples.

{{< highlight bash >}}
darkstar:~$ tar -xvzf /tmp/tarball.tar.gz
darkstar:~$ tar -xvfz /tmp/tarball.tar.gz
{{< /highlight  >}}

Above, the first example works as you would expect, but the second fails because ```tar``` was told to open the ```z``` file rather than the expected ```/tmp/tarball.tar.gz```.

Now we've got our arguments straightened out, lets look at a few examples of how to create and extract tarballs. As we've noted, the ```[-c]``` argument is used to create tarballs and [-x] extracts their contents. If we want to create or extract a compressed tarball though, we also have to specify the proper compression to use. If we don't want to compress the tarball at all, we can leave these options out. The following command creates a new tarball using the gzip compression algorithm. While it's not a strict requirement, it's also good practice to add the .tar extension to all tarballs and whatever extension is used by the compression algorithm.

{{< highlight bash >}}
darkstar:~$ tar -czf /tmp/tarball.tar.gz /tmp/tarball/
{{< /highlight  >}}


