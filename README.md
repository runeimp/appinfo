AppInfo
=======

Simple command line tool (BASH script) to gain pertinent app info for all executables with the specified name in your `$PATH`. Pertinent for me at least. You, I have no idea. Maybe yes. Maybe no. We shall see.

This was created on OS X. Should work in other BASH environments as well but has not yet been tested anywhere else.

Example Usage
-------------

```
$ appinfo git

  App Label:   git version 2.7.4 (Apple Git-66)
  App Version: 2.7.4
  File Path:   /Library/Developer/CommandLineTools/usr/bin/git
  File Size:   1 MB or 1825856 Bytes

  App Label:   git version 2.11.0
  App Version: 2.11.0
  File Path:   /usr/local/bin/git
  File Size:   1 MB or 1926032 Bytes
  Symlink to:  /usr/local/Cellar/git/2.11.0/bin/git

  App Label:   git version 2.7.4 (Apple Git-66)
  App Version: 2.7.4
  File Path:   /usr/bin/git
  File Size:   17 KB or 18176 Bytes

$ fileinfo git

  File Path:   /Library/Developer/CommandLineTools/usr/bin/git
  File Size:   1 MB or 1825856 Bytes

  File Path:   /usr/local/bin/git
  File Size:   1 MB or 1926032 Bytes
  Symlink to:  /usr/local/Cellar/git/2.11.0/bin/git

  File Path:   /usr/bin/git
  File Size:   17 KB or 18176 Bytes

```

Note that in the case of symlinks the _App Size_ is the size of the linked to file. Not the symlink reference.

Rational
--------

I was doing a fresh install of my OS X environment and decided I needed this information to populate a spreadsheet I was working on. I know, real moving. :wink:

Installation
------------

Copy the script into your `bin` directory. All git commands should work as expected now. In the bin directory you can make sure the command is executable with something like `chmod u+x appinfo` for the current user only. But this may not be necessary. Test with `appinfo git` in Terminal (or iTerm, etc.) to make sure it's working as expected.

### Example Installation

``` bash
$ cd ~
$ mkdir repos
$ cd repos
$ git clone git@github.com:runeimp/appinfo.git
$ chmod u+x appinfo/*info
$ cd ~/bin
$ ln -s ../repos/appinfo/appinfo
$ ln -s ../repos/appinfo/fileinfo
$ cd ~
$ appinfo git

  App Label:   git version 2.7.4 (Apple Git-66)
  App Version: 2.7.4
  File Path:   /usr/bin/git
  File Size:   17 KB or 18176 Bytes

```

This example should represent the default git installed in OS X 10.11.x _El Capitan_. Other operating systems (including other versions of OS X/macOS) will likely show other information.


Guarantee
---------

It works on my system. I make no statement of fitness for your usage. Use at your own risk. :angel:
