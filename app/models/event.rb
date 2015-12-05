class Event
  include ActiveModel::Model

  DEFAULT_OPTIONS = {
    filter: {object: 0, value: 1},
    sortfield: :clock,
    sortorder: :DESC,
    select_alerts: [:subject],
    limit: 3000
  }

  EVENT_URL_TEMPLATE = "#{Rails.application.config.zabbix.config[:url]}/tr_events.php?triggerid=%d&eventid=%d"

  attr_accessor :eventid
  attr_accessor :triggerid
  attr_accessor :clock
  attr_accessor :subject
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

        attrs[:subject] = event['alerts'].map {|i|
          i['subject']
        }.reject(&:empty?).first

        self.new(attrs)
      end
    end
  end # of class methods
end
