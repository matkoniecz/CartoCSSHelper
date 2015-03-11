module CartoCSSHelper::Git
  def checkout(branch, debug=false)
    silence = '> /dev/null 2>&1'
    if debug
      silence = ''
    end
    Dir.chdir(Configuration.get_path_to_tilemill_project_folder) {
      require 'open3'
      if !system("git checkout #{branch} #{silence}")
        raise 'failed checkout'
      end
    }
    init_commit_hash
  end

  def init_commit_hash
    Dir.chdir(Configuration.get_path_to_tilemill_project_folder) {
      Open3.popen3('git log -n 1 --pretty=format:"%H"') {|_, stdout, stderr, _|
        $commit = stdout.read.chomp
        error = stderr.read.chomp
        if error != ''
          raise error
        end
      }
    }
  end
end