# Ann Arbor FOIA RSS Feed

Generates an RSS feed from Ann Arbor's public [FOIA request database](https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx).

## Using the feed

If you're just interested in reading the feed, add [`https://www.dzombak.com/local/feed/a2-foia.rss`](https://www.dzombak.com/local/feed/a2-foia.rss) to your feed reader of choice.

## Deployment

1. `bundle install --path Vendor/bundle`
2. Refer to [the Nokogiri docs](http://www.nokogiri.org/tutorials/installing_nokogiri.html) to troubleshoot installation.
3. Schedule hourly via cron with something like `cd /home/cdzombak/scripts/a2-foia-rss && /usr/local/bin/bundle exec /usr/bin/ruby build_rss.rb > /home/cdzombak/scripts/a2-foia-rss/public/a2-foia.rss`
