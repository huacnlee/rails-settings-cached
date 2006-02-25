class Settings < ActiveRecord::Base
	
	def self.method_missing(method, *args)
		
		if var = find(:first, :conditions => ['var = ?', method.to_s])
			#varible exists, retrieve value
			
			var.value
			
		elsif method.to_s.include? '='
			#set a value for a variable
			
			var_name = method.to_s.gsub('=', '')
			value = args.first
			
			if var = find(:first, :conditions => ['var = ?', var_name])
				#var exists, set new value
				var.value = value
				var.save
				
			else
				#var does not exists, create new record
				
				var = self.create(
					:var => var_name,
					:value => value
				)
			end
			
			var.value
		else
			raise "Setting variable \"#{method.to_s}\" not found"
		end
	end
	
	def self.destroy(var_name)
		if var = find(:first, :conditions => ['var = ?', var_name.to_s])
			#varible exists, destroy row
			var.destroy
		else
			raise "Setting variable \"#{var_name}\" not found"
		end
	end
	
	def self.all
		#retrieve all settings as a hash
		vars = find(:all)
		
		result = {}
		vars.each do |record|
			result[record.var] = record.value
		end
		result.with_indifferent_access
	end
end


##Settings table migration:
#class CreateSettingsTable < ActiveRecord::Migration
#	def self.up
#		create_table :settings do |t|
#			t.column :var, :string, :null => false
#			t.column :value, :string, :null => true
#			t.column :created_at, :datetime
#			t.column :updated_at, :datetime
#		end
#	end
#
#	def self.down
#		drop_table :settings
#	end
#end