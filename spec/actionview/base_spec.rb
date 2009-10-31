require File.dirname(__FILE__) + '/../spec_helper'

describe ActionView::Base do
  describe "more_paginate" do
    describe "content" do
      it "should provide link with given text" do
        helper.more_paginate(records, :content => "more events").should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more events</a>)
      end

      it "should escape given text" do
        helper.more_paginate(records, :content => "<script>xss</script>").should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">&lt;script&gt;xss&lt;/script&gt;</a>)
      end

      it "should show text according to the current locale" do
        I18n.backend.store_translations :it, :more => "ancora"
        with_locale :it do
          helper.more_paginate(records).should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">ancora</a>)
        end
      end

      it "should show missing translation message if current locale has no :more key" do
        with_locale :de do
          helper.more_paginate(records).should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">&lt;span class=&quot;translation_missing&quot;&gt;de, more&lt;/span&gt;</a>)
        end
      end
    end

    describe "DOM id" do
      it "should provide default value" do
        helper.more_paginate(records).should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should use given value" do
        helper.more_paginate(records, :id => "more_paginate").should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_paginate">more</a>)
      end
    end

    describe "DOM class" do
      it "should provide default value" do
        helper.more_paginate(records).should == %(<a href="?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should use given value" do
        helper.more_paginate(records, :class => "more_paginate").should == %(<a href="?sort_key=id&amp;sort_value=" class="more_paginate" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "path_prefix" do
      it "should use given url prefix" do
        helper.more_paginate(records, :path_prefix => "/timeline").should == %(<a href="/timeline?sort_key=id&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "sort_key" do
      it "should use given value" do
        events = records [ ], :sort_key => "name"
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end

      it "should escape given value" do
        events = records [ ], :sort_key => "<script>xss</script>"
        helper.more_paginate(events).should == %(<a href="?sort_key=&lt;script&gt;xss&lt;/script&gt;&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "sort_value" do
      it "should use given value" do
        events = records [ Event.new :name => "ADTR live!" ], :sort_key => "name"
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=ADTR+live%21" class="more_link" data-sort-value="ADTR+live%21" id="more_link">more</a>)
      end

      it "should leave blank if the collection returns a blank value" do
        events = records [ Event.new ], :sort_key => "name"
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end

    describe "data-sort-value" do
      it "should set HTML5 attribute" do
        events = records [ Event.new :name => "ADTR live!" ], :sort_key => "name"
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=ADTR+live%21" class="more_link" data-sort-value="ADTR+live%21" id="more_link">more</a>)
      end

      it "should leave blank if the collection returns a blank value" do
        events = records [ Event.new ], :sort_key => "name"
        helper.more_paginate(events).should == %(<a href="?sort_key=name&amp;sort_value=" class="more_link" data-sort-value="" id="more_link">more</a>)
      end
    end
  end

  private
    def records(records = [], options = {})
      MorePaginate::Collection.new records, options
    end

    def with_locale(locale)
      current_locale = I18n.locale
      I18n.locale = locale
      yield
      I18n.locale = current_locale
    end

    def helper
      @helper ||= begin
        helper = Object.new
        helper.extend ActionView::Helpers
        helper.extend MorePaginate::Helpers
        helper
      end
    end
end