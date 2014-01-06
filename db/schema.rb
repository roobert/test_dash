#!/usr/bin/env ruby

ActiveRecord::Schema.define do
  create_table :networks do |t|
    t.column :location, :string
  end

  create_table :switches do |t|
    t.column :hostname, :string
    t.belongs_to :network
  end

  create_table :vlan_interfaces do |t|
    t.column :description, :string
    t.column :vlan, :int
    t.belongs_to :switch
  end

  create_table :ethernet_interfaces do |t|
    t.column :description, :string
    t.column :port, :int
    t.column :stack_member, :int
    t.column :speed, :string
    t.belongs_to :switch
  end

  create_table :switchports do |t|
    t.column :mode, :string
    t.column :port_type, :string
    t.column :tagged, :boolean
    t.column :acceptable_frame_type, :string
    t.column :permission, :string
    t.belongs_to :ethernet_interface
  end

  create_table :vlans do |t|
    t.column :vlan, :int
    t.belongs_to :switchport
  end

  create_table :bridge_address_tables do |t|
    t.column :identifier, :string
    t.column :port, :int
    t.column :stack_member, :int
    t.column :speed, :string
    t.belongs_to :switch
  end

  create_table :bridge_vlans do |t|
    t.column :vlan, :int
    t.belongs_to :bridge_address_table
  end

  create_table :macs do |t|
    t.column :mac, :string
    t.column :mode, :string
    t.belongs_to :bridge_vlan
  end

  execute <<-SQL
    CREATE VIEW view_full AS
      SELECT
        networks.location AS location,
        switches.hostname AS switch,
        ethernet_interfaces.stack_member AS stack_member,
        ethernet_interfaces.speed AS speed,
        ethernet_interfaces.port AS port,
        ethernet_interfaces.description AS port_description,
        switchports.mode AS mode,
        switchports.port_type AS port_type,
        switchports.tagged AS tagged,
        switchports.acceptable_frame_type AS acceptable_frame_type,
        switchports.permission AS permission,
        vlans.vlan AS vlan,
        vlan_interfaces.description AS vlan_description,
        macs.mac AS mac
      FROM
        switches
      INNER JOIN networks              ON switches.network_id                  = networks.id
      INNER JOIN ethernet_interfaces   ON ethernet_interfaces.switch_id        = switches.id
      INNER JOIN switchports           ON switchports.ethernet_interface_id    = ethernet_interfaces.id
      INNER JOIN vlans                 ON vlans.switchport_id                  = switchports.id
      INNER JOIN vlan_interfaces       ON vlan_interfaces.vlan                 = vlans.vlan
      INNER JOIN bridge_address_tables ON bridge_address_tables.switch_id      = switches.id
      INNER JOIN bridge_vlans          ON bridge_vlans.bridge_address_table_id = bridge_address_tables.id
      INNER JOIN macs                  ON macs.bridge_vlan_id                  = bridge_vlans.id
  SQL
end
