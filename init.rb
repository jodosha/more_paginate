ActiveRecord::Base.extend MorePaginate::ActiveRecord::ClassMethods
ActionView::Base.send(:include, MorePaginate::ActionView::Helpers) if defined?(ActionView)
I18n.backend.store_translations :en, :more => "more" if defined?(I18n)
