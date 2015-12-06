module EventsHelper

  PRIORITY_COLORS = {
    0 => '#DBDBDB',
    1 => '#D6F6FF',
    2 => '#FFF6A5',
    3 => '#FFB689',
    4 => '#FF9999',
    5 => '#FF3838',
  }

  def timeline_row(event)
    link_str = ""

    if event.priority.present?
      priority = Event::PRIORITIES.key(event.priority)
      priority_color = PRIORITY_COLORS[event.priority]
      link_str << %!<span style="color:#{priority_color};">[#{priority}]</span> !
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
end
