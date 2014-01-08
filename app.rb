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
set :database, "sqlite3:///db/db.sql"

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

raise 'fatal error!' unless Network.table_exists?

if Network.all.length == 0
  load_data
  translate_data
end

get '/css/:style.css' do
  scss :"#{params[:style]}"
end

get '/all' do
  haml :all
end

get '/:network/:switch/:interface/' do
  @network   = params[:network]
  @switch    = params[:switch]
  @interface = params[:interface]

  haml :interface
end

get '/:network/:switch/?' do
  @network   = params[:network]
  @switch    = params[:switch]

  haml :interfaces
end

get '/:network/?' do
  @network = params[:network]

  haml :switches
end


get '/' do
  haml :networks
end





