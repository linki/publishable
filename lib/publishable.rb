require 'publishable/railtie' if defined?(Rails)

module Publishable
  def self.extended(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def publishable(options = {})
      column_name = (options[:on] || :published_at).to_s

      if respond_to?(:scope)
        scope :published, lambda { |time = Time.now|
          where("#{column_name} IS NOT NULL AND #{column_name} <= ?", time.utc)
        }

        scope :unpublished, lambda { |time = Time.now|
          where("#{column_name} IS NULL OR #{column_name} > ?", time.utc)
        }
      end
      
      class_eval <<-EVIL, __FILE__, __LINE__ + 1
        def published?(time = Time.now)
          #{column_name} ? #{column_name} <= time : false
        end

        def publish(time = Time.now)
          self.#{column_name} = time unless published?(time)
        end

        def publish!(time = Time.now)
          publish(time) && (!respond_to?(:save) || save)
        end        
      EVIL
    end
  end
end