require_relative 'export_filter'
require 'fileutils'

# Add supporting methods to the Post extension
module Post

  # Return the posts's markup with Jekyll front-matter applied:
  # a combination of default front-matter defined below that is
  # augmented with any supplied in the post.
  def markdown
    md = super
    frontmatter= { 'layout'     => 'post',
                   'title'      => title,
                   'date'       => date(format: 'YYYY-MM-DD HH:mm:ss'),
                   'categories' => tags.join(' '),
                   'permalink'  => slug+'.html'
                  }
    match_regex = /^---$(.*?)^---$/m
    
    # augment frontmatter with any already in post
    if fm_match = md.match(match_regex)
      fm_match[1].strip.split("\n").each do |s|
        k,v = s.split(':').each{|s| s.strip!}
        frontmatter[k] = v
      end
    end

    # write frontmatter into post
    fm_str = %{---\n#{frontmatter.map{|k,v| "#{k}: #{v}"}.join("\n")}\n---\n}
    md.insert(0,fm_str) unless md.sub!(match_regex,fm_str)

    md
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
    content = post.markdown

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
