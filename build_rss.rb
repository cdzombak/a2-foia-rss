require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rss'

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

# options: atom, 2.0, 0.9
feed = RSS::Maker.make("2.0") do |maker|
    maker.channel.author = "City of Ann Arbor"
    maker.channel.language = "en"
    maker.channel.updated = Time.now.to_s
    maker.channel.link = "https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx"
    maker.channel.about = "https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx"
    maker.channel.title = "City of Ann Arbor FOIA Requests"
    maker.channel.description = "Unofficial feed of FOIA requests handled by the City of Ann Arbor. This feed does not include requests for police records."
    maker.image.url = "http://www.a2gov.org/publishingimages/color-logo.jpg"
    maker.image.title = "City of Ann Arbor FOIA Requests"

    for row in rows
        cells = row.css("td")
        req_id = cells[0].text.strip
        req_name = cells[1].text.strip
        req_text = cells[2].children.to_html.gsub("<br>", "<br />")
        req_date = Date.strptime(cells[3].text.strip, "%m/%d/%Y")
        due_date = Date.strptime(cells[4].text.strip, "%m/%d/%Y")
        req_status = cells[5].text.strip

        item_link = "https://www.a2gov.org/departments/city-clerk/Pages/FOIA-Requests.aspx\##{req_id}"
        item_title = "FOIA \##{req_id} by #{req_name}: #{req_status}"
        xhtml_content = "<b>FOIA \##{req_id}</b><br><b>Submitted by:</b> #{req_name}<br /><b>Received:</b> #{req_date.strftime("%B %-d, %Y")}<br /><b>Due:</b> #{due_date.strftime("%B %-d, %Y")}<br /><b>Status:</b> #{req_status}<br /><br />#{req_text}"

        maker.items.new_item do |item|
            item.id = req_id.to_s
            item.link = item_link
            item.title = item_title
            item.summary = xhtml_content
            item.content.type = "xhtml"
            item.content.xhtml = xhtml_content
            item.pubDate = req_date.to_s
            item.updated = req_date.to_s
        end
    end
end

puts feed
