require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Publishable do

  context 'with a Boolean publish attribute' do

    before :all do
      build_model :post do
        string :title
        text :body
        boolean :published
        attr_accessible :title, :body, :published
        validates :body, :title, :presence => true
        extend Publishable
        publishable
      end
    end

    before :each do
      @post = Post.new :title => Faker::Lorem.sentence(4), :body => Faker::Lorem.paragraphs(3).join("\n")
      @post.should be_valid
      @post.should_not be_published
    end

    it 'should become published when publish flag is set' do
      @post.publish!
      @post.should be_published
    end

    it 'should become unpublished when publish flag is cleared' do
      @post.published = true
      @post.should be_published
      @post.unpublish!
      @post.should_not be_published
    end

  end

  context 'with a Date publish attribute' do

    before :all do
      build_model :post do
        string :title
        text :body
        date :published
        attr_accessible :title, :body, :published
        validates :body, :title, :presence => true
        extend Publishable
        publishable
      end
    end

    before :each do
      @post = Post.new :title => Faker::Lorem.sentence(4), 
                       :body => Faker::Lorem.paragraphs(3).join("\n")
      @post.should be_valid
      @post.should_not be_published
    end

    it 'should be published if today is after the publish date' do
      @post.published = Date.current - 1.days
      @post.should be_published
    end

    it 'should be published if today is the publish date' do
      @post.published = Date.current
      @post.should be_published
    end

    it 'should not be published if today is before the publish date' do
      @post.published = Date.current + 1.days
      @post.should_not be_published
    end

    it 'should have a publish date of today or earlier after publish is directly called' do
      @post.publish
      @post.should be_published
      @post.published.should <= Date.current
    end

  end

  context 'with a DateTime publish attribute' do

    before :all do
      build_model :post do
        string :title
        text :body
        datetime :published
        attr_accessible :title, :body, :published
        validates :body, :title, :presence => true
        extend Publishable
        publishable
      end
    end

    describe 'publishing and unpublishing' do

      before :each do
        @post = Post.new :title => Faker::Lorem.sentence(4), 
                         :body => Faker::Lorem.paragraphs(3).join("\n")
        @post.should be_valid
        @post.should_not be_published
      end

      it 'should be published if now is after the publish time' do
        @post.published = DateTime.now - 1.minute
        @post.should be_published
      end

      it 'should not be published if now is before the publish time' do
        @post.published = DateTime.now + 1.minute
        @post.should_not be_published
      end

      it 'should have a publish time of now or earlier after publish is directly called' do
        @post.publish
        @post.should be_published
        @post.published.should <= DateTime.now
      end

    end

    describe 'querying for all upcoming items' do

      before :all do
        # create a bunch of published Posts
        (rand(9) + 1).times do
          days_ago = (rand(100) + 1).days
          Post.create :published => Date.current - days_ago,
                      :title => Faker::Lorem.sentence(4), 
                      :body => Faker::Lorem.paragraphs(3).join("\n")
        end
      end

      after :each do
        Post.upcoming.destroy_all
      end

      after :all do
        # have to destroy posts between tests - these are fake, not in the DB, so database-cleaner won't help us
        Post.destroy_all
      end

      [1, 2, 5, 10].each do |how_many|
        it "should return all #{how_many} upcoming queries if no limit is specified" do
          # create a known number of unpublished Posts
          how_many.times do
            days_from_now = (rand(100) + 1).days
            Post.create :published => Date.current + days_from_now,
                        :title => Faker::Lorem.sentence(4), 
                        :body => Faker::Lorem.paragraphs(3).join("\n")
          end
          size = Post.upcoming.size
          size.should == how_many
        end
      end

    end

    describe 'querying for all recent items' do

      before :all do
        # create a bunch of unpublished posts
        (rand(7) + 3).times do
          days_from_now = (rand(100) + 1).days
          Post.create :published => Date.current + days_from_now,
                      :title => Faker::Lorem.sentence(4), 
                      :body => Faker::Lorem.paragraphs(3).join("\n")
        end
      end

      after :each do
        Post.recent.destroy_all
      end

      after :all do
        Post.destroy_all
      end

      [1, 2, 5, 10].each do |how_many|
        it "should return all #{how_many} recent queries if no limit is specified" do
          # create a known number of published posts
          how_many.times do
            Post.create :published => Date.current - rand(100).days, 
                        :title => Faker::Lorem.sentence(4), 
                        :body => Faker::Lorem.paragraphs(3).join("\n")
          end
          Post.recent.size.should == how_many
        end
      end

    end

    describe 'queries for recent or upcoming items' do

      before :all do
        # this is more a test for Publishable than it is for Story, but let's set the time to near the end of the day
        # this was causing a failing condition due to UTC/local TZ differences
        new_time = Time.local(2013, 01, 23, 22, 0, 0)
        Timecop.travel(new_time)

        (-5..5).each do |n|
          Post.create :published =>  Date.current + n.days, 
                      :title =>  Faker::Lorem.sentence(4), 
                      :body =>  Faker::Lorem.paragraphs(3).join("\n")
        end
      end

      after :all do
        # go back to the normal time and date
        Timecop.return
        Post.destroy_all
      end

      context 'recent' do

        it 'returns only published items' do
          Post.recent.should each be_published
        end

        it 'returns the requested number of items' do
          Post.recent(2).size.should == 2
        end

        it 'returns as many items as available if we request too many' do
          Post.recent(10).size.should == 6
        end

      end

      context 'upcoming' do

        it 'returns only unpublished items' do
          Post.upcoming.should each be_unpublished
        end

        it 'returns the requested number of items' do
          Post.upcoming(2).size.should == 2
        end

        it 'returns as many items as available if we request too many' do
          Post.upcoming(50).size.should == 5
        end

      end

    end

  end

  describe 'with an invalid configuration' do

    it 'should raise a configuration error when defined on an invalid column type' do
      expect {
        build_model :post do
          string :title
          text :body
          attr_accessible :title, :body
          validates :body, :title, :presence => true
          extend Publishable
          publishable :on => :title
        end
      }.to raise_error ActiveRecord::ConfigurationError
    end

    it 'should not raise a configuration error when the publish column not defined' do
      expect {
        build_model :post do
          string :title
          text :body
          attr_accessible :title, :body
          validates :body, :title, :presence => true
          extend Publishable
          publishable
        end
      }.to_not raise_error
    end

    it 'should not raise a configuration error when defined on a missing column' do
      expect {
        build_model :post do
          string :title
          text :body
          datetime :published
          attr_accessible :title, :body, :published
          validates :body, :title, :presence => true
          extend Publishable
          publishable :on => :foobar
        end
      }.to_not raise_error
    end

  end

end
