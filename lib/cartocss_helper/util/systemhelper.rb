# frozen_string_literal: true

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

  def self.not_enough_free_space
    minimum_gb = 2
    available_gb = get_available_space_for_cache_in_gb
    if available_gb < minimum_gb
      puts "get_available_space_for_cache_in_gb: #{available_gb}, minimum_gb: #{minimum_gb}"
      return true
    else
      return false
    end
  end

  def get_available_space_for_cache_in_gb
    stat = Sys::Filesystem.stat(CartoCSSHelper::Configuration.get_path_to_folder_for_cache)
    return stat.block_size * stat.blocks_available / 1024 / 1024 / 1024
  end

  def delete_file(filename, reason)
    open(CartoCSSHelper::Configuration.get_path_to_folder_for_output + 'deleting_files_log.txt', 'a') do |file|
      message = "deleting #{filename}, #{File.size(filename) / 1024 / 1024}MB - #{reason}"
      puts message
      file.puts(message)
      File.delete(filename)
    end
  end
end
