class FailedCommandException < StandardError
end

module SystemHelper
  def execute_command(command, allowed_return_codes = [])
    Open3.popen3(command) do |_, stdout, stderr, wait_thr|
      error = stderr.read.chomp
      stdout = stdout.read.chomp
      if allowed_return_codes.include?(wait_thr.value)
        unless wait_thr.value.success?
          raise FailedCommandException, 'failed command ' + command + ' due to error code ' + wait_thr.value
        end
      end
      raise FailedCommandException, 'failed command ' + command + ' due to ' + error if error != '' || wait_thr.value.success? != true
      return stdout
    end
    raise 'impossible happened'
  end
end
