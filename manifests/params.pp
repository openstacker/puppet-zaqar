# these parameters need to be accessed from several locations and
# should be considered to be constant
class zaqar::params {

  $client_package_name = 'python-zaqarclient'

  case $::osfamily {
    'RedHat': {
      $queues_package_name      = 'openstack-zaqar'
      $queues_service_name      = 'openstack-zaqar-queues'
    }
    'Debian': {
      $queues_package_name      = 'zaqar-queues'
      $queues_service_name      = 'zaqar-queues'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }

}
