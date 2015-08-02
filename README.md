# Pail - Manage containers like nodes

Pail uses `debootstrap` and `systemd` to create and manage containers as puppet
nodes on Debian 8 systems.


Pail creates a base system using `debootstrap` and
then starts the container and installs Puppet on the system. It enables the
systemd Puppet unit and installs the specified `puppet.conf`. It then sends a
certificate signing request to the master. The resulting container will appear
to the master like any other Puppet node.

Please note that containers brought up with `systemd-nspawn` may not be
suitable for fully secure container setups. This is a proof of concept.


### What pail affects

* Pail installs `debootstrap`.
* Pail creates a directory tree at the specified location.
* Pail spins up and bootstraps a container.

### Beginning with pail

Here's an example to place in `site.pp`
```puppet
node 'node.vm' {
        class { 'pail':
                container_name => '/foo',
                puppet_conf => 'puppet.conf.erb',
                suite => 'squeeze', # The debian flavor to create, like sid
                system => 'http://http.debian.net/debian/'
        }
}
```
