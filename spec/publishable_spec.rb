require File.join(File.dirname(__FILE__), "spec_helper")

class Model < ActiveRecord::Base
  include Publishable
  publishable
end

describe Publishable do
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'db/test.sqlite3'
  load('db/schema.rb')
  
  before do
    Model.delete_all
    @model = Model.new
  end
  
  describe "published?" do
    it "should respond to published?" do
      @model.should respond_to(:published?)
    end

    it "should be published? when :published_at is now" do
      now = Time.now; Time.stubs(:now).returns(now)
      @model.published_at = Time.now
      @model.should be_published
    end
    
    it "should be published? when :published_at is in the past" do
      now = Time.now; Time.stubs(:now).returns(now)
      @model.published_at = Time.now - 1.day
      @model.should be_published
    end
    
    it "should not be published when :published_at is in the future" do
      now = Time.now; Time.stubs(:now).returns(now)
      @model.published_at = Time.now + 1.day
      @model.should_not be_published
    end
    
    it "should ask :publishable_column_name" do
      Model.expects(:publishable_column_name).returns(:published_at)
      @model.published?
    end
  end
  
  describe "publish" do
    it "should respond to publish" do
      @model.should respond_to(:publish)
    end

    it "should set :published_at to current time with no parameter" do
      now = Time.now; Time.expects(:now).returns(now)
      @model.expects(:published_at=).with(now).returns(now)
      @model.publish
    end
    
    it "should set :published_at to given time if parameter present" do
      tomorrow = Time.now + 1.day
      @model.expects(:published_at=).with(tomorrow).returns(tomorrow)
      @model.publish(tomorrow)      
    end
    
    it "should not set :published_at again if already published?" do
      @model.expects(:published?).once.returns(true)
      @model.stubs(:published_at=).never
      @model.publish
    end
  end
  
  describe "publish!" do
    it "should respond to publish!" do
      @model.should respond_to(:publish!)
    end
    
    it "should publish and save" do
      @model.expects(:publish).returns(true)
      @model.expects(:save).with(false).returns(true)
      @model.publish!
    end
  end
  
  describe "unpublished?" do
    it "should be unpublished? when not published?" do
      @model.expects(:published?).returns(false)
      @model.should be_unpublished
    end
    
    it "should not be unpublished? when published?" do
      @model.expects(:published?).returns(true)
      @model.should_not be_unpublished
    end
  end

  describe "named scopes" do
    before do
      @model_1 = Model.create!(:published_at => nil)
      @model_2 = Model.create!(:published_at => Time.now.utc - 1.day)
      @model_3 = Model.create!(:published_at => Time.now.utc)
      @model_4 = Model.create!(:published_at => Time.now.utc + 1.day)          
    end
    
    it "should find published records" do
      Model.published.all.should        == [@model_2, @model_3]
      Model.published(true).all.should  == [@model_2, @model_3]
    end
    
    it "should find unpublished records" do
      Model.unpublished.all.should      == [@model_1, @model_4]
      Model.published(false).all.should == [@model_1, @model_4]
    end
  end

  describe "database column" do
    it "should default to :published_at" do
      Model.publishable_column_name.should == :published_at
    end
    
    it "should be possible to change the column name" do
      class Model2 < ActiveRecord::Base
        include Publishable
        publishable :made_available_on
      end
      Model2.publishable_column_name.should == :made_available_on
    end
  end
end
