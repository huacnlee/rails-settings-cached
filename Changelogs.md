# For Rails 4.1 +

## 0.4.1

* ActiveRecord `table_name_prefix` support; #31

## 0.4.0

* Rails 4.1.0 compatibility.
* Setting.all -> Setting.get_all

# For Rails 4.0 +

## 0.3.2

* Enable destroy-ing a key with falsy data; #32
* Require Rails 4.0.0+;

## 0.3.1

* false value can't got back bug has fixed.

## 0.3.0

* Fix to work with Rails 4.0.0

# For Rails 3.x

## 0.2.4

* Setting.save_default method to direct write default value in database.
* fix mass-update bug.

## 0.2.3

* Fix bug with when key has cached a nil value, and then set a default value for that key, the default value can't right return.

## 0.2.2

* Add auto cache feature to all key visit.
