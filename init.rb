ActiveRecord::Base.send :include, MorePaginate
ActionView::Base.send(:include, MorePaginate::Helpers) if defined?(ActionView)
