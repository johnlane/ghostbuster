require 'net/ftp'
require 'tempfile'

class Publisher

private

  # FTP upload creates a compressed (bzip2) TAR archive of the export and uploads it
  # to the remote server. A companion script on the server should extract the archive
  # into the relevant location. An example is given in 'extras/ghostbuster-ftp-extract'
  def ftp(src,uri)
    log "Publishing #{src} to #{uri}..."
    
    host = uri.host

    # Use supplied credentials or get them from a ".netrc" file
    if uri.user
      user = uri.user
      password = uri.password
    else
      require 'net/netrc' # gem install net-netrc
      do_or_die(rc = Net::Netrc.locate(host), "Using FTP login (user='#{rc.login}')",
                                              "Could not obtain credentials for #{host}")
      user = rc.login
      password = rc.password

    end

    log "Creating archive for FTP upload"
    archive = Tempfile.new("ghostbuster-publish-")
    %x(tar jcf #{archive.path} -C #{src} .) 

    log "Connecting to #{host}"
    Net::FTP.open(host) do |ftp|
      do_or_die(ftp.login(user, password), "Authenticated", "Login failed")
      ftp.chdir(uri.path) unless uri.path.empty?
      log "Uploading"
      ftp.putbinaryfile(archive.path)
      ftp.close
      log "Done"
    end
  end

end
