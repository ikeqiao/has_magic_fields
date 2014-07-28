module HasMagicFields
  module Extend extend ActiveSupport::Concern
    module ClassMethods
      def has_magic_fields(options = {})
        # Associations
        has_many :magic_attribute_relationships, :as => :owner, :dependent => :destroy
        has_many :magic_attributes, :through => :magic_attribute_relationships, :dependent => :destroy
        
        # Eager loading - EXPERIMENTAL!
        if options[:eager]
          class_eval do
            def after_initialize
              initialize_magic_fields
            end
          end
        end
        
        # Inheritence
        cattr_accessor :inherited_from

        # if options[:through] is supplied, treat as an inherited relationship
        if self.inherited_from = options[:through]
          class_eval do
            def inherited_magic_fields
              raise "Cannot inherit MagicFields from a non-existant association: #{@inherited_from}" unless self.class.method_defined?(inherited_from)# and self.send(inherited_from)
              self.send(inherited_from).magic_fields
            end
          end
          alias_method :magic_fields, :inherited_magic_fields unless method_defined? :magic_fields

        # otherwise the calling model has the relationships
        else
          has_many :magic_field_relationships, :as => :owner, :dependent => :destroy
          has_many :magic_fields, :through => :magic_field_relationships, :dependent => :destroy
        end
        
        # # Hook into Base
        class_eval do
          alias_method :reload_without_magic, :reload
          alias_method :create_or_update_without_magic, :create_or_update
          alias_method :read_attribute_without_magic, :read_attribute
        end 

      
        # Add Magic to Base
        alias_method :reload, :reload_with_magic
        alias_method :read_attribute, :read_attribute_with_magic
        alias_method :create_or_update, :create_or_update_with_magic
      end
    end

    included do
      # Reinitialize MagicFields and MagicAttributes when Model is reloaded
      def reload_with_magic
        initialize_magic_fields
        reload_without_magic
      end

      def update_attributes(new_attributes)
        attributes = new_attributes.stringify_keys
        magic_attrs = magic_fields.map(&:name)

        super(attributes.select{ |k, v| !magic_attrs.include?(k) })
        attributes.select{ |k, v| magic_attrs.include?(k) }.each do |k, v|
          col = find_magic_field_by_name(k)
          attr = find_magic_attribute_by_column(col).first
          attr.update_attributes(:value => v)
        end
      end

      private
      
      # Save MagicAttributes from @attributes
      def create_or_update_with_magic
        if result = create_or_update_without_magic
          magic_fields.each do |column|
            value = @attributes[column.name]
            existing = find_magic_attribute_by_column(column)
            
            unless column.datatype == 'check_box_multiple'
              (attr = existing.first) ? 
                update_magic_attribute(attr, value) : 
                create_magic_attribute(column, value)
            else
              #TODO - make this more efficient
              value = [value] unless value.is_a? Array
              existing.map(&:destroy) if existing
              value.collect {|v| create_magic_attribute(column, v)}
            end
          end
        end
        result
      end
      
      # Load (lazily) MagicAttributes or fall back
      def method_missing(method_id, *args)
        super(method_id, *args)
      rescue NoMethodError
        method_name = method_id.to_s
        attr_names = magic_fields.map(&:name)
        initialize_magic_fields and retry if attr_names.include?(method_name) or 
          (md = /[\?|\=]/.match(method_name) and 
          attr_names.include?(md.pre_match))
        super(method_id, *args)
      end
      
      # Load the MagicAttribute(s) associated with attr_name and cast them to proper type.
      def read_attribute_with_magic(attr_name)
        return read_attribute_without_magic(attr_name) if column_for_attribute(attr_name) # filter for regular columns
        attr_name = attr_name.to_s
        
        if !(value = @attributes[attr_name]).nil?
          if column = find_magic_field_by_name(attr_name)
            if value.is_a? Array
              value.map {|v| column.type_cast(v)}
            else
              column.type_cast(value)
            end
          else
            value
          end
        else
          nil
        end
      end
      
      # Lookup all MagicAttributes and setup @attributes
      def initialize_magic_fields
        magic_fields.each do |column| 
          attribute = find_magic_attribute_by_column(column)
          name = column.name
          
          # Validation
          self.class.validates_presence_of(name) if column.is_required?

          # Write attribute
          unless column.datatype == 'check_box_multiple'
            (attr = attribute.first) ?
              write_magic_attribute(name, attr.to_s) :
              write_magic_attribute(name, column.default)
          else
            write_magic_attribute(name, attribute.map(&:to_s))
          end
        end
      end


      def write_magic_attribute(magic_attribute, value)
        @attributes[magic_attribute] = value
        @attributes_cache[magic_attribute] = value
      end
      
      def find_magic_attribute_by_column(column)
        magic_attributes.to_a.find_all {|attr| attr.magic_field_id == column.id}
      end
      
      def find_magic_field_by_name(attr_name)
        magic_fields.to_a.find {|column| column.name == attr_name}
      end
      
      def create_magic_attribute(magic_field, value)
        magic_attributes << MagicAttribute.create(:magic_field => magic_field, :value => value)
      end
      
      def update_magic_attribute(magic_attribute, value)
        magic_attribute.update_attributes(:value => value)
      end
    end

  end
end


