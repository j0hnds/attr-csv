require 'set'
require 'csv'

module AttrCsv

  CSV_ATTR_EXTENSION = '_csv'

  def self.extended(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
      @csved_attributes = Set.new
    end
  end

  module ClassMethods

    def attr_csv(*attributes)
      instance_methods_as_symbols = instance_methods.map { | mthd | mthd.to_sym }

      attributes.each do | attribute |
        # Construct the name to be used for the CSV version
        # of the attribute
        csv_attribute_name = [ attribute.to_s, CSV_ATTR_EXTENSION ].join.to_sym

        # Create the accessors for the csv attribute
        unless is_active_record_model?(self)
          attr_reader csv_attribute_name unless instance_methods_as_symbols.include?(csv_attribute_name)
          attr_writer csv_attribute_name unless instance_methods_as_symbols.include?("#{csv_attribute_name}=".to_sym)
        end

        # Now, define the array attribute reader
        define_method(attribute) do
          (instance_variable_get("@#{attribute}") || 
           instance_variable_set("@#{attribute}", 
                                 decode(attribute, send(csv_attribute_name))))
        end

        # and the array attribute writer
        define_method("#{attribute}=") do | value |
          send("#{csv_attribute_name}=", encode(attribute, value))
          instance_variable_set("@#{attribute}", value)
        end

        define_method("#{attribute}?") do
          value = send(attribute)
          value.respond_to?(:empty?) ? !value.empty? : !!value
        end

        csved_attributes << attribute.to_sym

      end

    end

    def is_active_record_model?(clazz)
      return false if clazz.nil?
      return true if clazz.to_s == 'ActiveRecord::Base'
      is_active_record_model?(clazz.superclass)
    end

    def attr_csved?(attribute)
      csved_attributes.include?(attribute.to_sym)
    end

    def csved_attributes
      @csved_attributes ||= superclass.csved_attributes.dup
    end

    def decode(attribute, csv_value)
      return [] if csv_value.nil? || csv_value.empty?
      CSV.parse(csv_value).first
    end

    def encode(attribute, array_value)
      return nil if array_value.nil? || array_value.empty?
      array_value.to_csv.chomp
    end

    def method_missing(method, *arguments, &block)
      if method.to_s =~ /^((en|de)code)_(.+)$/ && attr_csved?($3)
        send($1, $3, *arguments)
      else
        super
      end
    end

  end

  module InstanceMethods

    def decode(attribute, csv_value)
      self.class.decode(attribute, csv_value)
    end

    def encode(attribute, array_value)
      self.class.encode(attribute, array_value)
    end

    #
    # For ActiveRecord models, this method is called as a before_validation
    # callback to ensure that the CSV values have been update to the '_csv'
    # columns appropriately. The user might have used an array modifier
    # directly (e.g. << or push), which we wouldn't see. So, to make sure
    # the database gets updated appropriately, we do this.
    #
    def update_csved_attributes
      self.class.csved_attributes.each do | attribute |
        csv_attribute_name = [ attribute.to_s, CSV_ATTR_EXTENSION ].join.to_sym
        send("#{csv_attribute_name}=", encode(attribute, send(attribute)))
      end
    end

  end

end

Object.extend AttrCsv

require 'active_record'
require 'attr-csv/active-record'
