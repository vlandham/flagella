# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/environment', __FILE__)


Dir.glob(File.expand_path('../lib', __FILE__)+"/*.rake").each {|rake_file| load(rake_file)}
Dir.glob(File.expand_path('../analysis', __FILE__)+"/*.rake").each {|rake_file| load(rake_file)}


