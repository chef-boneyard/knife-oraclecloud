# knife-oraclecloud

This is a Knife plugin that will allow you to interact with
Oracle Cloud.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'knife-oraclecloud'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install knife-oraclecloud

... or, even better, from within ChefDK:

    $ chef gem install knife-oraclecloud

## Configuration

In order to communicate with Oracle Cloud, you must specify your user credentials. You can specify them in your knife.rb:

```ruby
knife[:oraclecloud_username] = 'myuser'
knife[:oraclecloud_password] = 'mypassword'
knife[:oraclecloud_api_url]  = 'https://cloud.oracle.com'
knife[:oraclecloud_domain]   = 'my_identity_domain'
```

... or you can supply them on the command-line:

```
knife oraclecloud command --oraclecloud-username myuser ...
```

## Usage

### knife oraclecloud server create (options)

Creates a server (a.k.a. an "instance") on Oracle Cloud and bootstraps it with Chef.

Common parameters to specify are:

 * `--shape`: Shape of the instance you'd like to create - use `knife oraclecloud shape list` to list available shapes
 * `--image`: Name of the image to use for your new instance - use `knife oraclecloud image list` to list available images
 * `--sshkeys`: comma-separated list of Oracle Cloud SSH keys to attach to the instance for login, in the format of "username@domain.io/keyname"
 * `--hostname`: hostname to use when creating the instance
 * `--public-ip`: optional; whether to configure a public IP for your instance. Valid options are "pool" to use the default pool, or the name of an already-configured IP reservation
 * `--label`: optional; text label to attach to your instance

While not required when using the Oracle Cloud UI, the API requires any instances that are created to be created via an "orchestration" which allows you to create a preconfigured set of machines and resources and start/stop them together.  `knife oraclecloud server create` will create a single-instance orchestration in order to complete your request.

```
$ knife oraclecloud server create --image /oracle/public/oel_6.6_20GB_x11_RD --shape oc3 --hostname test123 --public-ip pool --ssh-user opc --sshkeys user@domain.io/mysshkey --identity-file /Users/user/.ssh/id_rsa
Orchestration user@domain.io/test123 started - waiting for it to complete...

Current status: starting.............................................................................................
Orchestration started successfully.
Orchestration ID: user@domain.io/test123
Description: test123 by user@domain.io via Knife
Status: ready
Instance Count: 1

Server Label: test123
Status: running
Hostname: dad634.compute-usoracle12345.oraclecloud.internal.
IP Address: 10.106.13.22
Public IP Addresses: 1.2.3.4
Image: /oracle/public/oel_6.6_20GB_x11_RD
Shape: oc3
Orchestration: user@domain.io/test123
Bootstrapping the server by using bootstrap_protocol: ssh and image_os_type: linux

Waiting for sshd to host (1.2.3.4)...
...
```

### knife oraclecloud server list

Lists all the servers currently configured in Oracle Cloud.

```
$ knife oraclecloud server list
Hostname                                            Status        Shape  Image                               Instance ID                                                  Orchestration ID
aef06f.compute-usoracle12345.oraclecloud.internal.  initializing  oc3    /oracle/public/oel_6.4_5GB_RD       user@domain.io/ui1/0db7f5f2-7bdf-41a1-ba93-5710592c5bcf      none
dad634.compute-usoracle12345.oraclecloud.internal.  running       oc3    /oracle/public/oel_6.6_20GB_x11_RD  user@domain.io/test123/fd3af3da-d0be-4a06-a1f4-e452ab2fe7b4  user@domain.io/test123
```

### knife oraclecloud server show INSTANCE_ID

Displays additional information about an individual server, such as its IP addresses.

```
$ knife oraclecloud server show user@domain.io/test123/fd3af3da-d0be-4a06-a1f4-e452ab2fe7b4
Server Label: test123
Status: running
Hostname: dad634.compute-usoracle12345.oraclecloud.internal.
IP Address: 10.106.13.22
Public IP Addresses: 1.2.3.4
Image: /oracle/public/oel_6.6_20GB_x11_RD
Shape: oc3
Orchestration: user@domain.io/test123
```

### knife oraclecloud server delete INSTANCE_ID

Deletes a server/instance from Oracle Cloud. With this command, you can only delete instances that were *not* created by an orchestration.  If you need to delete an instance created by an orchestration (such as one created via `knife oraclecloud server create`), use `knife oraclecloud orchestration delete` instead.

If you supply `--purge`, the server will also be removed from the Chef Server.

```
$ knife oraclecloud server delete user@domain.io/ui1/0db7f5f2-7bdf-41a1-ba93-5710592c5bcf
Server Label: ui1
Status: running
Hostname: aef06f.compute-usoracle12345.oraclecloud.internal.
IP Address: 10.106.13.46
Public IP Addresses: 1.2.3.4
Image: /oracle/public/oel_6.4_5GB_RD
Shape: oc3
Orchestration: none

Do you really want to delete this server? (Y/N) Y
Deleting the instance...
Delete request complete.
```

### knife oraclecloud orchestration list

Lists the currently-configured orchestrations.

```
$ knife oraclecloud orchestration list
Orchestration ID        Description                          Status  Instance Count
user@domain.io/test123  test123 by user@domain.io via Knife  ready   1
```

### knife oraclecloud orchestration show

Shows details about the specified orchestration, as well as any instances created by that orchestration.

```
$ knife oraclecloud orchestration show user@domain.io/test123
Orchestration Summary
Orchestration ID: user@domain.io/test123
Description: test123 by user@domain.io via Knife
Status: ready
Instance Count: 1

Instance user@domain.io/test123/fd3af3da-d0be-4a06-a1f4-e452ab2fe7b4
Server Label: test123
Status: running
Hostname: dad634.compute-usoracle12345.oraclecloud.internal.
IP Address: 10.106.13.22
Public IP Addresses: 1.2.3.4
Image: /oracle/public/oel_6.6_20GB_x11_RD
Shape: oc3
Orchestration: user@domain.io/test123
```

### knife oraclecloud orchestration delete

Stops and deletes the specified orchestration and any instances created by that orchestration.

```
$ knife oraclecloud orchestration delete user@domain.io/test123
Orchestration ID: user@domain.io/test123
Description: test123 by user@domain.io via Knife
Status: ready
Instance Count: 1

Do you really want to delete this orchestration? (Y/N) Y
Stopping the orchestration and any instances...

Current status: ready.
Current status: stopping.......................
Deleting the orchestration and any instances...
Delete request complete.
```

### knife oraclecloud image list

Lists all the images available in the public catalog.

```
$ knife oraclecloud image list
Image Name                          Description
/oracle/public/oel_6.4_20GB_x11_RD  OEL 6.4 20 GB image
/oracle/public/oel_6.4_5GB_RD       OEL 6.4 5 GB image
/oracle/public/oel_6.6_20GB_x11_RD  OEL 6.6 20 GB image
```

### knife oraclecloud shape list

Lists all the shapes (i.e. flavors, sizes) of instances available to you.

```
$ knife oraclecloud shape list
Shape Name  CPUs  RAM     I/O
oc1m        2.0   15360   200
oc2m        4.0   30720   400
oc3         2.0   7680    200
oc3m        8.0   61440   600
oc4         4.0   15360   400
oc4m        16.0  122880  800
oc5         8.0   30720   600
oc5m        32.0  245760  1000
oc6         16.0  61440   800
oc7         32.0  122880  1000
```

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)

Copyright:: Copyright (c) 2015 Chef Software, Inc.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the specific language governing permissions
and limitations under the License.

## Contributing

We'd love to hear from you if you find this isn't working for you. Please submit a GitHub issue with any problems you encounter.

Additionally, contributions are welcome!  If you'd like to send up any fixes or changes:

1. Fork it ( https://github.com/chef-partners/knife-oraclecloud/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
