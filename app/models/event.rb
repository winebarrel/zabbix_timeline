class Event
  include ActiveModel::Model

  DEFAULT_OPTIONS = {
    filter: {object: 0, value: 1},
    sortfield: :clock,
    sortorder: :DESC,
    select_alerts: [:subject],
    limit: 3000
  }

 attr_accessor :eventid
 attr_accessor :triggerid
 attr_accessor :subject
 attr_accessor :url

  class << self
    def get(options = {})
      client = Rails.application.config.zabbix.client
      config = Rails.application.config.zabbix.config
      options = options.reverse_merge(DEFAULT_OPTIONS)

      events = client.event.get(options)

      events.map do |event|
        eventid = event['eventid'].to_i
        triggerid = event['objectid'].to_i

        subject = event['alerts'].map {|i|
          i['subject']
        }.reject(&:empty?).first

        url = "#{config[:url]}/tr_events.php?triggerid=#{triggerid}&eventid=#{eventid}"

        self.new(eventid: eventid, triggerid: triggerid, subject: subject, url: url)
      end
    end
  end # of class methods
end
