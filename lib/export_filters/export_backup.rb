require_relative 'export_filter'
require 'fileutils'

class ExportFilter_backup < ExportFilter

  def initialize(e)
    %w(config.js content ghostbuster.yml).each do |src|
      src = "#{e.path(:root)}/#{src}"
      FileUtils.cp_r(src,e.path(:destination),preserve: true) if File.exists?(src)
    end
  end

end
