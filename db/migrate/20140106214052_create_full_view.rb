class CreateFullView < ActiveRecord::Migration
  def up
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

  def down
    execute <<-SQL
      DROP VIEW full_views;
    SQL
  end
end
