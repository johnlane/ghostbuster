require_relative 'export_filter'
require 'yaml'

class ExportFilter_yaml < ExportFilter

  include Helpers

  # Output a post
  def export_post(post)

    extend_post(post,'yml')

    # work on a local copy of the post because of destructive actions
    yaml_post = post.clone

    # remove the fields that processed by other filters so they are not written to yaml
    yaml_post.delete('html')
    yaml_post.delete('markdown')

    # hash contains data twice - with feld-name keys and with numeric index keys
    yaml_post.delete_if {|k,v| k.is_a? Fixnum}

    # format dates as human-readable
    yaml_post.each do |k,v|             
      post[k] = DateTime.strptime(v.to_s,'%Q').strftime("%Y-%m-%d %H:%M:%S.%L %Z") if v.to_s =~/\d{13}/                             
    end 

    # write YAML file
    write(post.filename,yaml_post.to_yaml,post.update_timestamp)
  end

  def index
    '<a href="' + file_name_extn + '">(md)</a>'
  end

end
