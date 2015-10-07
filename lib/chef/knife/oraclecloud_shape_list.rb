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
      class OraclecloudShapeList < ResourceListCommand
        include OraclecloudServiceHelpers
        include OraclecloudServiceOptions

        banner 'knife oraclecloud shape list'

        def before_exec_command
          @columns_with_info = [
            { label: 'Shape Name', key: 'name' },
            { label: 'CPUs',       key: 'cpus' },
            { label: 'RAM',        key: 'ram' },
            { label: 'I/O',        key: 'io' }
          ]

          @sort_by_field = 'name'
        end

        def query_resource
          service.list_shapes
        end
      end
    end
  end
end
