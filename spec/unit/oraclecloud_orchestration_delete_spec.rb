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

require "spec_helper"
require "chef/knife/oraclecloud_orchestration_delete"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OraclecloudOrchestrationDelete do
  let(:command) { described_class.new(%w{orch1 orch2}) }
  let(:service) { double("service") }

  before do
    allow(command).to receive(:service).and_return(service)
  end

  it_behaves_like Chef::Knife::Cloud::Command, described_class.new(%w{orch1 orch2})

  describe '#validate_params!' do
    context "when no orchestrations are provided" do
      let(:command) { described_class.new }

      it "prints an error and exits" do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    context "when orchestrations are provided" do
      it "does not print an error or raise an exception" do
        expect(command.ui).not_to receive(:error)
        expect { command.validate_params! }.not_to raise_error
      end
    end
  end

  describe '#execute_command' do
    it "calls delete_orchestration for each orchestration" do
      expect(service).to receive(:delete_orchestration).with("orch1")
      expect(service).to receive(:delete_orchestration).with("orch2")

      command.execute_command
    end
  end
end
