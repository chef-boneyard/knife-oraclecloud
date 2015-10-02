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

require 'chef/knife'
require 'chef/knife/cloud/server/list_command'
require 'chef/knife/cloud/server/list_options'
require 'chef/knife/cloud/oraclecloud_service'
require 'chef/knife/cloud/oraclecloud_service_helpers'
require 'chef/knife/cloud/oraclecloud_service_options'

class Chef
  class Knife
    class Cloud
      class OraclecloudServerList < ServerListCommand
        include OraclecloudServiceHelpers
        include OraclecloudServiceOptions

        banner 'knife oraclecloud server list'

        def before_exec_command
          @columns_with_info = [
            { label: 'Hostname',         key: 'hostname' },
            { label: 'Status',           key: 'status', value_callback: method(:format_status_value) },
            { label: 'Shape',            key: 'shape' },
            { label: 'Image',            key: 'image' },
            { label: 'Instance ID',      key: 'id' },
            { label: 'Orchestration ID', key: 'orchestration', value_callback: method(:format_orchestration_value) }
          ]

          @sort_by_field = 'name'
        end

        def format_status_value(status)
          status = status.downcase
          status_color = case status
                         when 'running'
                           :green
                         when 'stopped'
                           :red
                         else
                           :yellow
                         end
          ui.color(status, status_color)
        end

        def format_orchestration_value(orchestration)
          orchestration.nil? ? 'none' : orchestration
        end
      end
    end
  end
end
