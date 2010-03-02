require File.dirname(__FILE__) + '/../spec_helper'

class MockHelper
  attr_accessor :output_buffer

  include ActionView::Helpers
  include MorePaginate::Helpers

  def initialize
    @output_buffer = ""
  end
end

describe ActionView::Base do
  describe "more_paginate" do
    describe "content" do
      it "should provide link with given text" do
        helper.more_paginate(records, :content => "more events").should == %(<a href="#" class="more_link" data-sort-value="" id="more_link">more events</a>)
      end

      it "should escape given text" do
        helper.more_paginate(records, :content => "<script>xss</script>").should == %(<a href="#" class="more_link" data-sort-value="" id="more_link">&lt;script&gt;xss&lt;/script&gt;</a>)
      end

      it "should escape given text unless marked as safe" do
        helper.more_paginate(records, :content => "<span>more</span>".html_safe!).should == %(<a href="#" class="more_link" data-sort-value="" id="more_link"><span>more</span></a>)
      end

      it "should show text according to the current locale" do
        I18n.backend.store_translations :it, :more => "ancora"
        with_locale :it do
          helper.more_paginate(records).should == %(<a href="#" class="more_link" data-sort-value="" id="more_link">ancora</a>)
        end
      end

      it "should show missing translation message if current locale has no :more key" do
        with_locale :de do
          helper.more_paginate(records).should == %(<a href="#" class="more_link" data-sort-value="" id="more_link"><span class=\"translation_missing\">de, more</span></a>)
        end
      end

      describe "block" do
        it "should accept a &block for yielding extra contents" do
          helper.more_paginate(records) do
            %(<img src="/images/more.png" />)
          end.should == %(<a href="#" class="more_link" data-sort-value="" id="more_link"><img src="/images/more.png" /></a>)
        end

        it "should correctly pass the options to the link" do
          helper.more_paginate(many_records, :query => "q=Rome") do
            %(<img src="/images/more.png" />)
          end.should == %(<a href="?q=Rome&amp;sort_key=id&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link"><img src="/images/more.png" /></a>)
        end
      end
    end

    describe "DOM id" do
      it "should provide default value" do
        helper.more_paginate(records).should == %(<a href="#" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should use given value" do
        helper.more_paginate(records, :id => "more_paginate").should == %(<a href="#" class="more_link" data-sort-value="" id="more_paginate">more</a>)
      end
    end

    describe "DOM class" do
      it "should provide default value" do
        helper.more_paginate(records).should == %(<a href="#" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should use given value" do
        helper.more_paginate(records, :class => "more_paginate").should == %(<a href="#" class="more_paginate" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "path_prefix" do
      it "should use given url prefix" do
        helper.more_paginate(many_records, :path_prefix => "/timeline").should == %(<a href="/timeline?sort_key=id&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "sort_key" do
      it "should use given value" do
        events = records [ ], :sort_key => "name"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should escape given value" do
        events = records [ ], :sort_key => "<script>xss</script>"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=&lt;script&gt;xss&lt;/script&gt;&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "sort_value" do
      it "should use given value" do
        events = records [ Event.new :name => "ADTR live!" ], :sort_key => "name"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=ADTR+live%21&amp;sort_id=" class="more_link" data-sort-value="ADTR+live%21" id="more_link">more</a>)
      end

      it "should leave blank if the collection returns a blank value" do
        events = records [ Event.new ], :sort_key => "name"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "sort_id" do
      it "should use given value" do
        event  = Event.create :name => "ADTR live!"
        events = records [ event ], :sort_key => "name", :primary_key => "id"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=ADTR+live%21&amp;sort_id=#{event.id}" class="more_link" data-sort-value="ADTR+live%21" id="more_link">more</a>)
      end
    end

    describe "sort_order" do
      it "should not display by default" do
        events = records [ Event.new ]
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=id&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should display the association value" do
        events = records [ Event.new ], :sort_order => "asc"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=id&amp;sort_value=&amp;sort_id=&amp;sort_order=asc" class="more_link" data-sort-value="" id="more_link">more</a>)

        events = records [ Event.new ], :sort_order => "desc"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=id&amp;sort_value=&amp;sort_id=&amp;sort_order=desc" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should allow to override the association value" do
        events = records [ Event.new ], :sort_order => "asc"
        events.stub!(:more?).and_return true
        helper.more_paginate(events, :sort_order => "desc").should == %(<a href="?sort_key=id&amp;sort_value=&amp;sort_id=&amp;sort_order=desc" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "query" do
      it "should prepend query string with user defined values" do
        helper.more_paginate(many_records, :query => "q=Rome").should == %(<a href="?q=Rome&amp;sort_key=id&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "data-sort-value" do
      it "should set HTML5 attribute" do
        events = records [ Event.new :name => "ADTR live!" ], :sort_key => "name"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=ADTR+live%21&amp;sort_id=" class="more_link" data-sort-value="ADTR+live%21" id="more_link">more</a>)
      end

      it "should leave blank if the collection returns a blank value" do
        events = records [ Event.new ], :sort_key => "name"
        events.stub!(:more?).and_return true
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=&amp;sort_id=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end
  end

  private
    def records(records = [ ], options = { })
      options.merge!(:limit => Event.per_page) unless options[:limit].present?
      MorePaginate::Collection.new records, options
    end

    def many_records
      returning result = records do
        result.stub!(:more?).and_return true
      end
    end

    def with_locale(locale)
      begin
        current_locale = I18n.locale
        I18n.locale = locale
        yield
      ensure
        I18n.locale = current_locale
      end
    end

    def helper
      @helper ||= MockHelper.new
    end
end