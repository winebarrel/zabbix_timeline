ActiveSupport::HashWithIndifferentAccess.new(
  YAML.load_file(Rails.root.join('config/zabbix.yml'))
).tap do |config|
  zabbix_options = ActiveSupport::OrderedOptions.new
  Rails.application.config.zabbix = zabbix_options

  zabbix_options.config = config

  client = Zabbix::Client.new(config[:endpoint], config)
  zabbix_options.client = client

  client.user.login(user: config[:user], password: config[:password])
end
