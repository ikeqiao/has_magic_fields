class MagicField < ActiveRecord::Base
  has_many :magic_field_relationships
  has_many :owners, :through => :magic_field_relationships, :as => :owner
  has_many :magic_options
  has_many :magic_attributes, :dependent => :destroy
  
  validates_presence_of :name, :datatype
  validates_format_of :name, :with => /\A[a-z][a-z0-9_]+\z/
  
  def type_cast(value)
    begin
      case datatype.to_sym
        when :check_box_boolean
        when :check_box_boolean
          (value.to_int == 1) ? true : false 
        when :date
          Date.parse(value)
        when :datetime
          Time.parse(value)
        when :integer
          value.to_int
      else
        value
      end
    rescue
      value
    end
  end
  
  # Display a nicer (possibly user-defined) name for the column or use a fancified default.
  def pretty_name
    super || name.humanize
  end

  #get or set a variable with the variable as the called method
  def self.method_missing(method, *args)
        debugger

    method_name = method.to_s
    super(method, *args)
  rescue NoMethodError
    debugger
    #set a value for a variable
    if method_name =~ /=$/
      var_name = method_name.gsub('=', '')
      value = args.first
      self[var_name] = value
    #retrieve a value
    else
      self[method_name]
    end
  end

  
end
