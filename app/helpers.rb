#!/usr/bin/env ruby

  def select_
  end

  def normalise_mac_address(mac)
    return nil unless mac
    mac.gsub!(/[:.]/, '')
    "#{mac[0..1]}:#{mac[2..3]}:#{mac[4..5]}:#{mac[6..7]}:#{mac[8..9]}:#{mac[10..11]}".upcase
  end

  # options:
  #
  # * switches
  # * network  name
  #

  def load_data

    switches = %w[ispsw03xa ispsw03xg ispsw03yc ispsw03yh]

    machine_config = YAML.load_file(File.join(DATA_DIR, 'network_interfaces.txt'))

    @network = Towser::Network.new('bunker')

    @network.add_switches(switches)

    switches.each do |switch|
      switch_config        = SwitchDataParser::Regexp::Config.parse(IO.readlines(File.join(CONFIG_DIR, switch)))
      bridge_address_table = SwitchDataParser::Regexp::BridgeAddressTable.parse(IO.readlines(File.join(BRIDGE_TABLE_DIR, switch)))

      @network.switches.each do |s|
        if s.identifier == switch
          s.load_switch_config(switch_config)
          s.load_bridge_address_table(bridge_address_table)
        end
      end
    end

    @network.add_machines(machine_config)
  end

  def translate_data
    @network.machines.machines.each do |machine|

      table_machine = Machine.create(:hostname => machine.identifier)

      next unless machine.interfaces

      machine.interfaces.each do |interface|
        active = 'true' unless interface.active_in_bond.nil?
        slaves = interface.slaves.join(',') unless interface.slaves.nil?

        table_machine_interface = MachineInterface.create(
            :interface        => interface.identifier,
            :mac_address      => normalise_mac_address(interface.mac_address),
            :member           => interface.member,
            :active_interface => interface.active_interface,
            :slaves           => slaves,
            :active_in_bond   => active,
            :machine          => table_machine,
        )

        next unless interface.ip_addresses

        interface.ip_addresses.each do |ip|
          IpAddress.create(
              :ip => ip,
              :machine_interface => table_machine_interface,
          )
        end
      end
    end

    [ @network ].each do |network|

      table_network = Network.create(:location => network.identifier)

      network.switches.each do |switch|

        table_switch = Switch.create(:hostname => switch.identifier, :network => table_network)

        switch.bridge_address_table.each do |entry|
          table_bridge_address_table = BridgeAddressTable.create(
            :identifier   => entry.identifier,
            :port         => entry.port,
            :stack_member => entry.stack_member,
            :speed        => entry.unit,
            :switch       => table_switch,
          )

          entry.vlans.each do |vlan|
            bridge_vlan = BridgeVlan.create(
              :vlan                 => vlan.identifier,
              :bridge_address_table => table_bridge_address_table,
            )

            next unless vlan.macs

            vlan.macs.each do |mac_data|
              Mac.create(
                :mac_address => normalise_mac_address(mac_data[:mac]),
                :mode        => mac_data[:mode],
                :bridge_vlan => bridge_vlan,
              )
            end
          end
        end

        switch.config.vlan_interfaces.each do |interface|
          VlanInterface.create(
            :vlan        => interface.vlan,
            :description => interface.description,
            :switch      => table_switch,
          )
        end

        switch.config.ethernet_interfaces.each do |interface|
          table_ethernet_interface = EthernetInterface.create(
            :description  => interface.description,
            :stack_member => interface.stack_member,
            :port         => interface.port,
            :speed        => interface.unit,
            :switch       => table_switch,
          )

          next unless interface.switchports

          interface.switchports.each do |switchport|

            permission, mode, tagged, port_type = nil, nil, nil, nil, nil

            mode = switchport.mode if switchport.respond_to?(:mode)

            if switchport.type
              if switchport.type.respond_to?(:tagged)
                tagged = 'true' if switchport.type.tagged.tagged if switchport.type.tagged.respond_to?(:tagged)
              end

              if switchport.type.respond_to?(:acceptable_frame_type)
                acceptable_frame_type = switchport.type.acceptable_frame_type.acceptable_frame_type if switchport.type.acceptable_frame_type.respond_to?(:acceptable_frame_type)
              end

              if switchport.type
                port_type = switchport.type.class.to_s.split(':')[-1].downcase
              end

              if switchport.type.respond_to?(:allowed)
                permission = switchport.type.allowed.allowed.class.to_s.split(':')[-1].downcase if switchport.type.allowed.respond_to?(:allowed)
              end
            end

            table_switchport = Switchport.create(
              :mode                  => mode,
              :port_type             => port_type,
              :permission            => permission,
              :ethernet_interface    => table_ethernet_interface,
              :tagged                => tagged,
              :acceptable_frame_type => acceptable_frame_type,
            )

            next unless switchport.type

            # cater for Access type which doesn't have permissions..
            if switchport.type.respond_to?(:vlans)

              switchport.type.vlans.each do |vlan|
                Vlan.create(
                  :vlan       => vlan.identifier,
                  :switchport => table_switchport,
                )
              end

            else

              next unless switchport.type.respond_to?(:allowed)
              next unless switchport.type.allowed.respond_to?(:allowed)
              next unless switchport.type.allowed.allowed.respond_to?(:vlans)

              switchport.type.allowed.allowed.vlans.each do |vlan|
                Vlan.create(
                  :vlan       => vlan.identifier,
                  :switchport => table_switchport,
                )
              end
            end
          end
        end
      end
    end
  end

## mac addresses are only associated with vlans - they should be associated with switchports too so 'access' mode shizzle will work.
## if a switchport is in 'access' mode is it considered attached to vlan 1 by default? - if so we can do some jiggerypokery
