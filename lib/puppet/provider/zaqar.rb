require 'json'
require 'puppet/util/inifile'

class Puppet::Provider::Zaqar < Puppet::Provider

  def self.conf_filename
    '/etc/zaqar/zaqar.conf'
  end

  def self.withenv(hash, &block)
    saved = ENV.to_hash
    hash.each do |name, val|
      ENV[name.to_s] = val
    end

    yield
  ensure
    ENV.clear
    saved.each do |name, val|
      ENV[name] = val
    end
  end

  def self.zaqar_credentials
    @zaqar_credentials ||= get_zaqar_credentials
  end

  def self.get_zaqar_credentials
    auth_keys = ['auth_host', 'auth_port', 'auth_protocol',
                 'admin_tenant_name', 'admin_user', 'admin_password']
    conf = zaqar_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      return Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Zaqar types will not work if zaqar is not \
correctly configured.")
    end
  end

  def zaqar_credentials
    self.class.zaqar_credentials
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.get_auth_endpoint
    q = zaqar_credentials
    "#{q['auth_protocol']}://#{q['auth_host']}:#{q['auth_port']}/v2.0/"
  end

  def self.zaqar_conf
    return @zaqar_conf if @zaqar_conf
    @zaqar_conf = Puppet::Util::IniConfig::File.new
    @zaqar_conf.read(conf_filename)
    @zaqar_conf
  end

  def self.auth_zaqar(*args)
    q = zaqar_credentials
    authenv = {
      :OS_AUTH_URL    => self.auth_endpoint,
      :OS_USERNAME    => q['admin_user'],
      :OS_TENANT_NAME => q['admin_tenant_name'],
      :OS_PASSWORD    => q['admin_password']
    }
    begin
      withenv authenv do
        zaqar(args)
      end
    rescue Exception => e
      if (e.message =~ /\[Errno 111\] Connection refused/) or
          (e.message =~ /\(HTTP 400\)/)
        sleep 10
        withenv authenv do
          zaqar(args)
        end
      else
       raise(e)
      end
    end
  end

  def auth_zaqar(*args)
    self.class.auth_zaqar(args)
  end

  def zaqar_manage(*args)
    cmd = args.join(" ")
    output = `#{cmd}`
    $?.exitstatus
  end

  def self.reset
    @zaqar_conf        = nil
    @zaqar_credentials = nil
  end

  def self.list_zaqar_resources(type, *args)
    json = auth_zaqar("--json", "#{type}-list", *args)
    return JSON.parse(json)
  end

  def self.get_zaqar_resource_attrs(type, id)
    json = auth_zaqar("--json", "#{type}-show", id)
    return JSON.parse(json)
  end

end
