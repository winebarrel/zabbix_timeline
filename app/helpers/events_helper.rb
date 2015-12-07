module EventsHelper

  PRIORITY_COLORS = {
    0 => '#DBDBDB',
    1 => '#D6F6FF',
    2 => '#FFF6A5',
    3 => '#FFB689',
    4 => '#FF9999',
    5 => '#FF3838',
  }

  EVENT_HISTORY_URL_TEMPLATE = "#{Rails.application.config.zabbix.config[:url]}/events.php?triggerid=%d&stime=%d&period=%d"

  def timeline_row(event)
    link_str = ""

    if event.count
      link_str << '(%d) ' % event.count
    end

    if event.priority.present?
      link_str << colored_priority(event.priority)
    end

    hosts = event.hosts.join(',')

    if hosts.present?
      link_str << "#{hosts}:"
    end

    link_str << event.message

    raw '[%s, null, "%s"]' % [
      time_to_javascript_date(event.clock),
      j(link_to raw(link_str), event.url, target: '_blank'),
    ]
  end

  def time_to_javascript_date(time)
    "new Date(#{time.to_i * 1000})"
  end

  def colored_priority(priority)
    priority_label = Event::PRIORITIES.key(priority)
    priority_color = PRIORITY_COLORS[priority]
    raw %!<span style="color:#{priority_color};">[#{priority_label}]</span> !
  end
end
