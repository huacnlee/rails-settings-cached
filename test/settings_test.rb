#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../../test/test_helper'

#module SettingsDefaults
#  DEFAULTS = {:some_setting => 'foo'}
#end

class SettingsTest < Test::Unit::TestCase
  
	def setup
		Settings.create(:var => 'test',           :value => 'foo'.to_yaml)
		Settings.create(:var => 'secondary_test', :value => 'bar'.to_yaml)
	end
	
#  def test_defaults
#    assert_equal 'foo', Settings.some_setting
#    assert_nil Settings.find(:first, :conditions => ['var = ?', 'some_setting'])
#    
#    Settings.some_setting = 'bar'
#    assert_equal 'bar', Settings.some_setting
#    assert_not_nil Settings.find(:first, :conditions => ['var = ?', 'some_setting'])
#  end
  
	def test_get
		assert_setting 'foo', :test
		assert_setting 'bar', :secondary_test
	end
	
	def test_update
		assert_assign_setting '321', :test
	end
	
	def test_create
    assert_assign_setting '123', :onetwothree
	end
  
  def test_complex_serialization
    object = [1, '2', {:three => true}]
    Settings.object = object
    assert_equal object, Settings.reload.object
  end
  
  def test_serialization_of_float
    Settings.float = 0.01
    Settings.reload
    assert_equal 0.01, Settings.float
    assert_equal 0.02, Settings.float * 2
  end
  
  private
    def assert_setting(value, key)
      key = key.to_sym
      assert_equal value, eval("Settings.#{key}")
      assert_equal value, Settings[key]
      assert_equal value, Settings[key.to_s]
    end
    
    def assert_assign_setting(value, key)
      key = key.to_sym
      assert_equal value, eval("Settings.#{key} = value")
      assert_setting value, key
      eval("Settings.#{key} = nil")
      
      assert_equal value, (Settings[key] = value)
      assert_setting value, key
      Settings[key] = nil
      
      assert_equal value, (Settings[key.to_s] = value)
      assert_setting value, key
    end
end