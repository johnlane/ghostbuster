require_relative 'export_filter'

class ExportFilter_markdown < ExportFilter

  include Helpers

  def initialize(e,p={})
    super
    load
  end

  # Output a post
  def export_post(post)
    extend_post(post,'md')
    write(post.filename,post.markdown,post.update_timestamp)
  end

  def index
    '<a href="' + file_name_extn + '">(md)</a>'
  end

private

  def load
  end

end
