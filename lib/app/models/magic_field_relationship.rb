class MagicFieldRelationship < ActiveRecord::Base
  belongs_to :magic_field
  belongs_to :owner, :polymorphic => true
  #belongs_to :extended_model, :polymorphic => true
  validates_uniqueness_of :name, scope: [:owner_id, :owner_type, :type_scoped]
  validates_presence_of :name, :type_scoped

  before_validation :sync_name

  def sync_name
    self.name = magic_field.name
    self.type_scoped = magic_field.type_scoped.blank? ? self.owner_type : magic_field.type_scoped
  end

end
