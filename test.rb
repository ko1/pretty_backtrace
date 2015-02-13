$: << './lib'
require 'pretty_backtrace/enable'

PrettyBacktrace::multi_line = true

1.times{
  2.times{
    3.times{
      raise
    }
  }
}

__END__


1.times{
  1.times{
    raise
  }
}
    

__END__

def recursive n
  str = "Hi #{n}!!  " * 128
  if n > 0
    recursive n - 1
  else
    raise "bottom of recursive"
  end
end

3.times{
recursive 3
}
