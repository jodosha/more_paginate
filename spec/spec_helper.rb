require "rubygems"
require "active_support"
require "active_record"
require "action_view"
require "rack"
$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
require "lib/more_paginate"
load "init.rb"
require "spec/fixtures"

def create_tables
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define do
    create_table :events, :force => true do |t|
      t.string :identifier
      t.string :name
    end
  end
end

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database  => ":memory:"
ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new "log/database.log"
create_tables
