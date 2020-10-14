# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"

module RailsSettings
  class InstallGenerator < Rails::Generators::NamedBase
    namespace "settings:install"
    desc "Generate RailsSettings files."
    include Rails::Generators::Migration

    argument :name, type: :string, default: "setting"

    source_root File.expand_path("templates", __dir__)

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
        format "%.3d", current_migration_number(dirname) + 1
      end
    end

    def install_setting
      template "model.rb", File.join("app/models", class_path, "#{file_name}.rb")
      migration_template "migration.rb", "db/migrate/create_settings.rb", migration_version: migration_version
    end

    def rails_version_major
      Rails::VERSION::MAJOR
    end

    def rails_version_minor
      Rails::VERSION::MINOR
    end

    def migration_version
      "[#{rails_version_major}.#{rails_version_minor}]" if rails_version_major >= 5
    end
  end
end
