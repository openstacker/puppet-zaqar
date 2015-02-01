class base {

  # Ensure the mongodb group exists
  group {'mongodb-group':
    name   => 'mongodb',
    ensure => 'present',
  }

  # Create the mongodb user
  user { 'mongodb-user':
    name   => 'mongodb',
    groups => 'mongodb',
  }
}
