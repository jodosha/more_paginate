require File.dirname(__FILE__) + '/../spec_helper'

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

  private
    def instantiate_collection(records = [], options = {})
      MorePaginate::Collection.new records, options
    end
end