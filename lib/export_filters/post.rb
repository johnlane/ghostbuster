require 'sanitize' # gem install sanitize
module Post

    include Helpers

    def file_extension=(e)
      @extn = e
    end

    def environment=(e)
      @environment = e
    end

    def e
      @environment
    end

    # Get key, return its value, applying optional modifiers
    # This just invokes a method with the key's name. If there is no such
    # method defined then 'method missing' performs the get_key task. 
    def get_key(key,modifiers)
      send(key,modifiers)
    end

    # Return the URL for the current post. Relative unless :absolute modifier given.
    def url(*args)
      modifiers(args)[:absolute] == 'true' ? e.setting(:url)+'/'+filename : filename
    end

    def filename
      "#{slug}.#{@extn}"
    end

    def file_extension
      @extn
    end

    # returns the update time as a Time object
    def update_timestamp
      DateTime.strptime(updated_at.to_s,'%Q').to_time
    end

    # Map generic date format specifiers to ruby Date.strftime format specifiers
    # Ghost uses the Moment.js date formatting library (http://momentjs.com)
    # Convert format strings defined here: http://momentjs.com/docs/#/displaying/format/
    # into those defined here:
    #  http://ruby-doc.org/stdlib-2.1.0/libdoc/date/rdoc/DateTime.html#method-i-strftime
    DATEFORMAT = {'YYYY'=>'%Y','MM'=>'%m', 'MMM'=>'%b','DD'=>'%d',
                  'HH'=>'%H', 'mm'=>'%M', 'ss'=>'%S'}

    # Returns the published date (or 'draft'). Supports a :format modifier
    def date(*args)

       if args and modifiers(args)[:format]
         format = modifiers(args)[:format]
         unless format == "rfc822"
          format = modifiers(args)[:format].gsub!(/([A-Za-z]+)([ -]?)/) { |m| DATEFORMAT[$~[1]]+$~[2] }
         end
       else
         format = '%d %b %Y'
       end

       date = published_at.to_s
       if  date =~ /\d{13}/
         date = DateTime.strptime(date,'%Q')
         format == 'rfc822' ? date.rfc822 : date.strftime(format)
       else
         '(draft)'
       end
   #    date =~ /\d{13}/ ? DateTime.strptime(date,'%Q').strftime(format) : '(draft)'
    end

    # returns an html-escaped and whitespace-condensed excerpt from the html
    def excerpt(*args)
      Sanitize.clean(html).gsub(/\s+/, ' ')[0..250]
    end

    # returns an array containing the posts tags
    def tags(*args)
      join('tags') - e.config(:hide_tags)
    end

    # returns true if this is a page/post
    def page?() page != 0 end
    def post?() page == 0 end

    # Handle a request for a key value that is not handled by an explicit method
    def method_missing(m, *args)
      debug("Requesting '#{m}'; args='#{args}")

      # Request is a field or a table.field
      m = m.to_s.match(/((?'table'[a-z_]+)\.)?(?'field'[a-z_]+)/)
      t = m[:table]
      f = m[:field]
      debug("Table: '#{t}'; Field: '#{f}'")

      if t
        value = join(f,t)
      else
        if has_key? f                 # if there is a key with this name, get its value
          value = replace(f,self[f])
        elsif f[-1,1] == 's'          # if key ends in s, try a join
          value = join(f)
          separator = modifiers(args)[:separator]
          separator = ', ' if separator.nil?
          value = value.join(separator)
        elsif setting(f)              # try the key as a setting
          value = setting(f)
        else
          abort "What do you mean, '#{f}' ???"
          exit
          value = nil
        end
      end
        
      return value
    end

private

    # Map field to join-table names
    JOIN_MAP = {'author' => 'users'}

    # Retrieve key values through a join table
    def join(field, table=nil)

      if table.nil?
        # table not given, look up values in join table for has_many field (e.g. 'tags')
        # return multiple values as an array
        join = "posts_"+field     # lookup table - where the post id is dereferenced
        q = "SELECT t.name FROM #{join} j JOIN #{field} t ON t.id = j.#{field.chop+'_id'} WHERE j.post_id = #{id}"
        r = e.query(q)
        r.map! {|r| r['name']} # just get names
      else
        # table given, look up field in given table using related id as join field
        join_table = JOIN_MAP[table] ? JOIN_MAP[table] : table
        join = "SELECT #{field} from #{join_table} WHERE id = '#{self[table+'_id']}'"
        e.db.execute(join).first[field]
      end
    end

    # Some fields support modifiers.
    # Accepts a hash or a string or an array containing such hashes and/or strings
    # If given a string, convert it into a hash
    # If given an array, acts on each element and returns a single hash of all modifiers
    # if given a hash, returns it unmodified
    def modifiers(s)
      if s.is_a? Array
       s.each_with_object({}) { |m,h| h.merge! modifiers(m) }
      else
        modifiers = s.nil? ? Hash.new : s        # initialise as supplied or empty
        modifiers = modifiers.join(' ') if modifiers.is_a? Array # Array to string

        # Convert string to hash
        if modifiers.is_a?(String)
          mods = {} # (http://rubular.com/r/LpvX7hBlmw)
          modifiers.match(/([a-z]*)=["'](.*?)["']/) { |m| mods[m[1].to_sym] = m[2] }
          modifiers = mods
        end
        return modifiers
      end
    end

    # Takes a key and a value
    # Looks for a replace expression associated with the key
    # Applies any such replace expression to the value
    # Returns the value
    def replace(key,value)
      debug("Begin #{key} replace on #{value}")
      if expression = e.config(:replace)[key]
        debug("Performing #{key} replace on '#{value}' => gsub(#{expression})")
        begin
          value = eval("value.gsub(#{expression})")
        rescue SyntaxError => e
          log("Syntax error in replace expression #{expression}")
        end
        debug("Value is now '#{value}'")
      end
      return value
    end

end

