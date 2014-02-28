require 'fileutils'

class ExportFilter

  attr_reader :environment
  def initialize(e)
    @environment = e
  end

  def setting(s) environment.setting(s) end
  def options(o) environment.option(o) end
  def path(p) environment.path(p) end

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
    p.environment = @environment
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

  # Copies directories from the environment's source path to its destination path
  # Does not copy when the source and destination are the same
  # Accepts a list of copydirs specified as an array or a comma-separated string
  # Each copydir is a directory path to copy, relative to the environment source
  # If copydir contains a '//' then the following sub-path is appended to the destination
  # If copydir ends with a '/' then the contents of the directory are copied
  def copy(copydirs)
    unless path(:source) == path(:destination)
      copydirs = copydirs.split(',') if copydirs.is_a? String
      abort("Export filter can't copy #{p option(:copydirs)}") unless copydirs.is_a? Array

      copydirs.each do |src|
        dest_subdirs = src[/\/\/(.*)/,1] # regex returns any part of src after '//' separator
        src.gsub!('//','/')              # collapse '//' separator in source path
        dest = path(:destination).dup    # destination path           
        dest << '/'+dest_subdirs if dest_subdirs # append any destination subdirectories
        src.insert(0,path(:source)+'/')  # prepend source directory
        src << '*' if src[-1,1] == '/'   # append '*' when copying directory contents
        log("copying '#{src}' to '#{dest}'")
        FileUtils.mkdir_p(dest)          # ensure dest intermediate dirs exist
        FileUtils.cp_r(Dir[src],dest,preserve: true) # Dir globs '*' added above
      end
    end
  end

private

  attr_reader :environment

  def setting(s) environment.setting(s) end
  def path(s) environment.path(s) end
  def option(s) environment.option(s) end

end
