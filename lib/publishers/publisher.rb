require 'uri'
require 'cgi'

class Publisher

  include Helpers

  def initialize(e)
    @environment = e
  end

  def publish

    config(:destination).split(',').each do |p|
      uri = URI(p)
      begin
        require_relative "publish_#{uri.scheme}"
      rescue LoadError => e
        abort("Failed to load #{uri.scheme} publisher: #{e}")
      end
      send(uri.scheme,path(:destination),uri)
    end
  end

private

  attr_reader :environment
  def config(s) environment.config(s) end
  def path(p) environment.path(p) end

  # Return a hash (keyed with symbols) containing any parameters in the URI query string
  def params(uri)
    if uri.query
      CGI.parse(uri.query).each_with_object({}){|(k,v),h| h[k.to_sym] = v} # symbolise keys
    else
      {}
    end
  end

  def method_missing(m,*args)
    abort("Cannot publish #{m}")
  end

end
