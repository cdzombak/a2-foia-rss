# Ann Arbor FOIA RSS Feed

## Setup

1. `bundle install --path Vendor/bundle`
2. Refer to [the Nokogiri docs](http://www.nokogiri.org/tutorials/installing_nokogiri.html) to troubleshoot installation.
3. Schedule hourly via cron with something like `cd /home/cdzombak/scripts/a2-foia-rss && /usr/local/bin/bundle exec /usr/bin/ruby build_rss.rb > /home/cdzombak/scripts/a2-foia-rss/public/a2-foia.rss`
