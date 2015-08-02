class pail::create_container {
  # Create container directory structure with debootstrap.
  # This may take a while
  exec { "/usr/sbin/debootstrap $pail::suite $pail::root_path $pail::system":
    creates => $pail::root_path,
    timeout     => 1800,
  }

  # Touch the os-release file so a container can be brought up.
  file { "$pail::root_path/etc/os-release":
    ensure => 'present',
  }

  # Bootstrap node.
  exec { "systemd-nspawn -M $pail::container_name -D $pail::root_path":
    path => '/usr/bin',
    # only if the container is not already running
    onlyif => "/bin/machinectl status $pail::container_name; test $? -ne 0"
  }

  # Install Puppet
  exec { "systemd-nspawn -M $pail::container_name 'apt-get install puppet'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -M $pail::container_name 'dpkg -s puppet'"
  }

  # Copy over the specified puppet.conf, defaulting to the puppet.conf on the
  # master

  # Oh for mkdir -p
  file { ["$pail::root_path/etc/",
          "$pail::root_path/etc/puppet/"]:
    ensure => directory,
  }

  file { "$pail::root_path/etc/puppet/puppet.conf":
    ensure => file,
    content => template($pail::puppet_conf),
    # notify => container_puppet
  }

  # Start the Puppet service
  exec { "systemd-nspawn -M $pail::container_name 'systemctl start puppet'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -M $pail::container_name 'systemctl status puppet'"
  }

  # Trigger the first Puppet run to generate certificates.
  exec { "systemd-nspawn -M $pail::container_name 'sudo puppet agent -t'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -M $pail::container_name 'systemctl status puppet'"
  }
}
