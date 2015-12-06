module EventsHelper
  def timeline(events, container_id, options)
    rows = events.map {|event| timeline_row(event) }.join(',')

    options = options.map {|k, v|
      if v.is_a?(Time)
        v = time_to_javascript_date(v)
      else
        v = '"' + j(v.to_s) + '"'
      end

      '"%s":%s' % [j(k.to_s), v]
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

    raw '[%s, null, "%s"]' % [
      time_to_javascript_date(event.clock),
      j(link_to str, event.url, target: '_blank'),
    ]
  end

  def time_to_javascript_date(time)
    "new Date(#{time.to_i * 1000})"
  end
end
