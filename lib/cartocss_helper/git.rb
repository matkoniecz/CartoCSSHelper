require_relative 'configuration.rb'

module CartoCSSHelper
  module Git
    def checkout(branch, debug=false)
      silence = '> /dev/null 2>&1'
      if debug
        silence = ''
      end
      Dir.chdir(Configuration.get_path_to_tilemill_project_folder) {
        require 'open3'
        command = "git checkout #{branch} #{silence}"
        Open3.popen3(command) {|_, stdout, stderr, wait_thr |
          error = stderr.read.chomp
          if error != '' or wait_thr.value.success? != true
            raise 'failed checkout to ' + branch + ' due to ' + error
          end
          return
        }
        raise 'impossible happened'
      }
    end

    def get_commit_hash
      Dir.chdir(Configuration.get_path_to_tilemill_project_folder) {
        Open3.popen3('git log -n 1 --pretty=format:"%H"') {|_, stdout, stderr, wait_thr|
          commit = stdout.read.chomp
          error = stderr.read.chomp
          if error != '' or wait_thr.value.success? != true
            raise error
          end
          return commit
        }
      }
      raise 'impossible happened'
    end
  end
end
