def switch_to_branch(branch)
  Dir.chdir(get_style_path) {
    require 'open3'
    if !system("git checkout #{branch}")
      raise 'failed checkout'
    end
  }
  init_commit_hash
end

def init_commit_hash
  Dir.chdir(get_style_path) {
    Open3.popen3('git log -n 1 --pretty=format:"%H"') {|_, stdout, stderr, _|
      $commit = stdout.read.chomp
      error = stderr.read.chomp
      if error != ''
        raise error
      end
    }
  }
end
