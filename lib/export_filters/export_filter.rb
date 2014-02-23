class ExportFilter

  def initialize(e)
    @environment = e
  end

  def close
  end

  # Extends the functionality of a post hash with methods to access
  # the post's content. Also requires the fle extension to be supplied;
  # this initialises the post's filename generation methods.
  def extend_post(p,e)
    # helper methods for post
    require_relative 'post'
    class << p
      include Post
    end
    p.file_extension = e
  end

protected

  # Writes content to file at destination and timestamps it
  def write(file,content,timestamp=nil)

    f = File.join(path(:destination),file)
    log("writing '#{f}'")

    # write the file 
    File.open(f, 'w') {|f| f.write(content) }

    # Time-stamp the file if required
    File.utime(Time.now,timestamp,f) unless timestamp.nil?

  end

private

  attr_reader :environment

  def setting(s) environment.setting(s) end
  def path(s) environment.path(s) end
  def option(s) environment.option(s) end

end
