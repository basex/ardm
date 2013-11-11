require 'active_support/concern'

module Ardm
  module ActiveRecord
    module Associations
      extend ActiveSupport::Concern

      def assign_attributes(attrs, *a)
        new_attrs = attrs.inject({}) do |memo,(k,v)|
          if assoc = self.class.reflect_on_association(k)
            memo[assoc.foreign_key] = v && v.send(v.class.primary_key)
          else
            memo[k] = v
          end
          memo
        end
        super new_attrs, *a
      end


      # Convert options from DM style to AR style.
      #
      # Keep any unknown keys to use as conditions.
      def self.convert_options(klass, options, *keep)
        keep += [:class_name, :foreign_key]

        ar = options.dup
        ar[:class_name]  = ar.delete(:model)      if ar[:model]
        ar[:foreign_key] = ar.delete(:child_key)  if ar[:child_key]
        ar[:foreign_key] = ar[:foreign_key].first if ar[:foreign_key].respond_to?(:to_ary)

        if ar[:foreign_key] && property = klass.properties[ar[:foreign_key]]
          ar[:foreign_key] = property.field
        end

        if (conditions = ar.slice!(*keep)).any?
          ar[:conditions] = conditions
        end
        ar
      end

      module ClassMethods
        def belongs_to(field, options={})
          options.delete(:default)
          options.delete(:required)
          opts = Ardm::ActiveRecord::Associations.convert_options(self, options)
          super field, opts
          assoc = reflect_on_association(field)
          property assoc.foreign_key, Ardm::Property::Integer
          nil
        end

        def n
          "many"
        end

        def has(count, name, *args)
          options = args.shift || {}

          if String === options # has n, :name, 'Class', options: 'here'
            options = (args.last || {}).merge(:model => options)
          end

          unless Hash === options
            raise ArgumentError, "bad has #{count} options format #{options.inspect}"
          end

          options[:order] = Ardm::ActiveRecord::Query.order(self, options[:order]) if options[:order]
          opts = Ardm::ActiveRecord::Associations.convert_options(self, options, :through, :order)

          case count
          when 1      then has_one  name, opts
          when "many" then has_many name, opts
          end
        end

      end
    end
  end
end