class AddHasMagicFieldsTables < ActiveRecord::Migration
  def change
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

    add_index :magic_attributes, [:magic_field_id, :magic_option_id], name:"attributes_column_option"
    add_index :magic_attribute_relationships, [:magic_attribute_id, :owner_id], name:"magic_attribute_owner"
    add_index :magic_field_relationships, [:magic_field_id, :owner_id], name:"magic_field_owner"
    
  end

end