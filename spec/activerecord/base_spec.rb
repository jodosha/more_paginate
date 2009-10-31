require File.dirname(__FILE__) + '/../spec_helper'

describe ActiveRecord::Base do
  describe "per page" do
    it "should have a class method" do
      ActiveRecord::Base.per_page.should == 30
    end

    it "should be able to set custom value" do
      Event.per_page.should == 23
    end
    
    it "should overwrite superclass value" do
      Festival.per_page.should == 11
    end
  end

  describe "prepare_more_paginate_options" do
    describe "order" do
      it "should set default" do
        options = { }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == "id ASC"
          collection_options[:order].should == "id ASC"
        end
      end

      it "should add default to the already existing value" do
        options = { :order => "name ASC" }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == "name ASC, id ASC"
          collection_options[:order].should == "name ASC, id ASC"
        end
      end

      it "should use class defined primary key" do
        options = { }
        Event.should_receive(:primary_key).twice.and_return "legacy_id"
        with_paginate_options options do |options, collection_options|
          options[:order].should            == "legacy_id ASC"
          collection_options[:order].should == "legacy_id ASC"
        end
      end
    end

    describe "limit" do
      it "should force class value" do
        options = { :limit => 1000 }
        with_paginate_options options do |options, collection_options|
          options[:limit].should            == Event.per_page
          collection_options[:limit].should == Event.per_page
        end
      end
    end

    describe "sort_key" do
      it "should remove from options" do
        options = { :sort_key => "name" }
        with_paginate_options options do |options, collection_options|
          options[:sort_key].should               be_nil
          collection_options[:sort_key].should == "name"
        end
      end
    end

    describe "sort_value" do
      it "should remove from options" do
        options = { :sort_value => "A Day To Remember live!" }
        with_paginate_options options do |options, collection_options|
          options[:sort_value].should               be_nil
          collection_options[:sort_value].should == "A Day To Remember live!"
        end
      end
    end

    describe "conditions" do
      it "should set default" do
        options = { :sort_key => "name", :sort_value => "A Day To Remember live!" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == ["BINARY(?) > BINARY(?)", "name", "A Day To Remember live!"]
        end        
      end

      it "should preserve given string SQL conditions" do
        options = { :conditions => "name IS NOT NULL", :sort_key => "name", :sort_value => "A Day To Remember live!" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == ["name IS NOT NULL AND BINARY(?) > BINARY(?)", "name", "A Day To Remember live!"]
        end
      end

      it "should preserve given array SQL conditions" do
        options = { :conditions => ["id IS IN(?)", 23], :sort_key => "name", :sort_value => "A Day To Remember live!" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == ["id IS IN(?) AND BINARY(?) > BINARY(?)", 23, "name", "A Day To Remember live!"]
        end
      end

      it "should preserve given hash SQL conditions"
      # it "should preserve given hash SQL conditions" do
      #   options = { :conditions => { :id => 23 }, :sort_key => "name", :sort_value => "A Day To Remember live!" }
      #   with_paginate_options options do |options, collection_options|
      #     options[:conditions].should == ["id IS IN(?) AND BINARY(?) > BINARY(?)", 23, "name", "A Day To Remember live!"]
      #   end
      # end

      it "shouldn't set if sort_value is missing" do
        options = { :conditions => "name IS NOT NULL", :sort_key => "name" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == "name IS NOT NULL"
        end
      end
    end

    describe "primary key" do
      it "should set table defined value" do
        options = { }
        with_paginate_options options do |options, collection_options|
          collection_options[:primary_key].should == "id"
        end
      end
    end

    describe "more_paginate_condition_string" do
      it "have default value" do
        Event.send(:more_paginate_condition_string).should == "BINARY(?) > BINARY(?)"
      end
    end
  end

  private
    def with_paginate_options(options)
      yield Event.send :prepare_more_paginate_options!, options
    end
end