if defined?(ActiveRecord::Base)

  module AttrCsv

    module Adapters

      module ActiveRecord

        protected

        #
        # Ensures the attribute methods for db fields have been defined 
        # before calling the original attr_encrypted method
        # 
        def attr_csv(*attributes)
          define_attribute_methods rescue nil
          super
          attributes.reject { | attr | attr.is_a?(Hash) }.each { | attr | alias_method "#{attr}_before_type_cast", attr }

          # Register before_validate to update the csv fields
          before_validation :update_csved_attributes
        end

      end

    end

  end

  ActiveRecord::Base.extend AttrCsv::Adapters::ActiveRecord

end
