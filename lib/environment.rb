require_relative('helpers')
require 'optparse'
require 'sqlite3'  # gem install sqlite3
class Environment

  # Accessors
  module Accessors
    def option(o)
      defined?(@options) ? @options[o.to_sym] 
                 : defined?(@environment) ? @environment.option(o) : Environment.option(o)
    end

    def path(p)
      defined?(@paths) ? @paths[p.to_sym]
                 : defined?(@environment) ? @environment.path(p) : Environment.path(p)
    end
    def setting(p)
      defined?(@settings) ? @settings[p.to_sym]
                 : defined?(@environment) ? @environment.setting(p) : Environment.setting(p)
    end
    def export_filters
      defined?(@export_filters) ? @export_filters
                 : defined?(@environment) ? @environment.export_filters : Environment.export_filters
    end

    def db
    defined?(@db) ? @db : defined?(@environment) ? @environment.db  : Environment.db
    end

    def posts
      log "Running posts query\n#{query(:posts)}"
      db.execute(query(:posts)) { |p| yield p }
    end

    def query(p)
      defined?(@queries) ? @queries[p] 
                       : defined?(@environment) ? @environment.query(p) : Environment.query(p)
    end
  end

  class << self

  include Helpers

  include Accessors

protected

  # Private accessors
  def options
    @options
  end
  def paths
    @paths
  end
  def settings
    @settings
  end

  def load_environment

    return if defined?(@options) # only parse options once 

    puts "parsing options..."

    @options = {}

    optparse = OptionParser.new do |opts|
     opts.banner = 'GhostBuster: Export and publish Ghost blog as static pages.'

      opts.on("--help", "show helpful documentation") do |v|
        puts File.read("#{File.dirname(__FILE__)}/../doc/HELP")
        exit 0
      end
    
      opts.on("--license", "show the MIT License") do |v|
        puts File.read("#{File.dirname(__FILE__)}/../LICENSE")
        exit 0
      end
    
      opts.on("-v", "--verbose", "Enable verbose message output") do |v|
        verbose_on
      end
    
      @options[:env] = 'development'
      opts.on("-e", "--environment ENV", "Environment to copy from") do |e|
       @options[:env] = e
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
    
      opts.on("-u", "--url URL", "Absolute URL to use in exported blog") do |u|
       @options[:url] = u
      end
    
      @options[:formats] = []
      opts.on("--html", "Extract html") do |f|
       @options[:formats] << :html
      end
      opts.on("--html_basic", "Extract html (basic)") do |f|
       @options[:formats] << :html_basic
      end
      opts.on("--markdown", "Extract Markdown") do |f|
       @options[:formats] << :markdown
      end
      opts.on("--yaml", "Extract YAML") do |f|
       @options[:formats] << :yaml
      end
    end

    optparse.parse!

    # default format options if not explicitly given as arguments
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
    @paths[:config] = @paths[:root] + '/config.js'
    @paths[:database] = @paths[:source] + '/data/ghost-dev.db'

    # Check paths are valid
    @paths.each do |name,path|
      do_or_die(File.exists?(path), "#{name} path '#{path}' is good",
                                    "#{name} path #{path} not found")
    end

    # Load configuration file
    do_or_die(config = File.read(@paths[:config]),"read config ok","read config failed")
    config.gsub!(/^\s*?\/\/.*?\n/m,'') # remove comments from config

    # Get database file
    match_dbfile = config.match(/#{options[:env]}:\s*{.*?database:\s*{.*?connection:\s*{.*?filename:.*?([\w-]*?\.db)/m)
    dbfile = match_dbfile.nil? ? abort("unable to find database file name for '#{options[:env]}' environment in configuration file") : match_dbfile[1]

     @paths[:database] = @paths[:source] + '/data/' + dbfile

    # Open database
    dbfile = @paths[:database]
    do_or_die(File.exists?(dbfile),'database found',"Cannot find database file #{dbfile}")
    do_or_die(@db = SQLite3::Database.new(dbfile),'database opened',
                                                  "Could not initialise database #{dbfile}")
    @db.results_as_hash = true

    # Load settings from database
    settings = %w[title description logo cover activeTheme]
    query = "select key,value from settings where key in (#{settings.map{|s|"'#{s}'"}.join(',')})"
    @settings = {}
    do_or_die(@db.execute(query).each{|s| @settings.update s[0].to_sym => s[1]},
          'read settings','unable to read settings')
    @settings.each { |k,v| log "setting(#{k}) = #{v}" }

    # Set the URL that will be used as the root on exported blogs
    if @options.include?(:url)
      @settings[:url] = @options[:url]
    else
      # Get site URL from config file and put it into settings array
      match_url = config.match(/#{options[:env]}:\s*{.*?url:\s*'(.*?)'/m)
      url = match_url.nil? ? abort("unable to find url for #{options[:env]} environment") : match_url[1]
      @settings[:url] = url
    end

    # Build posts query
    @queries = {}
    @queries[:posts] = 'SELECT posts.*, users.name as author_name from posts' \
                   << ' INNER JOIN users ON posts.author_id = users.id'

    whand = ' WHERE' # will change to 'AND' for subsequent clauses
    unless option(:with_tags).nil?   
      @queries[:posts] << whand << ' EXISTS (' \
                       <<   'SELECT 1 FROM posts_tags' \
                       <<   ' INNER JOIN tags ON tags.id = posts_tags.tag_id' \
                       <<   ' WHERE posts_tags.post_id = posts.id' \
                       <<   ' AND tags.name IN (' \
                       <<   option(:with_tags).split(',').map {|t| "'#{t}'" }.join(',') \
                       <<   '))'             
      whand = ' AND'
    end

    unless option(:without_tags).nil?
      @queries[:posts] << whand << ' NOT EXISTS (SELECT 1 FROM posts_tags' \
                       <<   ' INNER JOIN tags ON tags.id = posts_tags.tag_id' \
                       <<   ' WHERE posts_tags.post_id = posts.id' \
                       <<   ' AND tags.name IN (' \
                       <<   option(:without_tags).split(',').map {|t| "'#{t}'" }.join(',') \
                       <<   '))'                
      whand = ' AND'
    end

    @queries[:posts] << whand << " posts.status == 'published'" if option(:published) 
    @queries[:posts] << ' ORDER BY posts.published_at DESC'
#    @queries[:posts] << " LIMIT 1" # Debugging limit

    # Load modules for output filters
    @export_filters = []
    @options[:formats].each do |f|
      f = f.to_s
      log "Loading #{f} output filter"
      require_relative 'export_filters/export_'+f
      @export_filters << Object.const_get('ExportFilter_'+f).new(self)
    end

  end

end

  # Load the environment
  self.load_environment

end
