require 'publishable/railtie' if defined?(Rails)

module Publishable
  module ClassMethods
    def publishable
      scope :published, lambda { |time = Time.now|
        where('published_at IS NOT NULL AND published_at <= ?', time.utc)
      }

      scope :unpublished, lambda { |time = Time.now|
        where('published_at IS NULL OR published_at > ?', time.utc)
      }
      
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def published?(time = Time.now)
      published_at ? published_at <= time : false
    end

    def publish(time = Time.now)
      self.published_at = time unless published?
    end
    
    def publish!(time = Time.now)
      publish(time) && save
    end
  end
end