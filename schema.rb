#!/usr/bin/env ruby

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/db.sql')

ActiveRecord::Schema.define do
  create_table :networks do |t|
    t.column :location, :string
  end

  create_table :switches do |t|
    t.column :hostname, :string
    t.belongs_to :network
  end

  create_table :machines do |t|
    t.column :hostname, :string
  end

  create_table :machine_interfaces do |t|
    t.column :interface, :string
    t.column :mac_address, :string
    t.column :member, :string
    t.column :active_interface, :string
    t.column :slaves, :string
    t.column :active_in_bond, :string
    t.belongs_to :machine
  end

  create_table :ip_addresses do |t|
    t.column :ip, :string
    t.belongs_to :machine_interface
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
    t.column :tagged, :string
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
    t.column :mac_address, :string
    t.column :mode, :string
    t.belongs_to :bridge_vlan
    t.belongs_to :switchport
  end

  execute <<-SQL
    CREATE VIEW full_views AS
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
        macs.mac_address AS mac
      FROM
        switches
      INNER JOIN networks              ON switches.network_id                  = networks.id
      INNER JOIN ethernet_interfaces   ON ethernet_interfaces.switch_id        = switches.id
      INNER JOIN switchports           ON switchports.ethernet_interface_id    = ethernet_interfaces.id
      INNER JOIN vlans                 ON vlans.switchport_id                  = switchports.id
      INNER JOIN vlan_interfaces       ON vlan_interfaces.vlan                 = vlans.vlan
      INNER JOIN bridge_address_tables ON bridge_address_tables.switch_id      = switches.id
      INNER JOIN bridge_vlans          ON bridge_vlans.bridge_address_table_id = bridge_address_tables.id
      INNER JOIN macs                  ON macs.bridge_vlan_id                  = bridge_vlans.id;
  SQL

  execute <<-SQL
    CREATE VIEW second_views AS
      SELECT
        networks.location                 AS location,
        switches.hostname                 AS switch,
        ethernet_interfaces.stack_member  AS stack_member,
        ethernet_interfaces.speed         AS speed,
        ethernet_interfaces.port          AS port,
        ethernet_interfaces.description   AS port_description,
        switchports.mode                  AS mode,
        switchports.port_type             AS port_type,
        switchports.tagged                AS tagged,
        switchports.acceptable_frame_type AS acceptable_frame_type,
        switchports.permission            AS permission,
        vlans.vlan                        AS vlan,
        macs.mac_address                  AS mac,
        machines.hostname                 AS machine_hostname

      FROM
        networks 

      inner JOIN switches              ON  switches.network_id                  = networks.id
      inner JOIN ethernet_interfaces   ON  ethernet_interfaces.switch_id        = switches.id
      inner JOIN switchports           ON  switchports.ethernet_interface_id    = ethernet_interfaces.id
      left  JOIN vlans                 ON  vlans.switchport_id                  = switchports.id

      left  JOIN bridge_address_tables ON  bridge_address_tables.switch_id      = switches.id
                                       AND ethernet_interfaces.port             = bridge_address_tables.port
                                       AND ethernet_interfaces.speed            = bridge_address_tables.speed
                                       AND ethernet_interfaces.stack_member     = bridge_address_tables.stack_member

      left  JOIN bridge_vlans          ON  bridge_vlans.bridge_address_table_id = bridge_address_tables.id
                                       AND bridge_vlans.vlan                    = vlans.vlan

      left  JOIN macs                  ON  macs.bridge_vlan_id                  = bridge_vlans.id
      left  JOIN machine_interfaces    ON  machine_interfaces.mac_address       = macs.mac_address
      left  JOIN machines              ON  machine_interfaces.machine_id        = machines.id
  SQL

  execute <<-SQL
    CREATE VIEW machine_views AS
      SELECT
        machines.hostname AS hostname,
        machine_interfaces.interface AS interface,
        machine_interfaces.mac_address AS mac,
        machine_interfaces.member AS member,
        machine_interfaces.active_interface AS active_interface,
        machine_interfaces.slaves AS slaves,
        machine_interfaces.active_in_bond AS active_in_bond,
        ip_addresses.ip  AS ip
      FROM
        machines
      LEFT JOIN machine_interfaces ON machine_interfaces.machine_id     = machines.id
      LEFT JOIN ip_addresses       ON ip_addresses.machine_interface_id = machine_interfaces.id
  SQL
end
