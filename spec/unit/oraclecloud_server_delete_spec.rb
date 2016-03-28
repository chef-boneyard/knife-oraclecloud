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
require "chef/knife/oraclecloud_server_delete"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OraclecloudServerDelete do
  let(:command) { described_class.new(%w{server1}) }
  let(:service) { double("service") }
  let(:server)  { double("server") }

  it_behaves_like Chef::Knife::Cloud::Command, described_class.new(%w{server1})

  it "executes the correct methods in the overrided execute_command" do
    allow(command).to receive(:service).and_return(service)
    allow(server).to receive(:label).and_return("test_label")

    expect(service).to receive(:get_server).with("server1").and_return(server)
    expect(service).to receive(:delete_server).with("server1")
    expect(command).to receive(:delete_from_chef).with("test_label")

    command.execute_command
  end
end
