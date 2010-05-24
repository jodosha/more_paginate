require File.dirname(__FILE__) + '/../spec_helper'

MorePaginate::Collection.class_eval do
  attr_reader :options
end

describe MorePaginate::Collection do
  it "should inherit from Array" do
    MorePaginate::Collection.superclass.should == Array
  end

  describe "sort_key" do
    it "should use defined value" do
      collection = instantiate_collection [ ], :sort_key => "name"
      collection.sort_key.should == "name"
    end

    it "should use primary key if not set" do
      collection = instantiate_collection
      collection.sort_key.should == "id"
    end

    it "should use defined primary key if not set" do
      collection = instantiate_collection [ ], :primary_key => "legacy_id"
      collection.sort_key.should == "legacy_id"
    end

    it "should extract from order conditions" do
      collection = instantiate_collection [ ], :order => "id ASC"
      collection.sort_key.should == "id"

      collection = instantiate_collection [ ], :order => "id DESC"
      collection.sort_key.should == "id"

      collection = instantiate_collection [ ], :order => "name ASC, id ASC"
      collection.sort_key.should == "name"

      collection = instantiate_collection [ ], :order => "name, id ASC"
      collection.sort_key.should == "name"
    end
  end

  describe "sort_value_method" do
    it "should return given value" do
      collection = instantiate_collection [ ], :sort_value_method => "last_photo_created_at"
      collection.sort_value_method.should == "last_photo_created_at"
    end

    it "should fallback to sort_key if not configured" do
      collection = instantiate_collection [ ]
      collection.sort_value_method.should == "id"
    end
  end

  describe "sort_value" do
    it "should read from last record" do
      collection = instantiate_collection [ Event.new, Event.new(:name => "ADTR live!") ], :sort_key => "name"
      collection.sort_value.should == "ADTR live!"
    end

    it "should return nil on missing value" do
      collection = instantiate_collection [ Event.new ], :sort_key => "name"
      collection.sort_value.should be_nil
    end

    it "should return nil if empty" do
      collection = instantiate_collection [ ], :sort_key => "name"
      collection.sort_value.should be_nil
    end

    it "should return nil on unknown sort_key" do
      collection = instantiate_collection [ ], :sort_key => "unknown"
      collection.sort_value.should be_nil
    end

    it "should return nil on blank sort_key" do
      collection = instantiate_collection [ ]
      collection.sort_value.should be_nil

      collection = instantiate_collection [ ], :sort_key => ""
      collection.sort_value.should be_nil
    end

    it "should return value from specified sort_value_method" do
      event = Event.create :name => "ADTR live!"
      event.photos << Photo.new(:title => "Stage", :created_at => 1.week.ago)
      collection = instantiate_collection [ event ], :sort_value_method => "last_photo_created_at"
      collection.sort_value.should == 1.week.ago.to_s(:db)
    end

    it "should properly handle time values" do
      event = Event.create :name => "ADTR live!"
      collection = instantiate_collection [ event ], :sort_key => "created_at"
      collection.sort_value.should == Time.now.to_s(:db)
    end

    it "should properly handle date values" do
      event = Event.create :name => "ADTR live!", :start_on => Date.today
      collection = instantiate_collection [ event ], :sort_key => "start_on"
      collection.sort_value.should == Date.today.to_s(:db)
    end
  end

  describe "sort_id" do
    it "should read from last record" do
      event = Event.create :name => "ADTR live!"
      collection = instantiate_collection [ event ], :primary_key => "id"
      collection.sort_id.should == event.id
    end

    it "should return nil on missing value" do
      collection = instantiate_collection [ Event.new ], :primary_key => "id"
      collection.sort_id.should be_nil
    end
  end

  describe "sort_order" do
    it "should read from options" do
      collection = instantiate_collection [ Event.new ], :sort_order => "asc"
      collection.sort_order.should == "asc"

      collection = instantiate_collection [ Event.new ], :sort_order => "desc"
      collection.sort_order.should == "desc"
    end

    it "should ignore all but 'asc' and 'desc' values" do
      collection = instantiate_collection [ Event.new ], :sort_order => "unknown"
      collection.sort_order.should == ""
    end

    it "should clarify ambiguous values" do
      collection = instantiate_collection [ Event.new ], :sort_order => "ascdesc"
      collection.sort_order.should == ""
    end
  end

  describe "calculate_more!" do
    describe "more elements" do
      it "should remove last element and set more on true" do
        collection = instantiate_collection((1...25).to_a, :limit => Event.per_page + 1)
        collection.should be_more
        collection.size.should == collection.options[:limit]
      end
    end

    describe "few elements" do
      it "should keep all the collection" do
        records = (1..3).to_a
        original_size = records.size
        collection = instantiate_collection records, :limit => 23
        collection.should_not be_more
        collection.size.should == original_size
      end
    end
  end

  private
    def instantiate_collection(records = [], options = { })
      options.merge!(:limit => Event.per_page + 1) unless options[:limit].present?
      MorePaginate::Collection.new records, options
    end
end