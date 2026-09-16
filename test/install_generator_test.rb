# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/settings/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests RailsSettings::InstallGenerator
  destination File.join(Dir.tmpdir, "rails-settings-cached-generator-test")
  setup :prepare_destination
  setup { RailsSettings::InstallGenerator.class_variable_set(:@@migrations, false) }

  test "generates the default Setting model and migration" do
    run_generator

    assert_file "app/models/setting.rb" do |content|
      assert_match(/^class Setting < RailsSettings::Base$/, content)
      assert_match(/cache_prefix \{ "v1" \}/, content)
      assert_valid_ruby content
    end

    assert_migration "db/migrate/create_settings.rb" do |content|
      assert_match(/^class CreateSettings < ActiveRecord::Migration\[#{Rails::VERSION::MAJOR}\.#{Rails::VERSION::MINOR}\]$/, content)
      assert_match(/create_table :settings do/, content)
      assert_match(/add_index :settings, %i\(var\), unique: true/, content)
      assert_valid_ruby content
    end
  end

  test "generates a model with a custom name" do
    run_generator %w[config]

    assert_file "app/models/config.rb", /^class Config < RailsSettings::Base$/
    assert_no_file "app/models/setting.rb"
    assert_migration "db/migrate/create_settings.rb"
  end

  test "generates a namespaced model" do
    run_generator %w[admin/setting]

    assert_file "app/models/admin/setting.rb", /^class Admin::Setting < RailsSettings::Base$/
  end

  test "names the migration with a timestamp" do
    with_timestamped_migrations(true) do
      run_generator
    end

    migration = Dir[File.join(destination_root, "db/migrate/*_create_settings.rb")].first
    assert_match(/\A\d{14}_create_settings\.rb\z/, File.basename(migration))
  end

  test "next_migration_number increments the timestamp for further migrations in the same run" do
    with_timestamped_migrations(true) do
      first = RailsSettings::InstallGenerator.next_migration_number(destination_root)
      assert_match(/\A\d{14}\z/, first)

      FileUtils.mkdir_p(File.join(destination_root, "db/migrate"))
      FileUtils.touch(File.join(destination_root, "db/migrate", "#{first}_create_settings.rb"))
      assert_equal first.to_i + 1, RailsSettings::InstallGenerator.next_migration_number(File.join(destination_root, "db/migrate"))
    end
  end

  test "next_migration_number uses sequential numbers without timestamped migrations" do
    with_timestamped_migrations(false) do
      assert_equal "001", RailsSettings::InstallGenerator.next_migration_number(destination_root)
    end
  end

  test "migration_version matches the current Rails version" do
    generator = RailsSettings::InstallGenerator.new(["setting"])
    assert_equal "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]", generator.migration_version
  end

  test "is found as settings:install" do
    assert_equal RailsSettings::InstallGenerator, Rails::Generators.find_by_namespace("settings:install")
  end

  private

  def assert_valid_ruby(content)
    RubyVM::InstructionSequence.compile(content)
  rescue SyntaxError => e
    flunk "Generated code is not valid Ruby: #{e.message}"
  end

  def with_timestamped_migrations(value)
    owner = ActiveRecord.respond_to?(:timestamped_migrations=) ? ActiveRecord : ActiveRecord::Base
    original = owner.timestamped_migrations
    owner.timestamped_migrations = value
    yield
  ensure
    owner.timestamped_migrations = original
  end
end
