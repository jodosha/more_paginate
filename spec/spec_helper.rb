require "rubygems"
require "active_support"
require "active_record"
require "action_view"
require "rack"
$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
require "lib/more_paginate"
load "init.rb"
require "spec/fixtures"
