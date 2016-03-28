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
require "chef/knife"
require "chef/knife/cloud/oraclecloud_service"
require "chef/knife/cloud/oraclecloud_service_helpers"

class HelpersTester
  include Chef::Knife::Cloud::OraclecloudServiceHelpers
  attr_accessor :ui
end

describe "Chef::Knife::Cloud::OraclecloudServiceHelpers" do
  let(:tester) { HelpersTester.new }

  before do
    tester.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
  end

  describe '#create_service_instance' do
    it "creates a service instance" do
      allow(tester).to receive(:locate_config_value).with(:oraclecloud_username).and_return("test_user")
      allow(tester).to receive(:locate_config_value).with(:oraclecloud_password).and_return("test_password")
      allow(tester).to receive(:locate_config_value).with(:oraclecloud_api_url).and_return("https://cloud.oracle.com")
      allow(tester).to receive(:locate_config_value).with(:oraclecloud_domain).and_return("test_domain")
      allow(tester).to receive(:locate_config_value).with(:wait_time).and_return(300)
      allow(tester).to receive(:locate_config_value).with(:request_refresh_rate).and_return(5)
      allow(tester).to receive(:locate_config_value).with(:oraclecloud_private_cloud).and_return(false)
      allow(tester).to receive(:verify_ssl?).and_return(true)

      expect(Chef::Knife::Cloud::OraclecloudService).to receive(:new)
        .with(username:        "test_user",
              password:        "test_password",
              api_url:         "https://cloud.oracle.com",
              identity_domain: "test_domain",
              wait_time:       300,
              refresh_time:    5,
              private_cloud:   false,
              verify_ssl:      true)

      tester.create_service_instance
    end
  end

  describe '#verify_ssl?' do
    context "when oraclecloud_disable_ssl_verify is true" do
      it "returns false" do
        allow(tester).to receive(:locate_config_value).with(:oraclecloud_disable_ssl_verify).and_return(true)
        expect(tester.verify_ssl?).to be false
      end
    end

    context "when oraclecloud_disable_ssl_verify is false" do
      it "returns true" do
        allow(tester).to receive(:locate_config_value).with(:oraclecloud_disable_ssl_verify).and_return(false)
        expect(tester.verify_ssl?).to be true
      end
    end
  end

  describe '#check_for_missing_config_values!' do
    context "when all values exist" do
      it "does not raise an error" do
        allow(tester).to receive(:locate_config_value).with(:key1).and_return("value")
        allow(tester).to receive(:locate_config_value).with(:key2).and_return("value")
        expect(tester.ui).not_to receive(:error)
        expect { tester.check_for_missing_config_values!(:key1, :key2) }.not_to raise_error
      end
    end

    context "when a value does not exist" do
      it "prints an error and exits" do
        allow(tester).to receive(:locate_config_value).with(:key1).and_return("value")
        allow(tester).to receive(:locate_config_value).with(:key2).and_return(nil)
        expect(tester.ui).to receive(:error)
        expect { tester.check_for_missing_config_values!(:key1, :key2) }.to raise_error(SystemExit)
      end
    end
  end
end
