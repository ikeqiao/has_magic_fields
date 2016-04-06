require 'active_support'
require 'active_record'

module HasMagicFields
  module Extend extend ActiveSupport::Concern
    include ActiveModel::Validations
    module ClassMethods
      def has_magic_fields(options = {})
        # Associations
        has_many :magic_attribute_relationships, :as => :owner, :dependent => :destroy
        has_many :magic_attributes, :through => :magic_attribute_relationships, :dependent => :destroy
        
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
          # alias_method_chain :magic_fields, :scoped
        end
        alias_method  :magic_fields_without_scoped, :magic_fields
      end
      
    end

    included do

      def create_magic_field(options = {})
        type_scoped = options[:type_scoped].blank? ? self.class.name : options[:type_scoped].classify
        self.magic_fields.create options.merge(type_scoped: type_scoped )
      end

      def magic_fields_with_scoped(type_scoped = nil)
        type_scoped = type_scoped.blank? ? self.class.name : type_scoped.classify
        magic_fields_without_scoped.where(type_scoped: type_scoped)
      end
      
      def method_missing(method_id, *args)
        super(method_id, *args)
      rescue NoMethodError
        method_name = method_id.to_s
        super(method_id, *args) unless magic_field_names.include?(method_name) or (md = /[\?|\=]/.match(method_name) and magic_field_names.include?(md.pre_match))

        if method_name =~ /=$/
          var_name = method_name.gsub('=', '')
          value = args.first
          write_magic_attribute(var_name,value)
        else
          read_magic_attribute(method_name)
        end
      end

      def magic_field_names(type_scoped = nil)
        @magic_field_names ||= magic_fields_with_scoped(type_scoped).map(&:name)
      end

      def valid?(context = nil)
        output = super(context)
        magic_fields_with_scoped.each do |field| 
          if field.is_required?
            validates_presence_of(field.name) 
          end
        end
        errors.empty? && output
      end

      # Load the MagicAttribute(s) associated with attr_name and cast them to proper type.
      def read_magic_attribute(field_name)
        field = find_magic_field_by_name(field_name)
        attribute = find_magic_attribute_by_field(field)
        value = (attr = attribute.first) ?  attr.to_s : field.default
        value.nil?  ? nil : field.type_cast(value)
      end

      def write_magic_attribute(field_name, value)
        field = find_magic_field_by_name(field_name)
        attribute = find_magic_attribute_by_field(field) 
        (attr = attribute.first) ? update_magic_attribute(attr, value) : create_magic_attribute(field, value)
      end
      
      def find_magic_attribute_by_field(field)
        magic_attributes.to_a.find_all {|attr| attr.magic_field_id == field.id}
      end
      
      def find_magic_field_by_name(attr_name)
        magic_fields_with_scoped.to_a.find {|column| column.name == attr_name}
      end
      
      def create_magic_attribute(magic_field, value)
        magic_attributes << MagicAttribute.create(:magic_field => magic_field, :value => value)
      end
      
      def update_magic_attribute(magic_attribute, value)
        magic_attribute.update_attributes(:value => value)
      end
    end


    %w{ models }.each do |dir|
      path = File.join(File.dirname(__FILE__), '../app', dir)
      $LOAD_PATH << path
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    end
    
  end
end


