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
      options, collection_options = prepare_more_paginate_options(options)
      MorePaginateCollection.new find(scope, options), collection_options
    end

    private
      def prepare_more_paginate_options(options)
        options[:order] ||= ""
        options[:order] << ", id ASC"

        options.merge!(:limit => per_page)
        collection_options = options.dup

        sort_key   = options.delete(:sort_key)
        sort_value = options.delete(:sort_value)

        if sort_value
          options[:conditions] ||= []
          # TODO use safe conditions
          # options[:conditions] << ["BINARY(?) > BINARY(?)", sort_key, sort_value]
          options[:conditions] << ["BINARY(#{sort_key}) > BINARY(?)", sort_value]
          options[:conditions].flatten!
        end

        [options, collection_options]
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
    def more_paginate(records, options = {})
      # TODO prefix options
      options[:text]  ||= t(:more, :default => "more")
      options[:id]    ||= "more_link"
      options[:class] ||= "more_link"      
      link_to h(options[:text]), "?sort_key=#{h(records.sort_key)}&sort_value=#{h(records.sort_value)}",
        :id => options[:id], :class => options[:class], :"data-sort-value" => records.sort_value
    end
  end
end
