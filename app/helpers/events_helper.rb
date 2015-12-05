module EventsHelper
  def timeline(events, container_id, options)
    rows = events.map {|event| timeline_row(event) }.join(',')

    options = options.map {|k, v|
      '"%s":"%s"' % [j(k.to_s), j(v.to_s)]
    }.join(',')

    raw javascript_tag <<-EOS
      google.load("visualization", "1");

      // Set callback to run when API is loaded
      google.setOnLoadCallback(drawVisualization);

      // Called when the Visualization API is loaded.
      function drawVisualization() {
        // Create and populate a data table.
        var data = new google.visualization.DataTable();
        data.addColumn('datetime', 'start');
        data.addColumn('datetime', 'end');
        data.addColumn('string', 'content');

        data.addRows([#{rows}]);

        // specify options
        var options = {#{options}};

        // Instantiate our timeline object.
        var timeline = new links.Timeline(document.getElementById("#{j container_id.to_s}"), options);

        // Draw our timeline with the created data and options
        timeline.draw(data);
      }
    EOS
  end

  def timeline_row(event)
    str = event.hosts.join(',')
    str << ':' if str.present?
    str << event.message

    raw '[new Date(%d, %d, %d, %d, %d, %d), null, "%s"]' % [
      event.clock.year,
      event.clock.mon - 1,
      event.clock.day,
      event.clock.hour,
      event.clock.min,
      event.clock.sec,
      j(link_to str, event.url, target: '_blank'),
    ]
  end
end
