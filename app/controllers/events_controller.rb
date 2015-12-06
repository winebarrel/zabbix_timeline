class EventsController < ApplicationController
  EVENT_CHUNK_LENGTH = Rails.application.config.zabbix.config[:event_chunk_length] || 300

  def index
    config = Rails.application.config.zabbix.config
    now = Time.now
    @host_filter = params[:host_filter] || config[:host_filter]
    @exclude_host_filter = params[:exclude_host_filter] || config[:exclude_host_filter]
    @priority = params[:priority]
    @from = parse_time(params[:from], (now - 1.day).beginning_of_day)
    @till = parse_time(params[:till], (now + 1.day).end_of_day)

    @events = Event.get(
      host: @host_filter,
      exclude_host: @exclude_host_filter,
      priority: @priority,
      time_from: @from.to_i,
      time_till: @till.to_i
    ).chunk {|event|
      event.clock.to_i - event.clock.to_i % EVENT_CHUNK_LENGTH
    }.flat_map {|_, chunk_by_time|
      chunk_by_time.chunk {|event|
        event.triggerid
      }.flat_map {|_, chunk_by_trigger|
        event = chunk_by_trigger.first

        if chunk_by_trigger.count > 1
          event.message = '(%d) %s' % [chunk_by_trigger.count, event.message]
        end

        event
      }
    }
  end

  private

  def parse_time(time, defval)
    if time.present?
      if time =~ /\A\d+\z/
        Time.at(time.to_i)
      else
        Time.parse(time)
      end
    else
      defval
    end
  end
end
