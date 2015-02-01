#
# base zaqar config.
#
# == parameters
#   * package_ensure - ensure state for package.
#
class zaqar {

  # OpenStack Zaqar Requirement Includes
  include zaqar::repo
  include mongodb::server

  # Add the appropriate repo before installing mongodb
  Class['zaqar::repo'] -> Class['mongodb::server']

  # Create the openstack-zaqar user
  user { 'zaqar-user':
    name   => 'zaqar',
    groups => 'root',
    before => File['/etc/zaqar'],
  }

  # Create the openstack-zaqar directory
  file { '/etc/zaqar/':
    ensure => directory,
    owner  => 'zaqar',
    group => 'root',
    mode   => '0770',
  }
}
