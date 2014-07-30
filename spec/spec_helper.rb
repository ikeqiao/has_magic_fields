
require 'debugger'
require 'database_cleaner'
require 'rubygems'
require "active_record"
require 'active_support'
require 'sqlite3'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'rails'))
require "init"

require "rails/railtie"

module Rails
  def self.env
    @_env ||= ActiveSupport::StringInquirer.new(ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development")
  end
end



ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
# ActiveRecord::Base.configurations = true
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do

  create_table "users", :force => true do |t|
    t.column "name",       :text
    t.column "account_id", :integer
  end

  create_table "people", :force => true do |t|
    t.column "name",       :text
  end

  create_table "accounts", :force => true do |t|
    t.column "name",       :text
  end

  create_table "samples", :force => true do |t|
    t.column "name",       :text
    t.column "account_id", :integer
  end


  require_relative '../lib/generators/has_magic_fields/install/templates/migration'
  AddHasMagicFieldsTables.new.change
  
end


RSpec.configure do |config|
  
  config.before(:all) do
    class Account < ActiveRecord::Base
      include HasMagicFields::Extend
      has_many :users
      has_magic_fields
    end

    class Person < ActiveRecord::Base
      include HasMagicFields::Extend
      has_magic_fields
    end

    class User < ActiveRecord::Base
      include HasMagicFields::Extend
      belongs_to :account
      has_magic_fields :through => :account
    end 

    class Sample < ActiveRecord::Base
      include HasMagicFields::Extend
      belongs_to :account
      has_magic_fields :through => :account
    end 

  end
  
  config.after(:all) do
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

