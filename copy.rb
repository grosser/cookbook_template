#!/usr/bin/env ruby
def sh(cmd)
  puts cmd
  IO.popen(cmd) do |pipe|
    while str = pipe.gets
      puts str
    end
  end
  raise unless $?.success?
end

# extract options
unless cookbook_name = ARGV[0]
  abort "Usage: ./cookbook_template/copy.rb cookbook_name"
end

here = File.dirname(__FILE__)

# copy files and folders
files_to_copy = Dir["#{here}/**/**"] + ["#{here}/.gitignore"] - ["#{here}/copy.rb"]
files_to_copy.reject!{|f| File.directory?(f) }

files_to_copy.each do |file_to_copy|
  new_file = "#{cookbook_name}/#{file_to_copy.sub("#{here}/", "")}"
  sh "mkdir -p #{File.dirname(new_file)} 2>&1"

  # write modified content
  content = File.read(file_to_copy)
  content.gsub!('COOKBOOK_NAME', cookbook_name)
  File.open(new_file, 'w'){|f| f.write content }
end

# generate Gemfile.lock
sh "cd #{cookbook_name} && (bundle check || bundle)"

# commit everything into 'initial'
sh "cd #{cookbook_name} && git init && git add . && git commit -m 'initial by cookbook_template'"

puts "#{cookbook_name} is now ready at #{here}/#{cookbook_name}"

