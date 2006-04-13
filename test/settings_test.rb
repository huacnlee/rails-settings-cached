#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SettingsTest < Test::Unit::TestCase
	
	def setup
		Settings.create(:var => 'test',           :value => 'foo'.to_yaml)
		Settings.create(:var => 'secondary_test', :value => 'bar'.to_yaml)
	end
	
  def test_defaults
    Settings::DEFAULT_VALUES.merge!({:some_setting => 'foo'})
    assert_equal 'foo', Settings.some_setting
    assert_nil Settings.find(:first, :conditions => ['var = ?', 'some_setting'])
    
    Settings.some_setting = 'bar'
    assert_equal 'bar', Settings.some_setting
    assert_not_nil Settings.find(:first, :conditions => ['var = ?', 'some_setting'])
  end
  
	def test_get
		assert_equal 'foo', Settings.test
		assert_equal 'foo', Settings[:test]
		assert_equal 'foo', Settings['test']
		
		assert_equal 'bar', Settings.secondary_test
		assert_equal 'bar', Settings[:secondary_test]
		assert_equal 'bar', Settings['secondary_test']
	end
	
	def test_set
		assert_equal '321', Settings.test = '321'
		assert_equal '321', Settings[:test] = '321'
		assert_equal '321', Settings['test'] = '321'
		
		assert_equal '321', Settings.test
	end
	
	def test_create
		assert_equal '123', Settings.onetwothree = '123'
		assert_equal '123', Settings[:onetwothree] = '123'
		assert_equal '123', Settings['onetwothree'] = '123'
		
		assert_equal '123', Settings.onetwothree
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
end
