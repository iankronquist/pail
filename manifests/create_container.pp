class pail::create_container {
  # Create container directory structure
  exec { '/usr/sbin/debootstrap':
    creates => $pail::container_name
  }
  # Bootstrap node
  exec { "systemd-nspawn -D $pail::container_name 'apt-get install puppet'":
  }
  exec { "systemd-nspawn -D $pail::container_name 'service puppet start'":
  }
}
