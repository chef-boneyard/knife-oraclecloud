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
require "chef/knife/oraclecloud_orchestration_list"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OraclecloudOrchestrationList do
  let(:command) { described_class.new }
  let(:service) { double("service") }

  before do
    allow(command).to receive(:service).and_return(service)
  end

  it_behaves_like Chef::Knife::Cloud::Command, described_class.new

  describe '#query_resource' do
    it "calls list_orchestrations" do
      expect(service).to receive(:list_orchestrations)
      command.query_resource
    end
  end

  describe '#format_status_value' do
    it "returns green when the status is ready" do
      expect(command.ui).to receive(:color).with("ready", :green)
      command.format_status_value("ready")
    end

    it "returns red when the status is stopped" do
      expect(command.ui).to receive(:color).with("stopped", :red)
      command.format_status_value("stopped")
    end

    it "returns yellow when the status is something random" do
      expect(command.ui).to receive(:color).with("random", :yellow)
      command.format_status_value("random")
    end
  end
end
