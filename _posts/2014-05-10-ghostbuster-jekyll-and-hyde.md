---
layout: post
title: GhostBuster, Jekyll and Hyde
date: 2014-05-10 10:32:40
categories: GhostBuster
permalink: ghostbuster-jekyll-and-hyde.html
---
[GhostBuster]() is a tool that I wrote to export content from a [Ghost](https://ghost.org) webserver in various ways. I use it with [Jekyll](http://jekyllrb.com) to create the GhostBuster website, which is a collection of static [GitHub](https://pages.github.com) pages. 

This story explains how it all works. Look at it like a real-world usage example of GhostBuster.

### Preparation

First of all, I need to install what's needed to get the job done. The website content already exists on a Ghost server, so I just need to set up a Jekyll on my development machine. It has Ruby already and I use [RVM](https://rvm.io) to manage my Ruby projects, so I first create a working directory and a new [Gemset](https://rvm.io/gemsets/basics):

    $ mkdir ~/files/staticweb/jekyll
    $ echo 'ruby-2.0.0-p247@jekyll' > ~/files/staticweb/jekyll/.ruby-version
    $ cd ~/files/staticweb/jekyll
    
<small>**!** You don't need to use RVM, but I recommend it. If you don't know it, take a look at its [website](https://rvm.io)</small>

Then install the [gem](http://rubygems.org/gems/jekyll):

    $ gem install jekyll

Now I can create a new project. The site uses [Hyde]() as a starting point, so I clone that instead of starting from scratch:

    $ git clone https://github.com/poole/hyde ghostbuster
    $ cd ghostbuster
    
And, to make sure everything so far is good, run up the Jekyll server and check out `http://localhost:4000` in a browser:

    $ jekyll serve

[Safari, so goody](http://www.goodreads.com/quotes/213155-safari-so-goody), all is well and we can press on.

### Repositories

You'll recall that I cloned the Hyde repository from GitHub. In my clone, the *origin* remote is the repo that I cloned from (`https://github.com/poole/hyde`). I will leave the *master* branch intact as a copy of it (I'll periodically merge *origin/master* into my master).

Work on the GhostBuster site will be performed in another branch created like this:

    git checkout -b site
    git add -A
    git commit -m "first site commit"

This is the first commit of the new site. 

Using a separate branch and leaving *master* intact allows easy switching between the site and the vanilla *Hyde* install.

The site will be hosted on [GitHub Pages](https://pages.github.com/), so I created a new, empty [repository](https://github.com/johnlane/johnlane.github.io) on [GitHub](https://github.com) called `johnlane.github.io` which is the name dictated by [GitHub Pages](https://pages.github.com/).

I then added that site to my local repository as another remote that I'll refer to as *gh-pages*:

    $ git remote add gh-pages ssh://git@johnlane.github.com/johnlane/johnlane.github.io
    
I will push my local *site* branch to *gh-pages/master* to publish the site.

I also run a local, private, git server. I created a repository there to push the site to as a backup. I add that as a remote

    $ git remote add sodium git@git:ghostbuster-www
    

### Theme

The first part of theming is to customise the *Hyde* theme for the GhostBuster site. I made changes to a few files (on the *site* branch):

* `_config.yml` to personalise the site, replace the *Hyde* specific stuff with the new site-specifics.
* `_includes/sidebar.yml` to add a logo and remove the *current version* display.
* `_layouts/default.yml` to implement [per-page theme colour](https://github.com/poole/hyde/issues/33)
* `public\css\hyde.css` to add custom colourschemes
* `public/favicon.ico` to replace the default *Hyde* favicon image with a site-specific one.
` CNAME` to specify the site's domain name to be used when it is hosted on GitHub - `projects.johnlane.ie`.

I, of course, removed the *Hyde* readme (it's accessible on [GitHub](https://github.com/poole/hyde/blob/master/README.md)), the example *about* page and posts:

    $ rm README.md _posts/* about.md
    
Jekyll uses the [Redcarpet](https://github.com/vmg/redcarpet) markdown parser by default, as does Hyde, since [changing](https://github.com/poole/hyde/pull/25) its default from [Rdiscount](http://dafoster.net/projects/rdiscount); there are others too. To use the parser of your choice, change the `markdown` setting in `_config.yml`. I chose to use the markdown parser. 

I commit the *site* branch to my local repository regularly.

#### per-page theme colour

A page-specific theme can be specified using a `theme` entry in the page's front-matter:

    theme: green
    
The Jekyll layout can access this value as `{{ page.theme }}` and the modified `_layouts/default.html` uses it to select a CSS class that has been defined in `public\css\hyde.css`, for example:

    .theme-base-green .sidebar {
      background-color: #063
    }
    .theme-base-green .content a,
    .theme-base-green .related-posts li a:hover {
      color: #063;
     }


### Populate from Ghost

Now, to populate the site from the Ghost server, I use the following GhostBuster *environment* (which I keep on ghost server in `/srv/ghost/ghostbuster.yml`):

    Hyde:
      ghost_environment: development
      url: http://johnlane.github.io
      destination:
        ssh://john@hydrogen/home/john/jekyll/hyde
      filter: jekyll?page_layout=page&theme=dlr
      with_tags: site-ghostbuster             
      hide_tags: site-ghostbuster
      published: true

This configures GhostBuster to export all published content that is tagged with *site-ghostbuster* from Ghost into Hyde. Spooky.

Here's the command to kick it off:

    ghostbuster -v
    
<small>**!** before running this I make sure the *site* branch is selected in the repository on my development machine</small>
    
Once that completes, the content will be in the *Hyde* site. Although this is effectively generated content (originating in Ghost) it needs to be committed to the repository so that it can be uploaded to GitHub.

### Test, Commit and Publish

I can test the static content once GhostBuster completes. Back on my development machine (at the root of the `ghostbuster` working directory):

    $ jekyll serve
    
After confirming it looks good, I can review, making sure I am on the *site* branch, and commit the updates:

    $ git status
    $ git add .
    $ git commit -m "Ghost export"

When I am happy with the state of the *site* branch, I merge it with the *ghp* branch and push that GitHub pages, putting the changes live:

    $ git push gh-pages ghp:master

That pushes the local *ghp* branch to the *master* branch on the *gh-pages* remote repository.

I also push the *site* and *ghp* branches to my local server

    $git push sodium --all




