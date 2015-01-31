# == Class: zaqar::config
#
# This class is used to manage arbitrary zaqar configurations.
#
# === Parameters
#
# [*xxx_config*]
#   (optional) Allow configuration of arbitrary zaqar configurations.
#   The value is an hash of queues_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   queues_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# [**queues_config**]
#   (optional) Allow configuration of zaqar.conf configurations.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class zaqar::config (
  $queues_config                 = {},
) {
  validate_hash($queues_config)

  create_resources('zaqar_queues_config', $queues_config)
}
