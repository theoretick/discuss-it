json.array!(@slashdot_postings) do |slashdot_posting|
  json.extract! slashdot_posting, :title, :permalink, :urls
  json.url slashdot_posting_url(slashdot_posting, format: :json)
end
