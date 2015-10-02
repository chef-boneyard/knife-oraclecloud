#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'
require 'chef/knife/oraclecloud_server_create'
require 'support/shared_examples_for_servercreatecommand'

describe Chef::Knife::Cloud::OraclecloudServerCreate do
  argv = []
  argv += %w(--image /path/to/test_image)
  argv += %w(--shape test_shape)
  argv += %w(--hostname test_hostname)
  argv += %w(--public-ip pool)
  argv += %w(--sshkeys user/test_key)
  argv += %w(--bootstrap-protocol ssh)
  argv += %w(--ssh-password test_password)

  let(:command) { described_class.new(argv) }
  let(:service) { double('service') }
  let(:server)  { double('server') }

  before do
    allow(command).to receive(:service).and_return(service)
    allow(command).to receive(:server).and_return(server)
  end

  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, described_class.new

  describe '#validate_params!' do
    it 'checks for missing config values' do
      expect(command).to receive(:check_for_missing_config_values!).with(:image, :shape, :hostname)

      command.validate_params!
    end
  end

  describe '#public_ip' do
    it 'returns nil if no public IP is requested' do
      allow(command).to receive(:locate_config_value).with(:public_ip).and_return(nil)

      expect(command.public_ip).to eq(nil)
    end

    it 'returns :pool if a pool is specified' do
      allow(command).to receive(:locate_config_value).with(:public_ip).and_return('pool')

      expect(command.public_ip).to eq(:pool)
    end

    it 'returns an IP reservation name if something other than pool is specified' do
      allow(command).to receive(:locate_config_value).with(:public_ip).and_return('reserve1')

      expect(command.public_ip).to eq('ipreservation:reserve1')
    end
  end

  describe '#sshkeys' do
    it 'returns an empty array if no ssh keys are specified' do
      allow(command).to receive(:locate_config_value).with(:sshkeys).and_return(nil)

      expect(command.sshkeys).to eq([])
    end

    it 'returns an array of properly formatted keys' do
      allow(command).to receive(:locate_config_value).with(:sshkeys).and_return('key1,key2')
      allow(service).to receive(:prepend_identity_domain).with('key1').and_return('domain/key1')
      allow(service).to receive(:prepend_identity_domain).with('key2').and_return('domain/key2')

      expect(command.sshkeys).to eq([ 'domain/key1', 'domain/key2' ])
    end
  end

  describe '#label' do
    it 'returns the label if it has been provided' do
      allow(command).to receive(:locate_config_value).with(:label).and_return('test_label')

      expect(command.label).to eq('test_label')
    end

    it 'returns the hostname if no label has been provided' do
      allow(command).to receive(:locate_config_value).with(:label).and_return(nil)
      allow(command).to receive(:locate_config_value).with(:hostname).and_return('test_hostname')

      expect(command.label).to eq('test_hostname')
    end
  end

  describe '#ip_address' do
    it 'defaults to a public IP if a public IP was requested' do
      allow(command).to receive(:locate_config_value).with(:public_ip).and_return('pool')
      allow(server).to receive(:public_ip_addresses).and_return([ '1.2.3.4' ])

      expect(command.ip_address).to eq('1.2.3.4')
    end

    it 'returns the server private IP if a public IP was not requested' do
      allow(command).to receive(:locate_config_value).with(:public_ip).and_return(nil)
      allow(server).to receive(:ip_address).and_return('4.3.2.1')

      expect(command.ip_address).to eq('4.3.2.1')
    end
  end
end
