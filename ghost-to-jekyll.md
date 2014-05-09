---
layout: page
title: "Ghost to Jekyll"
date: 2014-05-09 15:06:56
categories: private
permalink: ghost-to-jekyll.html
---
GhostBuster can export content that can be used in a [Jekyll](http://jekyllrb.com) project to build a static website.

Publishing a Ghost site using Jekyll is a three-step process. First, prepare a Jekyll project, then use Ghostbuster to provide content and, finally, use Jekyll to publish it.

GhostBuster's `Jekyll` filter generates content to be placed in the `source` directory of a Jekyll project. It produces pages from the Ghost server's content. A complete Jekyll project will also require a site layout and Jekyll can produce this using templates. The default template is sufficient to get a site started.

Use of Jekyll is beyond the scope of this article but instructions are available on its [website](http://jekyllrb.com).

#### Prepare

##### Install Jekyll

<small>**!** Full instructions are available on the [Jekyll](http://jekyllrb.com) website.</small>

Jekyll requires a Ruby environment. Install the Jekyll [gem](http://rubygems.org/gems/jekyll):

    $ gem install jekyll

<small>You can check the installed version:

    $ jekyll --version
    jekyll 2.0.3     
</small>

##### Create Project
    
Create a new project using a template of your choosing.

    $ jekyll new mysite
    $ cd mysite

Test that it works

    $ jekyll serve

Point a browser at the address given when the server starts, usually `http://localhost:4000`. Stop the server with `Control+C` when satisfied.

#### Export content

<small>**!** The tasks in this section need to be completed on the Ghost server host.</small>

Create a suitable GhostBuster environment file, for example:

    Jekyll:
     ghost_environment: development
     destination: ssh:myuser@myhost/home/myuser/static-sites/mysite
     filter: jekyll
     published: true

<small>

* This example uses SSH to export to another host, which assumes a suitable key is lodged with an accesible SSH agent, as described [here]().
* the export destination is the Jekyll project's root directory.

</small>

The exported content contains Jekyll [front-matter](http://jekyllrb.com/docs/frontmatter/). Should you wish to specify a layout and theme, you can add parameters to the filter selection like this:

    filter: jekyll?page_layout=page&theme=mytheme

Run GhostBuster to export the content. Assuming a suitable environment similar to the above example is in `jekyll.yml`:

    ghostbuster -v -f jekyll.yml

#### Publish

To publish the site, Jekyll uses the files in the project's root directory to *build* static HTML pages in the `_site` directory.

To preview the site before building it, go to the project's directory and start the Jekyll server:

    cd ~/static-sites/mysite
    jekyll serve
    
Point a browser at the address given when the server starts; this is usually `http://localhost:4000`. Check it looks good then stop the server and build the static site pages:

    jekyll build

The contents of the `_site` directory can then be loaded onto any static web server. You can run up a simple server from the build directory (`cd _site`) to try the static site. Either with Python:

    $ python -m SimpleHTTPServer

or Ruby

    $ ruby -run -e httpd . -p 8000

Both of these examples serve the content at `http://localhost:8000`.


##### Templates
    
Jakyll uses templates to create sites. [Hyde](http://andhyde.com) is one such template and the GhostBuster site's layout is based on it.

First, clone [Hyde](http://andhyde.com/):

    $ git clone https://github.com/poole/hyde mysite
    
Check all's well

    cd mysite
    jekyll serve
    
and point your browser to `http://localhost:4000`. 

[Ghostbuster, Jekyll and Hyde]() documents the production of the GhostBuster website for those interested in such things.