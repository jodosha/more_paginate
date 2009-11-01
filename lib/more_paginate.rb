module MorePaginate
  def self.included(base)
    base.class_eval %{
      class_inheritable_accessor :per_page
      self.per_page = 30
    }

    base.extend ClassMethods
  end

  module ClassMethods
    def paginate(scope, options = {})
      options, collection_options = prepare_more_paginate_options!(options)
      Collection.new find(scope, options), collection_options
    end

    private
      def prepare_more_paginate_options!(options)
        add_more_paginate_order!(options)
        add_more_paginate_limit!(options)
        collection_options = options.dup
        add_more_paginate_primary_key!(collection_options)
        add_more_paginate_conditions!(options)

        [ options, collection_options ]
      end

      def add_more_paginate_primary_key!(options)
        options[:primary_key] = primary_key
      end

      def add_more_paginate_order!(options)
        if options[:order].blank?
          options[:order] = ""
          options[:order] << (options[:sort_key].blank? ? "" : "#{more_paginate_quoted_sort_key(options[:sort_key])} ASC, ")
          options[:order] << "#{table_name}.#{primary_key} ASC"
        else
          options[:order] << (options[:sort_key].blank? ? ", " : ", #{more_paginate_quoted_sort_key(options[:sort_key])} ASC, ")
          options[:order] << "#{table_name}.#{primary_key} ASC"
        end
      end

      def add_more_paginate_limit!(options)
        options.merge!(:limit => per_page)
      end

      def add_more_paginate_conditions!(options)
        sort_key   = options.delete(:sort_key)
        sort_value = options.delete(:sort_value)
        sort_id    = options.delete(:sort_id).to_i

        if sort_value
          case options[:conditions]
          when String
            options[:conditions] = [ "#{options[:conditions]} AND #{more_paginate_condition_string(sort_key)}", sort_value, sort_value, sort_id ]
          when Array
            options[:conditions][0] = "#{options[:conditions][0]} AND #{more_paginate_condition_string(sort_key)}"
            options[:conditions] << [ sort_value, sort_value, sort_id ]
            options[:conditions].flatten!
          when Hash
            # TODO implement
          else
            options[:conditions] = [more_paginate_condition_string(sort_key), sort_value, sort_value, sort_id]
          end
        end
      end

      def more_paginate_condition_string(sort_key)
        table_name = self.table_name
        sort_key   = more_paginate_quoted_sort_key(sort_key)
        "(#{sort_key} > ?) OR (#{sort_key} = ? AND #{table_name}.#{primary_key} > ?)"
      end

      def more_paginate_quoted_sort_key(sort_key)
        "#{table_name}.#{connection.quote_column_name sort_key}"
      end
  end

  class Collection < Array
    def initialize(array, options)
      @options = options
      super(array)
    end

    def sort_key
      @options[:sort_key] ||= begin
        if @options[:order].blank?
          @options[:primary_key] || "id"
        else
          key = @options[:order].split(",").first
          key.gsub(/\s(ASC|DESC)/, "")
        end
      end
    end

    def sort_value
      @sort_value ||= typecast last.try(:read_attribute, sort_key)
    end

    def sort_id
      @sort_id ||= last.try(:read_attribute, @options[:primary_key])
    end

    private
      def typecast(value)
        case value
        when Time, Date
          value.to_s(:db)
        else
          value
        end
      end
  end

  module Helpers
    include Rack::Utils

    def more_paginate(records, options = {})
      options[:content]  ||= t :more
      options[:id]       ||= "more_link"
      options[:class]    ||= "more_link"      
      link_to h(options[:content]), "#{options[:path_prefix]}?sort_key=#{h(records.sort_key)}&sort_value=#{escape(records.sort_value)}&sort_id=#{records.sort_id}",
        :id => options[:id], :class => options[:class], :"data-sort-value" => escape(records.sort_value)
    end
  end
end
