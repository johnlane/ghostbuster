require 'uri'

class Publisher

  include Helpers

  def initialize(e)
    @environment = e
  end

  def publish

    config(:publish).split(',').each do |p|
      uri = URI(p)
      begin
        require_relative "publishers/publish_#{uri.scheme}"
      rescue LoadError
        abort("Failed to load #{uri.scheme} publisher")
      end
      send(uri.scheme,config(:destination),uri)
    end
  end

private

  attr_reader :environment
  def config(s) environment.config(s) end

end
