require 'uri'

class Publisher

  include Helpers

  def initialize(e)
    @environment = e
  end

  def publish

    config(:destination).split(',').each do |p|
      uri = URI(p)
      begin
        require_relative "publishers/publish_#{uri.scheme}"
      rescue LoadError
        abort("Failed to load #{uri.scheme} publisher")
      end
      send(uri.scheme,path(:destination),uri)
    end
  end

private

  attr_reader :environment
  def config(s) environment.config(s) end
  def path(p) environment.path(p) end

  def method_missing(m,*args)
    abort("Cannot publish #{m}")
  end

end
