module EventsHelper
  def timeline_row(event)
    str = event.hosts.join(',')
    str << ':' if str.present?
    str << event.message

    raw '[%s, null, "%s"]' % [
      time_to_javascript_date(event.clock),
      j(link_to str, event.url, target: '_blank'),
    ]
  end

  def time_to_javascript_date(time)
    "new Date(#{time.to_i * 1000})"
  end
end
