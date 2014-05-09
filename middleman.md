---
layout: page
title: "Middleman"
date: 2014-05-09 13:04:53
categories: private
permalink: middleman.html
---
GhostBuster can export content that can be used in a [Middleman](http://middlemanapp.com) project to build a static website.

Publishing a Ghost site using Middleman is a three-step process. First, prepare a Middleman project, then use Ghostbuster to provide content and, finally, use Middleman to publish it.

GhostBuster's `Middleman` filter generates content to be placed in the `source` directory of a Middleman project. It produces pages from the Ghost server's content. A complete Middleman project will also require a site layout, which Middleman can produce using templates.

Use of Middleman is beyond the scope of this article but instructions are available on its [website]((http://middlemanapp.com)).

<small>**!** This filter should be considered experimental.</small>

#### Prepare

##### Install Middleman

<small>**!** Full instructions are available on the [Middleman](http://middlemanapp.com/basics/getting-started/) website.</small>

Middleman requires a Ruby environment. Install the Middleman [gem](http://rubygems.org/gems/middleman):

    $ gem install middleman

<small>You can check the installed version:

    $ middleman version
    Middleman 3.3.2     
</small>

##### Install Templates
    
Middleman uses templates to create sites. There is a casper-like theme available:

    git clone https://github.com/danielbayerlein/middleman-casper ~/.middleman/casper
    
##### Create Project
    
Create a new project using a template of your choosing.

    $ middleman init mysite --template=casper
    $ cd mysite

Install any gem dependencies that the template has

    $ bundle install

Test that it works

    $ middleman server

Point a browser at the address given when the server starts, usually `http://localhost:4567`. Stop the server with `Control+C` when satisfied.

#### Export content

<small>**!** The tasks in this section need to be completed on the Ghost server host.</small>

Create a suitable GhostBuster environment file, for example:

    Middleman:
     ghost_environment: development
     destination: ssh:myuser@myhost/home/myuser/static-sites/mysite/source
     filter: middleman
     published: true

<small>

* This example uses SSH to export to another host, which assumes a suitable key is lodged with an accesible SSH agent, as described [here]().
* the export destination is the middleman project's `source` directory.

</small>

Run GhostBuster to export the content. Assuming a suitable environment similar to the above example is in `middleman.yml`:

    ghostbuster -v -f middleman.yml


#### Publish

To publish the site, Middleman uses the files in the `source` directory to *build* static HTML pages in the `build` directory.

To preview the site before building it, go to the project's directory and start the Middleman server:

    cd ~/static-sites/mysite
    middleman server
    
Point a browser at the address given when the server starts; this is usually `http://localhost:4567`. Check it looks good then stop the server and build the static site pages:

    middleman build

The contents of the `build` directory can then be loaded onto any static web server. You can run up a simple server from the build directory (`cd build`) to try the static site. Either with Python:

    $ python -m SimpleHTTPServer

or Ruby

    $ ruby -run -e httpd . -p 8000

Both of these examples serve the content at `http://localhost:8000`.