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
require 'chef/knife/oraclecloud_orchestration_show'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OraclecloudOrchestrationShow do
  let(:command) { described_class.new(%w(orch1)) }
  let(:service) { double('service') }

  before do
    allow(command).to receive(:service).and_return(service)
  end

  it_behaves_like Chef::Knife::Cloud::Command, described_class.new

  describe '#validate_params!' do
    context 'when no orchestration is provided' do
      let(:command) { described_class.new }
      it 'print an error and exits' do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    context 'when more than one orchestration is provided' do
      let(:command) { described_class.new(%w(orch1 orch2)) }
      it 'print an error and exits' do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    context 'when one orchestration is provided' do
      it 'does not print an error and does not exit' do
        expect(command.ui).not_to receive(:error)
        expect { command.validate_params! }.not_to raise_error
      end
    end
  end

  describe '#execute_command' do
    let(:orchestration) { double('orchestration') }
    let(:ui)            { double('ui') }
    let(:instance1)     { double('instance1') }
    let(:instance2)     { double('instance2') }
    let(:instances)     { [ instance1, instance2 ] }

    before do
      allow(command).to receive(:ui).and_return(ui)
      allow(ui).to receive(:msg)
      allow(ui).to receive(:color)
      allow(service).to receive(:orchestration_summary)
      allow(service).to receive(:server_summary)
      allow(service).to receive(:get_orchestration).and_return(orchestration)
      allow(orchestration).to receive(:instances).and_return(instances)
      allow(instance1).to receive(:id)
      allow(instance2).to receive(:id)
    end

    it 'retrieves the orchestration' do
      expect(service).to receive(:get_orchestration).with('orch1').and_return(orchestration)

      command.execute_command
    end

    it 'outputs the orchestration summary' do
      expect(service).to receive(:orchestration_summary).with(orchestration)

      command.execute_command
    end

    it 'outputs a server summary for each instance' do
      expect(service).to receive(:server_summary).with(instance1)
      expect(service).to receive(:server_summary).with(instance2)

      command.execute_command
    end
  end
end
