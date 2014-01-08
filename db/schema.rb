# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140106214052) do

  create_table "bridge_address_tables", force: true do |t|
    t.string  "identifier"
    t.integer "port"
    t.integer "stack_member"
    t.string  "speed"
    t.integer "switch_id"
  end

  create_table "bridge_vlans", force: true do |t|
    t.integer "vlan"
    t.integer "bridge_address_table_id"
  end

  create_table "ethernet_interfaces", force: true do |t|
    t.string  "description"
    t.integer "port"
    t.integer "stack_member"
    t.string  "speed"
    t.integer "switch_id"
  end

  create_table "macs", force: true do |t|
    t.string  "mac"
    t.string  "mode"
    t.integer "bridge_vlan_id"
  end

  create_table "networks", force: true do |t|
    t.string "location"
  end

  create_table "switches", force: true do |t|
    t.string  "hostname"
    t.integer "network_id"
  end

  create_table "switchports", force: true do |t|
    t.string  "mode"
    t.string  "port_type"
    t.boolean "tagged"
    t.string  "acceptable_frame_type"
    t.string  "permission"
    t.integer "ethernet_interface_id"
  end

  create_table "vlan_interfaces", force: true do |t|
    t.string  "description"
    t.integer "vlan"
    t.integer "switch_id"
  end

  create_table "vlans", force: true do |t|
    t.integer "vlan"
    t.integer "switchport_id"
  end

end
