class pail::create_container {
  # Create container directory structure with debootstrap.
  # This may take a while
  exec { "/usr/sbin/debootstrap $pail::suite $pail::root_path $pail::system":
    creates => $pail::root_path,
    timeout     => 1800,
  }
  # Copy over the specified puppet.conf, defaulting to the puppet.conf on the
  # master
  file { "$pail::root_path/etc/puppet/puppet.conf":
    ensure => file,
    content => template($pail::puppet_conf),
    # notify => container_puppet
  }
  # Bootstrap node.
  exec { "systemd-nspawn -M $pail::container_name -M $pail::root_path 'apt-get install puppet'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -M $pail::root_path 'dpkg -s puppet'"
  }
  # Install Puppet
  exec { "systemd-nspawn -M $pail::container_name 'apt-get install puppet'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -M $pail::container_name 'dpkg -s puppet'"
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
