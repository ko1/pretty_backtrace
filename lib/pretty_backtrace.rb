require "pretty_backtrace/version"
require 'debug_inspector'

module PrettyBacktrace
  CONFIG = {
    truncate_length: 20,
    disabled_exception_classes: {},
  }

  EXCEPTION_MODIFIER_TRACE = TracePoint.new(:raise){|tp|
    begin
      e = tp.raised_exception

      CONFIG[:disabled_exception_classes].each{|klass, _|
        next if e.kind_of?(klass)
      }

      RubyVM::DebugInspector.open{|dc|
        locs = dc.backtrace_locations
        pretty_backtrace = locs.map.with_index{|loc, i|
          next if i < 2

          iseq = dc.frame_iseq(i)

          if iseq
            b = dc.frame_binding(i)
            lvs = iseq_local_variables(iseq)
            lvs_val = lvs.inject({}){|r, lv|
              v = b.local_variable_get(lv).inspect
              r[lv] = v; r
            }
          else
            lvs_val = {}
          end

          modify_trace_line loc, lvs_val
        }.compact
        e.set_backtrace pretty_backtrace
      }
    rescue => e
      puts e
      puts e.backtrace
      fail "PrettyBacktrace BUG"
    end
  }

  def self.enable
    if block_given?
      EXCEPTION_MODIFIER_TRACE.enable{
        yield
      }
    else
      EXCEPTION_MODIFIER_TRACE.enable
    end
  end

  def self.disable
    if block_given?
      EXCEPTION_MODIFIER_TRACE.disable{
        yield
      }
    else
      EXCEPTION_MODIFIER_TRACE.disable
    end
  end

  def self.iseq_local_variables iseq
    _,_,_,_,arg_info,name,path,a_path,_,type,lvs, * = iseq.to_a
    lvs
  end

  #
  # local_variables_values is a Hash object containing pairs of
  # a local variable name and value of local variable.
  #
  def self.modify_trace_line backtrace_location, local_variables_values
    trace_line = backtrace_location.to_s

    unless local_variables_values.empty?
      additional = local_variables_values.map{|lv, v|
        v = v[0..CONFIG[:truncate_length]] + '...' if v.length > CONFIG[:truncate_length]
        "#{lv} = #{v.to_s}"
      }.join(", ")
      trace_line = "#{trace_line} (#{additional})"
    end

    trace_line
  end
end
