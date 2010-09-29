require File.expand_path('../spec_helper', __FILE__)

class Album < ActiveRecord::Base
  extend Publishable
  publishable
end

class Feature < ActiveRecord::Base
  extend Publishable
  publishable :on => :public_since
end

describe Publishable do
  ActiveRecord::Base.establish_connection :adapter  => 'sqlite3',
                                          :database => File.expand_path('../../db/test.sqlite3', __FILE__)
  load('db/schema.rb')
  
  before do
    Album.delete_all
    @album = Album.new
  end
    
  it "should not be published" do
    # nil or false
    @album.published_at.should be_false
    @album.should_not be_published
    
    # in the future
    @album.published_at = Time.now + 60
    @album.should_not be_published
  end

  it "should be published" do
    # now
    @album.published_at = Time.now
    @album.should be_published
    
    # in the past
    @album.published_at = Time.now - 60
    @album.should be_published
  end
  
  it "should be publishable" do
    @album.should_not be_published
    @album.publish
    @album.should be_published
  end
  
  it "should persist" do
    @album.expects(:publish).returns(true)
    @album.expects(:save)
    @album.publish!
  end
  
  describe "scope" do
    before do
      @album_1 = Album.create!(:published_at => nil)
      @album_2 = Album.create!(:published_at => Time.now - 60)
      @album_3 = Album.create!(:published_at => Time.now)
      @album_4 = Album.create!(:published_at => Time.now + 60)
    end
  
    it "should find published records" do
      Album.published.should == [@album_2, @album_3]
    end
  
    it "should find unpublished records" do
      Album.unpublished.should == [@album_1, @album_4]
    end
  end
  
  describe "other column" do
    it "should be publishable" do
      @feature = Feature.new
      @feature.should_not be_published
      @feature.publish
      @feature.should be_published
    end
    
    describe "scope" do
      before do
        Feature.delete_all
        @feature_1 = Feature.create!(:public_since => nil)
        @feature_2 = Feature.create!(:public_since => Time.now - 60)
        @feature_3 = Feature.create!(:public_since => Time.now)
        @feature_4 = Feature.create!(:public_since => Time.now + 60)
      end

      it "should find published records" do
        Feature.published.should == [@feature_2, @feature_3]
      end

      it "should find unpublished records" do
        Feature.unpublished.should == [@feature_1, @feature_4]
      end
    end    
  end
end
