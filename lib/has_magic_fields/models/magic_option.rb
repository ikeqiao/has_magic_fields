class MagicOption < ActiveRecord::Base
  belongs_to :magic_field
  
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => :magic_field_id
  validates_uniqueness_of :synonym, :scope => :magic_field_id, :if => Proc.new{|this| !this.synonym.nil? and !this.synonym.empty?}
end