# Always work through the interface MagicAttribute.value
class MagicAttribute < ActiveRecord::Base
  belongs_to :magic_field
  
  def to_s
    value
  end
  
end
