class Create<%= class_name.pluralize %> < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :<%= plural_name%> do |t|
      t.string  :var,        null: false
      t.text    :value,      null: true
      t.timestamps
    end

    add_index :<%= plural_name %>, %i[var], unique: true
  end

  def self.down
    drop_table :<%= plural_name %>
  end
end
