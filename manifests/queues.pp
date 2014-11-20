# == Class zaqar::queues
#
# Configure Queues service in zaqar
#
# == Parameters
#
# [*keystone_password*]
#   (required) Password used to authentication.
#
# [*verbose*]
#   (optional) Rather to log the zaqar queues service at verbose level.
#   Default: false
#
# [*debug*]
#   (optional) Rather to log the zaqar queues service at debug level.
#   Default: false
#
# [*bind_host*]
#   (optional) The address of the host to bind to.
#   Default: 0.0.0.0
#
# [*bind_port*]
#   (optional) The port the server should bind to.
#   Default: 8888
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Default: /var/log/zaqar/queues.log
#
#  [*log_dir*]
#    (optional) directory to which zaqar logs are sent.
#    If set to boolean false, it will not log to any directory.
#    Defaults to '/var/log/zaqar'
#
# [*registry_port*]
#   (optional) The port of the Zaqar registry service.
#   Default: 9191
#
# [*auth_strategy*]
#   (optional) Type is authorization being used.
#   Defaults to 'keystone'
#
# [* auth_host*]
#   (optional) Host running auth service.
#   Defaults to '127.0.0.1'.
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to 'http://localhost:5000/v2.0'.
#
# [* auth_port*]
#   (optional) Port to use for auth service on auth_host.
#   Defaults to '35357'.
#
# [* auth_uri*]
#   (optional) Complete public Identity API endpoint.
#   Defaults to false.
#
# [*auth_admin_prefix*]
#   (optional) Path part of the auth url.
#   This allow admin auth URIs like http://auth_host:35357/keystone/admin.
#   (where '/keystone/admin' is auth_admin_prefix)
#   Defaults to false for empty. If defined, should be a string with a leading '/' and no trailing '/'.
#
# [* auth_protocol*]
#   (optional) Protocol to use for auth.
#   Defaults to 'http'.
#
# [*pipeline*]
#   (optional) Partial name of a pipeline in your paste configuration file with the
#   service name removed.
#   Defaults to 'keystone+cachemanagement'.
#
# [*keystone_tenant*]
#   (optional) Tenant to authenticate to.
#   Defaults to services.
#
# [*keystone_user*]
#   (optional) User to authenticate as with keystone.
#   Defaults to 'zaqar'.
#
# [*enabled*]
#   (optional) Whether to enable services.
#   Defaults to true.
#
# [*db_uri*]
#   (optional) Connection url to connect to nova database.
#   Defaults to 'sqlite:///var/lib/zaqar/zaqar.sqlite'
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Defaults to 3600
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to false.
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
class zaqar::queues(
  $keystone_password,
  $verbose                  = false,
  $debug                    = false,
  $transport_driver         = 'wsgi',
  $storage_driver           = 'sqlalchemy',
  $bind_host                = '0.0.0.0',
  $bind_port                = '8888',
  $log_file                 = '/var/log/zaqar/api.log',
  $log_dir                  = '/var/log/zaqar',
  $auth_strategy            = 'keystone',
  $auth_host                = '127.0.0.1',
  $auth_url                 = 'http://localhost:5000/v2.0',
  $auth_port                = '35357',
  $auth_uri                 = false,
  $auth_admin_prefix        = false,
  $auth_protocol            = 'http',
  $keystone_tenant          = 'services',
  $keystone_user            = 'zaqar',
  $enabled                  = true,
  $use_syslog               = false,
  $log_facility             = 'LOG_USER',
  $db_uri                   = 'sqlite:///var/lib/zaqar/zaqar.sqlite',
) inherits zaqar {

  Package[$zaqar::params::queues_package_name] -> File['/etc/zaqar/']
  Package[$zaqar::params::queues_package_name] -> Zaqar_queues_config<||>

  Zaqar_queues_config<||>   ~> Service['zaqar-queues']

  File {
    ensure  => present,
    owner   => 'zaqar',
    group   => 'zaqar',
    mode    => '0640',
    notify  => Service['zaqar-queues'],
    require => Class['zaqar']
  }

  if $storage_driver == 'sqlalchemy' {
    if($db_uri =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    } elsif($database_connection_real =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

    } elsif($database_connection_real =~ /sqlite:\/\//) {

    } else {
      fail("Invalid db connection ${database_connection_real}")
    }
    zaqar_queues_config {
      'drivers:storage:sqlalchemy/uri':   value => $db_uri, secret => true;
    }
  } elsif $storage_driver == 'mongodb' {
      zaqar_queues_config {
        'drivers:storage:mongodb/uri':   value => $db_uri, secret => true;
      }
  }

  # basic service config
  zaqar_queues_config {
    'DEFAULT/verbose':               value => $verbose;
    'DEFAULT/debug':                 value => $debug;
    'DEFAULT/auth_strategy'          value => $auth_strategy,
  }

  if $transport_driver == "wsgi" {
    'drivers:transport:wsgi/bind':             value => $bind_host;
    'drivers:transport:wsgi/port':             value => $bind_port;
  }

  # known_stores config
  if $known_stores {
    zaqar_queues_config {
      'DEFAULT/known_stores':  value => join($known_stores, ',');
    }
  } else {
    zaqar_queues_config {
      'DEFAULT/known_stores': ensure => absent;
    }
  }


  # configure api service to connect registry service
  zaqar_queues_config {
    'DEFAULT/registry_host':            value => $registry_host;
    'DEFAULT/registry_port':            value => $registry_port;
    'DEFAULT/registry_client_protocol': value => $registry_client_protocol;
  }


  if $auth_uri {
    zaqar_queues_config { 'keystone_authtoken/auth_uri': value => $auth_uri; }
  } else {
    zaqar_queues_config { 'keystone_authtoken/auth_uri': value => "${auth_protocol}://${auth_host}:5000/"; }
  }

  # auth config
  zaqar_queues_config {
    'keystone_authtoken/auth_host':     value => $auth_host;
    'keystone_authtoken/auth_port':     value => $auth_port;
    'keystone_authtoken/auth_protocol': value => $auth_protocol;
  }

  if $auth_admin_prefix {
    validate_re($auth_admin_prefix, '^(/.+[^/])?$')
    zaqar_queues_config {
      'keystone_authtoken/auth_admin_prefix': value => $auth_admin_prefix;
    }
  } else {
    zaqar_queues_config {
      'keystone_authtoken/auth_admin_prefix': ensure => absent;
    }
  }

  # keystone config
  if $auth_strategy == 'keystone' {
    require keystone::python
    zaqar_queues_config {
      'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
      'keystone_authtoken/admin_user'       : value => $keystone_user;
      'keystone_authtoken/admin_password'   : value => $keystone_password, secret => true;
    }
  }

  # Logging
  if $log_file {
    zaqar_queues_config {
      'DEFAULT/log_file': value  => $log_file;
    }
  } else {
    zaqar_queues_config {
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $log_dir {
    zaqar_queues_config {
      'DEFAULT/log_dir': value  => $log_dir;
    }
  } else {
    zaqar_queues_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # Syslog
  if $use_syslog {
    zaqar_queues_config {
      'DEFAULT/use_syslog'          : value => true;
      'DEFAULT/syslog_log_facility' : value => $log_facility;
    }
  } else {
    zaqar_queues_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  file { ['/etc/zaqar/zaqar-queues.conf']:
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'zaqar-queues':
    ensure     => $service_ensure,
    name       => $::zaqar::params::queues_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
  }
}
