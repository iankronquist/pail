class pail::create_container {
  # Create container directory structure
  exec { "/usr/sbin/debootstrap $pail::suite $pail::container_name $pail::system":
    creates => $pail::container_name
  }
  file { "$pail::container_name/puppet.conf":
    path => '/usr/bin',
    ensure => file,
    content => template($pail::puppet_conf),
    # notify => container_puppet
  }
  # Bootstrap node
  exec { "systemd-nspawn -D $pail::container_name 'apt-get install puppet'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -D $pail::container_name 'dpkg -s puppet'"
  }
  exec { "systemd-nspawn -D $pail::container_name 'systemctl start puppet'":
    path => '/usr/bin',
    onlyif => "systemd-nspawn -D $pail::container_name 'systemctl status puppet'"
  }
}
