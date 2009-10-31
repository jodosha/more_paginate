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
      MorePaginateCollection.new find(scope, options), collection_options
    end

    private
      def prepare_more_paginate_options!(options)
        add_more_paginate_order!(options)
        add_more_paginate_limit!(options)
        collection_options = options.dup
        add_more_paginate_conditions!(options)

        [ options, collection_options ]
      end

      def add_more_paginate_order!(options)
        # TODO use proper primary key instead of hardcoded 'id'
        if options[:order].blank?
          options[:order] = "id ASC"
        else
          options[:order] << ", id ASC"
        end
      end

      def add_more_paginate_limit!(options)
        options.merge!(:limit => per_page)
      end

      def add_more_paginate_conditions!(options)
        sort_key   = options.delete(:sort_key)
        sort_value = options.delete(:sort_value)

        if sort_value
          case options[:conditions]
          when String
            options[:conditions] = [ "#{options[:conditions]} AND #{more_paginate_condition_string}", sort_key, sort_value ]
          when Array
            options[:conditions][0] = "#{options[:conditions][0]} AND #{more_paginate_condition_string}"
            options[:conditions] << [ sort_key, sort_value ]
            options[:conditions].flatten!
          when Hash
            # TODO implement
          else
            options[:conditions] = [more_paginate_condition_string, sort_key, sort_value]
          end
        end
      end

      def more_paginate_condition_string
        "BINARY(?) > BINARY(?)"
      end
  end

  class MorePaginateCollection < Array
    def initialize(array, options)
      @options = options
      super(array)
    end

    def sort_key
      # TODO use proper primary key instead of hardcoded 'id'
      @options[:sort_key] ||= begin
        key = @options[:order].split(",").first
        key.blank ? "id" : key.gsub!(/\s(ASC|DESC)/, "")
      end
    end

    def sort_value
      @sort_value ||= last.try(:read_attribute, sort_key)
    end
  end

  module Helpers
    include Rack::Utils

    def more_paginate(records, options = {})
      # TODO prefix options
      options[:text]  ||= t(:more, :default => "more")
      options[:id]    ||= "more_link"
      options[:class] ||= "more_link"      
      link_to h(options[:text]), "?sort_key=#{h(records.sort_key)}&sort_value=#{escape(records.sort_value)}",
        :id => options[:id], :class => options[:class], :"data-sort-value" => records.sort_value
    end
  end
end
