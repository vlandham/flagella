require 'rubygems'
require 'bundler/setup'
require 'yaml'

Bundler.require

require 'active_record'

dbconfig = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# Load all the data mapper models into memory
dir = File.expand_path('../../models/', __FILE__)
Dir.glob(dir+"/*.rb").each {|file| require file }
