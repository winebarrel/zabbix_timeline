class Event
  include ActiveModel::Model

  DEFAULT_OPTIONS = {
    filter: {object: 0, value: 1},
    sortfield: :clock,
    sortorder: :DESC,
    selectHosts: [:host],
    select_alerts: [:subject],
    selectRelatedObject: [:description],
    limit: 10000
  }

  EVENT_URL_TEMPLATE = "#{Rails.application.config.zabbix.config[:url]}/tr_events.php?triggerid=%d&eventid=%d"
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

      events.map do |event|
        attrs = {}

        attrs[:eventid] = event['eventid'].to_i
        attrs[:triggerid] = event['objectid'].to_i
        attrs[:clock] = Time.at(event['clock'].to_i)
        attrs[:url] = EVENT_URL_TEMPLATE % [attrs[:triggerid], attrs[:eventid]]

        attrs[:hosts] = event['hosts'].map {|i|
          i['host']
        }.reject(&:empty?)

        subject = event['alerts'].map {|i|
          i['subject']
        }.reject(&:empty?).first

        related_object = event['relatedObject']
        description = related_object.is_a?(Hash) ? related_object['description'] : nil

        attrs[:message] = description || subject || DEFAULT_MESSAGE

        self.new(attrs)
      end
    end
  end # of class methods
end
