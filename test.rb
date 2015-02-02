$: << './lib'
require 'pretty_backtrace/enable'

# PrettyBacktrace::CONFIG[:multi_line] = true

def recursive n
  str = "Hi #{n}!!  " * 128
  if n > 0
    recursive n - 1
  else
    raise "bottom of recursive"
  end
end

recursive 3
