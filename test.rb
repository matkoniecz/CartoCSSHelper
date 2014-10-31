# encoding: UTF-8

load 'validator.rb'

def main
	tags = get_tags
	for tag in tags
		puts "#{tag[0]}=#{tag[1]}"
	end
	run_tests
end



main()
