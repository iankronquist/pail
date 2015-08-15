class pail::create_container {
  # FIXME: split into dependencies installation module
  package { "lxc":
    ensure => present
  }
  package { "lxc-templates":
    ensure => present
  }

  exec { "lxc-create -n $pail::name -t $pail::template":
    creates => "/var/lib/lxx/$pail::name/",
  }

  # Bootstrap node.
  exec { "lxc-start -n $pail::name":
    path => '/usr/bin',
    # only if the container is not already running
    onlyif => "/bin/machinectl status $pail::container_name; test $? -ne 0"
  }

  # Install Puppet
  exec { "lxc-execute -n $pail::name 'curl https://spencerkrum.com/install_puppet.sh | bash'":
    onlyif => "systemd-nspawn -M $pail::container_name 'dpkg -s puppet'"
  }

  # Copy over the specified puppet.conf, defaulting to the puppet.conf on the
  # master

  # Oh for mkdir -p
  # FIXME: install with puppet apply
  file { ["$pail::root_path/etc/",
          "$pail::root_path/etc/puppet/"]:
    ensure => directory,
  }

  # FIXME: install with puppet apply
  file { "$pail::root_path/etc/puppet/puppet.conf":
    ensure => file,
    content => template($pail::puppet_conf),
    # notify => container_puppet
  }

  # Start the Puppet service
  # FIXME: install with puppet apply
  # FIXME: fix only ifs
  exec { "lxc-execute -n $pail::name 'systemctl start puppet'":
    onlyif => "systemd-nspawn -M $pail::container_name 'systemctl status puppet'"
  }

  # Trigger the first Puppet run to generate certificates.
  # FIXME: fix only ifs
  exec { "lxc-execute -n $pail::name 'sudo puppet agent -t'":
    onlyif => "systemd-nspawn -M $pail::container_name 'systemctl status puppet'"
  }
}
