# Site Globals
class { '::mongodb::globals':
  server_package_name => 'mongodb-org-server',
  user                => 'mongodb',
  group               => 'mongodb',
}

# Node Manifest Definitions
node 'zaqar-test.example.com' {
  include base
  include zaqar
}
