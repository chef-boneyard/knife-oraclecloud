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

class Chef
  class Knife
    class Cloud
      module OraclecloudServiceOptions
        def self.included(includer)
          includer.class_eval do
            option :oraclecloud_api_url,
              long:        "--oraclecloud-api-url API_URL",
              description: "URL for the oraclecloud API server"

            option :oraclecloud_username,
              long:        "--oraclecloud-username USERNAME",
              description: "Username to use with the oraclecloud API"

            option :oraclecloud_password,
              long:        "--oraclecloud-password PASSWORD",
              description: "Password to use with the oraclecloud API"

            option :oraclecloud_domain,
              long:        "--oraclecloud-domain IDENTITYDOMAIN",
              description: "Identity domain to use with the oraclecloud API"

            option :oraclecloud_disable_ssl_verify,
              long:        "--oraclecloud-disable-ssl-verify",
              description: "Skip any SSL verification for the oraclecloud API",
              boolean:     true,
              default:     false

            option :oraclecloud_private_cloud,
              long:        "--oraclecloud-private-cloud",
              description: "Indicate the --oraclecloud-api-url is a private cloud endpoint",
              boolean:     true,
              default:     false

            option :request_refresh_rate,
              long:        "--request-refresh-rate SECS",
              description: "Number of seconds to sleep between each check of the request status, defaults to 2",
              default:     2,
              proc:        proc { |secs| secs.to_i }
          end
        end
      end
    end
  end
end
