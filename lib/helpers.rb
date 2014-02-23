module Helpers
  extend self

  @@debug = @@verbose = false

  def included(c)
    c.extend self
  end

  @@verbose = false

  def verbose_on
    @@verbose = true
  end

  def verbose_off
    @@verbose = false
  end

  def debug_on
    @@debug = true
  end

  def debug_off
    @@debug = false
  end

  def do_or_die(condition,log_message,error_message)
    condition ? log(log_message) : abort(error_message)
  end
  
  def abort(m)
    puts("#{m}. Cannot continue.")
    puts caller if @@debug
    exit 1
  end
  
  def log(m)
    puts m if @@verbose 
  end

  # Debug message
  # Displays if @@debug is true OR if 'show' is true OR if a prior call was
  # made from the same caller that was displayed.
  def debug(m,show=nil)
    method_name = caller[0][/`.*'/][1..-2] # http://stackoverflow.com/a/5100339/712506
    show = true if @last_caller == method_name or show == true
    show |= @@debug
    if show
      method_display = @@verbose ? caller[0] : method_name
      puts 'Debug : ' + method_display +' : ' + m
      @last_caller = method_name
    end
  end

end
