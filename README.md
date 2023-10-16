# Ann Arbor FOIA RSS/JSON Feed

Generates an RSS feed and a [JSON feed](https://jsonfeed.org) from Ann Arbor's public [FOIA request database](https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx).

## Subscribing to the feed

Add [`https://www.dzombak.com/local/feed/a2-foia.rss`](https://www.dzombak.com/local/feed/a2-foia.rss) to your feed reader of choice.

(Or use [`https://www.dzombak.com/local/feed/a2-foia.json`](https://www.dzombak.com/local/feed/a2-foia.json) if you prefer a [JSON Feed](https://jsonfeed.org).)

## Deployment (Docker)

Pre-built Docker images are available for amd64, 386, and arm64; see Docker Hub or GHCR for details (links TK). This is the preferred deployment method, as it avoids the need to deal with Ruby versions or building Nokogiri.

Run the image like the following:

```shell
docker run --rm \
    -v /srv/a2-foia-public:/app/public \
    --user=www-data:www-data \
    cdzombak/a2-foia-rss:1
```

Schedule it periodically with a crontab entry like:

```text
*/30  *  *  *  *  docker run --rm -v /srv/a2-foia-public:/app/public --user=www-data:www-data cdzombak/a2-foia-rss:main
```

Or, using [runner](https://github.com/cdzombak/runner) to retry in case of errors and suppress output on successful runs:

```text
*/30  *  *  *  *  runner -retries 2 -job-name "A2 FOIA RSS Feed" -- docker run --rm -v /srv/a2-foia-public:/app/public --user=www-data:www-data cdzombak/a2-foia-rss:main
```

## Deployment (local Ruby)

1. Clone the repo and change to the `a2-foia-rss` directory
1. `bundle install --path Vendor/bundle`
1. Refer to [the Nokogiri docs](http://www.nokogiri.org/tutorials/installing_nokogiri.html) to troubleshoot installation.
1. Schedule periodically via cron, with something like:

```text
0  *  *  *  *  cd /home/cdzombak/scripts/a2-foia-rss && /usr/local/bin/bundle exec /usr/bin/ruby build_rss.rb`
```

## Author & Contributors

Author: [Chris Dzombak](https://www.dzombak.com) ([GitHub @cdzombak](https://www.github.com/cdzombak))

Thank you to the contributors who have helped keep this running reliably:

- [Andy Blyler](https://github.com/ablyler)

## License

MIT; see `LICENSE` in this repository.
