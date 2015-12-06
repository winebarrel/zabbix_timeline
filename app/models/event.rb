class Event
  include ActiveModel::Model

  DEFAULT_OPTIONS = {
    filter: {object: 0, value: 1},
    sortfield: :clock,
    sortorder: :DESC,
    selectHosts: [:host],
    select_alerts: [:subject],
    selectRelatedObject: [:priority, :description],
    limit: 10000
  }

  EVENT_URL_TEMPLATE = "#{Rails.application.config.zabbix.config[:url]}/tr_events.php?triggerid=%d&eventid=%d"
  DEFAULT_PRIORITY = 3
  DEFAULT_MESSAGE = '🔥'

  attr_accessor :eventid
  attr_accessor :triggerid
  attr_accessor :clock
  attr_accessor :hosts
  attr_accessor :message
  attr_accessor :url

  class << self
    def get(options = {})
      options = options.reverse_merge(DEFAULT_OPTIONS)

      client = Rails.application.config.zabbix.client
      events = client.event.get(options)

      host = options.delete(:host)
      host = Regexp.new(host) if host
      priority = options.delete(:priority) || Rails.application.config.zabbix.config[:priority] || DEFAULT_PRIORITY

      events = events.select do |event|
        related_object = event['relatedObject']
        related_object.is_a?(Hash) and related_object['priority'].to_i >= priority
      end

      objs = []

      events.each do |event|
        attrs = {}

        attrs[:eventid] = event['eventid'].to_i
        attrs[:triggerid] = event['objectid'].to_i
        attrs[:clock] = Time.at(event['clock'].to_i)
        attrs[:url] = EVENT_URL_TEMPLATE % [attrs[:triggerid], attrs[:eventid]]

        hosts = event['hosts'].map {|i|
          i['host']
        }.reject(&:empty?)

        if host and not hosts.any? {|i| i =~ host }
          next
        end

        attrs[:hosts] = hosts

        subject = event['alerts'].map {|i|
          i['subject']
        }.reject(&:empty?).first

        related_object = event['relatedObject']
        description = related_object.is_a?(Hash) ? related_object['description'] : nil

        attrs[:message] = description || subject || DEFAULT_MESSAGE

        objs << self.new(attrs)
      end

      objs
    end
  end # of class methods
end
