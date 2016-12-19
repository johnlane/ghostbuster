---
layout: page
title: Usage
date: 2014-03-10 09:59:33
categories: private
permalink: ghostbuster-usage.html
theme: blue
---

##### NAME

`ghostbuster` - export and republish *Ghost* blogs

##### SYNOPSIS

       ghostbuster [OPTIONS]
       ghostbuster [OPTIONS] SOURCE [DESTINATION] [OPTIONS]

##### DESCRIPTION

GhostBuster extracts content from the `content` directory of a Ghost
environment. It takes various options on the command-line that together
define a run-time environment. Options may be supplied before or after the positional parameters `SOURCE` and `DESTINATION`.

Environments may also be defined in an *Environment File* in addition to or instead of using command-line options. This is described further below.

Each environment tells GhostBuster how to export and from where. By using an environment file, GhostBuster may perform multiple disparate exports in a single execution, making it easy to set up a single *cron* task to regularly perform multiple exports.

Each environment is defined by various `[OPTIONS]`, some of which are required and others are optional. Some of the required options get default values if not explicitly stated but others are mandatory. For a list of the available options, their default values and whether they are mandatory, please run:

    ghostbuster --help

The command-line arguments define an environment that is separate and in
addition to any environments defined in an environment file. If there are
insufficient command-line arguments to define an environment then an environment is not defined from the command-line.

GhostBuster exits without action if no environments are defined.

##### OPTIONS

`-h` `--help` displays a summary of the available command-line options and lists those that are required, defaulted or mandatory.

`--doc` shows detailed documentation (this document).

`--license` shows the License text. GhostBuster is released under the MIT LICENSE.

`-v` `--verbose` enables verbose message output.

`-n` `--environment-name NAME` specifies the environment name. This name is for identification purposes only; it is not used by GhostBuster. Defaults to `default`.

`-s` `--source` `-i` `--input-directory` specifies the source (input) directory (the location of the Ghost files to be exported). This can be given with or without the `content` subdirectory. Defaults to `/srv/ghost`.

`-d` `--destination` `-o` `--output-directory` specifies the destinations (comma-separated) where the export will be published.Specified as a [RFC2396](http://tools.ietf.org/html/rfc2396) URI (*Uniform Resource Indentifier*). Mandatory.

`-e` `--ghost-environment` is the name of an environment given in Ghost's `config.js` file. Defaults to `production`.

`--with-tags` lists tags (comma-separated) that posts must have, othwise they will not be exported. Optional. 
`--without-tags` lists tags (comma-separated) that posts must not have if they are to be exported. Optional.
`--hide-tags` lists tags (comma-separated) that will be ignored when building posts' tag lists (use this to suppress display of some tags).

`-p` `--published` will export only published content.

`-u` `--url` overrides the absolute URL of the blog that is written in the exported files.

`--export-filter` lists the export filters to use (comma-separated). See the *EXPORT FILTERS* section below.

`-f` `--environment-file` will load environments from the given file. See the *ENVIRONMENT FILE* section below.

`--replace` lists replacement expressions to use (comma-separated). See the *REPLACEMENT EXPRESSIONS* section below.

### Export Filters

GhostBuster uses *export filters* to export the content into different formats. These export filters are available:

  * `html` exports content as HTML along with images and other metadata. The HTML is derived from the active theme definition.
  * `html_basic` is similar but uses a static HTML template that is loosely based on the default 'Casper' theme. 
  * `jekyll` exports content ready for use as a [Jekyll](http://jekyllrb.com/) site.
  * [middleman](/middleman) exports content ready for use as a [Middleman](http://middlemanapp.com) site.
  * `markdown` export post content to markdown text files.
  * `yaml` export post metadata to YAML text files (excludes content).
  * `kramdown` processes Markdown into other formats including LaTeX.
  
There is one other export filter that is special because it doesn't *export* anything: `backup` copies `config.js`, `ghostbuster.yml` and the entire `content` directory. This is sufficient to back up a Ghost system (it doesn't copy the Ghost core becuase this is easily reinstalled. 
<small><span style="font-weight:bold">NOTE: </span>Because `backup` exports everything, the setting of `ghost-environment` has no effect on its output (it does, however, still need to be supplied with a valid value).</small>
 
The HTML filters produce a set of files that is a static representation of the Ghost blog. The files can be used to serve a static HTML-only snapshot of the Ghost blog on a static web server.

The `html_basic` filter is loosely based on the default *Casper* theme and produces a usable rendition of the blog. It uses the blog metadata (title and blog image) from the active theme, if there is one, or Casper. It doesn't include *advanced* features such as pagination or an RSS feed. All exported posts are indexed by a one-page `index.html` file. All post content is replicated, including images.

The `html` filter uses the theme source files for the active theme to produce, as close as possible, an exact replica of the blog as it rendered by the Ghost server. It includes a paginated set of index files, the first of which is called `index.html` and an RSS feed containing the 20 most recent posts at `/rss/index.xml`. All post content is replicated, including images.

Because the `html` filter attempts to translate the theme's *handlebars* source files, it may not always work perfectly. It works on Casper and should be fine with close derivatives thereof. It *should* work on other themes but any that use features that Casper doesn't may cause problems. Specifically, only the `default.hbs`, `index.hbs` and `posts.hbs` are parsed. Any theme using partials will not work. 

For occasions where the `html` filter falls short, the `html_basic` filter will work.

The RSS feed produced by the `html` filter uses a basic template that is loosely similar to Ghost's own. Notable differences include the fact that the Ghost feed contains entire posts whereas GhostBuster includes only an excerpt.  

### Publishers

You can specify the export destination as a URI. If there is a publisher for the URI *scheme* then it is invoked to publish the export to that URI.

The following publishers are available:

* `file` publishes to a path on the local filesystem.
* `ftp` publishes to a remote FTP server.
* `ssh` publishes to a remote SSH server (uses secure copy, `scp`).
* `sftp` publishes to a remote SFTP server.
* `rsync` publishes to a remote RSYNC server (using the rsync protocol, not ssh).
* `git` publishes to a local and, optionally, remote repository.
* `github` publishes to a Git repository hosted on [GitHub](http://github.com).

The URI format is defined by [RFC2396](http://tools.ietf.org/html/rfc2396); some examples are listed below

    file://relative//path
    file:///absolute/path

    ftp://ftp.example.org
    ftp://user:password@ftp.example.org
    ftp://user:password@ftp.example.org/path/to/publish/to
    
    ssh://user:password@ssh.example.org/path/to/publish/to
    ssh://user@ssh.example.org/path/to/publish/to
    ssh://ssh.example.org/path/to/publish/to
    
    sftp://user:password@sftp.example.org/path/to/publish/to
    sftp://user@sftp.example.org/path/to/publish/to
    sftp://sftp.example.org/path/to/publish/to

    github://user:password@repository/branch
    github://user:password@repository
    github://repository/branch
    github://repository
 
    git://relative/path/to/repo
    git:///absolute/path/to/repo
    git:///absolute/path/to/repo?params
    
The publishers will attempt to obtain login credentials (username and password) from a `.netrc` file if they are omitted from the URI.

The `ssh` and `sftp` publishers will use keys held by an SSH agent for authentication if Ghostbuster's envorironment was started with `SSH_AUTH_SOCK` defined and pointing at an agent. If `user` is not supplied then the user that Ghostbuster runs as is used. The path specified is an absolute path. 


<small><span style="font-weight:bold">TIP: </span>To start the agent, set `SSH_AUTH_SOCK` and load a key into the agent (requesting the key's passphrase if it has one):

    eval `ssh-agent` && ssh-add ~/.ssh/my_key
</small>

The URI may include parameters in the *query string* part of the URI. How these parameters are handled, if at all, depends on the publisher being used. The format of the parameters is

    <URI>?param1=value[[&param2=value]...]

The `rsync` publisher accepts the following parameters:

* `rsync_args` takes a list of rsync command-line arguments (see [man rsync](http://linux.die.net/man/1/rsync).

The `git` publisher accepts the following parameters:

* use `remote` to specify a remote Git repository. If the `path/to/repo` does not exist then it will be created by cloning this remote. The remote is specified using a URI of the form described below.
* use `commit` to specify `false` to prevent the changes being committed. Any other value has no effect.
* use `commit_message` to specify the message written on the commit. If this parameter is missing then the default commit message, *Ghostbuster publish*, will be used. Note that a URI requires spaces to be encoded as `%20`.
* use `push` to specify `false` to prevent the commit being pushed to the remote. Any other value has no effect. 

The remote repository can be specified using any format acceptable to `git clone` but only `ssh` allows the published changes to be pushed back. An example remote URI is shown below.

     ssh://git@user.github.com/user/repo

An example URI for the `git` publisher is shown below

    git:///local/path/to/repo?remote=ssh://git@myuser.github.com/myuser/repo&push=false&commit_message=a%20commit%20message

The `git` publisher adds/changes files in the target repository but does not delete anything. To also delete files that were not generated by the publisher, use the `rsync_args` parameter to specify `--delete` (the `git` publisher uses rsync to update the repository with the exported files).

To store GitHub credentials in a `.netrc` requires it to have an entry like this:

    machine api.github.com username password

### Environment File

An *Environment File* can be used insead of or in addition to defining the run-time environment using command-line options.

The Environment file contains one or more environment definitions and is supplied either using the `--environment-file`, or `-f`, command-line
argument or as a file called `ghostbuster.yml` in the `SOURCE` directory.

The file format is [YAML](http://www.yaml.org) and each environment definition is formatted like this:

    name:
      option: single-value
      option:
        multiple
        values

The `name` can be anything; it serves no purpose except to identify the
environment. There can be multiple options and these are described above but only the long-form option name can be used in an environment file (and only the first one if there are more) unless otherwise stated: some options
have shorter aliases that can be used in an environment file but these cannot be used on the command-line. Short-form option names can only be used on the command-line. When using an option in an environment file, the leading double-hyphen is omitted and connecting dashes are replaced by underscores.

Some options require a single value whereas other can be given multiple values.

An example `ghostbuster.yml` file is shown below:

    Public website:
      ghost_environment: development
      url: http://blog.example.com
      destination: /tmp/export
      filter: html

    Backup:
      ghost_environment: development
      destination: /tmp/backup
      filter:
        markdown
        yaml

#### Multiple values

Items that can take multiple values can be expressed in the environment file in four ways:

* on one line as a comma-delimited list
* on one line as a space-delimited list
* on multiple lines, indented
* on multiple lines, indented and prefixed with a hyphen

The following examples are equivalent.

    destination: file://data/export ftp:ftp.example.com
    
and

    destination: file://data/export,ftp:ftp.example.com
   
and

    destination:
      file://data/export
      ftp:ftp.example.com
      
and

    destination:
      - file://data/export
      - ftp:ftp.example.com

Use whatever style best matches your personal taste. Multiple values given as command-line options must always be comma-delimited.

### Replacement Expressions

Replacement expressions can be used to alter the value of fields as they are exported from Ghost. The format of a replacement expression is:

    field:old,new
    
where

* `field` is any field in the GhostBuster *posts* table
* `old` is used to match characters within the field's value and
* `new` replaces any matched characters

The `old` characters can be specified either as a text string or as a regular expression. [Rubular](http://rubular.com) is a useful resource that can help with forming suitable regular expressions. 

Regular Expressions must be bounded with `/` and strings with `'`. The full syntax capabilities of `old:new` follow the rules described [here](http://ruby-doc.org/core-2.0/String.html#method-i-gsub).

Every match of `old` found in the `field` is replaced with `new`. Badly formed replacement expressions are ignored. Replacement expressions could be used to alter, for example,

* the post's title `title` or
* its file name, whhich is derived from the `slug` field.

To specify multiple replacement expressions, use a single whitespace-separated string like this example:{% assign openTag = '{%' %}

    replace: "markdown:/{% raw %}({{|}}){% endraw %}/,'{{ openTag }} raw %}\\1{{ openTag }} endraw %}' title:':',' - '"

This example supplies two replacement expressions, the first applies to the `markdown` field and the second to the `title` field. It demonstrates use of regular expressions, strings and match variables.

### Examples

Export HTML from development, include published posts except those tagged as *private*:

    ghostbuster /srv/ghost /tmp/export --published --exclude-tags=private
    
Export Jekyll to GitHub. Include only published posts that have a specific tag and hide that tag so that it isn't displayed on the site:

    ghostbuster /srv/ghost file:///tmp/export --published --with-tags=microsite --hide-tags=microsite --export-filter=jekyll

#### Middleman


The `Middleman` filter generates the contents of the `source` directory in a Middleman project.

```
Middleman:
 ghost_environment: development
 destination: file:///home/myuser/middleman/blog/source
 filter: middleman
 published: true
```

Here is an example of using Middleman with a [Casper](https://github.com/danielbayerlein/middleman-casper) theme:
```
gem install middleman
mkdir ~/.middleman
git clone https://github.com/danielbayerlein/middleman-casper ~/.middleman/casper
middleman init blog --template=casper
cd blog
```
Then, from the server where Ghost is running (assuming a suitable environment similar to the above example is in `middleman.yml`):

    ghostbuster -v -f middleman.yml

And then, from the middleman blog:

    middleman server

and browse to `http://localhost:4567`.

#### kramdown

The `kramdown` filter can export to various formats. Specify the converter as a parameter to the `export_filter`, for example:
    
    export_filter: kramdown?convert=latex
    
If the `convert` parameter is not given, it defaults to `latex`.

##### LaTeX

Kramdown can generate LaTex. You can read about the LaTeX converter's options [here](http://kramdown.gettalong.org/converter/latex.html). They may be specified as parameters to the `export_filter`.

By default, the LaTeX converter outputs just the converted content and not a complete LaTeX document. The `template` option must be supplied to select a *framework* - a value of `default` is sufficient to generate a complete document. Consult the kramdown documentation(http://kramdown.gettalong.org/converter/latex.html) for further details. An example GhostBuster environment to generate LaTeX is given below:

    LaTeX:
      destination: file:///home/myuser/ghostlatex
      filter: kramdown?convert=latex&template=default

The generated LaTeX can be used to generate other document formats: for example, PDF.

    pdflatex file.tex
    
will produce `file.pdf`.

Onward processing of LaTeX documents is beyond GhostBuster's scope.


