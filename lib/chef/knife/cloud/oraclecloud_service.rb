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

require 'chef/knife/cloud/exceptions'
require 'chef/knife/cloud/service'
require 'chef/knife/cloud/helpers'
require 'chef/knife/cloud/oraclecloud_service_helpers'
require 'oraclecloud'

class Chef
  class Knife
    class Cloud
      class OraclecloudService < Service # rubocop:disable Metrics/ClassLength
        include OraclecloudServiceHelpers

        attr_reader :wait_time, :refresh_time

        def initialize(options = {})
          super(options)

          @username        = options[:username]
          @password        = options[:password]
          @api_url         = options[:api_url]
          @identity_domain = options[:identity_domain]
          @verify_ssl      = options[:verify_ssl]
          @wait_time       = options[:wait_time]
          @refresh_time    = options[:refresh_time]
        end

        def connection
          @client ||= OracleCloud::Client.new(
            api_url:         @api_url,
            identity_domain: @identity_domain,
            username:        @username,
            password:        @password,
            verify_ssl:      @verify_ssl
          )
        end

        def prepend_identity_domain(path)
          "#{connection.full_identity_domain}/#{path}"
        end

        def create_server(options = {})
          orchestration = create_orchestration(options)
          orchestration.start
          ui.msg("Orchestration #{orchestration.name_with_container} started - waiting for it to complete...")
          wait_for_status(orchestration, 'ready')
          ui.msg("Orchestration started successfully.\n")
          orchestration_summary(orchestration)
          ui.msg('')

          servers = orchestration.instances
          raise CloudExceptions::ServerCreateError, 'The orchestration created more than one server, ' \
            'but we were only expecting 1' if servers.length > 1
          raise CloudExceptions::ServerCreateError, 'The orchestration did not create any servers' if servers.length == 0

          servers.first
        end

        def delete_server(instance_id)
          instance = get_server(instance_id)
          server_summary(instance)
          ui.msg('')

          unless instance.orchestration.nil?
            ui.error('Unable to delete this server.  Delete the orchestration instead.')
            exit(1)
          end

          ui.confirm('Do you really want to delete this server')

          ui.msg('Deleting the instance...')
          instance.delete

          ui.msg('Delete request complete.')
        end

        def create_orchestration(options)
          connection.orchestrations.create(
            name: options[:name],
            description: "#{options[:name]} by #{connection.username} via Knife",
            instances: [ instance_request(options) ]
          )
        end

        def delete_orchestration(orchestration_id)
          orchestration = get_orchestration(orchestration_id)
          orchestration_summary(orchestration)
          ui.msg('')

          ui.confirm('Do you really want to delete this orchestration')

          ui.msg('Stopping the orchestration and any instances...')
          orchestration.stop
          wait_for_status(orchestration, 'stopped')

          ui.msg('Deleting the orchestration and any instances...')
          orchestration.delete

          ui.msg('Delete request complete.')
        end

        def instance_request(options)
          connection.instance_request(
            name:      options[:name],
            shape:     options[:shape],
            imagelist: options[:image],
            sshkeys:   options[:sshkeys],
            label:     options[:label],
            public_ip: options[:public_ip]
          )
        end

        def list_servers
          connection.instances.all
        end

        def list_orchestrations
          connection.orchestrations.all
        end

        def list_images
          connection.imagelists.all
        end

        def list_shapes
          connection.shapes.all
        end

        def get_server(instance_id)
          connection.instances.by_name(instance_id)
        end

        def get_orchestration(orchestration_id)
          connection.orchestrations.by_name(orchestration_id)
        end

        def orchestration_summary(orchestration)
          msg_pair('Orchestration ID', orchestration.name_with_container)
          msg_pair('Description', orchestration.description)
          msg_pair('Status', orchestration.status)
          msg_pair('Instance Count', orchestration.instance_count)
        end

        def server_summary(server, _columns_with_info = nil)
          msg_pair('Server Label', server.label)
          msg_pair('Status', server.status)
          msg_pair('Hostname', server.hostname)
          msg_pair('IP Address', server.ip_address.nil? ? 'none' : server.ip_address)
          msg_pair('Public IP Addresses', server.public_ip_addresses.empty? ? 'none' : server.public_ip_addresses.join(', '))
          msg_pair('Image', server.image)
          msg_pair('Shape', server.shape)
          msg_pair('Orchestration', server.orchestration.nil? ? 'none' : server.orchestration)
        end

        def wait_for_status(item, requested_status)
          last_status = ''

          begin
            Timeout.timeout(wait_time) do
              loop do
                item.refresh
                current_status = item.status

                if current_status == requested_status
                  print "\n"
                  break
                end

                if last_status == current_status
                  print '.'
                else
                  last_status = current_status
                  print "\n"
                  print "Current status: #{current_status}."
                end

                sleep refresh_time
              end
            end
          rescue Timeout::Error
            ui.msg('')
            ui.error("Request did not complete in #{wait_time} seconds. Check the Oracle Cloud Web UI for more information.")
            exit 1
          end
        end
      end
    end
  end
end
