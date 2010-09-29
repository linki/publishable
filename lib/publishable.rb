require 'publishable/railtie' if defined?(Rails)

module Publishable
  module ClassMethods
    def publishable
      scope :published, lambda { |published = true|
        if published
          where('published_at IS NOT NULL AND published_at <= ?', Time.now.utc)
        else
          where('published_at IS     NULL OR  published_at >  ?', Time.now.utc)
        end
      }

      def self.unpublished
        published(false)
      end    
      
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def published?
      published_at ? published_at <= Time.now : false
    end

    def publish
      self.published_at = Time.now.utc unless published?
    end
    
    def publish!
      publish && save
    end
  end
end