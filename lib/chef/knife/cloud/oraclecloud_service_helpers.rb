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
      module OraclecloudServiceHelpers
        def create_service_instance
          Chef::Knife::Cloud::OraclecloudService.new(username:        locate_config_value(:oraclecloud_username),
                                                     password:        locate_config_value(:oraclecloud_password),
                                                     api_url:         locate_config_value(:oraclecloud_api_url),
                                                     identity_domain: locate_config_value(:oraclecloud_domain),
                                                     wait_time:       locate_config_value(:wait_time),
                                                     refresh_time:    locate_config_value(:request_refresh_rate),
                                                     private_cloud:   locate_config_value(:oraclecloud_private_cloud),
                                                     verify_ssl:      verify_ssl?)
        end

        def verify_ssl?
          !locate_config_value(:oraclecloud_disable_ssl_verify)
        end

        def check_for_missing_config_values!(*keys)
          missing = keys.select { |x| locate_config_value(x).nil? }

          unless missing.empty?
            ui.error("The following required parameters are missing: #{missing.join(', ')}")
            exit(1)
          end
        end
      end
    end
  end
end
