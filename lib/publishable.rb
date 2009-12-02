module Publishable
  TRUE_VALUES = ["true", true, "1", 1] unless const_defined?(:TRUE_VALUES)
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def publishable(column = :published_at, options = {})

      named_scope :published, lambda { |*args|
        if args.first.nil? || TRUE_VALUES.include?(args.first)
          { :conditions => ["#{quoted_table_name}.#{quoted_publishable_column_name} IS NOT NULL AND #{quoted_table_name}.#{quoted_publishable_column_name} <= ?", Time.now.utc] }
        else
          { :conditions => ["#{quoted_table_name}.#{quoted_publishable_column_name} IS NULL OR #{quoted_table_name}.#{quoted_publishable_column_name} > ?", Time.now.utc] }
        end
      }

      class_eval do
        class << self
          attr_accessor :publishable_column_name

          def unpublished
            published(false)
          end
          
          def quoted_publishable_column_name
            ActiveRecord::Base.connection.quote_column_name(publishable_column_name)
          end
        end
        
        self.publishable_column_name = column

        def published?
          !!published
        end
        
        def unpublished?
          !published?
        end

        def published
          send(self.class.publishable_column_name) && send(self.class.publishable_column_name) <= Time.now
        end

        def published=(boolean)
          TRUE_VALUES.include?(boolean) ? publish : unpublish
        end
        
        def publish(time = Time.now)
          self.send("#{self.class.publishable_column_name}=", time.utc) unless published?
        end
        
        def unpublish
          self.send("#{self.class.publishable_column_name}=", nil)
        end
      
        def publish!
          unless published?
            publish
            save(false)
          end
        end

        def unpublish!
          unpublish
          update_attribute(self.class.publishable_column_name, send(publishable_column_name))
        end
      end
    end
  end
end