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

  describe "paginate" do
    it "return first records by id" do
      records = create_records
      Event.paginate(:all).should == records[0...23]
    end

    it "return following records with same sort value" do
      records = create_records
      Event.paginate(:all, :sort_key => "name", :sort_value => "ADTR live!", :sort_id => "23").should == records[23...30]
    end

    it "return following records with different sort value" do
      records = create_records
      records = records.sort_by { |record| record.identifier }
      sort_record = records[22]

      Event.paginate(:all, :sort_key => "identifier").should == records[0...23]
      Event.paginate(:all, :sort_key => "identifier", :sort_value => sort_record.identifier, :sort_id => sort_record.id).should == records[23...30]
    end

    it "return descending sorted records" do
      records = create_records
      records = records.sort_by { |record| record.created_at }.reverse

      Event.paginate(:all, :sort_key => "created_at", :sort_order => "desc").should == records[0...23]
    end
  end

  describe "prepare_more_paginate_options" do
    describe "order" do
      it "should set default" do
        options = { }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == quoted_sql(%("events"."id" ASC))
          collection_options[:order].should == quoted_sql(%("events"."id" ASC))
        end
      end

      it "should add default to the already existing value" do
        options = { :order => "name ASC" }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == quoted_sql(%(name ASC, "events"."id" ASC))
          collection_options[:order].should == quoted_sql(%(name ASC, "events"."id" ASC))
        end
      end

      it "should use class defined primary key" do
        options = { }
        Event.should_receive(:primary_key).twice.and_return "legacy_id"
        with_paginate_options options do |options, collection_options|
          options[:order].should            == quoted_sql(%("events"."legacy_id" ASC))
          collection_options[:order].should == quoted_sql(%("events"."legacy_id" ASC))
        end
      end

      it "should add clause for given sort_key" do
        options = { :order => "name ASC", :sort_key => "name" }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == quoted_sql(%(name ASC, "name" ASC, "events"."id" ASC))
          collection_options[:order].should == quoted_sql(%(name ASC, "name" ASC, "events"."id" ASC))
        end
      end

      it "should set order according to given sort_order key" do
        options = { :sort_order => "desc" }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == quoted_sql(%("events"."id" DESC))
          collection_options[:order].should == quoted_sql(%("events"."id" DESC))
        end

        options = { :sort_key => "name", :sort_order => "desc" }
        with_paginate_options options do |options, collection_options|
          options[:order].should            == quoted_sql(%("name" DESC, "events"."id" DESC))
          collection_options[:order].should == quoted_sql(%("name" DESC, "events"."id" DESC))
        end
      end      
    end

    describe "limit" do
      it "should use class value by default" do
        options = { }
        with_paginate_options options do |options, collection_options|
          options[:limit].should            == Event.per_page
          collection_options[:limit].should == Event.per_page
        end
      end

      it "should use given value" do
        options = { :limit => 1000 }
        with_paginate_options options do |options, collection_options|
          options[:limit].should            == 1000
          collection_options[:limit].should == 1000
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
        options = { :sort_value => "ADTR live!" }
        with_paginate_options options do |options, collection_options|
          options[:sort_value].should               be_nil
          collection_options[:sort_value].should == "ADTR live!"
        end
      end
    end

    describe "sort_id" do
      it "should remove from options" do
        options = { :sort_id => "23" }
        with_paginate_options options do |options, collection_options|
          options[:sort_id].should               be_nil
          collection_options[:sort_id].should == "23"
        end
      end
    end

    describe "sort_order" do
      it "should remove from options" do
        options = { :sort_order => "asc" }
        with_paginate_options options do |options, collection_options|
          options[:sort_order].should               be_nil
          collection_options[:sort_order].should == "asc"
        end
      end
    end

    describe "conditions" do
      it "should set default" do
        options = { :sort_key => "name", :sort_value => "ADTR live!", :sort_id => "23" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == [quoted_sql(%(("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?))), "ADTR live!", "ADTR live!", 23]
        end        
      end

      it "should preserve given string SQL conditions" do
        options = { :conditions => "name IS NOT NULL", :sort_key => "name", :sort_value => "ADTR live!", :sort_id => "23" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == [quoted_sql(%(name IS NOT NULL AND ("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?))), "ADTR live!", "ADTR live!", 23]
        end
      end

      it "should preserve given array SQL conditions" do
        options = { :conditions => ["name IS NOT IN(?)", "crappy live"], :sort_key => "name", :sort_value => "ADTR live!", :sort_id => "23" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == [quoted_sql(%(name IS NOT IN(?) AND ("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?))), "crappy live", "ADTR live!", "ADTR live!", 23]
        end
      end

      it "should preserve given hash SQL conditions"
      # it "should preserve given hash SQL conditions" do
      #   options = { :conditions => { :id => 23 }, :sort_key => "name", :sort_value => "ADTR live!", :sort_id => "23" }
      #   with_paginate_options options do |options, collection_options|
      #     options[:conditions].should == ["id IS IN(?) AND (? > ?) OR (? = ? AND events.id > ?)", 23, "name", "ADTR live!", "name", "ADTR live!", 23]
      #   end
      # end

      it "should set to zero missing sort_id" do
        options = { :sort_key => "name", :sort_value => "ADTR live!" }
        with_paginate_options options do |options, collection_options|
          options[:conditions].should == [quoted_sql(%(("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?))), "ADTR live!", "ADTR live!", 0]
        end
      end

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
        Event.send(:more_paginate_condition_string, "name").should == quoted_sql(%(("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?)))
      end

      it "should use class defined table name" do
        Event.should_receive(:table_name).at_least(1).times.and_return "gigs"
        Event.send(:more_paginate_condition_string, "name").should == quoted_sql(%(("gigs"."name" > ?) OR ("gigs"."name" = ? AND "gigs"."id" > ?)))
      end

      it "should use class defined primary key" do
        Event.should_receive(:primary_key).and_return "legacy_id"
        Event.send(:more_paginate_condition_string, "name").should == quoted_sql(%(("events"."name" > ?) OR ("events"."name" = ? AND "events"."legacy_id" > ?)))
      end

      it "should change comparison operator according to given sort_order value" do
        Event.send(:more_paginate_condition_string, "name", "desc").should    == quoted_sql(%(("events"."name" < ?) OR ("events"."name" = ? AND "events"."id" < ?)))
        Event.send(:more_paginate_condition_string, "name", "").should        == quoted_sql(%(("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?)))
        Event.send(:more_paginate_condition_string, "name", "ascdesc").should == quoted_sql(%(("events"."name" > ?) OR ("events"."name" = ? AND "events"."id" > ?)))
      end
    end
    
    describe "more_paginate_sql_order" do
      it "should return ASC by default" do
        options = { }
        Event.send(:more_paginate_sql_order, options).should == "ASC"

        options = { :sort_order => "unknown" }
        Event.send(:more_paginate_sql_order, options).should == "ASC"

        options = { :sort_order => "ascdesc" }
        Event.send(:more_paginate_sql_order, options).should == "ASC"
      end

      it "should return DESC when specified" do
        options = { :sort_order => "desc" }
        Event.send(:more_paginate_sql_order, options).should == "DESC"

        options = { :sort_order => "DESC" }
        Event.send(:more_paginate_sql_order, options).should == "DESC"
      end
    end
  end

  private
    def with_paginate_options(options)
      yield Event.send :prepare_more_paginate_options!, options
    end

    def quoted_sql(sql)
      sql.gsub(/"/, escape_string)
    end

    def create_records
      create_tables
      30.times { Event.create :name => "ADTR live!", :identifier => (rand * 100_000).to_i }
      Event.all
    end

    def escape_string
      @escape_string ||= begin
        case ActiveRecord::Base.connection.adapter_name.downcase.to_sym
          when :sqlite then "\""
          else              "`"
        end
      end
    end
end