require_relative 'export_filter'
require 'fileutils'
require 'kramdown'

class ExportFilter_kramdown < ExportFilter

  include Helpers

  def initialize(e,p={})
    super
    copy [ 'images' ]
  end

  # Output a post
  def export_post(post)

    extend_post(post,'tex')

    params = params
    params = {}

    # Get kramdown converter
    converter = params[:convert]

    # Default output filter
    converter = converter ? "to_#{converter}".to_sym : :to_latex

    params[:template] = 'document' unless params.has_key?(:template)

    # Get markdown
    content = post.markdown

    # Remove leading '/content' from URL paths
    content.gsub!(/(!\[\]\()\/content\//,'\1')

    # get markdown content
    content = Kramdown::Document.new(content, params).send(converter)

    # write the post
    write(post.filename,content,post.update_timestamp)

  end

end
