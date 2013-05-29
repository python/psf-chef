attribute :name, :kind_of => String, :name_attribute => true
attribute :count, :kind_of => Integer, :default => 1
attribute :minute, :kind_of => [Integer, String], :default => '*'
attribute :hour, :kind_of => [Integer, String], :default => '*'
attribute :day, :kind_of => [Integer, String], :default => '*'
attribute :month, :kind_of => [Integer, String], :default => '*'
attribute :weekday, :kind_of => [Integer, String], :default => '*'
