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
end