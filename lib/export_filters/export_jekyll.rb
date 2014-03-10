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

  def initialize(e,p={})
    super
    copy [ 'images' ]
    FileUtils.mkdir_p(path(:destination)+'/_posts')
  end

  # Output a post
  def export_post(post)

    extend_post(post,'md')

    # get markdown content
    content = post.front_matter + post.markdown

    # custom layout
    content.sub!(/^(layout: ).*/,'\1'+params[:page_layout]) if post.page? and params[:page_layout]
    content.sub!(/^(layout: ).*/,'\1'+params[:post_layout]) if post.post? and params[:post_layout]

     # Remove leading '/content' from URL paths
     content.gsub!(/(!\[\]\(\/)CONTENT\//,'\1')
  
    # write the post
    prefix = post.page == 0 ? "_posts/#{post.date format: 'YYYY-MM-DD'}-" : ''
    write(prefix+post.filename,content,post.update_timestamp)

  end

end
