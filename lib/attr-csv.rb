module AttrCsv

  CSV_ATTR_EXTENSION = '_csv'

  def self.extended(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end

  module ClassMethods

    def attr_csv(*attributes)
      attributes.each do | attribute |
        csv_attribute_name = [ attribute.to_s, CSV_ATTR_EXTENSION ]
      end
    end

  end

  module InstanceMethods

    def split_attr(attribute, csv_value)
      self.class.split_attr(attribute, csv_value)
    end

    def join_attr(attribute, array_value)
      self.class.join_attr(attribute, array_value)
    end

  end

end
