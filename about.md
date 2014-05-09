---
layout: page
title: "About"
date: 2014-03-10 09:54:51
categories: private
permalink: about.html
---
[Ghost](http://ghost.org) catalyses writing for web by making it easy to get on with writing. It's a fantastic, yet simple, plaform with a web-based content editor that is very easy to use. It gets out of the way and lets you focus on writing. It does, however, require a server-side installation that requires a [Node.js](http://nodejs.org/) platform. 

**GhostBuster** is for those occasions where it isn't practical to self-host a Node server on the internet. It's a tool that extracts content from a Ghost server and re-publishes it as static pages that can be hosted just about anywhere, including free static hosting services such as [GitHub Pages](http://pages.github.com).

**GhostBuster** also helps with more mundane tasks like making backups or storing posts in a version control system such as [Git](http://git-scm.com/).

It has *export filters* that export content and layout from the Ghost server into a collection of files in various formats and *publishers* that transmit the generated files to various destinations. Its extendable design makes it easy to add new export filters and publishers.

It can export the raw Markdown that Ghost content is written in or create a formatted, static HTML web site that looks the same as the original, complete with an RSS feed. Alternatively, export content into to another static page system and re-theme it there (GhostBuster supports [Jekyll](http://git-scm.com) and [Middleman](http://middlemanapp.com/)) or export via [Kramdown](http://kramdown.gettalong.org/) into various formats including [Latex](http://www.latex-project.org/) and [PDF](http://www.adobe.com/uk/products/acrobat/adobepdf.html) documents.

It can export in multiple ways and publish to many destinations at once, taking instructions from a configuration file or the command-line.

**GhostBuster** is open-source software released under the [MIT LICENSE](http://opensource.org/licenses/MIT).

## Installation

**GhostBuster** is written in Ruby version 2.0.0, so you need a suitable Ruby interpreter. Ideally this will be on [Linux](http://www.linux.org/) because this is what it was written on and for. Install 


## Usage

Those that don't want to read the detail can try this:

    $ ghostbuster /path/to/content /path/to/export

which will export the production database to HTML files. Alternatively, to get the full story, see the [User's Guide]().

## An example
**GhostBuster** created this web site from content written in [Ghost](http://ghost.org) that's exported as [Jekyll](http://jekyllrb.com/) pages and hosted by [GitHub Pages](http://pages.github.com/). The Jekyll layout is based on a theme called [Hyde](http://hyde.getpoole.com).


----
<div style=float:right>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
">
<input type="image" src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal – The safer, easier way to pay online.">
<img alt="" border="0" src="https://www.paypalobjects.com/en_GB/i/scr/pixel.gif" width="1" height="1">
</form>
</div>
<small><small>**GhostBuster** is written by [John Lane](http://johnlane.ie) on his own time and expense. If you find this useful and want to show your appreciation, please consider making a donation.</small></small>
