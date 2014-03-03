require_relative 'export_filter'

class ExportFilter_html < ExportFilter

  include Helpers

  def initialize(e)
    super
    abort "Cannot export HTML without an active theme" if setting(:activeTheme).nil?
    load
    copy [ 'images', 'themes/'+setting(:activeTheme) ]
  end

  # Output a post
  def export_post(post)

    extend_post(post,'html')

    # Make a copy of the html for this post
    post_html = @html['default'].gsub(/{{body}}/,@html['post'])
    post_handlebars(post,post_html)

    # Make a copy of the html for this post's index entry
    index_html = @html['index-post'].dup
    post_handlebars(post,index_html)
    @html_index << index_html

    # Write the post html file
    write(post.filename,post_html,post.update_timestamp)
  
  end

  # Close the output filter
  # Writes a paginated index file
  def close

    debug("Writing HTML index")
    posts_per_page = setting(:postsPerPage).to_i
    page = 0
    pages = @html_index.count / posts_per_page + 1

    begin

      index = @html['index-top'].dup
      posts = 0

      while !@html_index.empty? and posts < posts_per_page do
        index << @html_index.shift
        posts+=1
      end

      index << @html['index-bottom']

      # Pagination controls using HTML derived from Ghost default 
      # note that any "pagination.hbs" partial in the theme is ignored
      prev_file = page > 0 ? (page == 1 ? 'index.html' : "index#{page-1}.html") : nil
      this_file = page == 0 ? "index.html" : "index#{page}.html"
      next_file = @html_index.count + posts > posts_per_page ? "index#{page+1}.html" : nil
      pagination = '<nav class="pagination" role="pagination">'
      pagination << '<a class="newer-posts" href="'<<prev_file<<'">&larr;</a>' if prev_file
      page+=1
      pagination << '<span class="page-number">Page '<<page.to_s<<' of '<<pages.to_s<<'</span>'
      pagination << '<a class="older-posts" href="'<<next_file<<'">&rarr;</a>' if next_file
      index.gsub!(/{{pagination}}/,pagination)

      write(this_file,index)

    end until @html_index.empty?

  end

private

  def load

    # Collect HTML from theme
    themedir = path(:source) + '/themes/'+setting(:activeTheme)
    do_or_die(File.directory?(themedir),'theme directory ok',"'#{themedir} is not a directory")
    @html = {}
    %w(default index post).each do |f|
      do_or_die(@html[f] = File.read("#{themedir}/#{f}.hbs"),"read #{f}.hbs ok",
                                                            "read #{f}.hbs failed")
      # Remove a brace when there are three; simplify onward processing
      @html[f].gsub!(/{{{/,'{{')
      @html[f].gsub!(/}}}/,'}}')

      # Change handlebars comments to HTML
      @html[f].gsub!(/{{!(.*?)}}/m,'<!--\1-->')

      # Ignore some handlebars - turn them into comments
      @html[f].gsub!(/{{(ghost_head|ghost_foot)}}/,'<!--\1-->')

      # Substitute handlebars if/else blocks where the "if" checks a setting
      # http://rubular.com/r/EInc5TvAsP
      @html[f].gsub!(/{{#if @blog.([a-z]+)}}\s*(.*?)({{else}}\s*(.*?))?{{\/if}}/m) do
        setting($~.captures[0].to_sym) ? $~.captures[1] : $~.captures[3]
      end

      # Remove handlebars #if ... /if
      # @html[f].gsub!(/(.*){{#if.*?}}(.*){{\/if}}(.*)/,'\1 \2 \3')

      # Expand settings (http://rubular.com/r/toLo7a2FYQ)
      @html[f].gsub!(/{{(@blog\.|meta_)([a-z]+)}}/) do
        s = $~.captures[1].to_sym
        setting(s) unless setting(s).nil?
      end

      # Remove leading '/content' from URL paths
      @html[f].gsub!(/([\("'])\/content\//,'\1')
  
      # Prefix the assets URL with the theme directory name
      @html[f].gsub!(/((href|src)=['"])(\/assets\/)/,'\1'+setting(:activeTheme)+'\3')

      # Strip HTML comments (http://rubular.com/r/jd7C1Hdl0l)
      @html[f].gsub!(/<!--.*?-->/m,'')
      @html[f].gsub!(/^\s*$/m,'')      # strip empty lines
    end

    # Prepare the index html
    html_index = @html['default'].gsub(/{{body}}/,@html['index'])
    html_index.gsub!(/{{body_class}}/,"home-template")

    # Split the index html into three parts: the top, the post and the bottom
    # The post part is repeated for each post on the index page
    splits = html_index.split(/{{#foreach posts}}/)
    @html['index-top'] = splits[0]
    @html['index-post'], @html['index-bottom'] = splits[1].split(/{{\/foreach}}/)

    # Start the html index
    @html_index = []

  end

  def post_handlebars(post,post_html)
    # Remove post Handlebars wrappers
    post_html.gsub!(/{{[#\/]post}}/,'')

    # Insert the post content
    post_html.gsub!(/{{content}}/,post.html)

    # Substitute handlebars if/else blocks where the "if" checks a field
    # when expression looks for field f, this tests for presence of f or f_id
    post_html.gsub!(/{{#if ([a-z]+)}}\s(.*?)({{else}}\s(.*?))?{{\/if}}/m) do
      if post[$~.captures[0]]
        $~.captures[1]
      elsif post[$~.captures[0]+'_id']
        $~.captures[1]
      else
        $~.captures[3]
      end
    end

    # Substitute handlebars if/else blocks where the "if" checks a join field
    # when expression looks for field f, this tests for presence of f or f_id
    # http://rubular.com/r/eTWYVU4Led
    post_html.gsub!(/{{#if ([a-z]+)}}(.*){{\/if}}/) do
      q = "SELECT count(*) FROM posts_#{$~.captures[0]} WHERE post_id = #{post.id}"
      $~.captures[1] if environment.query(q).first[0] > 0
    end
  
    # Substitute handlebars field value-list references (http://rubular.com/r/HfdwHY0Sdw)
    # separate table and field: http://rubular.com/r/QPgUW8cskT
    # combined table and field: http://rubular.com/r/stjJodrz6c
    post_html.gsub!(/{{((?'field'[a-z\.]+)??(s)?)(\s+(?'modifiers'[a-z]+=["'].*?["']))?}}/) do
      df = $~[:field]
      mods = $~[:modifiers]
      post.get_key(df,mods)
    end

    # Expand body_class
    q = "SELECT t.name FROM posts_tags pt JOIN tags t ON t.id = pt.tag_id WHERE pt.post_id
 = #{post.id}"
    r = environment.query(q)
    tagcss = r.map! {|r| 'tag-'+r['name'].downcase.gsub(' ','-')}.join(' ') # tag names as CSS class IDs
    post_html.gsub!(/{{body_class}}/,"post-template "+tagcss)
    post_html.gsub!(/{{post_class}}/,"post "+tagcss)

    # Remove leading '/content' from URL paths
    post_html.gsub!(/([\("'])\/content\//,'\1')
  end
end
