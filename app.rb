#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'

Sinatra::Application.reset! 

require 'haml'
require 'sass'

require 'active_record'
require 'sqlite3'
require 'awesome_print'
require 'pp'
require 'yaml'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../towser/lib'))

require 'switch_data_parser'
require 'towser'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/db.sql')

DATA_DIR         = File.join(File.dirname(__FILE__), 'data')
CONFIG_DIR       = File.join(DATA_DIR, 'config')
BRIDGE_TABLE_DIR = File.join(DATA_DIR, 'bridge_address_table')

require_relative './app/model.rb'
require_relative './app/helpers.rb'

def view_switch_full(switch)
  SwitchView.where("switch" => switch)
end

def e(string)
  Rack::Utils.escape_html(string)
end

#load_data
#translate_data

get '/css/:style.css' do
  scss :"#{params[:style]}"
end

get '*' do
#  @data = view_switch_full('ispsw03xa')
  @data = SwitchView.all
  haml :content
end
