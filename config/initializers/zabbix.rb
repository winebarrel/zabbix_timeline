require 'zabbix/client'

Rails.application.config.zabbix = ActiveSupport::HashWithIndifferentAccess.new(
  YAML.load_file(Rails.root.join('config/zabbix.yml'))
)
