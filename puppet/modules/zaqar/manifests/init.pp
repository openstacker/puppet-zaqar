#
# base zaqar config.
#
# == parameters
#   * package_ensure - ensure state for package.
#
class zaqar {

  include zaqar::repo
  include mongodb::server

  Class['zaqar::repo'] -> Class['mongodb::server']

  user { 'zaqar-user':
    name   => 'zaqar',
    groups => 'root',
    before => File['/etc/zaqar'],
  }

  file { '/etc/zaqar/':
    ensure => directory,
    owner  => 'zaqar',
    group => 'root',
    mode   => '0770',
  }
}
