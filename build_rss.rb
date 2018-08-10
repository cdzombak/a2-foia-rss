require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rss'
require 'json'

page = Nokogiri::HTML(open("https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx"))   
rows = page.css("article table")[0].css("tr")

headers = rows[0].css("th").map{ |th| th.text.strip }
rows = rows.drop(1)

# sanity check table header; abort if things seem wrong
if headers.length != 6
    $stderr.puts("Expected 6 headers in table; got #{headers.length}")
    exit(2)
end
expected_headers = ["ID", "Name", "Request", "Received", "Due Date", "Status"]
headers.zip(expected_headers) do |actual, expected|
    if actual != expected
        $stderr.puts("Expected table header #{expected}; got #{actual}")
        exit(2)
    end
end

items = rows[0...50].map { |row| 
    cells = row.css("td")
    id = cells[0].text.strip
    req_name = cells[1].text.strip
    html = cells[2].children.to_html.gsub("<br>", "<br />")
    req_date = Date.strptime(cells[3].text.strip, "%m/%d/%Y")
    due_date = Date.strptime(cells[4].text.strip, "%m/%d/%Y")
    status = cells[5].text.strip

    {
        :id => id,
        :req_date => req_date,
        :req_name => req_name,
        :status => status,
        :title => "FOIA \##{id} by #{req_name}: #{status}",
        :link => "https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx\##{id}",
        :html_content => "<b>FOIA \##{id}</b><br /><b>Submitted by:</b> #{req_name}<br /><b>Received:</b> #{req_date.strftime("%B %-d, %Y")}<br /><b>Due:</b> #{due_date.strftime("%B %-d, %Y")}<br /><b>Status:</b> #{status}<br /><br />#{html}"
    }
}

feed_title = "City of Ann Arbor FOIA Requests"
feed_author = "City of Ann Arbor"
feed_webpage = "https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx"
feed_desc = "Unofficial feed of FOIA requests handled by the City of Ann Arbor. This feed does not include requests for police records."
feed_img = "http://www.a2gov.org/publishingimages/color-logo.jpg"

# options: atom, 2.0, 0.9
rss_feed = RSS::Maker.make("2.0") do |maker|
    maker.channel.author = feed_author
    maker.channel.language = "en"
    maker.channel.updated = Time.now.to_s
    maker.channel.link = feed_webpage
    maker.channel.about = feed_webpage
    maker.channel.title = feed_title
    maker.channel.description = feed_desc
    maker.image.url = feed_img
    maker.image.title = feed_title

    for i in items
        maker.items.new_item do |item|
            item.id = i[:id]
            item.link = i[:link]
            item.title = i[:title]
            item.summary = i[:html_content]
            item.content.type = "xhtml"
            item.content.xhtml = i[:html_content]
            item.pubDate = i[:req_date].to_s
            item.updated = i[:req_date].to_s
            item.author = i[:req_name]
        end
    end
end

File.write('public/a2-foia.rss', rss_feed.to_s)

json_feed = {
    "version" => "https://jsonfeed.org/version/1",
    "title" => feed_title,
    "home_page_url": feed_webpage,
    "feed_url" => "https://www.dzombak.com/local/feed/a2-foia.json",
    "description" => feed_desc,
    "icon" => feed_img,
    "author" => {
        "name" => feed_author,
        "url" => "https://www.a2gov.org",
        "avatar" => feed_img
    },
    "items" => items.map { |i| 
        {
            "id" => i[:id],
            "content_html" => i[:html_content],
            "url" => i[:link],
            "title" => i[:title],
            "date_published" => i[:req_date].to_time.to_datetime.rfc3339,
            "author" => i[:req_name],
            "tags" => [i[:status]]
        }
    }
}

File.write('public/a2-foia.json', JSON.pretty_generate(json_feed))
