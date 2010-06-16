module MorePaginate
  module ActiveRecord
    module ClassMethods
      def self.extended(base)
        base.class_eval %{
          class_inheritable_accessor :per_page
          self.per_page = 30
        }
      end

      def paginate(scope, options = {})
        options, collection_options = prepare_more_paginate_options!(options)
        Collection.new find(scope, options), collection_options
      end

      protected
        def more_paginate_condition_string(sort_key, sort_order = nil)
          table_name = self.quoted_table_name
          sort_key   = more_paginate_full_quoted_column(sort_key)
          sort_order = sort_order.to_s.downcase == "desc" ? "<" : ">"
          "(#{sort_key} #{sort_order} ?) OR (#{sort_key} = ? AND #{more_paginate_full_quoted_column primary_key} #{sort_order} ?)"
        end

      private
        def prepare_more_paginate_options!(options)
          add_more_paginate_order!(options)
          add_more_paginate_limit!(options)
          collection_options = options.dup
          options.delete(:sort_value_method)
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
            options[:order] << (options[:sort_key].blank? ? "" : "#{more_paginate_quoted_column(options[:sort_key])} #{order}, ")
            options[:order] << "#{more_paginate_full_quoted_column primary_key} #{order}"
          else
            options[:order] << (options[:sort_key].blank? ? ", " : ", #{more_paginate_quoted_column(options[:sort_key])} #{order}, ")
            options[:order] << "#{more_paginate_full_quoted_column primary_key} #{order}"
          end
        end

        def add_more_paginate_limit!(options)
          options[:limit] = options.fetch(:limit, per_page) + 1
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
          return column if more_paginate_skip_quote_column?(column)
          connection.quote_column_name column
        end

        def more_paginate_full_quoted_column(column)
          return column if more_paginate_skip_quote_column?(column)
          "#{quoted_table_name}.#{connection.quote_column_name column}"
        end

        def more_paginate_sql_order(options)
          options[:sort_order].to_s.downcase == "desc" ? "DESC" : "ASC"
        end

        def more_paginate_skip_quote_column?(column)
          column.blank? or column.match /\./
        end
    end
  end

  class Collection < Array
    def initialize(array, options)
      @options = options
      calculate_more! array
      super(array)
    end

    def more?
      @more
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

    def sort_value_method
      @sort_value_method ||= @options[:sort_value_method] || sort_key
    end

    def sort_value
      @sort_value ||= typecast last.try(sort_value_method)
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
      def calculate_more!(array)
        if @options[:limit] == array.size
          @more = true
          array.pop
        end

        @options.merge!(:limit => @options.delete(:limit) - 1)
      end

      def typecast(value)
        case value
        when Time, Date
          value.to_s(:db)
        else
          value
        end
      end
  end

  module ActionView
    module Helpers
      include Rack::Utils

      # Creates a link tag as JavaScript hook for pagination.
      #
      # ==== Options
      # * <tt>:content => "load more tweets"</tt> - This will change the link
      # content. If this option is missing, <tt>t(:more)</tt> will be invoked.
      # * <tt>:id => "more-tweets"</tt> - Assign a custom DOM id. Default is
      # <tt>more_link</tt>
      # * <tt>:class => "more-tweets"</tt> - Assign CSS classes. Default is
      # <tt>more_link</tt>
      # * <tt>:path_prefix => "/timeline"</tt> - This will set a prefix to the
      # generated query string.
      # * <tt>:sort_order => "desc"</tt> - This will change the records sort order
      # in the future AJAX requests. Default is <tt>desc</tt>
      #
      # ==== Examples
      # Basic usage:
      #   <%= more_paginate @tweets %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc">more</a>
      #
      # Specify the content:
      #   <%= more_paginate @tweets, :content => "more tweets please!" %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc">more tweets please!</a>
      #
      # Or specify the content by passing a block:
      #   <% more_paginate @tweets %>
      #     <span class="more">more tweets</span>
      #   <% end %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc"><span class="more">more tweets</span></a>
      #
      # Specify the DOM id:
      #   <%= more_paginate @tweets, :id => "more-tweets" %>
      #     # => <a id="more-tweets" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc">more</a>
      #
      # Specify the <tt>class</tt> attribute:
      #   <%= more_paginate @tweets, :class => "span-6 more-tweets" %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="span-6 more-tweets" href="?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc">more</a>
      #
      # Specify a path prefix:
      #   <%= more_paginate @tweets, :path_prefix => "/timeline" %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="/timeline?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc">more</a>
      #
      # Specify a sort order:
      #   <%= more_paginate @tweets, :sort_order => "asc" %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="?sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=asc">more</a>
      #
      # Specify a query string:
      #   <%= more_paginate @tweets, :query => "q=Rome" %>
      #     # => <a id="more_link" data-sort-value="2010-02-20+00%3A52%3A55" class="more_link" href="?q=Rome&sort_key=created_at&amp;sort_value=2010-02-20+00%3A52%3A55&amp;sort_id=785&amp;sort_order=desc">more</a>
      def more_paginate(records, options = {}, &block)
        content = options.delete(:content) || t(:more)
        query   = options.delete(:query) || ""
        query << "&" unless query.blank?
        options.merge!(:"data-sort-value" => escape(records.sort_value))
        options[:id]       ||= "more_link"
        options[:class]    ||= "more_link"

        url = "#"
        if records.more?
          url = "#{options.delete(:path_prefix)}?#{query}sort_key=#{h(records.sort_key)}&sort_value=#{escape(records.sort_value)}&sort_id=#{records.sort_id}"
          if sort_order = options.delete(:sort_order)
            url << "&sort_order=#{h(sort_order)}"
          elsif not records.sort_order.blank?
            url << "&sort_order=#{h(records.sort_order)}"
          end
        end

        if block_given?
          link_to concat(capture(&block)), url, options
        else
          link_to escape_content(content), url, options
        end
      end

      private
        def escape_content(content)
          if content.try(:html_safe?)
            content
          else
            h content
          end
        end
    end
  end
end
