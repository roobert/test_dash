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

def e(string)
  Rack::Utils.escape_html(string)
end

helpers do
  def network_view(location)
    NetworkView.where('location like (?)', location)
  end

  def switch_view(location, switch)
#SwitchView.where(switch: switch)
    NetworkView.where('location like (?) and switch like (?)', location, switch)
  end

  def port_view(stack_member, speed, port)
    PortView.where(stack_member: stack_member, speed: speed, port: port)
  end
end

get '/css/:style.css' do
  scss :"#{params[:style]}"
end

get '/machines' do
  haml :machines
end

get '/all' do
  @data  = network_view('%')

  haml :network
end

get '/:network/?' do
  @data  = network_view(params[:network])

  haml :network
end

get '/:network/:switch/?' do
  @data = switch_view(params[:network], params[:switch])

  haml :network
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


get '/' do
  haml :networks
end
