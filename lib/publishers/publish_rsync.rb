require 'rsync' # gem install rsync
require 'cgi'

class Publisher

private

  # Rsync publisher using the RSYNC protocol (NOT rsync over ssh)
  def rsync(src,uri)
    log "Publishing #{src} to #{uri}..."
    params = params(uri)

    rsync_args = "-a"
    rsync_args << ' ' << params[:rsync_args].join(' ') if params[:rsync_args]

    if uri.host
      dest = "#{uri.host}::#{uri.path.sub(/^\//,'')}" # destination without leading /
    else
      dest = uri.path
    end

    log "Copying..."
    Rsync.run(src+'/.',dest, rsync_args) { |r| abort(r.error) unless r.success? }
    log "Done"
  end

end
