class MagicFieldRelationship < ActiveRecord::Base
  belongs_to :magic_field
  belongs_to :owner, :polymorphic => true
  #belongs_to :extended_model, :polymorphic => true
end
