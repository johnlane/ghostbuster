---
layout: page
title: "About"
date: 2014-03-10 09:54:51
categories: 
permalink: about.html
---
**GhostBuster** is a tool that extracts content from a [Ghost](http://www.ghost.org) server and re-publishes it in various ways.

Example uses include

* publishing a lightweight copy of the blog on a static web server.
* performing backups

It uses *export filters* to extract content and layout from the Ghost server into a collection of files in various formats and *publishers* that transmit the generated files to various destinations.

The design allows for new export filters and publishers to be added easily.

GhostBuster is written in Ruby version 2.0.0.

### Quick Start

Those that don't want to read the detail can try this:

    $ ghostbuster /path/to/content /path/to/export

which will export the production database to HTML files.