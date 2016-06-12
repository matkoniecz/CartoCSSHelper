require_relative '../lib/cartocss_helper.rb'
require_relative '../lib/cartocss_helper/git.rb'
require 'spec_helper'

describe CartoCSSHelper::Git do
  it "what about failed chdir" do
    path_to_project = "aajaajajjaj"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return(path_to_project)

    # see http://ruby-doc.org/core-2.1.1/Dir.html#method-c-chdir
    allow(Dir).to receive(:chdir).and_raise(Errno::ENOENT)
    expect { CartoCSSHelper::Git.checkout("branch") }.to raise_error FailedCommandException
  end

  it "should issue correct command" do
    path_to_project = "aajaajajjaj"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return(path_to_project)

    # TODO: why Git is nested in CartoCSSHelper?
    allow(SystemHelper).to receive(:execute_command).and_raise(FailedCommandException)
    allow(Dir).to receive(:chdir) do |block|
      yield(block)
    end
    expect { CartoCSSHelper::Git.checkout("branch") }.to raise_error FailedCommandException
  end
end
