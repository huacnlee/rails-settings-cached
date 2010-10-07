require 'rails/generators/migration'

    class SettingsGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
  
      argument :name, :type => :string, :default => "my_settings"
  
      source_root File.expand_path('../templates', __FILE__)  
  
      @@migrations = false
      
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          if @@migrations          
            (current_migration_number(dirname) + 1)
          else
            @@migrations = true
            Time.now.utc.strftime("%Y%m%d%H%M%S")
          end
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end  

      def settings      
        #generate(:model, name, "--skip-migration")
        template "model.rb", File.join("app/models",class_path,"#{file_name}.rb"), :force => true
        migration_template "migration.rb", "db/migrate/create_settings.rb"
      end
    end