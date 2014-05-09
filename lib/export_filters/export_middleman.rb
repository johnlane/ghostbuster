require_relative 'export_filter'
require 'fileutils'

# Add supporting methods to the Post extension
module Post
  def front_matter # http://middlemanapp.com/basics/frontmatter/
    fm = "---"+NL
    fm << "title: \"#{title}\""+NL
    fm << "date: #{date format: 'YYYY-MM-DD'}"+NL
    fm << "tags: #{tags.join(' ')}"+NL
    fm << "---"+NL
  end
end

class ExportFilter_middleman < ExportFilter

  include Helpers

  def initialize(e,p={})
    super
    copy [ 'images' ]
  end

  # Output a post
  def export_post(post)

    extend_post(post,'html.md')

    # get markdown content
    content = post.front_matter + post.markdown

    # Remove leading '/content' from URL paths
    content.gsub!(/(!\[\]\(\/)CONTENT\//,'\1')
  
    # write the post
    prefix = "#{post.date format: 'YYYY-MM-DD'}-"
    write(prefix+post.filename,content,post.update_timestamp)

  end

end
