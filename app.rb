#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'sass'
require 'active_record'
require 'sqlite3'
require 'awesome_print'
require 'pp'
require 'yaml'
require 'model'

Sinatra::Application.reset!

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/db.sql')

set :database, "sqlite3:///db/db.sql"

def view_switch_full(switch)
  SwitchView.where("switch" => switch)
end

def e(string)
  Rack::Utils.escape_html(string)
end

get '/css/:style.css' do
  scss :"#{params[:style]}"
end

get '/machines' do
  haml :machines
end

get '/all' do
  haml :all
end

get '/machines/:machine' do
  @machine = params[:machine]
  haml :machine
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
