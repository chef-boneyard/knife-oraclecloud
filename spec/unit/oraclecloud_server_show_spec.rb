# frozen_string_literal: true

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
require 'chef/knife/oraclecloud_server_show'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OraclecloudServerShow do
  let(:command) { described_class.new(%w[server1]) }
  let(:service) { double('service') }

  before do
    allow(command).to receive(:service).and_return(service)
  end

  it_behaves_like Chef::Knife::Cloud::Command, described_class.new

  describe '#validate_params!' do
    context 'when no server is provided' do
      let(:command) { described_class.new }
      it 'print an error and exits' do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    context 'when more than one server is provided' do
      let(:command) { described_class.new(%w[server1 server2]) }
      it 'print an error and exits' do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    context 'when one server is provided' do
      it 'does not print an error and does not exit' do
        expect(command.ui).not_to receive(:error)
        expect { command.validate_params! }.not_to raise_error
      end
    end
  end
end
