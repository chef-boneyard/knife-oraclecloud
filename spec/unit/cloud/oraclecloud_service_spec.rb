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
require 'spec_helper'
require 'chef/knife'
require 'chef/knife/cloud/exceptions'
require 'chef/knife/cloud/oraclecloud_service'
require 'support/shared_examples_for_service'

describe Chef::Knife::Cloud::OraclecloudService do
  let(:service) do
    Chef::Knife::Cloud::OraclecloudService.new(username:        'myuser',
                                               password:        'mypassword',
                                               api_url:         'https://cloud.oracle.com',
                                               identity_domain: 'mydomain',
                                               verify_ssl:      true)
  end

  before do
    service.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    allow(service.ui).to receive(:msg)
  end

  describe '#connection' do
    it 'creates an OracleCloud::Client instance' do
      expect(service.connection).to be_an_instance_of(OracleCloud::Client)
    end
  end

  describe '#prepend_identity_domain' do
    let(:connection) { double('connection') }
    it 'prepends the identity domain' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:compute_identity_domain).and_return('test_domain')

      expect(service.prepend_identity_domain('foo')).to eq('test_domain/foo')
    end
  end

  describe '#create_server' do
    let(:orchestration) { double('orchestration') }
    let(:instance)      { double('instance') }
    let(:options)       { { key: 'value' } }

    before do
      allow(service).to receive(:create_orchestration).and_return(orchestration)
      allow(orchestration).to receive(:start)
      allow(orchestration).to receive(:name_with_container)
      allow(orchestration).to receive(:instances).and_return([ instance ])
      allow(service).to receive(:wait_for_status)
      allow(service).to receive(:orchestration_summary)
    end

    it 'creates the orchestration' do
      expect(service).to receive(:create_orchestration).with(options)

      service.create_server(options)
    end

    it 'starts the orchestration' do
      expect(orchestration).to receive(:start)

      service.create_server(options)
    end

    it 'waits for the orchestration to become ready' do
      expect(service).to receive(:wait_for_status).with(orchestration, 'ready')

      service.create_server(options)
    end

    it 'prints out an orchestration summary' do
      expect(service).to receive(:orchestration_summary).with(orchestration)

      service.create_server(options)
    end

    it 'gathers the instances from the orchestration' do
      expect(orchestration).to receive(:instances).and_return([ instance ])

      service.create_server(options)
    end

    it 'returns the instance to the caller' do
      expect(service.create_server(options)).to eq(instance)
    end

    context 'when more than one instance is returned' do
      it 'raises an exception' do
        allow(orchestration).to receive(:instances).and_return(%w(instance1 instance2))

        expect { service.create_server(options) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      end
    end

    context 'when more no instances are returned' do
      it 'raises an exception' do
        allow(orchestration).to receive(:instances).and_return([])

        expect { service.create_server(options) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      end
    end
  end

  describe '#delete_server' do
    let(:server) { double('server') }

    before do
      allow(service).to receive(:get_server).and_return(server)
      allow(service).to receive(:server_summary)
      allow(server).to receive(:orchestration)
      allow(server).to receive(:delete)
      allow(service.ui).to receive(:confirm)
    end

    it 'fetches the server' do
      expect(service).to receive(:get_server).with('server1')

      service.delete_server('server1')
    end

    it 'prints out a server summary' do
      expect(service).to receive(:server_summary).with(server)

      service.delete_server('server1')
    end

    it 'confirms that the user wishes to actually delete' do
      expect(service.ui).to receive(:confirm).with('Do you really want to delete this server')

      service.delete_server('server1')
    end

    it 'deletes the server' do
      expect(server).to receive(:delete)

      service.delete_server('server1')
    end

    context 'when the server has no orchestration' do
      it 'does not print an error or raise an exception' do
        expect(service.ui).not_to receive(:error)
        expect { service.delete_server('server1') }.not_to raise_error
      end
    end

    context 'when the server is part of an orchestration' do
      it 'prints an error and exits' do
        allow(server).to receive(:orchestration).and_return('test_orch')
        expect(service.ui).to receive(:error)
        expect { service.delete_server('server1') }.to raise_error(SystemExit)
      end
    end
  end

  describe '#create_orchestration' do
    let(:connection)       { double('connection') }
    let(:orchestration)    { double('orchestration') }
    let(:orchestrations)   { double('orchestrations') }
    let(:instance_request) { double('instance_request') }
    let(:options)          { { name: 'test_name' } }

    it 'creates an orchestration instance and returns it' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:orchestrations).and_return(orchestrations)
      allow(connection).to receive(:username).and_return('test_username')

      expect(service).to receive(:instance_request).with(options).and_return(instance_request)
      expect(orchestrations).to receive(:create).with(name: 'test_name',
                                                      description: 'test_name by test_username via Knife',
                                                      instances: [ instance_request ])
        .and_return(orchestration)
      expect(service.create_orchestration(options)).to eq(orchestration)
    end
  end

  describe '#delete_orchestration' do
    let(:orchestration) { double('orchestration') }

    before do
      allow(service).to receive(:get_orchestration).and_return(orchestration)
      allow(service).to receive(:orchestration_summary)
      allow(service).to receive(:wait_for_status)
      allow(service.ui).to receive(:confirm)
      allow(orchestration).to receive(:stop)
      allow(orchestration).to receive(:delete)
    end

    it 'fetches the orchestration' do
      expect(service).to receive(:get_orchestration).with('orch1').and_return(orchestration)

      service.delete_orchestration('orch1')
    end

    it 'prints an orchestration summary' do
      expect(service).to receive(:orchestration_summary).with(orchestration)

      service.delete_orchestration('orch1')
    end

    it 'confirms that the user wishes to actually delete' do
      expect(service.ui).to receive(:confirm).with('Do you really want to delete this orchestration')

      service.delete_orchestration('orch1')
    end

    it 'stops the orchestration' do
      expect(orchestration).to receive(:stop)

      service.delete_orchestration('orch1')
    end

    it 'deletes the orchestration' do
      expect(orchestration).to receive(:delete)

      service.delete_orchestration('orch1')
    end
  end

  describe '#instance_request' do
    let(:connection)       { double('connection') }
    let(:instance_request) { double('instance_request') }
    let(:options) do
      {
        name:      'test_name',
        shape:     'test_shape',
        image:     'test_imagelist',
        sshkeys:   'test_sshkeys',
        label:     'test_label',
        public_ip: 'test_public_ip'
      }
    end

    it 'creates an instance request and returns it' do
      allow(service).to receive(:connection).and_return(connection)
      expect(connection).to receive(:instance_request).with(name:      'test_name',
                                                            shape:     'test_shape',
                                                            imagelist: 'test_imagelist',
                                                            sshkeys:   'test_sshkeys',
                                                            label:     'test_label',
                                                            public_ip: 'test_public_ip')
        .and_return(instance_request)
      expect(service.instance_request(options)).to eq(instance_request)
    end
  end

  describe '#list_servers' do
    let(:connection) { double('connection') }
    let(:instances)  { double('instances') }
    it 'retrieves the instances and returns them' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:instances).and_return(instances)

      expect(instances).to receive(:all).and_return('list_of_instances')
      expect(service.list_servers).to eq('list_of_instances')
    end
  end

  describe '#list_orchestrations' do
    let(:connection)     { double('connection') }
    let(:orchestrations) { double('orchestrations') }
    it 'retrieves the orchestrations and returns them' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:orchestrations).and_return(orchestrations)

      expect(orchestrations).to receive(:all).and_return('list_of_orchestrations')
      expect(service.list_orchestrations).to eq('list_of_orchestrations')
    end
  end

  describe '#list_images' do
    let(:connection) { double('connection') }
    let(:images)     { double('images') }
    it 'retrieves the images and returns them' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:imagelists).and_return(images)

      expect(images).to receive(:all).and_return('list_of_images')
      expect(service.list_images).to eq('list_of_images')
    end
  end

  describe '#list_images' do
    let(:connection) { double('connection') }
    let(:shapes)     { double('shapes') }
    it 'retrieves the shapes and returns them' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:shapes).and_return(shapes)

      expect(shapes).to receive(:all).and_return('list_of_shapes')
      expect(service.list_shapes).to eq('list_of_shapes')
    end
  end

  describe '#get_server' do
    let(:connection) { double('connection') }
    let(:instances)  { double('instances') }
    let(:server)     { double('server') }

    it 'fetches the server and returns it' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:instances).and_return(instances)

      expect(instances).to receive(:by_name).with('server1').and_return(server)
      expect(service.get_server('server1')).to eq(server)
    end
  end

  describe '#get_orchestration' do
    let(:connection)     { double('connection') }
    let(:orchestration)  { double('orchestration') }
    let(:orchestrations) { double('orchestrations') }

    it 'fetches the orchestration and returns it' do
      allow(service).to receive(:connection).and_return(connection)
      allow(connection).to receive(:orchestrations).and_return(orchestrations)

      expect(orchestrations).to receive(:by_name).with('orch1').and_return(orchestration)
      expect(service.get_orchestration('orch1')).to eq(orchestration)
    end
  end

  describe '#wait_for_status' do
    let(:item) { double('item') }

    before do
      allow(service).to receive(:wait_time).and_return(600)
      allow(service).to receive(:refresh_time).and_return(2)

      # muffle any stdout output from this method
      allow(service).to receive(:print)

      # don't actually sleep
      allow(service).to receive(:sleep)
    end

    context 'when the items completes normally, 3 loops' do
      it 'only refreshes the item 3 times' do
        allow(item).to receive(:status).exactly(3).times.and_return('working', 'working', 'complete')
        expect(item).to receive(:refresh).exactly(3).times

        service.wait_for_status(item, 'complete')
      end
    end

    context 'when the item is completed on the first loop' do
      it 'only refreshes the item 1 time' do
        allow(item).to receive(:status).once.and_return('complete')
        expect(item).to receive(:refresh).once

        service.wait_for_status(item, 'complete')
      end
    end

    context 'when the timeout is exceeded' do
      it 'prints a warning and exits' do
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        expect(service.ui).to receive(:msg).with('')
        expect(service.ui).to receive(:error)
          .with('Request did not complete in 600 seconds. Check the Oracle Cloud Web UI for more information.')
        expect { service.wait_for_status(item, 'complete') }.to raise_error(SystemExit)
      end
    end

    context 'when a non-timeout exception is raised' do
      it 'raises the original exception' do
        allow(item).to receive(:refresh).and_raise(RuntimeError)
        expect { service.wait_for_status(item, 'complete') }.to raise_error(RuntimeError)
      end
    end
  end
end
