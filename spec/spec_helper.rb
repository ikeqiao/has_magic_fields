
require 'debugger'

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

ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do

  create_table "users", :force => true do |t|
    t.column "name",       :text
    t.column "account_id", :integer
  end

  create_table "accounts", :force => true do |t|
    t.column "name",       :text
  end

  create_table "people", :force => true do |t|
    t.column "name",       :text
  end


  # Has Magic Columns migration generator output

  create_table :magic_fields do |t|
    t.column :name,           :string
    t.column :pretty_name,    :string
    t.column :datatype,       :string, :default => "string"
    t.column :default,        :string
    t.column :is_required,    :boolean, :default => false
    t.column :include_blank,  :boolean, :default => false
    t.column :allow_other,    :boolean, :default => true
    t.column :created_at,     :datetime
    t.column :updated_at,     :datetime
  end
  
  create_table :magic_attributes do |t|
    t.column :magic_field_id, :integer
    t.column :magic_option_id, :integer
    t.column :value, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
  
  create_table :magic_options do |t|
    t.column :magic_field_id, :integer
    t.column :value, :string
    t.column :synonym, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
  
  create_table :magic_field_relationships do |t|
    t.column :magic_field_id, :integer
    t.column :owner_id, :integer
    t.column :owner_type, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
  
  create_table :magic_attribute_relationships do |t|
    t.column :magic_attribute_id, :integer
    t.column :owner_id, :integer
    t.column :owner_type, :string
  end   

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
  end
  
  config.after(:all) do
  end
end

