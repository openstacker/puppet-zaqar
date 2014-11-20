#
# Installs the zaqar python library.
#
# == parameters
#  * ensure - ensure state for pachage.
#
class zaqar::client (
  $ensure = 'present'
) {

  include zaqar::params

  package { 'python-zaqarclient':
    ensure => $ensure,
    name   => $::zaqar::params::client_package_name,
  }

}
