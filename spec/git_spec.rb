require_relative '../lib/cartocss_helper.rb'
require_relative '../lib/cartocss_helper/git.rb'
require 'spec_helper'
 
describe CartoCSSHelper::Git do
	it "should issue correct command" do
		#TODO: why Git is nested in CartoCSSHelper?
    allow(SystemHelper).to receive(:execute_command).and_raise(FailedCommandException)
    path_to_project = "aajaajajjaj"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return(path_to_project)
    allow(Dir).to receive(:chdir) do |block|
    	yield(block)
    end
    expect { CartoCSSHelper::Git.checkout("branch") }.to raise_error FailedCommandException 
	end	
end