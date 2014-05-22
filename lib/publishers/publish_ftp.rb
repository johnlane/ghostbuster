require 'net/ftp'
require 'tempfile'
require 'syncftp'

class Publisher

private

  # FTP uploader works in two ways:
  # (a) - the default - is to use syncftp to synchronise the remote ftp site with the
  #       export, deleting anything on the remote that is not present in the export.
  # (b) - if the URI parameter "tar=true" is given, create a compressed (bzip2) TAR
  # archive of the export and upload it to the remote server. A companion script on
  # the server should extract the archive into the relevant location. An example is
  # given in 'extras/ghostbuster-ftp-extract'
  def ftp(src,uri)
    log "Publishing #{src} to #{uri}..."

    params = params(uri)
    
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

    if params[:tar] and params[:tar][0] == 'true'

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

    else
      log "Connecting to #{host}"
      do_or_die(ftp = SyncFTP.new(host, username: user, password: password), "Authenticated", "Login failed")
      log "Syncing local:#{src} to remote:#{uri.path}"
      ftp.sync(local:src, remote:uri.path)
    end
  end

end
