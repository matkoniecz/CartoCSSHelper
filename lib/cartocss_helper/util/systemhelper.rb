class FailedCommandException < StandardError
end

module SystemHelper
  def check_error_code(command, stderr, status, allowed_return_codes)
    returned = status.exitstatus
    return if status.success?
    return if allowed_return_codes.include?(returned)
    explanation = "failed command #{command} due to error code #{returned}. stderr was #{stderr}"
    raise FailedCommandException.new(explanation)
  end

  def check_stderr(command, stderr, status, ignore_stderr_presence)
    return if ignore_stderr_presence
    return if stderr == ''
    returned = status.exitstatus
    explanation = "failed command #{command} due to < #{stderr}> on stderr. return code was #{returned}"
    raise FailedCommandException.new(explanation)
  end

  def execute_command(command, debug = false, allowed_return_codes: [], ignore_stderr_presence: false)
    puts command if debug
    stdout, stderr, status = Open3.capture3(command)

    check_error_code(command, stderr, status, allowed_return_codes)
    check_stderr(command, stderr, status, ignore_stderr_presence)

    return stderr + stdout
  end
end
