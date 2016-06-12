require_relative 'configuration.rb'
require_relative 'util/systemhelper.rb'

include SystemHelper

module CartoCSSHelper
  module Git
    def checkout(branch, debug = false)
      Dir.chdir(Configuration.get_path_to_tilemill_project_folder) do
        require 'open3'
        command = "git checkout #{branch}"
        begin
          execute_command(command, debug, ignore_stderr_presence: true) # or maybe just do not run if it is currently in the wanted branch?
        rescue FailedCommandException => e
          raise 'failed checkout to ' + branch + ' due to ' + e
        end
      end
    end

    def get_commit_hash
      Dir.chdir(Configuration.get_path_to_tilemill_project_folder) do
        command = 'git log -n 1 --pretty=format:"%H"'
        return execute_command(command)
      end
      raise 'impossible happened'
    end
  end
end
