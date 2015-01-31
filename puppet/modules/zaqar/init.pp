class zaqar {

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
