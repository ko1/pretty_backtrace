require "pretty_backtrace/version"
require 'debug_inspector'

module PrettyBacktrace
  CONFIG = {
    truncate_length: 20,
    disabled_exception_classes: {},
    effective_lines: 0, # 0 is infinite
    file_contents: true,
    file_contents_lines: 2,

    multi_line: false,
    multi_line_truncate_length: 60,
    multi_line_indent: 10,
  }

  EXCEPTION_MODIFIER_TRACE = TracePoint.new(:raise){|tp|
    begin
      e = tp.raised_exception

      CONFIG[:disabled_exception_classes].each{|klass, _|
        next if e.kind_of?(klass)
      }

      RubyVM::DebugInspector.open{|dc|
        locs = dc.backtrace_locations

        effective_lines = CONFIG[:effective_lines]
        effective_lines = locs.size - 2 if effective_lines == 0

        pretty_backtrace = locs.map.with_index{|loc, i|
          next if i < 2
          next loc.to_s unless (effective_lines -= 1) >= 0

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

          modify_trace_line loc, loc.absolute_path, loc.lineno, lvs_val
        }.compact
        e.set_backtrace pretty_backtrace
      }
    rescue => e
      puts e
      puts e.backtrace
      fail "PrettyBacktrace BUG"
    end
  }

  def self.iseq_local_variables iseq
    _,_,_,_,arg_info,name,path,a_path,_,type,lvs, * = iseq.to_a
    lvs
  end

  #
  # local_variables_values is a Hash object containing pairs of
  # a local variable name and value of local variable.
  #
  def self.modify_trace_line backtrace_location, absolute_path, lineno, local_variables_values
    trace_line = backtrace_location.to_s

    unless local_variables_values.empty?
      if CONFIG[:multi_line]
        indent = ' ' * CONFIG[:multi_line_indent]
        additional = ''

        # file scope
        if CONFIG[:file_contents] && File.exists?(absolute_path)
          fclines = CONFIG[:file_contents_lines]
          start_line = lineno - 1 - 1 * fclines
          start_line = 0 if start_line < 0

          additional << indent + "[FILE]\n"
          additional << open(absolute_path){|f| f.readlines[start_line, 1 + 2 * fclines]}.map.with_index{|line, i|
            ln = start_line + i + 1
            line = line.chomp
            '%s%4d|%s' % [ln == lineno ? indent[0..-3] + "->" : indent, ln, line]
          }.join("\n")
          additional << "\n"
          additional << "\n"
        end

        # local variables
        unless local_variables_values.empty?
          additional << indent + "[LOCAL VARIABLES]\n"
          additional << local_variables_values.map{|lv, v|
            v = v[0..CONFIG[:multi_line_truncate_length]] + '...' if v.length > CONFIG[:multi_line_truncate_length]
            indent + "  #{lv} = #{v.to_s}"
          }.join("\n") + "\n"
        end

        trace_line = "#{trace_line}\n#{additional}" unless additional.empty?
      else
        additional = local_variables_values.map{|lv, v|
          v = v[0..CONFIG[:truncate_length]] + '...' if v.length > CONFIG[:truncate_length]
          "#{lv} = #{v.to_s}"
        }.join(", ")
        trace_line = "#{trace_line} (#{additional})"
      end
    end

    trace_line
  end

  # configuration

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

  def self.multi_line=(setting)
    CONFIG[:multi_line] = setting
  end

  def self.file_contents=(setting)
    CONFIG[:file_contents] = setting
  end

  def self.effective_lines=(lines)
    CONFIG[:effective_lines] = lines
  end
end
