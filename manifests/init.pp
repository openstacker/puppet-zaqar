#
# base zaqar config.
#
# == parameters
#   * package_ensure - ensure state for package.
#
class zaqar {

  file { '/etc/zaqar/':
    ensure  => directory,
    owner   => 'zaqar',
    group   => 'root',
    mode    => '0770',
  }
}
