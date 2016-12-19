GhostBuster
===========

GhostBuster is an export utility for use with the Ghost blogging platform
(http://ghost.org). This is a brief outline; for further information please
refer the documentation - it can be found in the "doc" directory.

It uses *export filters* to export the contents of a Ghost blog into various
formats including a basic backup and static HTML representations of the blog.

It has *publishers* that publish the exported content onto other platforms.

Ghost has an extendable design that makes it easy to create new export filters
and publishers. 

LICENSE
-------

GhostBuster is released under the terms of the MIT LICENSE. For the full
wording of the license please either:

* refer to the LICENSE file contained within this distribution, or
* run the command `ghostbuster --license`, or
* visit http://github.com/johnlane/ghostbuster/LICENSE

USAGE
-----

Those that don't want to read the detail can try this:

    $ ghostbuster /path/to/content /path/to/export/to

Please refer to the documentation for full usage instructions. The
following documentation is available:

* For basic help, refer to the "doc/HELP" file or run the command
  `ghostbuster --help`.

* For detailed usage instructions, refer to the "doc/USERGUIDE" file

* For information about extending GhostBuster by writing new export filters 
  or publishers, refer to the "doc/EXTENDING" file

SUPPORT
-------

For support please contact the author via GitHub. Feel free to fix bugs or
extend functionality and send a pull request via GitHub.

DEPENDENCIES
------------

The sqlite3 and sanitize gems must be installed:

  $ gem install sqlite3 sanitize

Arch Linux package requirements:
ruby     : runtime (ruby 2.0)
devtools : may be required to install/build gems

                     (c) John Lane 2014
                Licensed under the MIT License.
             https://github.com/johnlane/ghostbuster


