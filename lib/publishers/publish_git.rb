require 'rsync' # gem install rsync
require 'cgi'

class Publisher

private

  # Updates a Git repository on the local machine
  # Can optionally
  #   - clone a remote
  #   - commit and push to remote
  #
  def git(src,uri)
    log "Publishing #{src} to #{uri}..."

    params = CGI.parse(uri.query).each_with_object({}){|(k,v),h| h[k.to_sym] = v} # symbolise

    unless File.directory?(uri.path) 
      if params[:remote][0]
        repo = File.basename(uri.path)
        dir = File.dirname(uri.path)
        log("Cloning #{params[:remote][0]} to #{dir}")
        system("cd #{dir}; git clone #{params[:remote][0]}")
      else
        abort("#{uri.path} does not exist")
      end
    end

    unless File.directory?(uri.path+'/.git')
      abort("#{uri.path} exists but doesn't look like a Git repository")
    end

    unless system("cd #{uri.path}; git diff-index --quiet HEAD --")
      abort("#{uri.path} has uncommitted changes")
    end

    log "Copying..."
    Rsync.run(src+'/.',uri.path, %w(-a --delete --exclude='.git')) { |r| abort(r.error) unless r.success? }

    if system("cd #{uri.path}; git diff-index --quiet HEAD --")
      log "No changes were made to the repository"
    elsif params[:commit].nil? or params[:commit][0] != 'false'
      log "Committing..."
      msg = params[:commit_message] ? params[:commit_message][0] : 'GhostBuster publish'
      system("cd #{uri.path}; git add -A .; git commit -m '#{msg}'")
      if params[:commit].nil? or params[:commit][0] != 'false'
        log "Pushing..."
        system("cd #{uri.path}; git push origin master")
      end
    end
  end
end
