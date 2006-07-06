class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :settings, :force => true do |t|
        t.column :var, :string, :null => false
        t.column :value, :text, :null => true
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :settings
  end
end
