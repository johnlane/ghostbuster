class GB_Environment

  LICENSE = File.read('LICENSE')
  README  = File.read('README')

  require 'optparse'

  def initialize

    puts "New GBE"
    @yyy = "yyy"

  end

  # Instance method uses class-instance variable accessor
  def optval(o)
    self.class.options[o]
  end
  def path(p)
    self.class.paths[p]
  end

private

  def self.parse_options

    return if defined?(@options)

    puts "parsing options..."

    @options = {}

    optparse = OptionParser.new do |opts|
    opts.banner = README

      opts.on("--license", "show the MIT License") do |v|
        puts LICENSE
        exit 0
      end
    
      opts.on("-v", "--verbose", "Enable verbose message output") do |v|
       $verbose = true
      end
    
      @options[:env] = 'development'
      opts.on("-e", "--environment ENV", "Environment to copy from") do |e|
       @options[:env] = e
      end
    
      opts.on("--copydirs COPYDIRS", "Specify directories to copy (comma-separated)") do |d|
        @options[:copydirs] = d
      end
    
      opts.on("--with-tags TAGS", "Include only posts with these tags (comma-separated)") do |d|
        @options[:with_tags] = d
      end
    
      opts.on("--without-tags TAGS", "Include only posts without these tags (comma-separated)") do
     |d|
        @options[:without_tags] = d
      end
    
      opts.on("-p", "--published", "Only published content") do |v|
       @options[:published] = true
      end
    
      @options[:formats] = []
      opts.on("--html", "Extract html") do |f|
       @options[:formats] << :html
      end
      opts.on("--markdown", "Extract Markdown") do |f|
       @options[:formats] << :markdown
      end
      opts.on("--yaml", "Extract YAML") do |f|
       @options[:formats] << :yaml
      end
    end

    optparse.parse!

    # default format options if non explicitly given as arguments
    @options[:formats] = [:html, :markdown, :yaml] if @options[:formats].empty?

    # Positional arguments
    if ARGV.empty?
      puts optparse
      exit 1
    end

    @paths = {source: ARGV[0].dup}
    if File.basename(@paths[:source]) == 'content'
      @paths[:root] = File.dirname(@paths[:source])
    else
      @paths[:root] = @paths[:source]
      @paths[:source] = @paths[:root] + '/content'
    end
    @paths[:destination] = ARGV.count >1 ? ARGV[1] : @paths[:source]
    @paths[:config] = @paths[:root] + 'config.js'
    @paths[:database] = @paths[:source] + '/data/ghost-dev.db'

  end

  # Class-instance variable accessor
  def self.options
    @options
  end
  def self.paths
    @paths
  end

  # Call class methods to initialise the class
  parse_options

end
