+++
title = "The Xterm"
date = 2018-08-02T14:27:00Z
description = "Xterm user guide"
draft = false
toc = true
categories = ["documentation"]
tags = ["xterm"]
type = "post"
images = [
  "/img/xterm_to_html.png"
]
+++

From it's manual page xterm(1):

The xterm program is a terminal emulator for the X Window System.  It provides DEC VT102/VT220 and selected features from higher-level terminals such as VT320/VT420/VT520 (VTxxx). It also provides Tektronix 4014 emulation for programs that cannot use the window system directly.If the underlying operating system supports terminal resizing capabilities (for example, the SIGWINCH signal in systems derived from 4.3BSD), xterm will use the facilities to notify programs running in the window whenever it is resized.

<!--more-->

It's currently maintained and the changes can be followed in [Thomas E. Dickey site](https://invisible-island.net/xterm/xterm.log.html)

Features and configuration
-----

It's reason to be, emulation of other terminals, should be considered on my opinion it's major feature. It provides emulation for a lot of old terminals, so that software written long ago can be used on today systems, emulating the screens those computers had. XTerm still provides a fairly complete emulation of those terminals. See for example [these Tektronix programs](https://www.dim13.org/teapot).

### Fonts

It can be condifured to use fonts supported by the [FreeType library](https://www.freetype.org/), which is pretty much any font you can find out there (TTF, OTF, etc.) It can only have one font size per session, so any given XTerm window will have the same font size on all the text buffer. But the size of the current font can be changed to multiple options (tiny, small, medium, huge, default) using the fonts menu (```CTRL+3rd mouse button click```).

{{< scr "/scr/xterm_xresources.xhtml">}}
Xterm showing the contents of an .Xresources file
{{< /scr >}}

The font management in X is a bit messy, but you can have decent results with a bit of work.

### Unicode

Xterm is able to show unicode characters. There is an xterm wrapper uxterm which set up xterm to show them,as it not show them by default. But it does not work well with all the fonts. In case you need non latin output, I suggest you to use uterm wrapper and the default fonts. Unless you need it to do heavy work that you will need to search for a good font for your needs.


{{< scr "/scr/xterm_unicode.xhtml">}}
Xterm with htop application running
{{< /scr >}}

Note that this terminal font is rendered in your browser and might have better Unicode support. Below is an image of what appeared on the screen:

{{< figure src="/img/xterm_unicode.png" caption="Xterm screenshot of Unicode test" class="lazyload" >}}


### ncurses

Xterm has the best support for ncurses programs AFAICT. It might me related to the fact that Thomas E. Dickey is related to both xterm and also ncruses.

### xhtml export

It has the feature to export the current window, not the whole buffer as an XHTML page. The terminals on this site have been generated using that functionality. Colors and ncurses are supported and the final result is quite good.

{{< scr "/scr/xterm_calcurses.xhtml" >}}
Xterm with calcurses application running
{{< /scr >}}

{{< scr "/scr/xterm_htop.xhtml">}}
Xterm with htop application running
{{< /scr >}}

Note that the screen captures uses the default monospace font from your browser. I'm using [Terminus (TTF)](https://files.ax86.net/terminus-ttf/) font as the monospace font in my browsers and the render of both consoles are just like I saw them in the Xterm.


Usability
-----

It's menu system, the .Xresources file, and the config modifications you can apply without closing and restarting the session is a bit annoying. But the work I normally do in XTerm does not requiere such things.

You can serach using a printerCommand, like the one in the screenshot of my ```.Xresources``` file, but it would be nice if you could just do that in the current buffer


Performance
-----

I do not require a special performance of a terminal emulator. Also I have plenty of memory to run an XTerm from time to time.


Bugs
-----

The XTerm is famous for its difficult code, its bugs, and its complexity:

 - cut/paste does not select tabs; instead spaces are selected. This is because the selection works from the array of displayed characters, on which tab/space conversion has already been performed.
 - does not implement the autorepeat feature of VTxxx terminals. 
 - the program must be run with fixed (nonproportional) fonts.
 - the home and end keys do not generate usable escape sequences, due to an indexing error.
 - the Main Options menu is improperly constructed, due to incorrect indices after removing the logging toggle. This makes the list of signals off by one.
 - very large screens (e.g., by using nil2 for a font) cause core dumps because the program uses a fixed array (200 lines) for adjusting pointers.
 - certain types of key translations cause a core dump because the program does not check the event class before attempting to use events. 
 