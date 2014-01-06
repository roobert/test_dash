#!/usr/bin/env ruby

class Network < ActiveRecord::Base
  has_many :switches
end

class Switch < ActiveRecord::Base
  belongs_to :network
  has_many :ethernet_interfaces
end

class BridgeAddressTable < ActiveRecord::Base
  belongs_to :switch
  has_many :bridge_vlans
end

class BridgeVlan < ActiveRecord::Base
  belongs_to :bridge_address_table
  has_many :macs
end

class Mac < ActiveRecord::Base
  belongs_to :bridge_vlan
end

class VlanInterface < ActiveRecord::Base
  belongs_to :switch
end

class EthernetInterface < ActiveRecord::Base
  belongs_to :switch
  has_many :switchports
end

class Switchport < ActiveRecord::Base
  belongs_to :ethernet_interface
  has_many :vlans
end

class Vlan < ActiveRecord::Base
  belongs_to :switchport
end

class SwitchView < ActiveRecord::Base; end
