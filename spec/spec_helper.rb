require 'rubygems'
require 'bundler'
Bundler.setup

require 'active_support'
require 'active_record'
require 'action_view'
require 'action_view/template/handlers/erb'
require 'rack'
$:.unshift File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/more_paginate'
load 'init.rb'

def create_tables
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define do
    create_table :events, :force => true do |t|
      t.string :identifier
      t.string :name
      t.date   :start_on

      t.timestamps
    end

    create_table :people, :force => true do |t|
      t.string :identifier
      t.string :name

      t.timestamps
    end

    create_table :events_people, :force => true, :id => false do |t|
      t.references :event
      t.references :person
    end

    create_table :photos, :force => true do |t|
      t.references :event
      t.string     :identifier
      t.string     :title

      t.timestamps
    end
    
    create_table :tags, :force => true do |t|
      t.string :identifier
      t.string :name

      t.timestamps
    end

    create_table :taggings, :force => true do |t|
      t.references :taggable, :polymorphic => true
      t.references :tag

      t.timestamps
    end
  end
end

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new 'log/database.log'
create_tables
require 'spec/fixtures'