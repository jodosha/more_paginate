require "rubygems"
require "active_support"
require "active_record"
require "action_view"
require "rack"
$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
require "lib/more_paginate"
load "init.rb"
require "spec/fixtures"

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database  => ":memory:"
ActiveRecord::Schema.define do
  create_table :events do |t|
    t.string :name
  end
end
