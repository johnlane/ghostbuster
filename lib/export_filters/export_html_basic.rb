require_relative 'export_filter'
require 'sanitize' # gem install sanitize

class ExportFilter_html_basic < ExportFilter

  NL = "\n"

  include Helpers

  def initialize(e)
    super
    prepare_html
    assets = 'themes/'+(setting(:activeTheme) ? setting(:activeTheme) : 'casper')+'//assets/'
    copy [ 'images', assets+'css/', assets+'fonts/' ]
  end

  # Output a post
  def export_post(post)

    extend_post(post,'html')

    # get html content
    content = post.html
  
    # adjust local urls so that they will work in the html
    content.gsub!('/content/','')
  
    # wrte html for the post page
    html = @html_head + NL
    html << '<span class="post-meta"><time>' + post.date + '</span>'
    html << '<h1>'+post.title+'</h1>'
    html << '<section class="post-content">'+content+'</section>'
    html << @html_foot

    # write the post
    write(post.filename,html,post.update_timestamp)

    # write index entry
    output_index(post)

  end

  def close
    log("writing html index")
    @html_index << @html_foot
    File.open("#{path(:destination)}/index.html", 'w') {|f| f.write(@html_index) }
  end

private

  # define file extension for this filter
  def file_extension
    'html'
  end

  def output_index(post)

    # get a plain-text excerpt from content for the index page
    excerpt = Sanitize.clean(post.html)[0..250]
  
    # write entry to the index page for this post
    @html_index << '<article class="post"><header class="post-header">' << NL
    @html_index << '<span class="post-meta"><time>' + post.date + '</span>' << NL
    @html_index << '<h2 class="post-title"><a href="' + post.filename + '">' + post.title + '</a></h2>' << NL
    @html_index << '<section class="post-excerpt"><p>'+post.excerpt+'&hellip;</p>' << NL

    # get index links from other output filters
#    if export_filters.count > 1
#      @html_index << '<p style="font-size:small">' << NL
#      export_filters.each do |f|
#        url = f.filename(post)   ### this does not work, so commented out block
#        link = File.extname(url)
#        @html_index << '<a href="' + url + '">(' + link + ')</a>' << NL
#      end
#      @html_index << '</p>' << NL
#    end
  
    # end this index entry
    @html_index << '</section></article>' << NL

  end
  
  def prepare_html

    meta = '<meta http-equiv="Content-Type" content="text/html" charset="UTF-8" />' + NL
    meta << '<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />' + NL
    meta << '<link rel="stylesheet" type="text/css" href="/assets/css/screen.css"/>' + NL
    meta << '<link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Droid+Serif:400,700,400italic|Open+Sans:700,400" />' + NL
    meta << '<meta name="generator" content="GhostBuster" />'

    @html_index='<html><head>' + NL + meta + NL + '</head>'
    @html_index << '<body class="home-template">' << NL

    cover_path = /\/content\/(.*)/.match(setting(:cover))[1]
    logo_path = /\/content\/(.*)/.match(setting(:logo))[1]

    year = Time.now.strftime('%Y')

    @html_index << '<header id="site-head" style="background-image: url('+cover_path+')">' << NL
    @html_index << '<div class="vertical"><div id="site-head-content" class="inner">'
    @html_index << '<h1 class="blog-title">' + setting(:title) + '</h1>'
    @html_index << '<h2 class="blog-description">' + setting(:description) + '</h2>'
    @html_index << '</div></div>' << NL << '</header>' << NL << '<main class="content" role="main">'
  
    @html_head='<html><head>' + NL + meta + NL + '</head>' + NL
    @html_head << '<body class="post-template"><main class="content" role="main">'
    @html_head << '<article class="post"><header class="post-header">'
    @html_head << '<a id="blog-logo" href="index.html"><img src="'+logo_path+'" alt="Blog Logo" /></a></header>'
  
    @html_foot='</main>'
    @html_foot = '<footer class="site-footer"><div class="inner">'
    @html_foot << '<section class="copyright">All content copyright <a href="index.html">'
    @html_foot << setting(:title) << '</a> &copy; '+year+' &bull; All rights reserved.</section>'
    @html_foot << '<section class="poweredby">Powered by <a href="https://github.com/johnlane/ghostbuster">GhostBuster</a> &copy;'+year+' John Lane</section>'
    @html_foot << '</div></footer>'
    @html_foot << '</body></html>'

  end

end
