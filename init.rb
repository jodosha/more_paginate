ActiveRecord::Base.send :include, MorePaginate
ActionView::Base.send(:include, MorePaginate::Helpers) if defined?(ActionView)
I18n.backend.store_translations :en, :more => "more" if defined?(I18n)
