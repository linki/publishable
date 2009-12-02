module Publishable
  TRUE_VALUES = ["true", true, "1", 1] unless const_defined?(:TRUE_VALUES)
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def publishable(column = :published_at, options = {})

      named_scope :published, lambda { |*args|
        if args.first.nil? || TRUE_VALUES.include?(args.first)
          { :conditions => ["#{quoted_table_name}.#{publishable_column} IS NOT NULL AND #{quoted_table_name}.#{publishable_column} <= ?", Time.now.utc] }
        else
          { :conditions => ["#{quoted_table_name}.#{publishable_column} IS NULL OR #{quoted_table_name}.#{publishable_column} > ?", Time.now.utc] }
        end
      }

      class_eval do
        class << self
          attr_accessor :publishable_column

          def unpublished
            published(false)
          end          
        end
        
        self.publishable_column = column

        def published?
          !!published
        end
        
        def unpublished?
          !published?
        end

        def published
          send(self.class.publishable_column) && send(self.class.publishable_column) <= Time.now
        end

        def published=(boolean)
          TRUE_VALUES.include?(boolean) ? publish : unpublish
        end
        
        def publish(time = Time.now)
          self.send("#{self.class.publishable_column}=", time.utc) unless published?
        end
        
        def unpublish
          self.send("#{self.class.publishable_column}=", nil)
        end
      
        def publish!
          unless published?
            publish
            save(false)
          end
        end

        def unpublish!
          unpublish
          update_attribute(self.class.publishable_column, published_at)
        end
      end
    end
  end
end