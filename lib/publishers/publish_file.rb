require 'fileutils'

class Publisher

private

  # File publisher copies the temporary export space to a local path
  def file(src,uri)
    log "Publishing #{src} to #{uri}..."
    FileUtils.cp_r(src+'/.',uri.path, preserve: true)
    log "Done"
  end

end
