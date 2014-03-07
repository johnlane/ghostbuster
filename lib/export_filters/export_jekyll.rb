require_relative 'export_filter'
require 'fileutils'

# Add supporting methods to the Post extension
module Post
  def front_matter # http://jekyllrb.com/docs/frontmatter
    fm = "---"+NL
    fm << "layout: post"+NL
    fm << "title: \"#{title}\""+NL
    fm << "date: #{date format: 'YYYY-MM-DD HH:mm:ss'}"+NL
    fm << "categories: #{tags.join(' ')}"+NL
    fm << "permalink: #{slug}.html"+NL
    fm << "---"+NL
  end
end

class ExportFilter_jekyll < ExportFilter

  include Helpers

  def initialize(e)
    super
    assets = 'themes/'+(setting(:activeTheme) ? setting(:activeTheme) : 'casper')+'//assets/'
    copy [ 'images', assets+'css/', assets+'fonts/' ]
    FileUtils.mkdir_p(path(:destination)+'/_posts')
  end

  # Output a post
  def export_post(post)

    extend_post(post,'md')

    # get markdown content
    content = post.front_matter + post.markdown
  
    # write the post
    write("_posts/#{post.date format: 'YYYY-MM-DD'}-#{post.filename}",content,post.update_timestamp)

  end

end
