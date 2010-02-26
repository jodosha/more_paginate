require File.dirname(__FILE__) + '/../../spec_helper'

describe ActiveRecord::Associations::HasManyAssociation do
  describe "paginate" do
    it "return first records by id" do
      event, records = create_records
      event.photos.paginate(:all, :limit => 23 + 1).should == records[0...23]
    end

    it "return following records with same sort value" do
      event, records = create_records
      event.photos.paginate(:all, :sort_key => "title", :sort_value => "ADTR on stage!", :sort_id => "23").should == records[23...30]
    end

    it "return following records with different sort value" do
      event, records = create_records
      records = records.sort_by { |record| record.identifier }
      sort_record = records[22]

      event.photos.paginate(:all, :sort_key => "identifier", :limit => 23 + 1).should == records[0...23]
      event.photos.paginate(:all, :sort_key => "identifier", :limit => 23 + 1, :sort_value => sort_record.identifier, :sort_id => sort_record.id).should == records[23...30]
    end

    it "return descending sorted records" do
      event, records = create_records
      records = records.sort_by { |record| record.created_at }.reverse

      event.photos.paginate(:all, :sort_key => "created_at", :sort_order => "desc").should == records
    end
  end

  private
    def create_records
      create_tables
      event = Event.create :name => "ADTR live!"
      30.times { Photo.create :title => "ADTR on stage!", :identifier => (rand * 100_000).to_i, :event => event }
      [ event, Photo.all ]
    end
end