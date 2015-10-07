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
require 'chef/knife/cloud/server/create_command'
require 'chef/knife/cloud/server/create_options'
require 'chef/knife/cloud/oraclecloud_service'
require 'chef/knife/cloud/oraclecloud_service_helpers'
require 'chef/knife/cloud/oraclecloud_service_options'

class Chef
  class Knife
    class Cloud
      class OraclecloudServerCreate < ServerCreateCommand
        include OraclecloudServiceOptions
        include OraclecloudServiceHelpers
        include ServerCreateOptions

        banner 'knife oraclecloud server create (options)'

        option :hostname,
               long:        '--hostname HOSTNAME',
               description: 'hostname of the server to be created',
               proc:        proc { |i| Chef::Config[:knife][:hostname] = i }

        option :shape,
               long:        '--shape SHAPE',
               description: 'shape name (i.e. size of instance) to be created',
               proc:        proc { |i| Chef::Config[:knife][:shape] = i }

        option :public_ip,
               long:        '--public-ip POOL_OR_RESERVATION_NAME',
               description: 'optional; "pool" to use the default public IP pool, or specify an IP reservation name to use for the public IP'

        option :label,
               long:        '--label LABEL',
               description: 'optional; text to use as label for the new instance and orchestration'

        option :sshkeys,
               long:        '--sshkeys SSHKEY1,SSHKEY2',
               description: 'optional; comma-separated list of ssh keys to enable for this instance. Key name must be user@domain.io/keyname.'

        def validate_params!
          super
          check_for_missing_config_values!(:image, :shape, :hostname)
        end

        def public_ip
          return nil unless locate_config_value(:public_ip)

          (locate_config_value(:public_ip) == 'pool') ? :pool : "ipreservation:#{locate_config_value(:public_ip)}"
        end

        def sshkeys
          return [] unless locate_config_value(:sshkeys)

          locate_config_value(:sshkeys).split(',').map { |key| service.prepend_identity_domain(key) }
        end

        def label
          locate_config_value(:label) ? locate_config_value(:label) : locate_config_value(:hostname)
        end

        def before_exec_command
          super

          @create_options = {
            name:             locate_config_value(:hostname),
            shape:            locate_config_value(:shape),
            image:            locate_config_value(:image),
            label:            label,
            public_ip:        public_ip,
            sshkeys:          sshkeys
          }
        end

        def ip_address
          locate_config_value(:public_ip) ? server.public_ip_addresses.first : server.ip_address
        end

        def before_bootstrap
          super

          config[:chef_node_name] = locate_config_value(:chef_node_name) ? locate_config_value(:chef_node_name) : server.name
          config[:bootstrap_ip_address] = ip_address
        end
      end
    end
  end
end
