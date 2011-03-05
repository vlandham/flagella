require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'logger'

Bundler.require

require 'active_record'
DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'

@db_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__))[DATABASE_ENV]
ActiveRecord::Base.establish_connection @db_config
ActiveRecord::Base.logger = Logger.new STDOUT if @db_config['logger']


# Load all the models into memory
dir = File.expand_path('../../models/', __FILE__)
Dir.glob(dir+"/*.rb").each {|file| require file }
