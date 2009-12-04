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

    protected
      def more_paginate_condition_string(sort_key, sort_order = nil)
        table_name = self.quoted_table_name
        sort_key   = more_paginate_quoted_column(sort_key)
        sort_order = sort_order.to_s.downcase == "desc" ? "<" : ">"
        "(#{sort_key} #{sort_order} ?) OR (#{sort_key} = ? AND #{more_paginate_quoted_column primary_key} #{sort_order} ?)"
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
        order = more_paginate_sql_order(options)

        if options[:order].blank?
          options[:order] = ""
          options[:order] << (options[:sort_key].blank? ? "" : "#{connection.quote_column_name(options[:sort_key])} #{order}, ")
          options[:order] << "#{more_paginate_quoted_column primary_key} #{order}"
        else
          options[:order] << (options[:sort_key].blank? ? ", " : ", #{connection.quote_column_name(options[:sort_key])} #{order}, ")
          options[:order] << "#{more_paginate_quoted_column primary_key} #{order}"
        end
      end

      def add_more_paginate_limit!(options)
        options[:limit] = options.fetch(:limit, per_page)
      end

      def add_more_paginate_conditions!(options)
        sort_key   = options.delete(:sort_key)
        sort_value = options.delete(:sort_value)
        sort_id    = options.delete(:sort_id).to_i
        sort_order = options.delete(:sort_order)

        if sort_value
          case options[:conditions]
          when String
            options[:conditions] = [ "#{options[:conditions]} AND #{more_paginate_condition_string(sort_key, sort_order)}", sort_value, sort_value, sort_id ]
          when Array
            options[:conditions][0] = "#{options[:conditions][0]} AND #{more_paginate_condition_string(sort_key, sort_order)}"
            options[:conditions] << [ sort_value, sort_value, sort_id ]
            options[:conditions].flatten!
          when Hash
            # TODO implement
          else
            options[:conditions] = [more_paginate_condition_string(sort_key, sort_order), sort_value, sort_value, sort_id]
          end
        end
      end

      def more_paginate_quoted_column(column)
        "#{quoted_table_name}.#{connection.quote_column_name column}"
      end

      def more_paginate_sql_order(options)
        options[:sort_order].to_s.downcase == "desc" ? "DESC" : "ASC"
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

    def sort_order
      @sort_order ||= begin
        return "" if @options[:sort_order].blank?

        result = @options[:sort_order].to_s.downcase.gsub(/[^(asc|desc)]/, "")
        %w(asc desc).include?(result) ? result : ""
      end
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

      url = "#{options[:path_prefix]}?sort_key=#{h(records.sort_key)}&sort_value=#{escape(records.sort_value)}&sort_id=#{records.sort_id}"
      if options[:sort_order]
        url << "&sort_order=#{h(options[:sort_order])}"
      elsif not records.sort_order.blank?
        url << "&sort_order=#{h(records.sort_order)}"
      end

      link_to h(options[:content]), url,
        :id => options[:id], :class => options[:class], :"data-sort-value" => escape(records.sort_value)
    end
  end
end
