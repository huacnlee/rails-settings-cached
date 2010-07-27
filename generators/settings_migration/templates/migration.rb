class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :settings, :force => true do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :object_id, :null => true
      t.string :object_type, :limit => 30, :null => true
      t.timestamps
    end
    
    add_index :settings, [ :object_type, :object_id, :var ], :uniq => true
  end

  def self.down
    drop_table :settings
  end
end
