require 'puppet'
require 'spec_helper'
require 'puppet/provider/zaqar'

klass = Puppet::Provider::Zaqar

describe Puppet::Provider::Zaqar do
  after :each do
    klass.reset
  end
end
