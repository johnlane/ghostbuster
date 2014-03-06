require 'net/sftp' # gem install net-sftp
require 'etc'

class Publisher

private

  def sftp(src,uri)
    log "Publishing #{src} to #{uri}..."
    
    host = uri.host
    user = uri.user ? uri.user : Etc.getlogin
    pass = uri.password ? { password: uri.password } : {}
    dest = uri.path

    log "Connecting to #{host}"
    begin
      Net::SFTP.start(host,user,pass) do |sftp|
        log "Uploading"
        sftp.upload!(src+'/.',dest, recursive: true)
        log "Done"
      end
    rescue Net::SSH::AuthenticationFailed, Net::SFTP::Error => e
      abort ("SFTP Failure: #{e}")
    end
  end

end
