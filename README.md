# Zabbix Timeline

Zabbix Event Timeline Viewer.

This application uses [Timeline.js](http://almende.github.io/chap-links-library/timeline.html).

## Installation

```sh
bundle install
cp config/zabbix.yml.sample config/zabbix.yml
vi config/zabbix.yml
bundle exec rails s
```

Then go to `http://localhost:3000`.

## Demo

![](https://raw.githubusercontent.com/winebarrel/zabbix_timeline/master/etc/zabbix_timeline-demo.gif)
