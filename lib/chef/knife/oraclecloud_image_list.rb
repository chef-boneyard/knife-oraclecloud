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

require 'chef/knife'
require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/cloud/oraclecloud_service'
require 'chef/knife/cloud/oraclecloud_service_helpers'
require 'chef/knife/cloud/oraclecloud_service_options'

class Chef
  class Knife
    class Cloud
      class OraclecloudImageList < ResourceListCommand
        include OraclecloudServiceHelpers
        include OraclecloudServiceOptions

        banner 'knife oraclecloud image list'

        def before_exec_command
          @columns_with_info = [
            { label: 'Image Name',  key: 'name' },
            { label: 'Description', key: 'description' }
          ]

          @sort_by_field = 'name'
        end

        def query_resource
          service.list_images
        end

        def format_status_value(status)
          status = status.downcase
          status_color = case status
                         when 'ready'
                           :green
                         when 'stopped'
                           :red
                         else
                           :yellow
                         end

          ui.color(status, status_color)
        end
      end
    end
  end
end
