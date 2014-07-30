class MagicFieldRelationship < ActiveRecord::Base
  belongs_to :magic_field
  belongs_to :owner, :polymorphic => true
  #belongs_to :extended_model, :polymorphic => true

  validates_uniqueness_of :name, scope: [:owner_id, :owner_type]

  before_validation :sync_name

  def sync_name
    self.name = magic_field.name
  end

end
