require "rust_watcher/version"
require 'thermite/fiddle'

class RustWatcher
  def initialize(path, &block)
    @path = path
    @block = block
    raise 'Block must take exactly two arguments' unless @block.arity == 2
  end

  def path
    @path
  end

  def start_watcher
    return if watcher_running?

    child_read, parent_write = IO.pipe
    parent_read, child_write = IO.pipe

    @watcher_pid = fork do
      begin
        parent_read.close
        parent_write.close

        watch_binding(child_read, child_write)
      ensure
        child_read.close
        child_write.close
      end
    end

    child_read.close
    child_write.close

    @runner_pid = fork do
      begin
        loop do
          break unless watcher_running?
          read_pipe = IO.select([parent_read]).first.first

          if read_pipe
            output = string_presence(read_pipe.gets)
            if output
              op, file = output.split('~~~', 2)
              @block.call(op, file[1..-2])
            end
          end
        end
      ensure
        parent_read.close
      end
    end

    parent_read.close
    @writer = parent_write

    nil
  end

  def stop_watcher
    if watcher_running?
      unless @writer.closed?
        @writer.write "."
        @writer.close
      end
      Process.kill("TERM", @watcher_pid)
    end

    if runner_running?
      Process.kill("TERM", @runner_pid)
    end

    nil
  end

  private
  def watcher_running?
    begin
      Process.getpgid(@watcher_pid || -1)
      true
    rescue Errno::ESRCH
      false
    end
  end

  def runner_running?
    begin
      Process.getpgid(@runner_pid || -1)
      true
    rescue Errno::ESRCH
      false
    end
  end

  def string_presence(str)
    if str
      stripped = str.strip
      stripped.length > 0 ? stripped : nil
    else
      nil
    end
  end
end

toplevel_dir = File.dirname(File.dirname(__FILE__))
Thermite::Fiddle.load_module('init_rust_watcher', cargo_project_path: toplevel_dir, ruby_project_path: toplevel_dir)
