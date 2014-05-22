require 'net/scp' # gem install net-scp
require 'etc'

class Publisher

private

  # FTP upload creates a compressed (bzip2) TAR archive of the export and uploads it
  # to the remote server. A companion script on the server should extract the archive
  # into the relevant location. An example is given in 'extras/ghostbuster-ftp-extract'
  def ssh(src,uri)
    log "Publishing #{src} to #{uri}..."
    
    host = uri.host
    user = uri.user ? uri.user : Etc.getlogin
    pass = uri.password ? { password: uri.password } : {}
    dest = uri.path

    log "Connecting to #{host}"
    begin
      Net::SCP.start(host,user,pass) do |scp|
        log "Uploading"
        scp.upload!(src+'/.',dest, recursive: true, preserve: true)
        log "Done"
      end
    rescue Net::SSH::AuthenticationFailed, Net::SCP::Error => e
      abort ("SCP Failure: #{e}")
    end
  end

end
