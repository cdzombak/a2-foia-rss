require 'rubygems'
require 'nokogiri'
require 'open-uri'

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

for row in rows
	cells = row.css("td").map{ |td| td.text.strip }
	req_id = cells[0]
	req_name = cells[1]
	req_text = cells[2]
	req_date = cells[3]
	req_status = cells[5]

	puts("FOIA #{req_id} from #{req_name} on #{req_date}: #{req_status}")
	puts(req_text)
	puts("")
end
