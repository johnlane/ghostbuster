require 'fileutils'

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

  # Copy directories unless source and destination are the same
  def copy(copydirs)
    unless path(:source) == path(:destination)
      copydirs = copydirs.split(',') if copydirs.is_a? String
      abort("Export filter can't copy #{p option(:copydirs)}") unless copydirs.is_a? Array

      copydirs.each do |src|
        dest = src.dup
        src.insert(0,path(:source)+'/')       # prepend source directory
        dest.insert(0,path(:destination)+'/') # prepend destination directory
        FileUtils.mkdir_p(dest)               # ensure dest intermediate dirs exist
        log("copying '#{src}' to '#{dest}'")
        FileUtils.cp_r(src,dest,preserve: true)
      end
    end
  end


private

  attr_reader :environment

  def setting(s) environment.setting(s) end
  def path(s) environment.path(s) end
  def option(s) environment.option(s) end

end
