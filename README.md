# Pail - Manage containers like nodes

Pail uses `lxc` to create and manage containers as puppet nodes.


Pail creates a base system using `lxc-create` and
then starts the container and installs Puppet on the system. It enables the
systemd Puppet unit and installs the specified `puppet.conf`. It then sends a
certificate signing request to the master. The resulting container will appear
to the master like any other Puppet node.


### What pail affects

* Pail installs `lxc` and `lxc-templates`.
* Pail spins up and bootstraps a container.

### Beginning with pail

Here's an example to place in `site.pp`
```puppet
node 'node.vm' {
        class { 'pail':
                container_name='test', # The machine name of the container
                root_path='/test', # The fully qualified path to where the
                # filesystem will be unpacked. This will be created with
                # debootstrap if it doesn't exist
                puppet_conf='/etc/puppet/puppet.conf', # A template for the
                # puppet.conf file
                suite='squeeze', # The debian version to include, like sid or
                # unstable
                system='http://http.debian.net/debian/', # Where to download
                # the packages from
) {
        }
}
```
