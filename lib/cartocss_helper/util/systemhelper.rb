class FailedCommandException < StandardError
end

module SystemHelper
  def execute_command(command, debug = false, allowed_return_codes = [], ignore_stderr_presence: false)
    puts command if debug
    Open3.popen3(command) do |_, stdout, stderr, wait_thr|
      error = stderr.read.chomp
      stdout = stdout.read.chomp
      unless allowed_return_codes.include?(wait_thr.value)
        unless wait_thr.value.success?
          raise FailedCommandException.new('failed command ' + command + ' due to error code ' + wait_thr.value)
        end
      end
      unless ignore_stderr_presence
        raise FailedCommandException.new('failed command ' + command + ' due to <' + error + '> on stderr') if error != ''
      end
      return error + stdout
    end
    raise 'impossible happened'
  end
end
