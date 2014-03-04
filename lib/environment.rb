require_relative('helpers')
require 'optparse'
require 'sqlite3'  # gem install sqlite3
require 'yaml'
class Environment

  # Default configuration applies to all environments unless customised
  CONFIG = { name: 'default',
             ghost_environment: 'production',
             export_filters: 'html',
             source: '/srv/ghost',
           }

  # An environment will abort unless it receives values for these items.
  # They must either be defined above in CONFIG or otherwise supplied into
  # an environment from the command-line or an environment file.
  CONFIG_REQUIRED = %i(source destination ghost_environment export_filters)

  # The options that are required but don't get defaulted
  CONFIG_MANDATORY = (CONFIG_REQUIRED - CONFIG.keys)

  # Name of the default environment file that will be used if present
  # and no other environment file is given on the command-line.
  ENVIRONMENT_FILE = 'ghostbuster.yml'

  # Instantiated environments get added to this array
  @environments = []
  
  @@limit_posts = false # if true the export is limited to one post ( -1 cmd-line)

  class << self

    include Helpers
  
#    attr_reader :environments

  protected
  
    # Parses the options given on the command-line and, optionally, in a
    # supplimentary configuration file
    def load_environments
  
      return if defined?(@options) # only parse options once 

      log("parsing options...")
  
      options = {}
      environments = []
  
      optparse = OptionParser.new do |opts|
       opts.banner = 'GhostBuster: Export and publish Ghost blog as static pages.'
  
        opts.on('-h', "--help", "show this help information") do |v|
          puts optparse
          puts
          puts option_summary
          exit 0
        end
      
        opts.on("--doc", "show detailed documentation") do
          puts File.read("#{File.dirname(__FILE__)}/../doc/HELP")
          exit 0
        end
      
        opts.on("--license", "show the MIT License") do
          puts File.read("#{File.dirname(__FILE__)}/../LICENSE")
          exit 0
        end
      
        opts.on("-v", "--verbose", "Enable verbose message output") do
          verbose_on
        end

        opts.on("-1", "Limit posts query to one row (for testing)") do
          options[:maximum_posts] = 1
          @@limit_posts = true
        end
      
      
        opts.on("-n", "--environment-name NAME", "Name this enviroment") do |n|
         options[:name] = n
        end

        opts.on("-s", "--source", "-i", "--input-directory DIR", "Input directory (location of Ghost files)") do |d|
         options[:source] = d
        end

        opts.on('-d', '--destination', '-o', '--output-directory DIR', 'Output directory') do |d|
         options[:destination] = d
        end

        opts.on("-e", "--ghost-environment ENV", "Environment to copy from") do |e|
         options[:ghost_environment] = e
        end
      
        opts.on("--with-tags TAGS", "Include only posts with these tags (comma-separated)") do |d|
         options[:with_tags] = d
        end
      
        opts.on("--without-tags TAGS", "Include only posts without these tags (comma-separated)") do
       |d|
         options[:without_tags] = d
        end
      
        opts.on("-p", "--published", "Only published content") do |v|
          options[:published] = true
        end
      
        opts.on("-u", "--url URL", "Absolute URL to use in exported blog") do |u|
         options[:url] = u
        end

        opts.on("-f", "--export-filter FILTERS", "Export filters to use (comma-separated)") do |f|
          options[:export_filters] = f
        end
      
        opts.on("-b", "--publish URL", "Publish to URL") do |u|
          options[:publish] = u
        end
      
        # Supplementary environments
        opts.on("-f", "--environment-file FILE", "Load environments from file") do |f|
          environments.concat(load_environment_file(f))
        end
      end

      optparse.parse!

      # Positional arguments
      if ARGV.count > 0
        options[:source] = ARGV[0].dup unless options[:source]
        options[:destination] = ARGV[1].dup if ARGV.count > 1 and options[:destination].nil?
      end

      # Default source directory if we still don't have one
      options[:source] = CONFIG[:source] unless options[:source]

      # Look for an environment file in the source directory if none already loaded
      f = options[:source]+'/'+ENVIRONMENT_FILE
      environments.concat(load_environment_file(f)) if environments.empty? and File.exists?(f)

      # Add environment defined by command-line
      # an export filter must be given but all other attributes will default
      if (options.keys & CONFIG_MANDATORY) == CONFIG_MANDATORY
        environments << options
      else
        log("Ignoring incomplete command-line environment:\n#{options}")
        log("Missing keys:\n#{CONFIG_MANDATORY - options.keys}")
      end

      # Output help if no environments
      if environments.empty?
        puts optparse
        puts
        puts option_summary
        exit 1
      end

      # Instantiate environments
      environments.each { |e| @environments << Environment.new(e) }

    end

    # Loads environment definitions from YAML file and returns array
    def load_environment_file(f)
      do_or_die(File.exists?(f),"Loading environments from #{f}",
                                "Environment file #{f} does not exist")
          supp_envs = YAML.load_file(f)
          supp_envs.each_with_object([]) do |(name,options),envs|

            # store the environment name inside its configuration hash
            options[:name] = name
            
            # translate alternative keywords for export filters
            %w(filter filters export-filters).each do |f|
              if options.include?(f)                           
                options[:export_filters] = options[f].split(/[ ,]/)
                options.delete(f)                               
              end                                       
            end                                       

            options = options.each_with_object({}){|(k,v),h| h[k.to_sym] = v} # symbolise keys

            # convert arrays into comma-delimited strings
            options = options.each_with_object({}) do |(k,v),h|
               h[k] = v.is_a?(Array) ? v.join(',') : v
            end

            # convert space-delimited into comma-delimited strings
            %i(publish with_tags without_tags).each do |f|
              options[f] = options[f].split(/[ ,]/).join(',') if options.include?(f)
            end

            envs << options # add hash to environments array
          end
    end
  
    def option_summary
     summary = "An environment requires these options:" + NL
     CONFIG_REQUIRED.each { |k| summary << '--'+k.to_s+NL }
     summary << "where these ones are mandatory:" + NL
     CONFIG_MANDATORY.each { |k| summary << '--'+k.to_s+NL }
     summary << "Some options get default valuess if omitted:" + NL
     CONFIG.each { |k,v| summary << '--'+k.to_s+' = '+v+NL }
     summary
  end

  end # of class << self

  # Creates a new environment with the given configuration
  def initialize(config)

    @config = CONFIG.merge config # apply given configuration over defaults

    # Sanity check the supplied config for required sane values
    CONFIG_REQUIRED.each { |k| abort "A #{k} is required" unless @config.has_key? k }
    @config.each { |k,v| abort("An empty #{k} cannot be used") if v.nil? or (v.respond_to?(:empty) && v.empty?) }

    log "Initialising environment '#{config(:name)}'"

    # Uncomment the below line to prohibit source and destination being the same
    abort("source and destination are the same") if config(:source)==config(:destination)

    @paths = {source: @config[:source], destination: @config[:destination]}
    if File.basename(@paths[:source]) == 'content'
      paths[:root] = File.dirname(@paths[:source])
    else
      paths[:root] = path(:source)
      paths[:source] = path(:root) + '/content'
    end
    paths[:config] = path(:root) + '/config.js'

    # Check paths are valid
    paths.each do |name,path|
      do_or_die(File.exists?(path), "#{name} path '#{path}' is good",
                                    "#{name} path #{path} not found")
    end
  
    # Load Ghost configuration file
    do_or_die(gconfig = File.read(path(:config)),"read config ok","read config failed")
    gconfig.gsub!(/^\s*?\/\/.*?\n/m,'') # remove comments from config
  
    # Get database file
    match_dbfile = gconfig.match(/#{config(:ghost_environment)}:\s*{.*?database:\s*{.*?connection:\s*{.*?filename:.*?([\w-]*?\.db)/m)
    dbfile = match_dbfile.nil? ? abort("unable to find database file name for '#{config(:ghost_environment)}' environment in configuration file") : match_dbfile[1]
    paths[:database] = path(:source) + '/data/' + dbfile
  
    # Open database
    dbfile = path(:database)
    do_or_die(File.exists?(dbfile),"database #{dbfile} found",
                                   "Cannot find database file #{dbfile}")
    do_or_die(self.db = SQLite3::Database.new(dbfile, readonly: true),'database opened',
                                                    "Could not initialise database #{dbfile}")
    db.results_as_hash = true
  
    # Load settings from database
    @settings = {}
    query = "select key,value from settings"
    do_or_die(db.execute(query).each{|s| @settings.update s[0].to_sym => s[1]},
          'read settings','unable to read settings')
    #settings.each { |k,v| log "setting(#{k}) = #{v}" }
  
    # Set the URL that will be used as the root on exported blogs
    if config.include?(:url)
      settings[:url] = config(:url)
    else
      # Get site URL from config file and put it into settings array
      match_url = gconfig.match(/#{config(:ghost_environment)}:\s*{.*?url:\s*'(.*?)'/m)
      url = match_url.nil? ? abort("unable to find url for #{config(:ghost_environment)} environment") : match_url[1]
      settings[:url] = url
    end
  
    # Build posts query
    @queries = {}
    queries[:posts] = 'SELECT posts.*, users.name as author_name from posts' \
                   << ' INNER JOIN users ON posts.author_id = users.id'
  
    whand = ' WHERE' # will change to 'AND' for subsequent clauses
    unless config(:with_tags).nil?   
      queries[:posts] << whand << ' EXISTS (' \
                      <<   'SELECT 1 FROM posts_tags' \
                      <<   ' INNER JOIN tags ON tags.id = posts_tags.tag_id' \
                      <<   ' WHERE posts_tags.post_id = posts.id' \
                      <<   ' AND tags.name IN (' \
                      <<   config(:with_tags).split(',').map {|t| "'#{t}'" }.join(',') \
                      <<   '))'             
      whand = ' AND'
    end
  
    unless config(:without_tags).nil?
      queries[:posts] << whand << ' NOT EXISTS (SELECT 1 FROM posts_tags' \
                      <<   ' INNER JOIN tags ON tags.id = posts_tags.tag_id' \
                      <<   ' WHERE posts_tags.post_id = posts.id' \
                      <<   ' AND tags.name IN (' \
                      <<   config(:without_tags).split(/[ ,]/).map {|t| "'#{t}'" }.join(',') \
                      <<   '))'                
      whand = ' AND'
    end
  
    queries[:posts] << whand << " posts.status == 'published'" if config(:published) 
    queries[:posts] << ' ORDER BY posts.published_at DESC'

    # Debugging limit
    #queries[:posts] << " LIMIT #{config[:maximum_posts]}" if config[:maximum_posts]
    queries[:posts] << " LIMIT 1" if @@limit_posts

    # Load export filters
    export_filters = []
    config(:export_filters).split(',').each do |f|
      f = f.to_s
      log "Loading #{f} export filter"
      begin
        require_relative 'export_filters/export_'+f
      rescue LoadError
        abort("Failed to load export filter '#{f}'")
      end
      export_filters << Object.const_get('ExportFilter_'+f).new(self)
    end

    # Run all posts through each filter
    db.execute(queries[:posts]) { |post| export_filters.each { |f| f.export_post(post) } }

    # Run the publisher
    if config(:publish)
      require_relative 'publisher'
      Publisher.new(self).publish
    end

    # Close the database
    db.close 
  
    # Close all filters
    export_filters.each { |f| f.close }

  end

  # Public accessors
  def path(p) @paths[p] end
  def setting(s) @settings[s] end
  def config(c) @config[c] end

  def query(q)
    db.execute(q)
  end

  private

  # Private accessors
  attr_reader :paths, :settings, :queries # access array (contents can be written)
  attr_accessor :db
  include Helpers

  # Load environments defined by command-line options
  self.load_environments

end
